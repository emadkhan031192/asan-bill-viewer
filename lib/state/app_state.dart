import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/l10n/strings.dart';
import '../models/saved_bill.dart';
import '../models/vault_file.dart';

/// Overridden in main() with the real instance before runApp.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override sharedPreferencesProvider in main()'),
);

// ------------------------------------------------------------------
// Settings (language + theme), persisted in SharedPreferences.
// ------------------------------------------------------------------
class AppSettings {
  const AppSettings({this.lang = 'en', this.themeMode = 'auto'});

  /// 'en' or 'ur'.
  final String lang;

  /// 'auto', 'light' or 'dark'.
  final String themeMode;

  ThemeMode get theme => switch (themeMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  AppSettings copyWith({String? lang, String? themeMode}) => AppSettings(
        lang: lang ?? this.lang,
        themeMode: themeMode ?? this.themeMode,
      );

  Map<String, dynamic> toJson() => {'lang': lang, 'themeMode': themeMode};

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        lang: json['lang'] as String? ?? 'en',
        themeMode: json['themeMode'] as String? ?? 'auto',
      );
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static AppSettings _load(SharedPreferences prefs) {
    final raw = prefs.getString('settings');
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(
          (jsonDecode(raw) as Map).cast<String, dynamic>());
    } catch (_) {
      return const AppSettings();
    }
  }

  void _persist() =>
      _prefs.setString('settings', jsonEncode(state.toJson()));

  /// Instant language switch — the whole UI rebuilds on the next frame.
  void setLang(String lang) {
    if (lang == state.lang) return;
    state = state.copyWith(lang: lang);
    _persist();
  }

  void setThemeMode(String mode) {
    if (mode == state.themeMode) return;
    state = state.copyWith(themeMode: mode);
    _persist();
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.watch(sharedPreferencesProvider));
});

/// Typed strings for the current language. Rebuilds instantly on switch.
final stringsProvider = Provider<Strings>(
  (ref) => Strings(ref.watch(settingsProvider).lang),
);

// ------------------------------------------------------------------
// Saved bills, persisted in SharedPreferences as JSON.
// ------------------------------------------------------------------
class SavedBillsNotifier extends StateNotifier<List<SavedBill>> {
  SavedBillsNotifier(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static List<SavedBill> _load(SharedPreferences prefs) {
    final raw = prefs.getString('saved_bills');
    if (raw == null) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      final bills = list.map(SavedBill.fromJson).toList()
        ..sort(SavedBill.sortByDueDate);
      return bills;
    } catch (_) {
      return [];
    }
  }

  void _persist() => _prefs.setString(
      'saved_bills', jsonEncode(state.map((b) => b.toJson()).toList()));

  /// Insert a new bill, or update the existing entry when the same
  /// provider + reference is saved again.
  SavedBill upsert({
    required String providerId,
    required String reference,
    required String nickname,
    int? amountRs,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) {
    final now = DateTime.now();
    final next = [...state];
    final idx = next.indexWhere(
        (b) => b.providerId == providerId && b.reference == reference);
    late final SavedBill bill;
    if (idx >= 0) {
      bill = next[idx].copyWith(
        nickname: nickname,
        amountRs: amountRs,
        dueDate: dueDate,
        clearDueDate: clearDueDate,
        updatedAt: now,
      );
      next[idx] = bill;
    } else {
      bill = SavedBill(
        id: 'bill_${now.microsecondsSinceEpoch}',
        providerId: providerId,
        reference: reference,
        nickname: nickname,
        amountRs: amountRs,
        dueDate: dueDate,
        updatedAt: now,
      );
      next.add(bill);
    }
    next.sort(SavedBill.sortByDueDate);
    state = next;
    _persist();
    return bill;
  }

  void togglePaid(String id) {
    final next = state
        .map((b) => b.id == id
            ? b.copyWith(paid: !b.paid, updatedAt: DateTime.now())
            : b)
        .toList()
      ..sort(SavedBill.sortByDueDate);
    state = next;
    _persist();
  }

  void remove(String id) {
    state = state.where((b) => b.id != id).toList();
    _persist();
  }
}

final savedBillsProvider =
    StateNotifierProvider<SavedBillsNotifier, List<SavedBill>>((ref) {
  return SavedBillsNotifier(ref.watch(sharedPreferencesProvider));
});

// ------------------------------------------------------------------
// Vault: PDF index in SharedPreferences, files in app-private storage.
// ------------------------------------------------------------------
class VaultNotifier extends StateNotifier<List<VaultFile>> {
  VaultNotifier(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static List<VaultFile> _load(SharedPreferences prefs) {
    final raw = prefs.getString('vault_index');
    if (raw == null) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      final files = list.map(VaultFile.fromJson).toList()
        ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
      return files;
    } catch (_) {
      return [];
    }
  }

  void _persist() => _prefs.setString(
      'vault_index', jsonEncode(state.map((f) => f.toJson()).toList()));

  Future<Directory> _vaultDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/vault');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Copy [sourcePath] into the private vault and index it.
  Future<VaultFile> addFile({
    required String providerId,
    required String title,
    required String sourcePath,
  }) async {
    final dir = await _vaultDir();
    final id = 'pdf_${DateTime.now().microsecondsSinceEpoch}';
    final dest = await File(sourcePath).copy('${dir.path}/$id.pdf');
    final size = (await dest.stat()).size;
    final entry = VaultFile(
      id: id,
      providerId: providerId,
      title: title,
      fileName: '$id.pdf',
      sizeBytes: size,
      savedAt: DateTime.now(),
    );
    state = [entry, ...state];
    _persist();
    return entry;
  }

  /// The actual file for an index entry, or null when missing.
  Future<File?> fileFor(VaultFile entry) async {
    final dir = await _vaultDir();
    final file = File('${dir.path}/${entry.fileName}');
    return await file.exists() ? file : null;
  }

  Future<void> remove(String id) async {
    VaultFile? entry;
    for (final f in state) {
      if (f.id == id) {
        entry = f;
        break;
      }
    }
    if (entry != null) {
      final file = await fileFor(entry);
      try {
        await file?.delete();
      } catch (_) {
        // Index cleanup still proceeds.
      }
    }
    state = state.where((f) => f.id != id).toList();
    _persist();
  }
}

final vaultProvider =
    StateNotifierProvider<VaultNotifier, List<VaultFile>>((ref) {
  return VaultNotifier(ref.watch(sharedPreferencesProvider));
});

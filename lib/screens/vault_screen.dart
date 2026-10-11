import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../core/data/providers.dart';
import '../core/format.dart';
import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../models/vault_file.dart';
import '../state/app_state.dart';
import '../widgets/slip_card.dart' show kindIcon;

/// On-device PDF vault. Files live in app-private storage
/// (path_provider); nothing here ever leaves the phone unless the user
/// explicitly shares a file.
class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  String _query = '';
  UtilityKind? _filter;

  @override
  Widget build(BuildContext context) {
    final strings = Strings(Localizations.localeOf(context).languageCode);
    final theme = Theme.of(context);
    final colors = AppColors.of(theme.brightness);
    final files = ref.watch(vaultProvider);

    final visible = files.where((f) {
      final provider = providerById(f.providerId);
      if (_filter != null && provider?.kind != _filter) return false;
      if (_query.isEmpty) return true;
      return f.title.toLowerCase().contains(_query.toLowerCase()) ||
          (provider?.code.toLowerCase().contains(_query.toLowerCase()) ??
              false);
    }).toList();

    // Group by month, newest first.
    final groups = <String, List<VaultFile>>{};
    for (final f in visible) {
      final key = '${f.savedAt.year}-${f.savedAt.month.toString().padLeft(2, '0')}';
      groups.putIfAbsent(key, () => []).add(f);
    }
    final keys = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(strings.vaultTitle),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: colors.brandSoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.smartphone,
                      size: 13, color: colors.brand),
                  const SizedBox(width: 4),
                  Text(
                    strings.onThisPhone,
                    style: theme.textTheme.titleSmall!.copyWith(
                      fontSize: 11,
                      color: colors.brand,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: files.isEmpty
          ? _EmptyVault()
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: strings.searchHint,
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onChanged: (v) =>
                        setState(() => _query = v.trim()),
                  ),
                ),
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _FilterChip(
                        label: strings.filterAll,
                        selected: _filter == null,
                        onTap: () =>
                            setState(() => _filter = null),
                      ),
                      for (final kind in UtilityKind.values)
                        _FilterChip(
                          label: switch (kind) {
                            UtilityKind.electricity =>
                              strings.kindElectricity,
                            UtilityKind.gas => strings.kindGas,
                            UtilityKind.telecom =>
                              strings.kindTelecom,
                            UtilityKind.water => strings.kindWater,
                          },
                          selected: _filter == kind,
                          onTap: () => setState(() => _filter =
                              _filter == kind ? null : kind),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? Center(
                          child: Text(strings.noVaultResults,
                              style: theme.textTheme.bodyMedium!
                                  .copyWith(color: colors.muted)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                              16, 8, 16, 32),
                          itemCount: keys.length,
                          itemBuilder: (context, gi) {
                            final key = keys[gi];
                            final items = groups[key]!;
                            final first = items.first.savedAt;
                            final header = strings.isUrdu
                                ? '${strings.monthName(first.month)} ${first.year}'
                                : '${strings.monthName(first.month)} ${first.year}';
                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(
                                          4, 12, 4, 8),
                                  child: Text(header,
                                      style: theme
                                          .textTheme.titleSmall!
                                          .copyWith(
                                              color: colors.muted)),
                                ),
                                for (final f in items)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 8),
                                    child: _VaultRow(file: f),
                                  ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(theme.brightness);
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: colors.brandSoft,
        labelStyle: theme.textTheme.titleSmall!.copyWith(
          fontSize: 13,
          color: selected ? colors.brand : colors.muted,
        ),
      ),
    );
  }
}

class _VaultRow extends ConsumerWidget {
  const _VaultRow({required this.file});

  final VaultFile file;

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final strings =
        Strings(Localizations.localeOf(context).languageCode);
    final f = await ref.read(vaultProvider.notifier).fileFor(file);
    if (f == null || !context.mounted) return;
    final result = await OpenFilex.open(f.path);
    if (result.type != ResultType.done && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.pdfOpened)),
      );
    }
  }

  Future<void> _menu(BuildContext context, WidgetRef ref) async {
    final strings =
        Strings(Localizations.localeOf(context).languageCode);
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(strings.share),
              onTap: () => Navigator.of(context).pop('share'),
            ),
            ListTile(
              leading: Icon(Icons.delete,
                  color: Theme.of(context).colorScheme.error),
              title: Text(strings.deletePdf),
              onTap: () => Navigator.of(context).pop('delete'),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    if (action == 'share') {
      final f = await ref.read(vaultProvider.notifier).fileFor(file);
      if (f != null) {
        await Share.shareXFiles([XFile(f.path)], text: file.title);
      }
    } else if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(strings.deleteConfirmTitle),
          content: Text(strings.deleteConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(strings.delete,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error)),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await ref.read(vaultProvider.notifier).remove(file.id);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = Strings(Localizations.localeOf(context).languageCode);
    final theme = Theme.of(context);
    final colors = AppColors.of(theme.brightness);
    final provider = providerById(file.providerId);
    final kind = provider?.kind ?? UtilityKind.electricity;
    final tint = utilityTint(kind, theme.brightness);

    return Semantics(
      button: true,
      label: '${file.title}, ${formatBytes(file.sizeBytes)}',
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.line),
        ),
        child: InkWell(
          onTap: () => _open(context, ref),
          onLongPress: () => _menu(context, ref),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: tint.bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.picture_as_pdf,
                      color: tint.fg, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(file.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        '${formatBytes(file.sizeBytes)} • ${strings.isUrdu ? formatDateLocalized(file.savedAt, strings.monthName(file.savedAt.month)) : formatDateShort(file.savedAt)}',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              size: 14, color: colors.brand),
                          const SizedBox(width: 4),
                          Text(strings.offlineTick,
                              style: theme.textTheme.bodySmall!
                                  .copyWith(color: colors.brand)),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(kindIcon(kind), color: colors.muted, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyVault extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final strings = Strings(Localizations.localeOf(context).languageCode);
    final theme = Theme.of(context);
    final colors = AppColors.of(theme.brightness);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.brandSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.folder_open,
                  size: 36, color: colors.brand),
            ),
            const SizedBox(height: 20),
            Text(strings.vaultEmptyTitle,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(strings.vaultEmptyBody,
                style: theme.textTheme.bodyMedium!
                    .copyWith(color: colors.muted),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

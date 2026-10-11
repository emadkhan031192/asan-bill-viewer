import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/vault_screen.dart';
import 'state/app_state.dart';

class AsanBillApp extends ConsumerWidget {
  const AsanBillApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      title: 'Asan Bill Viewer',
      debugShowCheckedModeBanner: false,
      locale: Locale(settings.lang),
      supportedLocales: const [Locale('en'), Locale('ur')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: buildAppTheme(Brightness.light, settings.lang),
      darkTheme: buildAppTheme(Brightness.dark, settings.lang),
      themeMode: settings.theme,
      home: const MainShell(),
    );
  }
}

/// Bottom navigation: Bills (Home), Vault, Settings.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    const pages = [HomeScreen(), VaultScreen(), SettingsScreen()];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long),
            label: strings.navBills,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.folder),
            label: strings.navVault,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: strings.navSettings,
          ),
        ],
      ),
    );
  }
}

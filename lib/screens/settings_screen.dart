import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/data/providers.dart';
import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../state/app_state.dart';
import '../state/demo_seed.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = Strings(Localizations.localeOf(context).languageCode);
    final theme = Theme.of(context);
    final colors = AppColors.of(theme.brightness);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _SectionLabel(strings.language),
          _OptionsCard(
            options: [
              _Option(
                label: strings.english,
                selected: settings.lang == 'en',
                onTap: () =>
                    ref.read(settingsProvider.notifier).setLang('en'),
              ),
              _Option(
                label: strings.urdu,
                selected: settings.lang == 'ur',
                onTap: () =>
                    ref.read(settingsProvider.notifier).setLang('ur'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _SectionLabel(strings.theme),
          _OptionsCard(
            options: [
              _Option(
                label: strings.themeAuto,
                selected: settings.themeMode == 'auto',
                onTap: () => ref
                    .read(settingsProvider.notifier)
                    .setThemeMode('auto'),
              ),
              _Option(
                label: strings.themeLight,
                selected: settings.themeMode == 'light',
                onTap: () => ref
                    .read(settingsProvider.notifier)
                    .setThemeMode('light'),
              ),
              _Option(
                label: strings.themeDark,
                selected: settings.themeMode == 'dark',
                onTap: () => ref
                    .read(settingsProvider.notifier)
                    .setThemeMode('dark'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _SectionLabel(strings.trustTitle),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(strings.trustSub,
                style: theme.textTheme.bodySmall!
                    .copyWith(color: colors.muted)),
          ),
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.line),
            ),
            child: Column(
              children: [
                for (var i = 0;
                    i < allOfficialDomains().length;
                    i++) ...[
                  if (i > 0) Divider(height: 1, color: colors.line),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.verified,
                            size: 18, color: colors.brand),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            allOfficialDomains()[i],
                            style: tabular(theme
                                .textTheme.titleSmall!
                                .copyWith(fontFamily: 'Sora')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.brandSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lock_outline,
                        size: 18, color: colors.brand),
                    const SizedBox(width: 8),
                    Text(strings.privacyTitle,
                        style: theme.textTheme.titleSmall!
                            .copyWith(color: colors.brand)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(strings.privacyBody,
                    style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snap) {
              final version = snap.data?.version ?? '1.0.0';
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4),
                title: Text(strings.version,
                    style: theme.textTheme.titleSmall),
                trailing: Text(
                  version,
                  style: tabular(theme.textTheme.bodyMedium!
                      .copyWith(fontFamily: 'Sora')),
                ),
              );
            },
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                await seedDemoBills(ref);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(strings.demoLoaded)),
                  );
                }
              },
              icon: const Icon(Icons.science_outlined),
              label: Text(strings.loadDemo),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Text(strings.demoNote,
                  style: theme.textTheme.bodySmall!
                      .copyWith(color: colors.muted)),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleSmall!
            .copyWith(color: AppColors.of(Theme.of(context).brightness).muted),
      ),
    );
  }
}

class _Option {
  const _Option({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
}

class _OptionsCard extends StatelessWidget {
  const _OptionsCard({required this.options});

  final List<_Option> options;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(Theme.of(context).brightness);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.line),
      ),
      child: Column(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) Divider(height: 1, color: colors.line),
            Semantics(
              button: true,
              selected: options[i].selected,
              label: options[i].label,
              child: InkWell(
                onTap: options[i].onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(options[i].label,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium),
                      ),
                      if (options[i].selected)
                        Icon(Icons.check_circle,
                            color: colors.brand, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

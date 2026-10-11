import 'package:flutter/material.dart';

import '../core/data/providers.dart';
import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import 'slip_card.dart' show kindIcon;

/// Home "Check a bill" tile: code + Urdu name, grouped by utility kind.
class ProviderTile extends StatelessWidget {
  const ProviderTile({
    super.key,
    required this.provider,
    required this.onTap,
  });

  final BillProvider provider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(theme.brightness);
    final strings = Strings(Localizations.localeOf(context).languageCode);
    final tint = utilityTint(provider.kind, theme.brightness);
    final rtl =
        Directionality.of(context) == TextDirection.rtl;

    return Semantics(
      button: true,
      label: strings.isUrdu ? provider.nameUr : provider.nameEn,
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.line),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tint.bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(kindIcon(provider.kind),
                      color: tint.fg, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        provider.code,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tabular(theme.textTheme.titleSmall!.copyWith(
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.w700,
                        )),
                      ),
                      Text(
                        provider.nameUr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  rtl ? Icons.chevron_left : Icons.chevron_right,
                  color: colors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Section header with an optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: theme.textTheme.headlineSmall),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// EN | اردو pill switcher.
class LanguagePill extends StatelessWidget {
  const LanguagePill({
    super.key,
    required this.lang,
    required this.onChanged,
  });

  final String lang;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(theme.brightness);
    final strings = Strings(lang);

    Widget segment(String value, String label, bool selected) {
      return Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          onTap: () => onChanged(value),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? colors.brand : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: theme.textTheme.titleSmall!.copyWith(
                fontSize: 13,
                color: selected ? colors.brandInkOn : colors.muted,
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: strings.language,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            segment('en', strings.english, lang == 'en'),
            segment('ur', strings.urdu, lang == 'ur'),
          ],
        ),
      ),
    );
  }
}

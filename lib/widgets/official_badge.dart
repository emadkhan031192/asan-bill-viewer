import 'package:flutter/material.dart';

import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';

/// The green OFFICIAL-SOURCE BADGE: verified icon + domain in Sora.
class OfficialBadge extends StatelessWidget {
  const OfficialBadge({super.key, required this.domain, this.compact = false});

  final String domain;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(theme.brightness);
    final strings = Strings(Localizations.localeOf(context).languageCode);
    return Semantics(
      label: '${strings.officialSource}: $domain',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: compact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: colors.brandSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, color: colors.brand, size: compact ? 14 : 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                domain,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tabular(
                  (compact
                          ? theme.textTheme.bodySmall
                          : theme.textTheme.titleSmall)!
                      .copyWith(
                    fontFamily: 'Sora',
                    color: colors.brand,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

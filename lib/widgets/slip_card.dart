import 'package:flutter/material.dart';

import '../core/data/providers.dart';
import '../core/format.dart';
import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../models/bill_status.dart';
import '../models/saved_bill.dart';

/// Icon per utility kind (stable, no emoji).
IconData kindIcon(UtilityKind kind) => switch (kind) {
      UtilityKind.electricity => Icons.bolt,
      UtilityKind.gas => Icons.local_fire_department,
      UtilityKind.telecom => Icons.phone,
      UtilityKind.water => Icons.water_drop,
    };

/// The signature SAVED BILL AS A TORN PAYMENT SLIP.
///
/// CustomPainter draws: rounded body with real cut-out notches on both
/// edges (even-odd path, so the card shadow follows the tear), a 4px
/// utility-colour band along the top, and a dashed tear line.
class SlipCard extends StatelessWidget {
  const SlipCard({
    super.key,
    required this.bill,
    required this.provider,
    required this.onTap,
    required this.onTogglePaid,
  });

  final SavedBill bill;
  final BillProvider provider;
  final VoidCallback onTap;
  final VoidCallback onTogglePaid;

  static const double _tearY = 96;
  static const double _height = 152;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(theme.brightness);
    final strings = Strings(Localizations.localeOf(context).languageCode);
    final now = DateTime.now();
    final status = bill.statusAt(now);
    final tint = statusTint(status, theme.brightness);
    final uTint = utilityTint(provider.kind, theme.brightness);

    final statusLabel = switch (status) {
      DueStatus.paid => strings.statusPaid,
      DueStatus.overdue => strings.statusOverdue,
      DueStatus.dueToday => strings.statusDueToday,
      DueStatus.dueSoon =>
        strings.statusDueIn(daysRemaining(bill.dueDate, now) ?? 0),
      DueStatus.upcoming =>
        strings.statusDueIn(daysRemaining(bill.dueDate, now) ?? 0),
      DueStatus.noDueDate => strings.statusNoDueDate,
    };

    return Semantics(
      button: true,
      label: '${bill.nickname}, ${provider.code}, $statusLabel',
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: _SlipPainter(
            surface: colors.surface,
            band: utilityBand(provider.kind),
            line: colors.line,
            tearY: _tearY,
          ),
          child: SizedBox(
            width: double.infinity,
            height: _height,
            child: Column(
              children: [
                // ---- Upper part: identity + amount ----
                SizedBox(
                  height: _tearY,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: uTint.bg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(kindIcon(provider.kind),
                              color: uTint.fg, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bill.nickname,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${provider.code} ••••${bill.last4}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tabular(theme.textTheme.bodySmall!
                                    .copyWith(fontFamily: 'Sora')),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (bill.amountRs != null)
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerEnd,
                            child: Text(
                              formatRs(bill.amountRs!),
                              style: tabular(
                                theme.textTheme.titleLarge!.copyWith(
                                  fontSize: 22,
                                  fontFamily: 'Sora',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // ---- Lower stub: status chip + due date + paid toggle ----
                SizedBox(
                  height: _height - _tearY,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 8, 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: tint.bg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            statusLabel,
                            style: theme.textTheme.titleSmall!
                                .copyWith(color: tint.fg, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (bill.dueDate != null)
                          Expanded(
                            child: Text(
                              strings.isUrdu
                                  ? formatDateLocalized(bill.dueDate!,
                                      strings.monthName(bill.dueDate!.month))
                                  : formatDateShort(bill.dueDate!),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tabular(theme.textTheme.bodySmall!
                                  .copyWith(fontFamily: 'Sora')),
                            ),
                          )
                        else
                          const Spacer(),
                        Semantics(
                          button: true,
                          label: bill.paid
                              ? strings.markUnpaid
                              : strings.markPaid,
                          child: IconButton(
                            onPressed: onTogglePaid,
                            icon: Icon(
                              bill.paid
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              color: bill.paid ? colors.brand : colors.muted,
                            ),
                            tooltip: bill.paid
                                ? strings.markUnpaid
                                : strings.markPaid,
                            constraints: const BoxConstraints(
                                minWidth: 44, minHeight: 44),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SlipPainter extends CustomPainter {
  _SlipPainter({
    required this.surface,
    required this.band,
    required this.line,
    required this.tearY,
  });

  final Color surface;
  final Color band;
  final Color line;
  final double tearY;

  static const double _radius = 16;
  static const double _notchR = 11;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body with true cut-out notches on both edges.
    final path = Path()
      ..addRRect(RRect.fromLTRBR(0, 0, w, h, const Radius.circular(_radius)))
      ..addOval(Rect.fromCircle(center: Offset(0, tearY), radius: _notchR))
      ..addOval(Rect.fromCircle(center: Offset(w, tearY), radius: _notchR));
    path.fillType = PathFillType.evenOdd;

    canvas.drawShadow(path, const Color(0x1F000000), 6, true);
    canvas.drawPath(path, Paint()..color = surface);

    // 4px utility-colour band along the top.
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, w, 4),
        topLeft: const Radius.circular(_radius),
        topRight: const Radius.circular(_radius),
      ),
      Paint()..color = band,
    );

    // Dashed tear line between the notches.
    const dash = 7.0;
    const gap = 5.0;
    var x = 16.0;
    final paint = Paint()
      ..color = line
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    while (x < w - 16) {
      final x2 = (x + dash).clamp(0.0, w - 16);
      canvas.drawLine(Offset(x, tearY), Offset(x2, tearY), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _SlipPainter old) =>
      old.surface != surface ||
      old.band != band ||
      old.line != line ||
      old.tearY != tearY;
}

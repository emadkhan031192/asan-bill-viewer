import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/data/providers.dart';
import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../services/validators.dart';
import '../widgets/official_badge.dart';
import '../widgets/slip_card.dart' show kindIcon;
import 'scan_screen.dart';
import 'viewer_screen.dart';

class LookupScreen extends ConsumerStatefulWidget {
  const LookupScreen({super.key, required this.provider, this.initialNumber});

  final BillProvider provider;
  final String? initialNumber;

  @override
  ConsumerState<LookupScreen> createState() => _LookupScreenState();
}

class _LookupScreenState extends ConsumerState<LookupScreen> {
  late final TextEditingController _controller;
  String _digits = '';

  @override
  void initState() {
    super.initState();
    final initial = digitsOnly(widget.initialNumber ?? '');
    _controller = TextEditingController(text: groupDigits(initial));
    _digits = initial;
    _controller.addListener(() {
      final d = digitsOnly(_controller.text);
      if (d != _digits) setState(() => _digits = d);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setDigits(String digits) {
    final d = digitsOnly(digits);
    final capped = d.length > widget.provider.maxLength
        ? d.substring(0, widget.provider.maxLength)
        : d;
    _controller.value = TextEditingValue(
      text: groupDigits(capped),
      selection: TextSelection.collapsed(offset: groupDigits(capped).length),
    );
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';
    if (text.isEmpty || !mounted) return;
    _setDigits(text);
  }

  Future<void> _scan() async {
    final result = await Navigator.of(context).push<ScanResult>(
      MaterialPageRoute(
        builder: (_) => ScanScreen(lockProviderId: widget.provider.id),
      ),
    );
    if (result == null || !mounted) return;
    if (result.providerId == widget.provider.id) {
      _setDigits(result.number);
    } else {
      final other = providerById(result.providerId);
      if (other == null) return;
      // The scanned number belongs to a different provider: open its lookup.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              LookupScreen(provider: other, initialNumber: result.number),
        ),
      );
    }
  }

  void _viewBill() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ViewerScreen(
          provider: widget.provider,
          reference: _digits,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    final strings = Strings(Localizations.localeOf(context).languageCode);
    final theme = Theme.of(context);
    final colors = AppColors.of(theme.brightness);
    final tint = utilityTint(p.kind, theme.brightness);
    final valid = isValidReference(p, _digits);
    final domain = Uri.parse(p.url).host;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            // Kind label with icon.
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: tint.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(kindIcon(p.kind), size: 18, color: tint.fg),
                  const SizedBox(width: 8),
                  Text(
                    switch (p.kind) {
                      UtilityKind.electricity => strings.kindElectricity,
                      UtilityKind.gas => strings.kindGas,
                      UtilityKind.telecom => strings.kindTelecom,
                      UtilityKind.water => strings.kindWater,
                    },
                    style: theme.textTheme.titleSmall!
                        .copyWith(color: tint.fg),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(p.nameEn, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(p.nameUr, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OfficialBadge(domain: domain),
            ),
            const SizedBox(height: 28),

            // Reference number field.
            Semantics(
              label: strings.referenceLabel,
              textField: true,
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  ReferenceInputFormatter(p.maxLength),
                ],
                style: tabular(
                  theme.textTheme.titleLarge!.copyWith(fontFamily: 'Sora'),
                ),
                decoration: InputDecoration(
                  labelText: strings.referenceLabel,
                  suffixIcon: TextButton(
                    onPressed: _paste,
                    child: Text(strings.paste),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    strings.isUrdu ? p.hintUr : p.hintEn,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  label: '${_digits.length} / ${p.maxLength}',
                  child: Text(
                    '${_digits.length}/${p.maxLength}',
                    style: tabular(theme.textTheme.bodySmall!.copyWith(
                      fontFamily: 'Sora',
                      color: valid ? colors.brand : colors.muted,
                      fontWeight:
                          valid ? FontWeight.w700 : FontWeight.w400,
                    )),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Primary + secondary actions.
            FilledButton(
              onPressed: valid ? _viewBill : null,
              child: Text(strings.viewBill),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _scan,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(strings.scanPrinted),
            ),
            const SizedBox(height: 20),
            Text(
              strings.lookupFootnote,
              style:
                  theme.textTheme.bodySmall!.copyWith(color: colors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

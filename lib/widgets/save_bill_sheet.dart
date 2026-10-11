import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/data/providers.dart';
import '../core/format.dart';
import '../core/l10n/strings.dart';
import '../state/app_state.dart';

/// Bottom sheet for "Save bill": nickname, optional amount, optional due
/// date. Saving the same provider + reference updates the existing entry.
class SaveBillSheet extends ConsumerStatefulWidget {
  const SaveBillSheet({
    super.key,
    required this.provider,
    required this.reference,
  });

  final BillProvider provider;
  final String reference;

  @override
  ConsumerState<SaveBillSheet> createState() => _SaveBillSheetState();
}

class _SaveBillSheetState extends ConsumerState<SaveBillSheet> {
  late final TextEditingController _nick;
  late final TextEditingController _amount;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _nick = TextEditingController(text: widget.provider.code);
    _amount = TextEditingController();
  }

  @override
  void dispose() {
    _nick.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 7)),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _save() {
    final nickname = _nick.text.trim();
    if (nickname.isEmpty) return;
    final amountText = _amount.text.replaceAll(RegExp(r'[^0-9]'), '');
    ref.read(savedBillsProvider.notifier).upsert(
          providerId: widget.provider.id,
          reference: widget.reference,
          nickname: nickname,
          amountRs: amountText.isEmpty ? null : int.tryParse(amountText),
          dueDate: _dueDate,
          clearDueDate: _dueDate == null,
        );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final strings = Strings(Localizations.localeOf(context).languageCode);
    final theme = Theme.of(context);
    final valid = _nick.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(strings.saveBillTitle,
              style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            '${widget.provider.code} ••••${widget.reference.length <= 4 ? widget.reference : widget.reference.substring(widget.reference.length - 4)}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nick,
            decoration: InputDecoration(
              labelText: strings.nickname,
              hintText: strings.nicknameHint,
            ),
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: strings.amount,
              hintText: strings.amountHint,
            ),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    _dueDate == null
                        ? strings.pickDate
                        : (strings.isUrdu
                            ? formatDateLocalized(_dueDate!,
                                strings.monthName(_dueDate!.month))
                            : formatDateShort(_dueDate!)),
                  ),
                ),
              ),
              if (_dueDate != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => setState(() => _dueDate = null),
                  child: Text(strings.clearDate),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: valid ? _save : null,
            child: Text(strings.save),
          ),
        ],
      ),
    );
  }
}

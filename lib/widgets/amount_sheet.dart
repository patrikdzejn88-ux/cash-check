import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../utils/money.dart';

/// Универсальный шит ввода суммы: используется и для траты, и для правки баланса.
class AmountSheet extends StatefulWidget {
  const AmountSheet({
    super.key,
    required this.title,
    required this.actionLabel,
    this.withNote = false,
    this.initialAmount,
    this.initialNote,
  });

  final String title;
  final String actionLabel;
  final bool withNote;
  final double? initialAmount;
  final String? initialNote;

  @override
  State<AmountSheet> createState() => _AmountSheetState();
}

class AmountSheetResult {
  const AmountSheetResult(this.amount, this.note);
  final double amount;
  final String note;
}

class _AmountSheetState extends State<AmountSheet> {
  late final TextEditingController _amount = TextEditingController(
    text: widget.initialAmount == null
        ? ''
        : formatMoney(widget.initialAmount!, withSuffix: false)
            .replaceAll('\u2009', ''),
  );
  late final TextEditingController _note =
      TextEditingController(text: widget.initialNote ?? '');
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    final value = parseAmount(_amount.text);
    if (value == null) {
      setState(() => _error = 'Введите сумму');
      return;
    }
    if (value < 0) {
      setState(() => _error = 'Сумма не может быть отрицательной');
      return;
    }
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(AmountSheetResult(value, _note.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amount,
                      autofocus: true,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1,
                        color: AppColors.text,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textFaint,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      kCurrencySuffix,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.negative)),
              ],
              if (widget.withNote) ...[
                const SizedBox(height: 18),
                TextField(
                  controller: _note,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontSize: 15, color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: 'На что потратил',
                    hintStyle: const TextStyle(color: AppColors.textFaint),
                    filled: true,
                    fillColor: AppColors.surfaceHigh,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 15),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ],
              const SizedBox(height: 22),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: const Color(0xFF06150E),
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  widget.actionLabel,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

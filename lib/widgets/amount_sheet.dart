import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/categories.dart';
import '../theme/app_theme.dart';
import '../utils/money.dart';

/// Универсальный шит ввода суммы: используется и для траты, и для правки баланса.
class AmountSheet extends StatefulWidget {
  const AmountSheet({
    super.key,
    required this.title,
    required this.actionLabel,
    this.withCategory = false,
    this.initialAmount,
  });

  final String title;
  final String actionLabel;
  final bool withCategory;
  final double? initialAmount;

  @override
  State<AmountSheet> createState() => _AmountSheetState();
}

class AmountSheetResult {
  const AmountSheetResult(this.amount, this.categoryId);
  final double amount;
  final String categoryId;
}

class _AmountSheetState extends State<AmountSheet> {
  late final TextEditingController _amount = TextEditingController(
    text: widget.initialAmount == null
        ? ''
        : formatMoney(widget.initialAmount!, withSuffix: false)
            .replaceAll(' ', ''),
  );
  String _categoryId = kCategories.first.id;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
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
    Navigator.of(context).pop(AmountSheetResult(value, _categoryId));
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
                Text(
                  _error!,
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.negative),
                ),
              ],
              if (widget.withCategory) ...[
                const SizedBox(height: 22),
                const Text(
                  'КАТЕГОРИЯ',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textFaint,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final category in kCategories) ...[
                      Expanded(
                        child: _CategoryChip(
                          category: category,
                          selected: category.id == _categoryId,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _categoryId = category.id);
                          },
                        ),
                      ),
                      if (category != kCategories.last)
                        const SizedBox(width: 10),
                    ],
                  ],
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
                  style:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final ExpenseCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withValues(alpha: 0.13)
              : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.accent : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 21,
              color: selected ? AppColors.accent : AppColors.textMuted,
            ),
            const SizedBox(height: 7),
            Text(
              category.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.accent : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/app_theme.dart';
import '../utils/money.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({
    super.key,
    required this.expense,
    required this.onDelete,
  });

  final Expense expense;

  /// Возвращает false, если окно отмены успело закрыться между
  /// жестом и записью — тогда плитка не исчезает.
  final Future<bool> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final deletable = expense.isDeletable();

    return Dismissible(
      key: ValueKey<int?>(expense.id),
      direction:
          deletable ? DismissDirection.endToStart : DismissDirection.none,
      confirmDismiss: (_) async {
        if (!expense.isDeletable()) {
          _showWindowClosed(context);
          return false;
        }
        return onDelete();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.negative.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.undo_rounded,
            color: AppColors.negative, size: 22),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: deletable ? null : () => _showWindowClosed(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(expense.category.icon,
                      size: 18, color: AppColors.textMuted),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.category.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            _time(expense.createdAt),
                            style: const TextStyle(
                                fontSize: 12.5, color: AppColors.textFaint),
                          ),
                          if (deletable) ...[
                            const SizedBox(width: 7),
                            Text(
                              '· отмена ${_minutesLeft(expense)} мин',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '−${formatMoney(expense.amount)}',
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _minutesLeft(Expense e) {
    // Без clamp: его статический тип — num, а здесь нужен строго int.
    final minutes = (e.remainingDeleteWindow().inSeconds / 60).ceil();
    if (minutes < 1) return 1;
    if (minutes > kDeleteWindow.inMinutes) return kDeleteWindow.inMinutes;
    return minutes;
  }

  void _showWindowClosed(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceHigh,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(
            'Отменить трату можно только в первые '
            '${kDeleteWindow.inMinutes} минут после записи',
            style: const TextStyle(fontSize: 13.5, color: AppColors.text),
          ),
        ),
      );
  }

  String _time(DateTime d) {
    final now = DateTime.now();
    final sameDay =
        d.year == now.year && d.month == now.month && d.day == now.day;
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    if (sameDay) return 'Сегодня, $hh:$mm';
    final yesterday = now.subtract(const Duration(days: 1));
    if (d.year == yesterday.year &&
        d.month == yesterday.month &&
        d.day == yesterday.day) {
      return 'Вчера, $hh:$mm';
    }
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}, $hh:$mm';
  }
}

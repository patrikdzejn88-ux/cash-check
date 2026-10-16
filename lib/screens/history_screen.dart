import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../data/wallet_repository.dart';
import '../state/wallet_state.dart';
import '../theme/app_theme.dart';
import '../utils/money.dart';
import '../widgets/expense_tile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WalletState>();
    final groups = _groupByDay(state.expenses);

    return Scaffold(
      appBar: AppBar(
        title: const Text('История',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      ),
      body: groups.isEmpty
          ? const Center(
              child: Text('Трат пока нет',
                  style: TextStyle(color: AppColors.textFaint)),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
              itemCount: groups.length + 1,
              itemBuilder: (_, i) {
                if (i == groups.length) return const _RetentionNote();
                final group = groups[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 18, 4, 4),
                      child: Row(
                        children: [
                          Text(
                            group.label,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            formatMoney(group.total),
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textFaint),
                          ),
                        ],
                      ),
                    ),
                    ...group.items.map(
                      (e) => ExpenseTile(
                        expense: e,
                        onDelete: () =>
                            context.read<WalletState>().deleteExpense(e),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  List<_DayGroup> _groupByDay(List<Expense> expenses) {
    final map = <String, List<Expense>>{};
    for (final e in expenses) {
      final key =
          '${e.createdAt.year}-${e.createdAt.month}-${e.createdAt.day}';
      map.putIfAbsent(key, () => []).add(e);
    }
    return map.values.map((items) {
      final first = items.first.createdAt;
      return _DayGroup(
        label: _dayLabel(first),
        items: items,
        total: items.fold(0.0, (s, e) => s + e.amount),
      );
    }).toList();
  }

  static const _months = [
    'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
    'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
  ];

  String _dayLabel(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Сегодня';
    }
    final y = now.subtract(const Duration(days: 1));
    if (d.year == y.year && d.month == y.month && d.day == y.day) {
      return 'Вчера';
    }
    final label = '${d.day} ${_months[d.month - 1]}';
    return d.year == now.year ? label : '$label ${d.year}';
  }
}

class _RetentionNote extends StatelessWidget {
  const _RetentionNote();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(4, 28, 4, 8),
      child: Text(
        'История хранится за последние $kHistoryMonths месяцев. '
        'Записи старше удаляются автоматически — баланс при этом не меняется.',
        style: TextStyle(
          fontSize: 12,
          height: 1.5,
          color: AppColors.textFaint,
        ),
      ),
    );
  }
}

class _DayGroup {
  const _DayGroup({
    required this.label,
    required this.items,
    required this.total,
  });

  final String label;
  final List<Expense> items;
  final double total;
}

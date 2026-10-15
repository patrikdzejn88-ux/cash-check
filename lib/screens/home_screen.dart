import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/wallet_state.dart';
import '../theme/app_theme.dart';
import '../widgets/amount_sheet.dart';
import '../widgets/balance_display.dart';
import '../widgets/expense_tile.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _editBalance(BuildContext context) async {
    final state = context.read<WalletState>();
    final result = await showModalBottomSheet<AmountSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => AmountSheet(
        title: 'Изменить баланс',
        actionLabel: 'Сохранить',
        initialAmount: state.balance,
      ),
    );
    if (result != null) await state.setBalance(result.amount);
  }

  Future<void> _addExpense(BuildContext context) async {
    final state = context.read<WalletState>();
    HapticFeedback.selectionClick();
    final result = await showModalBottomSheet<AmountSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => const AmountSheet(
        title: 'Новая трата',
        actionLabel: 'Списать',
        withNote: true,
      ),
    );
    if (result != null) {
      await state.addExpense(amount: result.amount, title: result.note);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WalletState>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
              child: Row(
                children: [
                  const Text(
                    'Cash Check',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: AppColors.text,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const HistoryScreen()),
                    ),
                    icon: const Icon(Icons.receipt_long_rounded,
                        size: 21, color: AppColors.textMuted),
                    tooltip: 'История',
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Center(
                child: BalanceDisplay(
                  balance: state.balance,
                  spentThisMonth: state.spentThisMonth,
                  onTap: () => _editBalance(context),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Row(
                        children: [
                          const Text(
                            'Последние траты',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const Spacer(),
                          if (state.expenses.length > 12)
                            TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                    builder: (_) => const HistoryScreen()),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Все',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.accent)),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: state.loading
                          ? const SizedBox.shrink()
                          : state.expenses.isEmpty
                              ? const _EmptyState()
                              : ListView.builder(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                  itemCount: state.recent.length,
                                  itemBuilder: (_, i) {
                                    final expense = state.recent[i];
                                    return ExpenseTile(
                                      expense: expense,
                                      onDelete: () =>
                                          state.deleteExpense(expense),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addExpense(context),
        backgroundColor: AppColors.accent,
        foregroundColor: const Color(0xFF06150E),
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text('Трата',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.savings_outlined, size: 34, color: AppColors.textFaint),
            SizedBox(height: 14),
            Text(
              'Пока пусто',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted),
            ),
            SizedBox(height: 6),
            Text(
              'Нажми «Трата», чтобы списать первую сумму с баланса',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, height: 1.45, color: AppColors.textFaint),
            ),
          ],
        ),
      ),
    );
  }
}

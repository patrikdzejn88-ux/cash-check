import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models.dart';
import '../data/wallet_repository.dart';

class WalletState extends ChangeNotifier {
  WalletState(this._repo);

  final WalletRepository _repo;

  double _balance = 0;
  List<Expense> _expenses = const [];
  bool _loading = true;
  Timer? _windowTicker;

  double get balance => _balance;
  List<Expense> get expenses => _expenses;
  bool get loading => _loading;

  List<Expense> get recent => _expenses.take(12).toList();

  double get spentThisMonth {
    final now = DateTime.now();
    return _expenses
        .where((e) =>
            e.createdAt.year == now.year && e.createdAt.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Future<void> load() async {
    await _repo.pruneOldExpenses();
    _balance = await _repo.readBalance();
    _expenses = await _repo.readExpenses();
    _loading = false;
    _syncWindowTicker();
    notifyListeners();
  }

  Future<void> setBalance(double value) async {
    await _repo.writeBalance(value);
    _balance = value;
    notifyListeners();
  }

  Future<void> addExpense({
    required double amount,
    required String categoryId,
  }) async {
    await _repo.addExpense(Expense(
      amount: amount,
      categoryId: categoryId,
      createdAt: DateTime.now(),
    ));
    await load();
  }

  /// false — окно отмены уже закрылось, трата осталась на месте.
  Future<bool> deleteExpense(Expense expense) async {
    final removed = await _repo.deleteExpense(expense);
    if (removed) await load();
    return removed;
  }

  /// Пока в списке есть траты в окне отмены, подталкиваем UI —
  /// иначе подпись «отмена N мин» и доступность свайпа застынут.
  void _syncWindowTicker() {
    final hasOpenWindow = _expenses.any((e) => e.isDeletable());
    if (hasOpenWindow) {
      _windowTicker ??= Timer.periodic(
        const Duration(seconds: 20),
        (_) {
          if (_expenses.any((e) => e.isDeletable())) {
            notifyListeners();
          } else {
            _stopWindowTicker();
            notifyListeners();
          }
        },
      );
    } else {
      _stopWindowTicker();
    }
  }

  void _stopWindowTicker() {
    _windowTicker?.cancel();
    _windowTicker = null;
  }

  @override
  void dispose() {
    _stopWindowTicker();
    super.dispose();
  }
}

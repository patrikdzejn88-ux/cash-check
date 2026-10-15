import 'package:flutter/foundation.dart';

import '../data/models.dart';
import '../data/wallet_repository.dart';

class WalletState extends ChangeNotifier {
  WalletState(this._repo);

  final WalletRepository _repo;

  double _balance = 0;
  List<Expense> _expenses = const [];
  bool _loading = true;

  double get balance => _balance;
  List<Expense> get expenses => _expenses;
  bool get loading => _loading;

  List<Expense> get recent => _expenses.take(12).toList();

  double get spentThisMonth {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.createdAt.year == now.year && e.createdAt.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Future<void> load() async {
    _balance = await _repo.readBalance();
    _expenses = await _repo.readExpenses();
    _loading = false;
    notifyListeners();
  }

  Future<void> setBalance(double value) async {
    await _repo.writeBalance(value);
    _balance = value;
    notifyListeners();
  }

  Future<void> addExpense({required double amount, required String title}) async {
    await _repo.addExpense(Expense(
      amount: amount,
      title: title.trim(),
      createdAt: DateTime.now(),
    ));
    await load();
  }

  Future<void> deleteExpense(Expense expense) async {
    await _repo.deleteExpense(expense);
    await load();
  }

  Future<void> updateExpense(Expense before, Expense after) async {
    await _repo.updateExpense(before, after);
    await load();
  }
}

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'models.dart';

/// Всё локально: SQLite в приватной папке приложения. Сети нет вообще.
class WalletRepository {
  static const _balanceKey = 'balance';
  late final Database _db;

  Future<void> init() async {
    final dir = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dir, 'cash_check.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL,
            title TEXT NOT NULL DEFAULT '',
            created_at INTEGER NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_expenses_date ON expenses(created_at DESC)');
        await db.execute('''
          CREATE TABLE meta (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
        await db.insert('meta', {'key': _balanceKey, 'value': '0'});
      },
    );
  }

  Future<double> readBalance() async {
    final rows = await _db.query('meta',
        where: 'key = ?', whereArgs: [_balanceKey], limit: 1);
    if (rows.isEmpty) return 0;
    return double.tryParse(rows.first['value'] as String) ?? 0;
  }

  Future<void> writeBalance(double value) async {
    await _db.insert(
      'meta',
      {'key': _balanceKey, 'value': value.toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Expense>> readExpenses({int? limit}) async {
    final rows = await _db.query('expenses',
        orderBy: 'created_at DESC, id DESC', limit: limit);
    return rows.map(Expense.fromMap).toList();
  }

  /// Добавление траты и списание с баланса — одной транзакцией,
  /// чтобы баланс не разъехался со списком при сбое.
  Future<Expense> addExpense(Expense expense) async {
    late Expense saved;
    await _db.transaction((txn) async {
      final id = await txn.insert('expenses', expense.toMap());
      saved = expense.copyWith(id: id);
      await _adjustBalance(txn, -expense.amount);
    });
    return saved;
  }

  Future<void> deleteExpense(Expense expense) async {
    if (expense.id == null) return;
    await _db.transaction((txn) async {
      await txn.delete('expenses', where: 'id = ?', whereArgs: [expense.id]);
      await _adjustBalance(txn, expense.amount); // возврат на баланс
    });
  }

  Future<void> updateExpense(Expense before, Expense after) async {
    if (before.id == null) return;
    await _db.transaction((txn) async {
      await txn.update('expenses', after.toMap(),
          where: 'id = ?', whereArgs: [before.id]);
      await _adjustBalance(txn, before.amount - after.amount);
    });
  }

  Future<void> _adjustBalance(DatabaseExecutor txn, double delta) async {
    final rows = await txn.query('meta',
        where: 'key = ?', whereArgs: [_balanceKey], limit: 1);
    final current =
        rows.isEmpty ? 0.0 : double.tryParse(rows.first['value'] as String) ?? 0;
    await txn.insert(
      'meta',
      {'key': _balanceKey, 'value': (current + delta).toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

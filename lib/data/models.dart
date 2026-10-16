import 'categories.dart';

/// Окно, в течение которого трату ещё можно отменить.
const Duration kDeleteWindow = Duration(minutes: 5);

class Expense {
  const Expense({
    this.id,
    required this.amount,
    required this.categoryId,
    required this.createdAt,
  });

  final int? id;
  final double amount;
  final String categoryId;
  final DateTime createdAt;

  ExpenseCategory get category => categoryById(categoryId);

  /// Сколько осталось до закрытия окна отмены (ноль, если уже закрыто).
  Duration remainingDeleteWindow([DateTime? now]) {
    final elapsed = (now ?? DateTime.now()).difference(createdAt);
    final left = kDeleteWindow - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  bool isDeletable([DateTime? now]) => remainingDeleteWindow(now) > Duration.zero;

  Expense copyWith({
    int? id,
    double? amount,
    String? categoryId,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'amount': amount,
        'category': categoryId,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Expense.fromMap(Map<String, Object?> map) => Expense(
        id: map['id'] as int?,
        amount: (map['amount'] as num).toDouble(),
        categoryId: (map['category'] as String?) ?? kDefaultCategoryId,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      );
}

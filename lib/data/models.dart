class Expense {
  const Expense({
    this.id,
    required this.amount,
    required this.title,
    required this.createdAt,
  });

  final int? id;
  final double amount;
  final String title;
  final DateTime createdAt;

  Expense copyWith({int? id, double? amount, String? title, DateTime? createdAt}) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'amount': amount,
        'title': title,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Expense.fromMap(Map<String, Object?> map) => Expense(
        id: map['id'] as int?,
        amount: (map['amount'] as num).toDouble(),
        title: (map['title'] as String?) ?? '',
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      );
}

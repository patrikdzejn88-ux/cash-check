import 'package:flutter/material.dart';

/// В базе хранится [id], а не подпись: переименование категории
/// не должно ломать уже записанные траты.
class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

const kCategories = <ExpenseCategory>[
  ExpenseCategory(
    id: 'delivery',
    label: 'Доставка',
    icon: Icons.delivery_dining_rounded,
  ),
  ExpenseCategory(
    id: 'store',
    label: 'Магазин',
    icon: Icons.shopping_basket_rounded,
  ),
  ExpenseCategory(
    id: 'other',
    label: 'Разное',
    icon: Icons.auto_awesome_mosaic_rounded,
  ),
];

const kDefaultCategoryId = 'other';

ExpenseCategory categoryById(String id) {
  return kCategories.firstWhere(
    (c) => c.id == id,
    orElse: () => kCategories.last,
  );
}

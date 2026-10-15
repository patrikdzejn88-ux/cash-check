import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/money.dart';

/// Крупная сумма по центру. Тап — редактирование.
class BalanceDisplay extends StatelessWidget {
  const BalanceDisplay({
    super.key,
    required this.balance,
    required this.spentThisMonth,
    required this.onTap,
  });

  final double balance;
  final double spentThisMonth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // Сумма может быть длинной — подбираем кегль под ширину экрана.
    final text = formatMoney(balance, withSuffix: false);
    final fontSize = switch (text.length) {
      <= 6 => width * 0.19,
      <= 8 => width * 0.155,
      <= 10 => width * 0.125,
      _ => width * 0.10,
    };

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Баланс',
            style: TextStyle(
              fontSize: 13,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w500,
              color: AppColors.textFaint,
            ),
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.18),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                    parent: animation, curve: Curves.easeOutCubic)),
                child: child,
              ),
            ),
            child: Row(
              key: ValueKey<double>(balance),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize,
                    height: 1.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1.5,
                    color: balance < 0 ? AppColors.negative : AppColors.text,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: fontSize * 0.13, left: 8),
                  child: Text(
                    kCurrencySuffix,
                    style: TextStyle(
                      fontSize: fontSize * 0.28,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'За месяц: ${formatMoney(spentThisMonth)}',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

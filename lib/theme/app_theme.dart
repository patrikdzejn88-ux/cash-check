import 'package:flutter/material.dart';

/// Палитра. Не чистый чёрный: на #000 пропадают тени и слои,
/// интерфейс выглядит плоским. Графит даёт глубину.
class AppColors {
  static const background = Color(0xFF0E0F13);
  static const surface = Color(0xFF16181F);
  static const surfaceHigh = Color(0xFF1E212B);
  static const border = Color(0xFF272B36);
  static const text = Color(0xFFF2F3F7);
  static const textMuted = Color(0xFF8A8F9E);
  static const textFaint = Color(0xFF5C6373);
  static const accent = Color(0xFF5BE49B);
  static const negative = Color(0xFFF87171);
}

ThemeData buildAppTheme() {
  const scheme = ColorScheme.dark(
    primary: AppColors.accent,
    onPrimary: Color(0xFF06150E),
    secondary: AppColors.accent,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    error: AppColors.negative,
  );

  final base = ThemeData.dark(useMaterial3: true);

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,
    splashColor: Colors.white.withValues(alpha: 0.04),
    highlightColor: Colors.transparent,
    dividerColor: AppColors.border,
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: AppColors.text,
    ),
  );
}

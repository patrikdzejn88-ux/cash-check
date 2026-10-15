/// Форматирование сумм вручную, без зависимости от локали устройства —
/// приложение офлайн и должно выглядеть одинаково везде.
library;

const String kCurrencySuffix = 'kr';

String formatMoney(double value, {bool withSuffix = true}) {
  final negative = value < 0;
  final abs = value.abs();
  final whole = abs.truncate();
  final cents = ((abs - whole) * 100).round();

  final digits = whole.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('\u2009'); // тонкий пробел — разряды не «разваливаются»
    }
    buffer.write(digits[i]);
  }

  var result = buffer.toString();
  if (cents != 0) {
    result = '$result,${cents.toString().padLeft(2, '0')}';
  }
  if (negative) result = '\u2212$result';
  return withSuffix ? '$result\u2009$kCurrencySuffix' : result;
}

/// Принимает и «12,50», и «12.50», и «1 200».
double? parseAmount(String raw) {
  final cleaned = raw
      .replaceAll('\u2009', '')
      .replaceAll(' ', '')
      .replaceAll(',', '.');
  if (cleaned.isEmpty) return null;
  final parsed = double.tryParse(cleaned);
  if (parsed == null || parsed.isNaN || parsed.isInfinite) return null;
  return parsed;
}

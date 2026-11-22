import 'package:kaiosk/features/price_preview/domain/money.dart';

Money euros(String text) {
  final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
  final cents = int.parse(digits);
  return Money.cents(text.startsWith('−') ? -cents : cents);
}

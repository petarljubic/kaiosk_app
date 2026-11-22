import '../domain/money.dart';

String euro(Money amount) {
  final cents = amount.cents.abs();
  final sign = amount.cents < 0 ? '−' : '';
  final fraction = (cents % 100).toString().padLeft(2, '0');
  return '$sign${_grouped(cents ~/ 100)},$fraction €';
}

String _grouped(int whole) {
  final digits = whole.toString();
  final groups = <String>[];
  for (var end = digits.length; end > 0; end -= 3) {
    groups.insert(0, digits.substring(end < 3 ? 0 : end - 3, end));
  }
  return groups.join('.');
}

import 'money.dart';

final _entry = RegExp(r'^(\d{1,5})(?:[.,](\d{1,2}))?$');

Money? parseOwnPrice(String entry) {
  final match = _entry.firstMatch(entry);
  if (match == null) return null;
  final euros = int.parse(match.group(1)!);
  final cents = int.parse((match.group(2) ?? '0').padRight(2, '0'));
  final price = Money.cents(euros * 100 + cents);
  return price.isZero ? null : price;
}

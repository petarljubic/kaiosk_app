import '../domain/money.dart';
import '../domain/price_preview.dart';
import '../domain/quote.dart';
import '../domain/rates.dart';
import '../domain/settlement.dart';
import 'euro_format.dart';
import 'wordings.dart';

enum Plural { one, few, other }

final class Forms {
  const Forms(this.one, this.other, {String? few}) : few = few ?? other;

  final String one;
  final String few;
  final String other;

  String of(Plural plural) => switch (plural) {
        Plural.one => one,
        Plural.few => few,
        Plural.other => other,
      };
}

final class GuestWording {
  const GuestWording({
    required this.plural,
    required this.adult,
    required this.child,
    required this.smallChild,
    required this.night,
    required this.use,
    required this.vehicles,
    required this.free,
    required this.electricity,
    required this.washingMachine,
    required this.touristTax,
    required this.total,
    required this.reduction,
    required this.adjustedPrice,
    required this.toPay,
  });

  final Plural Function(int count) plural;
  final Forms adult;
  final Forms child;
  final Forms smallChild;
  final Forms night;
  final Forms use;
  final Map<Vehicle, String> vehicles;
  final String free;
  final String electricity;
  final String washingMachine;
  final String touristTax;
  final String total;
  final String reduction;
  final String adjustedPrice;
  final String toPay;

  String label(PriceLine line) => switch (line.item) {
        LineItem.vehicle => vehicles[line.vehicle]!,
        LineItem.adults => _counted(line.basis, adult),
        LineItem.children => _counted(line.basis, child),
        LineItem.smallChildren => _counted(line.basis, smallChild),
        LineItem.electricity => electricity,
        LineItem.washingMachine => washingMachine,
        LineItem.touristTax => touristTax,
      };

  String workedOut(PriceLine line) => switch (line.basis) {
        PeoplePerNight(:final people, :final nights) => '$people × ${_count(nights, night)} × ${euro(line.rate)}',
        PerNight(:final nights) => '${_count(nights, night)} × ${euro(line.rate)}',
        PerUse(:final uses) => '${_count(uses, use)} × ${euro(line.rate)}',
        Free() => free,
      };

  String adjustmentLabel(Adjustment adjustment) => switch (adjustment) {
        PercentTakenOff(:final percent) => '$reduction ${percent.value} %',
        OwnPriceTakenOff() => reduction,
        OwnPriceAdded() => adjustedPrice,
      };

  String adjustmentAmount(Adjustment adjustment) => switch (adjustment) {
        OwnPriceAdded(:final amount) => euro(amount),
        _ => takenOff(adjustment.amount),
      };

  String _counted(Basis basis, Forms forms) {
    final people = switch (basis) {
      PeoplePerNight(:final people) => people,
      Free(:final people) => people,
      _ => 0,
    };
    return _count(people, forms);
  }

  String _count(int count, Forms forms) => '$count ${forms.of(plural(count))}';
}

String takenOff(Money amount) => amount.isZero ? euro(amount) : '−${euro(amount)}';

GuestWording wordingFor(GuestLanguage language) => switch (language) {
      GuestLanguage.english => english,
      GuestLanguage.german => german,
      GuestLanguage.dutch => dutch,
      GuestLanguage.french => french,
      GuestLanguage.polish => polish,
      GuestLanguage.turkish => turkish,
      GuestLanguage.serbian => serbian,
    };

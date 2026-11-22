import 'money.dart';
import 'party.dart';
import 'rates.dart';

enum LineItem {
  vehicle,
  adults,
  children,
  smallChildren,
  electricity,
  washingMachine,
  touristTax,
}

sealed class Basis {
  const Basis();

  int get multiplier;
}

final class PeoplePerNight extends Basis {
  const PeoplePerNight(this.people, this.nights);

  final int people;
  final int nights;

  @override
  int get multiplier => people * nights;
}

final class PerNight extends Basis {
  const PerNight(this.nights);

  final int nights;

  @override
  int get multiplier => nights;
}

final class PerUse extends Basis {
  const PerUse(this.uses);

  final int uses;

  @override
  int get multiplier => uses;
}

final class Free extends Basis {
  const Free(this.people);

  final int people;

  @override
  int get multiplier => 0;
}

final class PriceLine {
  const PriceLine(this.item, this.basis, this.rate, {this.vehicle});

  final LineItem item;
  final Basis basis;
  final Money rate;
  final Vehicle? vehicle;

  Money get amount => rate.times(basis.multiplier);
}

final class Quote {
  const Quote(this.lines);

  final List<PriceLine> lines;

  Money get total => lines.fold(Money.zero, (sum, line) => sum + line.amount);
}

Quote? quoteFor(Party party) {
  if (party.adults == 0) return null;
  return Quote([
    ?_vehicleLine(party),
    PriceLine(LineItem.adults, PeoplePerNight(party.adults, party.nights), Rates.adultPerNight),
    if (party.children > 0)
      PriceLine(LineItem.children, PeoplePerNight(party.children, party.nights), Rates.childPerNight),
    if (party.smallChildren > 0)
      PriceLine(LineItem.smallChildren, Free(party.smallChildren), Money.zero),
    if (party.electricity)
      PriceLine(LineItem.electricity, PerNight(party.nights), Rates.electricityPerNight),
    if (party.washes > 0)
      PriceLine(LineItem.washingMachine, PerUse(party.washes), Rates.washingMachinePerUse),
    PriceLine(
      LineItem.touristTax,
      PeoplePerNight(party.adults + party.children, party.nights),
      Rates.touristTaxPerPersonPerNight,
    ),
  ]);
}

PriceLine? _vehicleLine(Party party) {
  final vehicle = party.vehicle;
  if (vehicle == null) return null;
  return PriceLine(LineItem.vehicle, PerNight(party.nights), vehicle.ratePerNight, vehicle: vehicle);
}

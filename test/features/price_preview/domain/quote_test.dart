import 'package:flutter_test/flutter_test.dart';
import 'package:kaiosk/features/price_preview/domain/party.dart';
import 'package:kaiosk/features/price_preview/domain/quote.dart';
import 'package:kaiosk/features/price_preview/domain/rates.dart';

import '../euros.dart';

Quote quoted(Party party) => quoteFor(party)!;

PriceLine lineFor(Party party, LineItem item) =>
    quoted(party).lines.singleWhere((line) => line.item == item);

const workedExample = Party(
  nights: 3,
  adults: 2,
  children: 1,
  smallChildren: 1,
  vehicle: Vehicle.camper,
  electricity: true,
);

void main() {
  test('Price preview 02 - Children without an adult give no price', () {
    expect(quoteFor(const Party(smallChildren: 3)), isNull);
    expect(quoteFor(const Party(children: 2)), isNull);
    expect(quoteFor(const Party(children: 2, smallChildren: 1)), isNull);
  });

  test('Price preview 03 - The first adult brings the price', () {
    expect(quoted(const Party(adults: 1)).total, euros('8,00 €'));
  });

  test('Price preview 04 - The worked example is itemised line by line', () {
    final lines = quoted(workedExample).lines;
    expect([for (final line in lines) line.item], [
      LineItem.vehicle,
      LineItem.adults,
      LineItem.children,
      LineItem.smallChildren,
      LineItem.electricity,
      LineItem.touristTax,
    ]);
    expect([for (final line in lines) line.amount], [
      euros('33,00 €'),
      euros('42,00 €'),
      euros('12,00 €'),
      euros('0,00 €'),
      euros('9,00 €'),
      euros('9,00 €'),
    ]);
    expect(quoted(workedExample).total, euros('105,00 €'));
  });

  group('Price preview 05 - The total matches the rates to the cent', () {
    final rows = <(Party, String)>[
      (const Party(nights: 1, adults: 1), '8,00 €'),
      (workedExample, '105,00 €'),
      (const Party(nights: 5, adults: 2, vehicle: Vehicle.caravan), '110,00 €'),
      (const Party(nights: 1, adults: 3, vehicle: Vehicle.tent), '27,00 €'),
      (const Party(nights: 2, adults: 1, smallChildren: 5, vehicle: Vehicle.bicycle, washes: 3), '30,00 €'),
      (const Party(nights: 4, adults: 1, children: 2, vehicle: Vehicle.motorbike, electricity: true, washes: 1), '96,00 €'),
      (const Party(nights: 60, adults: 20, children: 20, smallChildren: 20, vehicle: Vehicle.camper, electricity: true, washes: 20), '16.520,00 €'),
    ];
    for (final (party, total) in rows) {
      test(total, () => expect(quoted(party).total, euros(total)));
    }
  });

  group('Price preview 06 - Each input shows in the price before the next one', () {
    const base = Party(adults: 2);
    final rows = <(String, Party, String)>[
      ('electricity', base.withElectricity(true), '19,00 €'),
      ('nights', base.withCount(Counter.nights, 2), '32,00 €'),
      ('vehicle', base.withVehicle(Vehicle.car), '21,00 €'),
      ('washing machine uses', base.withCount(Counter.washes, 1), '20,00 €'),
      ('children aged 7 to 15', base.withCount(Counter.children, 1), '21,00 €'),
      ('children under 7', base.withCount(Counter.smallChildren, 2), '16,00 €'),
      ('adults', base.withCount(Counter.adults, 3), '24,00 €'),
    ];
    test('starting total', () => expect(quoted(base).total, euros('16,00 €')));
    for (final (input, changed, total) in rows) {
      test(input, () => expect(quoted(changed).total, euros(total)));
    }
  });

  test('Price preview 07 - Only the newly chosen vehicle applies', () {
    final party = const Party(nights: 3, adults: 2, vehicle: Vehicle.camper).withVehicle(Vehicle.car);
    final vehicleLines = quoted(party).lines.where((line) => line.item == LineItem.vehicle);
    expect([for (final line in vehicleLines) (line.vehicle, line.amount)], [(Vehicle.car, euros('15,00 €'))]);
    expect(quoted(party).total, euros('63,00 €'));
  });

  test('Price preview 08 - Electricity is charged for every night', () {
    final party = const Party(adults: 2, electricity: true).withCount(Counter.nights, 4);
    final line = lineFor(party, LineItem.electricity);
    expect((line.basis as PerNight).nights, 4);
    expect(line.amount, euros('12,00 €'));
  });

  test('Price preview 09 - Washing machine uses do not depend on the nights', () {
    final party = const Party(adults: 2, washes: 2).withCount(Counter.nights, 5);
    final line = lineFor(party, LineItem.washingMachine);
    expect((line.basis as PerUse).uses, 2);
    expect(line.amount, euros('8,00 €'));
  });

  group('Price preview 10 - The tourist tax is charged per adult and child aged 7 to 15, per night', () {
    final rows = <(Party, int, int, String)>[
      (const Party(nights: 1, adults: 1), 1, 1, '1,00 €'),
      (const Party(nights: 3, adults: 2, children: 1, smallChildren: 1), 3, 3, '9,00 €'),
      (const Party(nights: 2, adults: 1, smallChildren: 5), 1, 2, '2,00 €'),
      (const Party(nights: 60, adults: 20, children: 20, smallChildren: 20), 40, 60, '2.400,00 €'),
    ];
    for (final (party, people, nights, amount) in rows) {
      test(amount, () {
        final taxLines = quoted(party).lines.where((line) => line.item == LineItem.touristTax);
        expect(taxLines, hasLength(1));
        final basis = taxLines.single.basis as PeoplePerNight;
        expect((basis.people, basis.nights), (people, nights));
        expect(taxLines.single.amount, euros(amount));
      });
    }
  });

  test('Price preview 11 - Items with nothing to charge have no line, except children under 7', () {
    final lines = quoted(const Party(adults: 1, smallChildren: 4)).lines;
    expect([for (final line in lines) line.item], [LineItem.adults, LineItem.smallChildren, LineItem.touristTax]);
    final free = lineFor(const Party(adults: 1, smallChildren: 4), LineItem.smallChildren);
    expect((free.basis as Free).people, 4);
    expect(free.amount, euros('0,00 €'));
  });

  group('Price preview 13 - Inputs stay within their limits', () {
    final rows = <(Counter, int, int)>[
      (Counter.nights, 1, -1),
      (Counter.nights, 60, 1),
      (Counter.adults, 0, -1),
      (Counter.adults, 20, 1),
      (Counter.children, 0, -1),
      (Counter.children, 20, 1),
      (Counter.smallChildren, 0, -1),
      (Counter.smallChildren, 20, 1),
      (Counter.washes, 0, -1),
      (Counter.washes, 20, 1),
    ];
    for (final (counter, value, step) in rows) {
      test('${counter.name} $value', () {
        final atLimit = const Party().withCount(counter, value);
        expect(atLimit.withCount(counter, value + step).count(counter), value);
      });
    }
  });
}

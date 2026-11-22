import 'package:flutter_test/flutter_test.dart';
import 'package:kaiosk/features/price_preview/domain/money.dart';
import 'package:kaiosk/features/price_preview/domain/own_price_entry.dart';
import 'package:kaiosk/features/price_preview/domain/party.dart';
import 'package:kaiosk/features/price_preview/domain/price_preview.dart';
import 'package:kaiosk/features/price_preview/domain/rates.dart';
import 'package:kaiosk/features/price_preview/domain/settlement.dart';

import '../euros.dart';

const total101 = PricePreview(party: Party(adults: 12, children: 1));
const total97 = PricePreview(party: Party(adults: 9, children: 5));
const caravanStay = PricePreview(party: Party(nights: 5, adults: 2, vehicle: Vehicle.caravan));

Settlement settled(PricePreview preview) => preview.settlement!;

Money takenOff(String shown) => euros(shown.replaceAll('−', ''));

PricePreview withNights(PricePreview preview, int nights) =>
    preview.withParty(preview.party.withCount(Counter.nights, nights));

void main() {
  group('Price preview 14 - The amount to pay is rounded to the nearest 0,10 €', () {
    final rows = <(String, Percent, String, String)>[
      ('101,00 €', Percent.ten, '−10,10 €', '90,90 €'),
      ('97,00 €', Percent.three, '−2,90 €', '94,10 €'),
      ('101,00 €', Percent.three, '−3,00 €', '98,00 €'),
      ('359,00 €', Percent.three, '−10,80 €', '348,20 €'),
      ('25,00 €', Percent.five, '−1,20 €', '23,80 €'),
      ('97,00 €', Percent.five, '−4,80 €', '92,20 €'),
      ('105,00 €', Percent.ten, '−10,50 €', '94,50 €'),
    ];
    for (final (total, percent, off, toPay) in rows) {
      test('$total ${percent.value} %', () {
        final settlement = settle(euros(total), PercentOff(percent));
        expect(settlement.total, euros(total));
        final adjustment = settlement.adjustment as PercentTakenOff;
        expect((adjustment.percent, adjustment.amount), (percent, takenOff(off)));
        expect(settlement.toPay, euros(toPay));
      });
    }
  });

  test('Price preview 15 - Choosing the active percentage again removes it', () {
    final preview = total101.choosePercent(Percent.ten).choosePercent(Percent.ten);
    expect(preview.reduction, isA<NoReduction>());
    expect(settled(preview).toPay, euros('101,00 €'));
  });

  test('Price preview 16 - A different percentage replaces the active one', () {
    final preview = total101.choosePercent(Percent.ten).choosePercent(Percent.five);
    expect((preview.reduction as PercentOff).percent, Percent.five);
    expect(settled(preview).toPay, euros('96,00 €'));
  });

  test('Price preview 17 - A percentage follows a change of inputs', () {
    final reduced = caravanStay.choosePercent(Percent.ten);
    expect(settled(reduced).total, euros('110,00 €'));
    final settlement = settled(withNights(reduced, 6));
    expect(settlement.total, euros('132,00 €'));
    expect(settlement.adjustment?.amount, takenOff('−13,20 €'));
    expect(settlement.toPay, euros('118,80 €'));
  });

  group('Price preview 18 - An own price lower, equal or higher than the total', () {
    final rows = <(String, Type, String, String)>[
      ('40,00', OwnPriceTakenOff, '−57,00 €', '40,00 €'),
      ('96,99', OwnPriceTakenOff, '−0,01 €', '96,99 €'),
      ('97,00', OwnPriceTakenOff, '0,00 €', '97,00 €'),
      ('110,00', OwnPriceAdded, '13,00 €', '110,00 €'),
    ];
    for (final (ownPrice, kind, difference, toPay) in rows) {
      test(ownPrice, () {
        final settlement = settled(total97.applyOwnPrice(parseOwnPrice(ownPrice)!));
        expect(settlement.total, euros('97,00 €'));
        expect(settlement.adjustment.runtimeType, kind);
        expect(settlement.adjustment?.amount, takenOff(difference));
        expect(settlement.toPay, euros(toPay));
      });
    }
  });

  group('Price preview 19 - Own prices the owner may provide', () {
    final rows = <(String, String)>[
      ('40', '40,00 €'),
      ('40,5', '40,50 €'),
      ('40.50', '40,50 €'),
      ('0,01', '0,01 €'),
      ('1234,50', '1.234,50 €'),
      ('99999,99', '99.999,99 €'),
    ];
    for (final (entry, toPay) in rows) {
      test(entry, () => expect(parseOwnPrice(entry), euros(toPay)));
    }
  });

  group('Price preview 20 - A refused own price leaves the previous amount to pay standing', () {
    const entries = ['40a', '1.234,50', '40.5.0', '40,505', '0', '0,00', '-40', '40 €', '4 0', '100000', '99999,999', ''];
    for (final entry in entries) {
      test('"$entry"', () => expect(parseOwnPrice(entry), isNull));
    }
  });

  test('Price preview 22 - An own price stays fixed when inputs change', () {
    final preview = withNights(caravanStay.applyOwnPrice(euros('40,00 €')), 6);
    expect(settled(preview).total, euros('132,00 €'));
    expect(settled(preview).toPay, euros('40,00 €'));
  });

  test('Price preview 23 - An own price replaces a percentage', () {
    final preview = total101.choosePercent(Percent.ten).applyOwnPrice(euros('40,00 €'));
    expect(preview.reduction, isA<OwnPrice>());
    expect(settled(preview).toPay, euros('40,00 €'));
  });

  test('Price preview 24 - A percentage replaces an own price', () {
    final preview = total101.applyOwnPrice(euros('40,00 €')).choosePercent(Percent.five);
    expect((preview.reduction as PercentOff).percent, Percent.five);
    expect(settled(preview).toPay, euros('96,00 €'));
  });

  group('Price preview 25 - Removing a reduction brings back the calculated total', () {
    final rows = <(String, PricePreview)>[
      ('a 10 % reduction', caravanStay.choosePercent(Percent.ten)),
      ('an own price of 40,00 €', caravanStay.applyOwnPrice(euros('40,00 €'))),
      ('an own price of 120,00 €', caravanStay.applyOwnPrice(euros('120,00 €'))),
    ];
    for (final (name, reduced) in rows) {
      test(name, () {
        final preview = reduced.removeReduction();
        expect(preview.reduction, isA<NoReduction>());
        expect(settled(preview).toPay, euros('110,00 €'));
        expect(preview.party, caravanStay.party);
      });
    }
  });

  group('Price preview 26 - Removing every adult removes the price and its reduction', () {
    const stay = PricePreview(party: Party(nights: 5, adults: 2, children: 1, vehicle: Vehicle.caravan));
    final rows = <(String, PricePreview)>[
      ('a 10 % reduction', stay.choosePercent(Percent.ten)),
      ('an own price of 40,00 €', stay.applyOwnPrice(euros('40,00 €'))),
    ];
    for (final (name, reduced) in rows) {
      test(name, () {
        final empty = reduced.withParty(reduced.party.withCount(Counter.adults, 0));
        expect(empty.settlement, isNull);
        expect(empty.reduction, isA<NoReduction>());
        final again = empty.withParty(empty.party.withCount(Counter.adults, 2));
        expect(settled(again).toPay, euros('135,00 €'));
      });
    }
  });

  test('Price preview 02 - No reduction can apply while no price exists', () {
    const childrenOnly = PricePreview(party: Party(children: 2));
    expect(childrenOnly.choosePercent(Percent.ten).reduction, isA<NoReduction>());
    expect(childrenOnly.applyOwnPrice(euros('40,00 €')).reduction, isA<NoReduction>());
  });

  test('Price preview 35 - The guest language is one choice kept with the party', () {
    final preview = caravanStay.choosePercent(Percent.ten).withLanguage(GuestLanguage.turkish);
    expect(preview.language, GuestLanguage.turkish);
    expect(preview.party, caravanStay.party);
    expect(preview.reduction, isA<PercentOff>());
  });
}

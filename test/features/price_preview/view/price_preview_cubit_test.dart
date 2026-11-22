import 'package:flutter_test/flutter_test.dart';
import 'package:kaiosk/features/price_preview/domain/party.dart';
import 'package:kaiosk/features/price_preview/domain/price_preview.dart';
import 'package:kaiosk/features/price_preview/domain/rates.dart';
import 'package:kaiosk/features/price_preview/domain/settlement.dart';
import 'package:kaiosk/features/price_preview/view/price_preview_cubit.dart';

import '../euros.dart';

PricePreviewCubit cubitWith(Party party) {
  final cubit = PricePreviewCubit();
  for (final counter in Counter.values) {
    cubit.changeCount(counter, party.count(counter));
  }
  cubit
    ..chooseVehicle(party.vehicle)
    ..chooseElectricity(party.electricity);
  return cubit;
}

const workedExample = Party(
  nights: 3,
  adults: 2,
  children: 1,
  smallChildren: 1,
  vehicle: Vehicle.camper,
  electricity: true,
);

const total101 = Party(adults: 12, children: 1);

void main() {
  test('Price preview 01 - Nothing is priced before the owner begins', () {
    final state = PricePreviewCubit().state;
    expect(state.priceExists, isFalse);
    expect(state.preview.party, const Party());
    expect(state.preview.language, GuestLanguage.english);
    expect(state.preview.reduction, isA<NoReduction>());
  });

  test('Price preview 06 - Each input shows in the price before the next one', () {
    final cubit = cubitWith(const Party(adults: 2));
    expect(cubit.state.preview.settlement!.total, euros('16,00 €'));
    cubit.chooseElectricity(true);
    expect(cubit.state.preview.settlement!.total, euros('19,00 €'));
    cubit.chooseVehicle(Vehicle.car);
    expect(cubit.state.preview.settlement!.total, euros('24,00 €'));
  });

  test('Price preview 20 - A refused own price leaves the previous amount to pay standing', () {
    final cubit = cubitWith(total101)..choosePercent(Percent.ten);
    cubit.provideOwnPrice('40a');
    expect(cubit.state.ownPriceRefused, isTrue);
    expect((cubit.state.preview.reduction as PercentOff).percent, Percent.ten);
    expect(cubit.state.preview.settlement!.toPay, euros('90,90 €'));
  });

  test('Price preview 21 - The refusal message goes once an own price is accepted', () {
    final cubit = cubitWith(total101)..provideOwnPrice('1.234,50');
    expect(cubit.state.ownPriceRefused, isTrue);
    cubit.provideOwnPrice('40,00');
    expect(cubit.state.ownPriceRefused, isFalse);
    expect(cubit.state.preview.settlement!.toPay, euros('40,00 €'));
  });

  test('Price preview 02 - The owner cannot provide an own price or show the guests without an adult', () {
    final cubit = cubitWith(const Party(children: 2))
      ..provideOwnPrice('40,00')
      ..showGuests();
    expect(cubit.state.preview.reduction, isA<NoReduction>());
    expect(cubit.state.showingGuests, isFalse);
  });

  test('Price preview 30 - Returning from the guests changes nothing', () {
    final cubit = cubitWith(workedExample)
      ..choosePercent(Percent.ten)
      ..chooseLanguage(GuestLanguage.dutch)
      ..showGuests();
    expect(cubit.state.showingGuests, isTrue);
    cubit.returnFromGuests();
    expect(cubit.state.showingGuests, isFalse);
    expect(cubit.state.preview.party, workedExample);
    expect(cubit.state.preview.language, GuestLanguage.dutch);
    expect(cubit.state.preview.settlement!.toPay, euros('94,50 €'));
  });

  test('Price preview 34 - The guest language chosen while showing the guests is the one choice', () {
    final cubit = cubitWith(workedExample)..showGuests();
    cubit.chooseLanguage(GuestLanguage.french);
    cubit.returnFromGuests();
    expect(cubit.state.preview.language, GuestLanguage.french);
  });

  test('Price preview 37 - Starting again returns every input to its starting value', () {
    final cubit = cubitWith(workedExample)
      ..choosePercent(Percent.ten)
      ..chooseLanguage(GuestLanguage.dutch)
      ..startAgain();
    expect(cubit.state.priceExists, isFalse);
    expect(cubit.state.preview.party, const Party());
    expect(cubit.state.preview.reduction, isA<NoReduction>());
    expect(cubit.state.preview.language, GuestLanguage.english);
  });

  test('Price preview 38 - Going back after a mistaken start again restores the previous party', () {
    final cubit = cubitWith(workedExample)
      ..choosePercent(Percent.ten)
      ..chooseLanguage(GuestLanguage.dutch)
      ..startAgain();
    expect(cubit.state.previousParty, isNotNull);
    cubit.goBack();
    expect(cubit.state.preview.party, workedExample);
    expect((cubit.state.preview.reduction as PercentOff).percent, Percent.ten);
    expect(cubit.state.preview.language, GuestLanguage.dutch);
    expect(cubit.state.preview.settlement!.toPay, euros('94,50 €'));
    expect(cubit.state.previousParty, isNull);
  });

  group('Price preview 39 - The previous party is gone once the next party has an input', () {
    final inputs = <(String, void Function(PricePreviewCubit))>[
      ('1 adult', (cubit) => cubit.changeCount(Counter.adults, 1)),
      ('2 nights', (cubit) => cubit.changeCount(Counter.nights, 2)),
      ('Turkish as guest language', (cubit) => cubit.chooseLanguage(GuestLanguage.turkish)),
    ];
    for (final (name, provide) in inputs) {
      test(name, () {
        final cubit = cubitWith(const Party(nights: 5, adults: 2, vehicle: Vehicle.caravan))..startAgain();
        provide(cubit);
        expect(cubit.state.previousParty, isNull);
        cubit.goBack();
        expect(cubit.state.preview.party.adults, isNot(2));
      });
    }
  });

  test('Price preview 40 - Nothing is kept when the app is opened again', () {
    cubitWith(const Party(nights: 5, adults: 2, vehicle: Vehicle.caravan)).close();
    final reopened = PricePreviewCubit();
    expect(reopened.state.priceExists, isFalse);
    expect(reopened.state.preview.party, const Party());
    expect(reopened.state.previousParty, isNull);
  });
}

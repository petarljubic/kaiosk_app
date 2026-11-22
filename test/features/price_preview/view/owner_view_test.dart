import 'package:flutter_test/flutter_test.dart';
import 'package:kaiosk/features/price_preview/domain/party.dart';
import 'package:kaiosk/features/price_preview/domain/rates.dart';
import 'package:kaiosk/features/price_preview/domain/settlement.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

const hint = 'Add an adult to see the price.';

bool isEnabled(WidgetTester tester, String key) {
  final widget = tester.widget(find.byKey(ValueKey(key)));
  return switch (widget) {
    TextField(:final enabled) => enabled ?? true,
    ButtonStyleButton() => widget.enabled,
    _ => throw StateError('$key is ${widget.runtimeType}'),
  };
}

String shownCount(WidgetTester tester, Counter counter) =>
    (tester.widget(find.byKey(ValueKey('${counter.name}.value'))) as Text).data!;

void main() {
  testWidgets('Price preview 01 - Nothing is priced before the owner begins', (tester) async {
    await pumpPreview(tester);
    expect(find.text(hint), findsOneWidget);
    expect(find.text('Total'), findsNothing);
    expect({for (final counter in Counter.values) counter: shownCount(tester, counter)}, {
      Counter.adults: '0',
      Counter.children: '0',
      Counter.smallChildren: '0',
      Counter.nights: '1',
      Counter.washes: '0',
    });
    expect(tester.widget<ChoiceChip>(find.byKey(const ValueKey('vehicle.none'))).selected, isTrue);
    expect(tester.widget<SwitchListTile>(find.byKey(const ValueKey('electricity'))).value, isFalse);
    expect(tester.widget<ChoiceChip>(find.byKey(const ValueKey('language.english'))).selected, isTrue);
  });

  testWidgets('Price preview 02 - Children without an adult give no price', (tester) async {
    await pumpPreview(tester, const Party(children: 2, smallChildren: 1));
    expect(find.text(hint), findsOneWidget);
    expect(isEnabled(tester, 'ownPrice'), isFalse);
    expect(isEnabled(tester, 'showGuests'), isFalse);
  });

  testWidgets('Price preview 03 - The first adult brings the price', (tester) async {
    await pumpPreview(tester);
    await tapKey(tester, 'adults.more');
    expect(find.text(hint), findsNothing);
    expect(rowTexts(tester).last, 'Total | 8,00 €');
  });

  testWidgets('Price preview 04 - The worked example is itemised line by line', (tester) async {
    await pumpPreview(tester, workedExample);
    expect(rowTexts(tester), [
      'Camper | 3 nights × 11,00 € | 33,00 €',
      '2 adults | 2 × 3 nights × 7,00 € | 42,00 €',
      '1 child (7 to 15) | 1 × 3 nights × 4,00 € | 12,00 €',
      '1 child (under 7) | free | 0,00 €',
      'Electricity | 3 nights × 3,00 € | 9,00 €',
      'Tourist tax | 3 × 3 nights × 1,00 € | 9,00 €',
      'Total | 105,00 €',
    ]);
  });

  testWidgets('Price preview 07 - Only the newly chosen vehicle applies', (tester) async {
    await pumpPreview(tester, const Party(nights: 3, adults: 2, vehicle: Vehicle.camper));
    await tapKey(tester, 'vehicle.car');
    expect(rowTexts(tester), contains('Car | 3 nights × 5,00 € | 15,00 €'));
    expect(rowTexts(tester).where((row) => row.startsWith('Camper')), isEmpty);
    expect(rowTexts(tester).last, 'Total | 63,00 €');
  });

  testWidgets('Price preview 08 - Electricity is charged for every night', (tester) async {
    await pumpPreview(tester, const Party(adults: 2, electricity: true));
    for (var night = 1; night < 4; night++) {
      await tapKey(tester, 'nights.more');
    }
    expect(rowTexts(tester), contains('Electricity | 4 nights × 3,00 € | 12,00 €'));
  });

  testWidgets('Price preview 09 - Washing machine uses do not depend on the nights', (tester) async {
    final cubit = await pumpPreview(tester, const Party(adults: 2, washes: 2));
    cubit.changeCount(Counter.nights, 5);
    await tester.pumpAndSettle();
    expect(rowTexts(tester), contains('Washing machine | 2 uses × 4,00 € | 8,00 €'));
  });

  testWidgets('Price preview 10 - The tourist tax is charged per adult and child aged 7 to 15, per night', (tester) async {
    await pumpPreview(tester, const Party(adults: 1));
    expect(rowTexts(tester), contains('Tourist tax | 1 × 1 night × 1,00 € | 1,00 €'));
  });

  testWidgets('Price preview 11 - Items with nothing to charge have no line, except children under 7', (tester) async {
    await pumpPreview(tester, const Party(adults: 1, smallChildren: 4));
    expect(rowTexts(tester), [
      '1 adult | 1 × 1 night × 7,00 € | 7,00 €',
      '4 children (under 7) | free | 0,00 €',
      'Tourist tax | 1 × 1 night × 1,00 € | 1,00 €',
      'Total | 8,00 €',
    ]);
  });

  testWidgets('Price preview 12 - Free amenities never appear in the price', (tester) async {
    await pumpPreview(tester, workedExample);
    for (final amenity in ['Water', 'Waste disposal', 'Showers', 'Fridge', 'Pool']) {
      expect(find.descendant(of: itemised, matching: find.textContaining(amenity)), findsNothing);
    }
  });

  testWidgets('Price preview 13 - Inputs stay within their limits', (tester) async {
    await pumpPreview(tester, const Party(adults: 20));
    await tapKey(tester, 'nights.fewer');
    await tapKey(tester, 'adults.more');
    await tapKey(tester, 'washes.fewer');
    expect(shownCount(tester, Counter.nights), '1');
    expect(shownCount(tester, Counter.adults), '20');
    expect(shownCount(tester, Counter.washes), '0');
  });

  testWidgets('Price preview 14 - The amount to pay is rounded to the nearest 0,10 €', (tester) async {
    await pumpPreview(tester, const Party(adults: 12, children: 1));
    await tapKey(tester, 'percent.10');
    expect(rowTexts(tester).sublist(rowTexts(tester).length - 3), [
      'Total | 101,00 €',
      'Reduction 10 % | −10,10 €',
      'To pay | 90,90 €',
    ]);
  });

  testWidgets('Price preview 15 - Choosing the active percentage again removes it', (tester) async {
    await pumpPreview(tester, const Party(adults: 12, children: 1));
    await tapKey(tester, 'percent.10');
    await tapKey(tester, 'percent.10');
    expect(rowTexts(tester).last, 'Total | 101,00 €');
  });

  testWidgets('Price preview 18 - An own price lower, equal or higher than the total', (tester) async {
    final cubit = await pumpPreview(tester, const Party(adults: 9, children: 5));
    for (final (entry, line) in [
      ('40,00', 'Reduction | −57,00 €'),
      ('97,00', 'Reduction | 0,00 €'),
      ('110,00', 'Adjusted price | 13,00 €'),
    ]) {
      await tester.enterText(find.byKey(const ValueKey('ownPrice')), entry);
      await tapKey(tester, 'ownPrice.apply');
      expect(rowTexts(tester).sublist(rowTexts(tester).length - 2), [line, 'To pay | $entry €']);
      expect(cubit.state.ownPriceRefused, isFalse);
      expect(find.byType(AlertDialog), findsNothing);
    }
  });

  testWidgets('Price preview 20 - A refused own price leaves the previous amount to pay standing', (tester) async {
    await pumpPreview(tester, const Party(adults: 12, children: 1));
    await tapKey(tester, 'percent.10');
    await tester.enterText(find.byKey(const ValueKey('ownPrice')), '1.234,50');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Enter an amount like 40,00'), findsOneWidget);
    expect(rowTexts(tester).last, 'To pay | 90,90 €');
  });

  testWidgets('Price preview 21 - The refusal message goes once an own price is accepted', (tester) async {
    await pumpPreview(tester, const Party(adults: 12, children: 1));
    await tester.enterText(find.byKey(const ValueKey('ownPrice')), '40a');
    await tapKey(tester, 'ownPrice.apply');
    expect(find.text('Enter an amount like 40,00'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('ownPrice')), '40,00');
    await tapKey(tester, 'ownPrice.apply');
    expect(find.text('Enter an amount like 40,00'), findsNothing);
    expect(rowTexts(tester).last, 'To pay | 40,00 €');
  });

  testWidgets('Price preview 25 - Removing a reduction brings back the calculated total', (tester) async {
    final cubit = await pumpPreview(tester, const Party(nights: 5, adults: 2, vehicle: Vehicle.caravan));
    await tapKey(tester, 'percent.10');
    await tapKey(tester, 'removeReduction');
    expect(rowTexts(tester).last, 'Total | 110,00 €');
    expect(cubit.state.preview.reduction, isA<NoReduction>());
    expect(cubit.state.preview.party, const Party(nights: 5, adults: 2, vehicle: Vehicle.caravan));
  });

  testWidgets('Price preview 26 - Removing every adult removes the price and its reduction', (tester) async {
    await pumpPreview(tester, const Party(nights: 5, adults: 2, children: 1, vehicle: Vehicle.caravan));
    await tapKey(tester, 'percent.10');
    await tapKey(tester, 'adults.fewer');
    await tapKey(tester, 'adults.fewer');
    expect(find.text(hint), findsOneWidget);
    await tapKey(tester, 'adults.more');
    await tapKey(tester, 'adults.more');
    expect(rowTexts(tester).last, 'Total | 135,00 €');
  });

  testWidgets('Price preview 29 - The price cannot be shown to the guests while no price exists', (tester) async {
    await pumpPreview(tester);
    expect(isEnabled(tester, 'showGuests'), isFalse);
  });

  testWidgets('Price preview 35 - Only the itemised price changes language', (tester) async {
    await pumpPreview(tester, const Party(adults: 2));
    await tapKey(tester, 'language.turkish');
    expect(inItemised('Toplam'), findsOneWidget);
    for (final label in ['Adults', 'Nights', 'Vehicle', 'Electricity', 'Show to guests', 'Start again', 'Own price']) {
      expect(find.text(label), findsWidgets, reason: label);
    }
  });

  testWidgets('Price preview 37 - Starting again returns every input to its starting value', (tester) async {
    final cubit = await pumpPreview(tester, workedExample);
    await tapKey(tester, 'percent.10');
    await tapKey(tester, 'language.dutch');
    await tapKey(tester, 'startAgain');
    expect(find.text(hint), findsOneWidget);
    expect(shownCount(tester, Counter.adults), '0');
    expect(shownCount(tester, Counter.nights), '1');
    expect(tester.widget<ChoiceChip>(find.byKey(const ValueKey('language.english'))).selected, isTrue);
    expect(cubit.state.preview.reduction, isA<NoReduction>());
  });

  testWidgets('Price preview 38 - Going back after a mistaken start again restores the previous party', (tester) async {
    await pumpPreview(tester, workedExample);
    await tapKey(tester, 'percent.10');
    await tapKey(tester, 'language.dutch');
    await tapKey(tester, 'startAgain');
    await tapKey(tester, 'goBack');
    expect(rowTexts(tester).last, 'Te betalen | 94,50 €');
    expect(shownCount(tester, Counter.adults), '2');
  });

  testWidgets('Price preview 39 - The previous party is gone once the next party has an input', (tester) async {
    await pumpPreview(tester, const Party(nights: 5, adults: 2, vehicle: Vehicle.caravan));
    await tapKey(tester, 'startAgain');
    expect(find.byKey(const ValueKey('goBack')), findsOneWidget);
    await tapKey(tester, 'adults.more');
    expect(find.byKey(const ValueKey('goBack')), findsNothing);
  });

  testWidgets('Price preview 40 - Nothing is kept when the app is opened again', (tester) async {
    await pumpPreview(tester, const Party(nights: 5, adults: 2, vehicle: Vehicle.caravan));
    await pumpPreview(tester);
    expect(find.text(hint), findsOneWidget);
    expect(find.byKey(const ValueKey('goBack')), findsNothing);
  });
}

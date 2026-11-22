import 'package:flutter_test/flutter_test.dart';
import 'package:kaiosk/features/price_preview/domain/party.dart';
import 'package:kaiosk/features/price_preview/domain/price_preview.dart';
import 'package:kaiosk/features/price_preview/domain/rates.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

Finder get guestView => find.byKey(const ValueKey('guestView'));

double contrast(Color a, Color b) {
  final lighter = a.computeLuminance() > b.computeLuminance() ? a : b;
  final darker = identical(lighter, a) ? b : a;
  return (lighter.computeLuminance() + 0.05) / (darker.computeLuminance() + 0.05);
}

const workedAmounts = ['33,00 €', '42,00 €', '12,00 €', '0,00 €', '9,00 €', '9,00 €', '105,00 €', '−10,50 €', '94,50 €'];

List<String> amountsOf(List<String> rows) => [for (final row in rows) row.split(' | ').last];

Future<void> showWorkedExampleToGuests(WidgetTester tester) async {
  await pumpPreview(tester, workedExample);
  await tapKey(tester, 'percent.10');
  await tapKey(tester, 'showGuests');
}

void main() {
  testWidgets('Price preview 27 - The guests see every line, the reduction and the amount to pay', (tester) async {
    await showWorkedExampleToGuests(tester);
    expect(guestView, findsOneWidget);
    expect(find.byKey(const ValueKey('ownPrice')), findsNothing);
    expect(rowTexts(tester), [
      'Camper | 3 nights × 11,00 € | 33,00 €',
      '2 adults | 2 × 3 nights × 7,00 € | 42,00 €',
      '1 child (7 to 15) | 1 × 3 nights × 4,00 € | 12,00 €',
      '1 child (under 7) | free | 0,00 €',
      'Electricity | 3 nights × 3,00 € | 9,00 €',
      'Tourist tax | 3 × 3 nights × 1,00 € | 9,00 €',
      'Total | 105,00 €',
      'Reduction 10 % | −10,50 €',
      'To pay | 94,50 €',
    ]);
  });

  testWidgets('Price preview 28 - The guests can read the total at arm\'s length in sunlight', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await showWorkedExampleToGuests(tester);
    final headline = find.byKey(const ValueKey('headline'));
    final style = DefaultTextStyle.of(tester.element(headline)).style.merge(tester.widget<Text>(headline).style);
    final background = tester.widget<Scaffold>(find.descendant(of: guestView, matching: find.byType(Scaffold))).backgroundColor!;
    expect(style.fontSize, greaterThanOrEqualTo(64));
    expect(contrast(style.color!, background), greaterThanOrEqualTo(7));
    expect(tester.getSize(headline).height, greaterThanOrEqualTo(64));
  });

  testWidgets('Price preview 30 - Returning from the guests changes nothing', (tester) async {
    final cubit = await pumpPreview(tester, workedExample);
    await tapKey(tester, 'percent.10');
    await tapKey(tester, 'language.dutch');
    await tapKey(tester, 'showGuests');
    await tapKey(tester, 'back');
    expect(guestView, findsNothing);
    expect(cubit.state.preview.party, workedExample);
    expect(cubit.state.preview.language, GuestLanguage.dutch);
    expect(rowTexts(tester).last, 'Te betalen | 94,50 €');
  });

  group('Price preview 31 - The itemised price is worded in the chosen guest language', () {
    final rows = <(GuestLanguage, String, String, String, String, String)>[
      (GuestLanguage.english, '2 adults', 'free', 'Tourist tax', 'Total', 'To pay'),
      (GuestLanguage.german, '2 Erwachsene', 'kostenlos', 'Kurtaxe', 'Gesamt', 'Zu zahlen'),
      (GuestLanguage.dutch, '2 volwassenen', 'gratis', 'Toeristenbelasting', 'Totaal', 'Te betalen'),
      (GuestLanguage.french, '2 adultes', 'gratuit', 'Taxe de séjour', 'Total', 'À payer'),
      (GuestLanguage.polish, '2 dorosłych', 'bezpłatnie', 'Opłata miejscowa', 'Razem', 'Do zapłaty'),
      (GuestLanguage.turkish, '2 yetişkin', 'ücretsiz', 'Turist vergisi', 'Toplam', 'Ödenecek'),
      (GuestLanguage.serbian, '2 одрасле', 'бесплатно', 'Боравишна такса', 'Укупно', 'За плаћање'),
    ];
    for (final (language, adults, free, tax, total, toPay) in rows) {
      testWidgets(language.name, (tester) async {
        await pumpPreview(tester, workedExample);
        await tapKey(tester, 'percent.10');
        await tapKey(tester, 'language.${language.name}');
        for (final shown in [rowTexts(tester), await _guestRows(tester)]) {
          final labels = [for (final row in shown) row.split(' | ').first];
          expect(labels, containsAll([adults, tax, total, toPay]));
          expect(shown, contains(predicate<String>((row) => row.contains('| $free |'))));
        }
      });
    }
  });

  group('Price preview 32 - Every figure is identical in every guest language', () {
    for (final language in GuestLanguage.values.skip(1)) {
      testWidgets(language.name, (tester) async {
        await pumpPreview(tester, workedExample);
        await tapKey(tester, 'percent.10');
        final english = rowTexts(tester);
        await tapKey(tester, 'language.${language.name}');
        final translated = rowTexts(tester);
        expect(amountsOf(translated), workedAmounts);
        String figures(String row) => row.replaceAll(RegExp(r'[^0-9,.×€−]'), '');
        expect([for (final row in translated) figures(row)], [for (final row in english) figures(row)]);
      });
    }
  });

  testWidgets('Price preview 33 - Large amounts keep one format in every guest language', (tester) async {
    await pumpPreview(tester, const Party(
      nights: 60,
      adults: 20,
      children: 20,
      smallChildren: 20,
      vehicle: Vehicle.camper,
      electricity: true,
      washes: 20,
    ));
    await tapKey(tester, 'language.polish');
    expect(rowTexts(tester).last, 'Razem | 16.520,00 €');
  });

  testWidgets('Price preview 34 - The guest language chosen while showing the guests is the one choice', (tester) async {
    await pumpPreview(tester, workedExample);
    await tapKey(tester, 'showGuests');
    await tapKey(tester, 'language.french');
    expect(rowTexts(tester).last, 'Total | 105,00 €');
    expect(rowTexts(tester).first, startsWith('Camping-car'));
    await tapKey(tester, 'back');
    expect(tester.widget<ChoiceChip>(find.byKey(const ValueKey('language.french'))).selected, isTrue);
  });

  testWidgets('Price preview 36 - Every guest language works without a connection', (tester) async {
    await pumpPreview(tester, const Party(adults: 2));
    await tapKey(tester, 'language.serbian');
    expect(rowTexts(tester), [
      '2 одрасле | 2 × 1 ноћ × 7,00 € | 14,00 €',
      'Боравишна такса | 2 × 1 ноћ × 1,00 € | 2,00 €',
      'Укупно | 16,00 €',
    ]);
  });
}

Future<List<String>> _guestRows(WidgetTester tester) async {
  await tapKey(tester, 'showGuests');
  final rows = rowTexts(tester);
  await tapKey(tester, 'back');
  return rows;
}

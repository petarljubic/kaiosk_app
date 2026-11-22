import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaiosk/features/price_preview/domain/party.dart';
import 'package:kaiosk/features/price_preview/domain/rates.dart';
import 'package:kaiosk/features/price_preview/view/price_preview_cubit.dart';
import 'package:kaiosk/features/price_preview/view/price_preview_page.dart';
import 'package:material_ui/material_ui.dart';

const workedExample = Party(
  nights: 3,
  adults: 2,
  children: 1,
  smallChildren: 1,
  vehicle: Vehicle.camper,
  electricity: true,
);

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

Future<PricePreviewCubit> pumpPreview(WidgetTester tester, [Party party = const Party()]) async {
  tester.view.physicalSize = const Size(1400, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final cubit = cubitWith(party);
  await tester.pumpWidget(MaterialApp(
    home: BlocProvider.value(value: cubit, child: const PricePreviewPage()),
  ));
  return cubit;
}

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(ValueKey(key)));
  await tester.tap(find.byKey(ValueKey(key)));
  await tester.pumpAndSettle();
}

Finder get itemised => find.byKey(const ValueKey('itemised'));

List<String> rowTexts(WidgetTester tester) {
  final rows = find.descendant(of: itemised, matching: find.byKey(const ValueKey('row'), skipOffstage: false));
  return [
    for (final row in rows.evaluate())
      [
        for (final text in find.descendant(of: find.byWidget(row.widget), matching: find.byType(Text)).evaluate())
          (text.widget as Text).data ?? '',
      ].join(' | '),
  ];
}

Finder inItemised(String text) => find.descendant(of: itemised, matching: find.text(text));

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/own_price_entry.dart';
import '../domain/party.dart';
import '../domain/price_preview.dart';
import '../domain/rates.dart';
import '../domain/settlement.dart';

final class PricePreviewState {
  const PricePreviewState({
    this.preview = const PricePreview(),
    this.ownPriceRefused = false,
    this.showingGuests = false,
    this.previousParty,
  });

  final PricePreview preview;
  final bool ownPriceRefused;
  final bool showingGuests;
  final PricePreview? previousParty;

  bool get priceExists => preview.quote != null;
}

final class PricePreviewCubit extends Cubit<PricePreviewState> {
  PricePreviewCubit() : super(const PricePreviewState());

  PricePreview get _preview => state.preview;

  void changeCount(Counter counter, int value) =>
      _changeParty(_preview.party.withCount(counter, value));

  void chooseVehicle(Vehicle? vehicle) => _changeParty(_preview.party.withVehicle(vehicle));

  void chooseElectricity(bool wanted) => _changeParty(_preview.party.withElectricity(wanted));

  void chooseLanguage(GuestLanguage language) => _provide(_preview.withLanguage(language));

  void choosePercent(Percent percent) => _provide(_preview.choosePercent(percent));

  void provideOwnPrice(String entry) {
    final price = parseOwnPrice(entry.trim());
    if (!state.priceExists) return;
    if (price == null) {
      emit(_copy(ownPriceRefused: true));
      return;
    }
    _provide(_preview.applyOwnPrice(price), ownPriceRefused: false);
  }

  void removeReduction() => _provide(_preview.removeReduction());

  void showGuests() {
    if (state.priceExists) emit(_copy(showingGuests: true));
  }

  void returnFromGuests() => emit(_copy(showingGuests: false));

  void startAgain() => emit(PricePreviewState(previousParty: _preview));

  void goBack() {
    final previous = state.previousParty;
    if (previous != null) emit(PricePreviewState(preview: previous));
  }

  void _changeParty(Party party) => _provide(_preview.withParty(party));

  void _provide(PricePreview preview, {bool? ownPriceRefused}) => emit(PricePreviewState(
        preview: preview,
        ownPriceRefused: ownPriceRefused ?? state.ownPriceRefused,
        showingGuests: state.showingGuests,
      ));

  PricePreviewState _copy({bool? ownPriceRefused, bool? showingGuests}) => PricePreviewState(
        preview: _preview,
        ownPriceRefused: ownPriceRefused ?? state.ownPriceRefused,
        showingGuests: showingGuests ?? state.showingGuests,
        previousParty: state.previousParty,
      );
}

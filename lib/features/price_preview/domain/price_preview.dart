import 'money.dart';
import 'party.dart';
import 'quote.dart';
import 'settlement.dart';

enum GuestLanguage { english, german, dutch, french, polish, turkish, serbian }

final class PricePreview {
  const PricePreview({
    this.party = const Party(),
    this.reduction = const NoReduction(),
    this.language = GuestLanguage.english,
  });

  final Party party;
  final Reduction reduction;
  final GuestLanguage language;

  Quote? get quote => quoteFor(party);

  Settlement? get settlement {
    final current = quote;
    return current == null ? null : settle(current.total, reduction);
  }

  PricePreview withParty(Party changed) => PricePreview(
        party: changed,
        reduction: quoteFor(changed) == null ? const NoReduction() : reduction,
        language: language,
      );

  PricePreview choosePercent(Percent percent) {
    final current = reduction;
    final isActive = current is PercentOff && current.percent == percent;
    return _reducedBy(isActive ? const NoReduction() : PercentOff(percent));
  }

  PricePreview applyOwnPrice(Money price) => _reducedBy(OwnPrice(price));

  PricePreview removeReduction() => _reducedBy(const NoReduction());

  PricePreview withLanguage(GuestLanguage chosen) =>
      PricePreview(party: party, reduction: reduction, language: chosen);

  PricePreview _reducedBy(Reduction chosen) {
    if (quote == null) return this;
    return PricePreview(party: party, reduction: chosen, language: language);
  }
}

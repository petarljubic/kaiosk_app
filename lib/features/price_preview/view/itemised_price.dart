import 'package:material_ui/material_ui.dart';

import '../domain/price_preview.dart';
import '../domain/quote.dart';
import '../domain/settlement.dart';
import 'euro_format.dart';
import 'guest_wording.dart';

class ItemisedPrice extends StatelessWidget {
  const ItemisedPrice({
    super.key,
    required this.quote,
    required this.settlement,
    required this.language,
    this.forGuests = false,
  });

  final Quote quote;
  final Settlement settlement;
  final GuestLanguage language;
  final bool forGuests;

  @override
  Widget build(BuildContext context) {
    final wording = wordingFor(language);
    final adjustment = settlement.adjustment;
    final base = Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: forGuests ? 24 : 16);
    return DefaultTextStyle(
      style: base,
      child: Column(
        key: const ValueKey('itemised'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final line in quote.lines)
            _Row(label: wording.label(line), workedOut: wording.workedOut(line), amount: euro(line.amount)),
          const Divider(),
          _Row(
            label: wording.total,
            amount: euro(settlement.total),
            headline: adjustment == null ? _headline(base) : null,
          ),
          if (adjustment != null) ...[
            _Row(label: wording.adjustmentLabel(adjustment), amount: wording.adjustmentAmount(adjustment)),
            _Row(label: wording.toPay, amount: euro(settlement.toPay), headline: _headline(base)),
          ],
        ],
      ),
    );
  }

  TextStyle _headline(TextStyle base) => base.copyWith(
        fontSize: forGuests ? 72 : 28,
        fontWeight: FontWeight.bold,
        color: forGuests ? Colors.black : null,
      );
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.amount, this.workedOut, this.headline});

  final String label;
  final String? workedOut;
  final String amount;
  final TextStyle? headline;

  @override
  Widget build(BuildContext context) {
    final emphasis = headline?.copyWith(fontSize: null);
    return Padding(
      key: const ValueKey('row'),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(flex: 3, child: Text(label, style: emphasis)),
          if (workedOut != null) Expanded(flex: 3, child: Text(workedOut!)),
          Text(
            amount,
            key: headline == null ? null : const ValueKey('headline'),
            style: headline,
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }
}

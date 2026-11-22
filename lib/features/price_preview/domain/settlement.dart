import 'money.dart';

enum Percent {
  three(3),
  five(5),
  ten(10);

  const Percent(this.value);

  final int value;
}

sealed class Reduction {
  const Reduction();
}

final class NoReduction extends Reduction {
  const NoReduction();
}

final class PercentOff extends Reduction {
  const PercentOff(this.percent);

  final Percent percent;
}

final class OwnPrice extends Reduction {
  const OwnPrice(this.price);

  final Money price;
}

sealed class Adjustment {
  const Adjustment(this.amount);

  final Money amount;
}

final class PercentTakenOff extends Adjustment {
  const PercentTakenOff(this.percent, super.amount);

  final Percent percent;
}

final class OwnPriceTakenOff extends Adjustment {
  const OwnPriceTakenOff(super.amount);
}

final class OwnPriceAdded extends Adjustment {
  const OwnPriceAdded(super.amount);
}

final class Settlement {
  const Settlement(this.total, this.toPay, this.adjustment);

  final Money total;
  final Money toPay;
  final Adjustment? adjustment;
}

Settlement settle(Money total, Reduction reduction) => switch (reduction) {
      NoReduction() => Settlement(total, total, null),
      PercentOff(:final percent) => _settlePercent(total, percent),
      OwnPrice(:final price) => Settlement(
          total,
          price,
          price > total ? OwnPriceAdded(price - total) : OwnPriceTakenOff(total - price),
        ),
    };

Settlement _settlePercent(Money total, Percent percent) {
  final toPay = _roundToTenCents(total.cents * (100 - percent.value));
  return Settlement(total, toPay, PercentTakenOff(percent, total - toPay));
}

Money _roundToTenCents(int hundredthsOfCents) =>
    Money.cents((hundredthsOfCents + 500) ~/ 1000 * 10);

extension on Money {
  bool operator >(Money other) => compareTo(other) > 0;
}

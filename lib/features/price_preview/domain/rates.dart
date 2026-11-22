import 'money.dart';

enum Vehicle {
  camper(Money.cents(1100)),
  caravan(Money.cents(600)),
  car(Money.cents(500)),
  tent(Money.cents(300)),
  motorbike(Money.cents(200)),
  bicycle(Money.cents(100));

  const Vehicle(this.ratePerNight);

  final Money ratePerNight;
}

abstract final class Rates {
  static const adultPerNight = Money.cents(700);
  static const childPerNight = Money.cents(400);
  static const electricityPerNight = Money.cents(300);
  static const washingMachinePerUse = Money.cents(400);
  static const touristTaxPerPersonPerNight = Money.cents(100);
}

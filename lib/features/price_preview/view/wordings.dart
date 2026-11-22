import '../domain/rates.dart';
import 'guest_wording.dart';

Plural _oneOrOther(int count) => count == 1 ? Plural.one : Plural.other;

Plural _french(int count) => count <= 1 ? Plural.one : Plural.other;

Plural _slavic(int count, {required bool oneEndsInOne}) {
  final lastDigit = count % 10;
  final lastTwo = count % 100;
  final isOne = oneEndsInOne ? lastDigit == 1 && lastTwo != 11 : count == 1;
  if (isOne) return Plural.one;
  final isFew = lastDigit >= 2 && lastDigit <= 4 && (lastTwo < 12 || lastTwo > 14);
  return isFew ? Plural.few : Plural.other;
}

final english = GuestWording(
  plural: _oneOrOther,
  adult: const Forms('adult', 'adults'),
  child: const Forms('child (7 to 15)', 'children (7 to 15)'),
  smallChild: const Forms('child (under 7)', 'children (under 7)'),
  night: const Forms('night', 'nights'),
  use: const Forms('use', 'uses'),
  vehicles: const {
    Vehicle.camper: 'Camper',
    Vehicle.caravan: 'Caravan',
    Vehicle.car: 'Car',
    Vehicle.tent: 'Tent',
    Vehicle.motorbike: 'Motorbike',
    Vehicle.bicycle: 'Bicycle',
  },
  free: 'free',
  electricity: 'Electricity',
  washingMachine: 'Washing machine',
  touristTax: 'Tourist tax',
  total: 'Total',
  reduction: 'Reduction',
  adjustedPrice: 'Adjusted price',
  toPay: 'To pay',
);

final german = GuestWording(
  plural: _oneOrOther,
  adult: const Forms('Erwachsener', 'Erwachsene'),
  child: const Forms('Kind (7 bis 15)', 'Kinder (7 bis 15)'),
  smallChild: const Forms('Kind (unter 7)', 'Kinder (unter 7)'),
  night: const Forms('Nacht', 'Nächte'),
  use: const Forms('Nutzung', 'Nutzungen'),
  vehicles: const {
    Vehicle.camper: 'Wohnmobil',
    Vehicle.caravan: 'Wohnwagen',
    Vehicle.car: 'Auto',
    Vehicle.tent: 'Zelt',
    Vehicle.motorbike: 'Motorrad',
    Vehicle.bicycle: 'Fahrrad',
  },
  free: 'kostenlos',
  electricity: 'Strom',
  washingMachine: 'Waschmaschine',
  touristTax: 'Kurtaxe',
  total: 'Gesamt',
  reduction: 'Rabatt',
  adjustedPrice: 'Angepasster Preis',
  toPay: 'Zu zahlen',
);

final dutch = GuestWording(
  plural: _oneOrOther,
  adult: const Forms('volwassene', 'volwassenen'),
  child: const Forms('kind (7 t/m 15)', 'kinderen (7 t/m 15)'),
  smallChild: const Forms('kind (onder 7)', 'kinderen (onder 7)'),
  night: const Forms('nacht', 'nachten'),
  use: const Forms('keer', 'keer'),
  vehicles: const {
    Vehicle.camper: 'Camper',
    Vehicle.caravan: 'Caravan',
    Vehicle.car: 'Auto',
    Vehicle.tent: 'Tent',
    Vehicle.motorbike: 'Motor',
    Vehicle.bicycle: 'Fiets',
  },
  free: 'gratis',
  electricity: 'Elektriciteit',
  washingMachine: 'Wasmachine',
  touristTax: 'Toeristenbelasting',
  total: 'Totaal',
  reduction: 'Korting',
  adjustedPrice: 'Aangepaste prijs',
  toPay: 'Te betalen',
);

final french = GuestWording(
  plural: _french,
  adult: const Forms('adulte', 'adultes'),
  child: const Forms('enfant (7 à 15 ans)', 'enfants (7 à 15 ans)'),
  smallChild: const Forms('enfant (moins de 7 ans)', 'enfants (moins de 7 ans)'),
  night: const Forms('nuit', 'nuits'),
  use: const Forms('utilisation', 'utilisations'),
  vehicles: const {
    Vehicle.camper: 'Camping-car',
    Vehicle.caravan: 'Caravane',
    Vehicle.car: 'Voiture',
    Vehicle.tent: 'Tente',
    Vehicle.motorbike: 'Moto',
    Vehicle.bicycle: 'Vélo',
  },
  free: 'gratuit',
  electricity: 'Électricité',
  washingMachine: 'Machine à laver',
  touristTax: 'Taxe de séjour',
  total: 'Total',
  reduction: 'Réduction',
  adjustedPrice: 'Prix ajusté',
  toPay: 'À payer',
);

final polish = GuestWording(
  plural: (count) => _slavic(count, oneEndsInOne: false),
  adult: const Forms('dorosły', 'dorosłych'),
  child: const Forms('dziecko (7–15 lat)', 'dzieci (7–15 lat)'),
  smallChild: const Forms('dziecko (poniżej 7 lat)', 'dzieci (poniżej 7 lat)'),
  night: const Forms('noc', 'nocy', few: 'noce'),
  use: const Forms('użycie', 'użyć', few: 'użycia'),
  vehicles: const {
    Vehicle.camper: 'Kamper',
    Vehicle.caravan: 'Przyczepa kempingowa',
    Vehicle.car: 'Samochód',
    Vehicle.tent: 'Namiot',
    Vehicle.motorbike: 'Motocykl',
    Vehicle.bicycle: 'Rower',
  },
  free: 'bezpłatnie',
  electricity: 'Prąd',
  washingMachine: 'Pralka',
  touristTax: 'Opłata miejscowa',
  total: 'Razem',
  reduction: 'Rabat',
  adjustedPrice: 'Cena skorygowana',
  toPay: 'Do zapłaty',
);

final turkish = GuestWording(
  plural: (_) => Plural.other,
  adult: const Forms('yetişkin', 'yetişkin'),
  child: const Forms('çocuk (7–15 yaş)', 'çocuk (7–15 yaş)'),
  smallChild: const Forms('çocuk (7 yaş altı)', 'çocuk (7 yaş altı)'),
  night: const Forms('gece', 'gece'),
  use: const Forms('kullanım', 'kullanım'),
  vehicles: const {
    Vehicle.camper: 'Karavan (motorlu)',
    Vehicle.caravan: 'Çekme karavan',
    Vehicle.car: 'Araba',
    Vehicle.tent: 'Çadır',
    Vehicle.motorbike: 'Motosiklet',
    Vehicle.bicycle: 'Bisiklet',
  },
  free: 'ücretsiz',
  electricity: 'Elektrik',
  washingMachine: 'Çamaşır makinesi',
  touristTax: 'Turist vergisi',
  total: 'Toplam',
  reduction: 'İndirim',
  adjustedPrice: 'Düzeltilmiş fiyat',
  toPay: 'Ödenecek',
);

final serbian = GuestWording(
  plural: (count) => _slavic(count, oneEndsInOne: true),
  adult: const Forms('одрасла', 'одраслих', few: 'одрасле'),
  child: const Forms('дете (7–15)', 'деце (7–15)', few: 'детета (7–15)'),
  smallChild: const Forms('дете (млађе од 7)', 'деце (млађе од 7)', few: 'детета (млађе од 7)'),
  night: const Forms('ноћ', 'ноћи'),
  use: const Forms('коришћење', 'коришћења'),
  vehicles: const {
    Vehicle.camper: 'Камп-возило',
    Vehicle.caravan: 'Камп-приколица',
    Vehicle.car: 'Аутомобил',
    Vehicle.tent: 'Шатор',
    Vehicle.motorbike: 'Мотоцикл',
    Vehicle.bicycle: 'Бицикл',
  },
  free: 'бесплатно',
  electricity: 'Струја',
  washingMachine: 'Веш-машина',
  touristTax: 'Боравишна такса',
  total: 'Укупно',
  reduction: 'Попуст',
  adjustedPrice: 'Коригована цена',
  toPay: 'За плаћање',
);

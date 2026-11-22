import 'rates.dart';

enum Counter {
  adults(0, 20),
  children(0, 20),
  smallChildren(0, 20),
  nights(1, 60),
  washes(0, 20);

  const Counter(this.min, this.max);

  final int min;
  final int max;

  int clamp(int value) => value.clamp(min, max);
}

final class Party {
  const Party({
    this.adults = 0,
    this.children = 0,
    this.smallChildren = 0,
    this.vehicle,
    this.electricity = false,
    this.nights = 1,
    this.washes = 0,
  });

  final int adults;
  final int children;
  final int smallChildren;
  final Vehicle? vehicle;
  final bool electricity;
  final int nights;
  final int washes;

  int count(Counter counter) => switch (counter) {
        Counter.adults => adults,
        Counter.children => children,
        Counter.smallChildren => smallChildren,
        Counter.nights => nights,
        Counter.washes => washes,
      };

  Party withCount(Counter counter, int value) {
    final clamped = counter.clamp(value);
    return _copy(
      adults: counter == Counter.adults ? clamped : adults,
      children: counter == Counter.children ? clamped : children,
      smallChildren: counter == Counter.smallChildren ? clamped : smallChildren,
      nights: counter == Counter.nights ? clamped : nights,
      washes: counter == Counter.washes ? clamped : washes,
    );
  }

  Party withVehicle(Vehicle? chosen) => Party(
        adults: adults,
        children: children,
        smallChildren: smallChildren,
        vehicle: chosen,
        electricity: electricity,
        nights: nights,
        washes: washes,
      );

  Party withElectricity(bool wanted) => _copy(electricity: wanted);

  Party _copy({
    int? adults,
    int? children,
    int? smallChildren,
    bool? electricity,
    int? nights,
    int? washes,
  }) =>
      Party(
        adults: adults ?? this.adults,
        children: children ?? this.children,
        smallChildren: smallChildren ?? this.smallChildren,
        vehicle: vehicle,
        electricity: electricity ?? this.electricity,
        nights: nights ?? this.nights,
        washes: washes ?? this.washes,
      );

  @override
  bool operator ==(Object other) =>
      other is Party &&
      other.adults == adults &&
      other.children == children &&
      other.smallChildren == smallChildren &&
      other.vehicle == vehicle &&
      other.electricity == electricity &&
      other.nights == nights &&
      other.washes == washes;

  @override
  int get hashCode => Object.hash(
        adults,
        children,
        smallChildren,
        vehicle,
        electricity,
        nights,
        washes,
      );
}

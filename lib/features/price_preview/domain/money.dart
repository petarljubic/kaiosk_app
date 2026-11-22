final class Money implements Comparable<Money> {
  const Money.cents(this.cents);

  static const zero = Money.cents(0);

  final int cents;

  bool get isZero => cents == 0;

  Money operator +(Money other) => Money.cents(cents + other.cents);

  Money operator -(Money other) => Money.cents(cents - other.cents);

  Money times(int factor) => Money.cents(cents * factor);

  @override
  int compareTo(Money other) => cents.compareTo(other.cents);

  @override
  bool operator ==(Object other) => other is Money && other.cents == cents;

  @override
  int get hashCode => cents.hashCode;

  @override
  String toString() => 'Money.cents($cents)';
}

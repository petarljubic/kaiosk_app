import 'package:material_ui/material_ui.dart';

import '../domain/party.dart';
import '../domain/price_preview.dart';
import '../domain/rates.dart';

class CountStepper extends StatelessWidget {
  const CountStepper({
    super.key,
    required this.counter,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final Counter counter;
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
          IconButton.outlined(
            key: ValueKey('${counter.name}.fewer'),
            onPressed: value > counter.min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 48,
            child: Text(
              '$value',
              key: ValueKey('${counter.name}.value'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          IconButton.outlined(
            key: ValueKey('${counter.name}.more'),
            onPressed: value < counter.max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add),
          ),
        ],
      );
}

class Choices<T> extends StatelessWidget {
  const Choices({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.keyOf,
    required this.onSelected,
  });

  final List<T> options;
  final T selected;
  final String Function(T option) labelOf;
  final String Function(T option) keyOf;
  final ValueChanged<T>? onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final option in options)
            ChoiceChip(
              key: ValueKey(keyOf(option)),
              label: Text(labelOf(option)),
              selected: option == selected,
              onSelected: onSelected == null ? null : (_) => onSelected!(option),
            ),
        ],
      );
}

const counterLabels = {
  Counter.adults: 'Adults',
  Counter.children: 'Children aged 7 to 15',
  Counter.smallChildren: 'Children under 7',
  Counter.nights: 'Nights',
  Counter.washes: 'Washing machine uses',
};

const vehicleLabels = {
  null: 'None',
  Vehicle.camper: 'Camper',
  Vehicle.caravan: 'Caravan',
  Vehicle.car: 'Car',
  Vehicle.tent: 'Tent',
  Vehicle.motorbike: 'Motorbike',
  Vehicle.bicycle: 'Bicycle',
};

const languageNames = {
  GuestLanguage.english: 'English',
  GuestLanguage.german: 'Deutsch',
  GuestLanguage.dutch: 'Nederlands',
  GuestLanguage.french: 'Français',
  GuestLanguage.polish: 'Polski',
  GuestLanguage.turkish: 'Türkçe',
  GuestLanguage.serbian: 'Српски',
};

class LanguageChoices extends StatelessWidget {
  const LanguageChoices({super.key, required this.selected, required this.onSelected});

  final GuestLanguage selected;
  final ValueChanged<GuestLanguage> onSelected;

  @override
  Widget build(BuildContext context) => Choices<GuestLanguage>(
        options: GuestLanguage.values,
        selected: selected,
        labelOf: (language) => languageNames[language]!,
        keyOf: (language) => 'language.${language.name}',
        onSelected: onSelected,
      );
}

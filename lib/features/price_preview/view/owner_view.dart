import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/party.dart';
import '../domain/rates.dart';
import 'input_controls.dart';
import 'itemised_price.dart';
import 'price_preview_cubit.dart';
import 'reduction_controls.dart';

class OwnerView extends StatelessWidget {
  const OwnerView({super.key, required this.state});

  final PricePreviewState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PricePreviewCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price preview'),
        actions: [
          if (state.previousParty != null)
            TextButton.icon(
              key: const ValueKey('goBack'),
              onPressed: cubit.goBack,
              icon: const Icon(Icons.undo),
              label: const Text('Go back to previous party'),
            ),
          TextButton.icon(
            key: const ValueKey('startAgain'),
            onPressed: cubit.startAgain,
            icon: const Icon(Icons.restart_alt),
            label: const Text('Start again'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final inputs = _PartyInputs(state: state);
          final price = _PricePanel(state: state);
          if (constraints.maxWidth < 900) {
            return ListView(padding: const EdgeInsets.all(16), children: [inputs, const SizedBox(height: 24), price]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: ListView(padding: const EdgeInsets.all(24), children: [inputs])),
              Expanded(child: ListView(padding: const EdgeInsets.all(24), children: [price])),
            ],
          );
        },
      ),
    );
  }
}

class _PartyInputs extends StatelessWidget {
  const _PartyInputs({required this.state});

  final PricePreviewState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PricePreviewCubit>();
    final party = state.preview.party;
    final heading = Theme.of(context).textTheme.titleMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final counter in Counter.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CountStepper(
              counter: counter,
              label: counterLabels[counter]!,
              value: party.count(counter),
              onChanged: (value) => cubit.changeCount(counter, value),
            ),
          ),
        const SizedBox(height: 8),
        Text('Vehicle', style: heading),
        const SizedBox(height: 8),
        Choices<Vehicle?>(
          options: vehicleLabels.keys.toList(),
          selected: party.vehicle,
          labelOf: (vehicle) => vehicleLabels[vehicle]!,
          keyOf: (vehicle) => 'vehicle.${vehicle?.name ?? 'none'}',
          onSelected: cubit.chooseVehicle,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          key: const ValueKey('electricity'),
          contentPadding: EdgeInsets.zero,
          title: Text('Electricity', style: heading),
          value: party.electricity,
          onChanged: cubit.chooseElectricity,
        ),
      ],
    );
  }
}

class _PricePanel extends StatelessWidget {
  const _PricePanel({required this.state});

  final PricePreviewState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PricePreviewCubit>();
    final preview = state.preview;
    final quote = preview.quote;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Guest language', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            LanguageChoices(selected: preview.language, onSelected: cubit.chooseLanguage),
            const SizedBox(height: 16),
            if (quote == null)
              Text('Add an adult to see the price.', style: Theme.of(context).textTheme.titleLarge)
            else
              ItemisedPrice(quote: quote, settlement: preview.settlement!, language: preview.language),
            const SizedBox(height: 16),
            const ReductionControls(),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const ValueKey('showGuests'),
              onPressed: state.priceExists ? cubit.showGuests : null,
              icon: const Icon(Icons.visibility),
              label: const Text('Show to guests'),
            ),
          ],
        ),
      ),
    );
  }
}

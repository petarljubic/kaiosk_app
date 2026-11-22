import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/settlement.dart';
import 'input_controls.dart';
import 'price_preview_cubit.dart';

class ReductionControls extends StatefulWidget {
  const ReductionControls({super.key});

  @override
  State<ReductionControls> createState() => _ReductionControlsState();
}

class _ReductionControlsState extends State<ReductionControls> {
  final _ownPrice = TextEditingController();

  @override
  void dispose() {
    _ownPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PricePreviewCubit>();
    return BlocConsumer<PricePreviewCubit, PricePreviewState>(
      listenWhen: (before, after) => after.preview.reduction is! OwnPrice && !after.ownPriceRefused,
      listener: (context, state) => _ownPrice.clear(),
      builder: (context, state) {
        final reduction = state.preview.reduction;
        final available = state.priceExists;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reduction', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Choices<Percent?>(
              options: Percent.values,
              selected: reduction is PercentOff ? reduction.percent : null,
              labelOf: (percent) => '${percent!.value} %',
              keyOf: (percent) => 'percent.${percent!.value}',
              onSelected: available ? (percent) => cubit.choosePercent(percent!) : null,
            ),
            const SizedBox(height: 12),
            _ownPriceRow(cubit, state),
            if (reduction is! NoReduction)
              TextButton.icon(
                key: const ValueKey('removeReduction'),
                onPressed: cubit.removeReduction,
                icon: const Icon(Icons.close),
                label: const Text('Remove reduction'),
              ),
          ],
        );
      },
    );
  }

  Widget _ownPriceRow(PricePreviewCubit cubit, PricePreviewState state) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              key: const ValueKey('ownPrice'),
              controller: _ownPrice,
              enabled: state.priceExists,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              onSubmitted: cubit.provideOwnPrice,
              decoration: InputDecoration(
                labelText: 'Own price',
                suffixText: '€',
                errorText: state.ownPriceRefused ? 'Enter an amount like 40,00' : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            key: const ValueKey('ownPrice.apply'),
            onPressed: state.priceExists ? () => cubit.provideOwnPrice(_ownPrice.text) : null,
            child: const Text('Apply'),
          ),
        ],
      );
}

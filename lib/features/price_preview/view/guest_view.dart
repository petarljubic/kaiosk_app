import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'input_controls.dart';
import 'itemised_price.dart';
import 'price_preview_cubit.dart';

class GuestView extends StatelessWidget {
  const GuestView({super.key, required this.state});

  final PricePreviewState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PricePreviewCubit>();
    final preview = state.preview;
    return Theme(
      key: const ValueKey('guestView'),
      data: ThemeData(brightness: Brightness.light, colorSchemeSeed: Colors.green),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OutlinedButton.icon(
                      key: const ValueKey('back'),
                      onPressed: cubit.returnFromGuests,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: LanguageChoices(selected: preview.language, onSelected: cubit.chooseLanguage),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: ItemisedPrice(
                      quote: preview.quote!,
                      settlement: preview.settlement!,
                      language: preview.language,
                      forGuests: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

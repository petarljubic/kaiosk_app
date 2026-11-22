import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'guest_view.dart';
import 'owner_view.dart';
import 'price_preview_cubit.dart';

class PricePreviewPage extends StatelessWidget {
  const PricePreviewPage({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<PricePreviewCubit, PricePreviewState>(
        builder: (context, state) => state.showingGuests && state.priceExists
            ? GuestView(state: state)
            : OwnerView(state: state),
      );
}

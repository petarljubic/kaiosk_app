import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'features/price_preview/view/price_preview_cubit.dart';
import 'features/price_preview/view/price_preview_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'kAIosk',
      theme: ThemeData(colorSchemeSeed: Colors.green),
      darkTheme: ThemeData(colorSchemeSeed: Colors.green, brightness: Brightness.dark),
      home: BlocProvider(
        create: (_) => PricePreviewCubit(),
        child: const PricePreviewPage(),
      ),
    );
  }
}

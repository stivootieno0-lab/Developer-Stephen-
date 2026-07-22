import 'package:flutter/material.dart';
import 'app_state.dart';
import 'screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await state.initialise();
  runApp(NrdApp(state: state));
}

class NrdApp extends StatelessWidget {
  const NrdApp({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: state,
        builder: (_, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'National Revival Desk',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff053aa7)),
            inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
          ),
          home: state.token.isEmpty ? LoginPage(state: state) : HomePage(state: state),
        ),
      );
}

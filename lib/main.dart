import 'package:flutter/material.dart';
import 'package:tdd_clean_architecture/features/number_trivia/presentation/pages/number_trivia_page.dart';
import 'package:tdd_clean_architecture/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Just to be on the safe side whenever you have await inside the init
  // just await also the whole init method before running the app
  // and building the UI subsequently
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Trivia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.green.shade800,
          secondary: Colors.green.shade600,
        ),
      ),
      home: const NumberTriviaPage(),
    );
  }
}

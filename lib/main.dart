import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/welcome/welcome_screen.dart';

void main() {
  // ProviderScope is the Riverpod engine that stores all our state.
  runApp(const ProviderScope(child: CreditPassportApp()));
}

class CreditPassportApp extends StatelessWidget {
  const CreditPassportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CreditPassport',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
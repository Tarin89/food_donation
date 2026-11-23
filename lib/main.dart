
import 'package:flutter/material.dart';
import 'package:food_donation/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wfjepjqiducnlkbgvniq.supabase.co',
    publishableKey: 'sb_publishable_JN5mUQOQE3vQ_hA-A-Viqg_te3cnmsH',
  );

  runApp(const FoodShare());
}

class FoodShare extends StatelessWidget {
  const FoodShare({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MealShare',

      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F6F7),

        primaryColor: const Color(0xFFB4D1E0),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB4D1E0),
          primary: const Color(0xFF83AEC5),
          secondary: const Color(0xFFD4D8DC),
          surface: const Color(0xFFFFFFFF),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB4D1E0),
          foregroundColor: Color(0xFF526D7D),
          centerTitle: true,
          elevation: 0,
        ),

        useMaterial3: true,
      ),

      home: const AuthGate(),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:food_donation/login_screen.dart';
//import 'package:food_donation/auth_gate.dart';
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
        scaffoldBackgroundColor: const Color(0xFFF5F8F5),

        primaryColor: const Color(0xFF2E8B57),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E8B57),
          primary: const Color(0xFF2E8B57),
          secondary: const Color(0xFF81C784),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E8B57),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),

        useMaterial3: true,
      ),

      home: const LoginScreen(),
    );
  }
}



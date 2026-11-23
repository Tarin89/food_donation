
import 'package:flutter/material.dart';
import 'package:food_donation/login_screen.dart';
import 'package:food_donation/home_screen.dart';
import 'package:food_donation/guest_mode.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return ValueListenableBuilder<bool>(
      valueListenable: guestMode,
      builder: (context, isGuest, child) {
        if (isGuest && supabase.auth.currentSession == null) {
          return const HomeScreen();
        }

        return StreamBuilder<AuthState>(
          stream: supabase.auth.onAuthStateChange,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                supabase.auth.currentSession == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final session =
                snapshot.data?.session ?? supabase.auth.currentSession;

            if (session != null) {
              return const HomeScreen();
            } else {
              return const LoginScreen();
            }
          },
        );
      },
    );
  }
}

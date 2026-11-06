import 'package:flutter/material.dart';
import 'package:food_donation/register_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  final supabase = Supabase.instance.client;

 
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful!'),
          backgroundColor: Colors.green,
        ),
      );


    } on AuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong!'),
        ),
      );

    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                
                const Icon(
                  Icons.volunteer_activism,
                  size: 85,
                  color: Color(0xFF2E8B57),
                ),

                const SizedBox(height: 15),

               
                const Text(
                  'MealShare',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E8B57),
                  ),
                ),

                const SizedBox(height: 8),

                // Tagline
                const Text(
                  'Share Food, Spread Happiness',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 28),

               
                Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                    ),

                    child: Card(
                      elevation: 6,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(20),

                        child: Form(
                          key: _formKey,

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,

                            children: [

                              const Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              const Text(
                                'Login to continue helping others.',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 22),

                              
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,

                                decoration: InputDecoration(
                                  labelText: 'Email Address',
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                  ),

                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),

                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }

                                  final emailRegex = RegExp(
                                    r'^[\w.+-]+@[\w-]+\.[\w.-]+$',
                                  );

                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return 'Enter a valid email address';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 15),

                            
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,

                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                  ),

                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),

                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword =
                                            !_obscurePassword;
                                      });
                                    },
                                  ),

                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),

                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }

                                  if (value.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 22),

                              
                              SizedBox(
                                height: 48,

                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF2E8B57),
                                    foregroundColor: Colors.white,

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),

                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          'Login',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  const Text(
                                    "Don't have an account?",
                                    style: TextStyle(fontSize: 13),
                                  ),

                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterScreen(),
                                        ),
                                      );
                                    },

                                    child: const Text(
                                      'Register',
                                      style: TextStyle(
                                        color: Color(0xFF2E8B57),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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
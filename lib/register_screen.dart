
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'Donor';

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final supabase = Supabase.instance.client;

  // Baby Blue & Soft Grey Theme
  static const Color primaryBlue = Color(0xFFB4D1E0);
  static const Color buttonBlue = Color(0xFF83AEC5);
  static const Color backgroundColor = Color(0xFFF5F6F7);
  static const Color softGrey = Color(0xFFD4D8DC);
  static const Color textColor = Color(0xFF526D7D);

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),

        data: {
          'full_name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': _selectedRole,
        },
      );

      if (!mounted) return;

      if (response.session != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration Successful!'),
            backgroundColor: buttonBlue,
          ),
        );

        Navigator.pop(context);

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify your email address.'),
            backgroundColor: buttonBlue,
          ),
        );

        Navigator.pop(context);
      }

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
          content: Text('Registration failed!'),
          backgroundColor: Colors.red,
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: textColor,
        elevation: 0,
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const Icon(
                  Icons.volunteer_activism,
                  size: 70,
                  color: buttonBlue,
                ),

                const SizedBox(height: 12),

                const Text(
                  'MealShare',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Join MealShare!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 25),

                Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                    ),

                    child: Card(
                      elevation: 5,
                      color: Colors.white,
                      shadowColor: softGrey.withValues(alpha: 0.6),
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
                                'Create Your Account',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),

                              const SizedBox(height: 6),

                              const Text(
                                'Fill in the details to get started.',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 22),

                              // Full Name
                              TextFormField(
                                controller: _nameController,

                                decoration: _decoration(
                                  'Full Name',
                                  Icons.person_outline,
                                ),

                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Please enter your name';
                                  }

                                  if (!RegExp(r'^[a-zA-Z ]+$')
                                      .hasMatch(value.trim())) {
                                    return 'Only letters are allowed';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 15),

                              // Email
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,

                                decoration: _decoration(
                                  'Email Address',
                                  Icons.email_outlined,
                                ),

                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }

                                  if (!RegExp(
                                    r'^[\w.+-]+@[\w-]+\.[\w.-]+$',
                                  ).hasMatch(value.trim())) {
                                    return 'Enter a valid email address';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 15),

                              // Phone Number
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,

                                decoration: _decoration(
                                  'Phone Number',
                                  Icons.phone_outlined,
                                ),

                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Please enter your phone number';
                                  }

                                  if (!RegExp(r'^01[3-9]\d{8}$')
                                      .hasMatch(value.trim())) {
                                    return 'Enter a valid BD phone number';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 15),

                              // Account Type
                              DropdownButtonFormField<String>(
                                initialValue: _selectedRole,

                                decoration: _decoration(
                                  'Account Type',
                                  Icons.account_circle_outlined,
                                ),

                                items: const [
                                  DropdownMenuItem(
                                    value: 'Donor',
                                    child: Text('Donor - Donate Food'),
                                  ),

                                  DropdownMenuItem(
                                    value: 'Receiver',
                                    child: Text('Receiver - Request Food'),
                                  ),
                                ],

                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedRole = value;
                                    });
                                  }
                                },
                              ),

                              const SizedBox(height: 15),

                              // Password
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,

                                decoration: _decoration(
                                  'Password',
                                  Icons.lock_outline,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: buttonBlue,
                                    ),

                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword =
                                            !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),

                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }

                                  final passwordRegex = RegExp(
                                    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$',
                                  );

                                  if (!passwordRegex.hasMatch(value)) {
                                    return 'Use uppercase, lowercase, number and symbol (8+ chars)';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 15),

                              // Confirm Password
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,

                                decoration: _decoration(
                                  'Confirm Password',
                                  Icons.lock_reset,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: buttonBlue,
                                    ),

                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),

                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }

                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 22),

                              // Create Account Button
                              SizedBox(
                                height: 48,

                                child: ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : _register,

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: buttonBlue,
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
                                          'Create Account',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Login Navigation
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  const Flexible(
                                    child: Text(
                                      'Already have an account?',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),

                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },

                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                        color: buttonBlue,
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

  // Input Decoration
  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,

      prefixIcon: Icon(
        icon,
        color: buttonBlue,
      ),

      filled: true,
      fillColor: backgroundColor,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: softGrey,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: buttonBlue,
          width: 2,
        ),
      ),
    );
  }
}

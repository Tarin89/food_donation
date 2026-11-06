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
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify your email address.'),
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
      backgroundColor: const Color(0xFFF5F8F5),

      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
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
                  color: Color.fromARGB(255, 46, 139, 87),
                ),

                const SizedBox(height: 12),

                
                const Text(
                  'MealShare',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E8B57),
                  ),
                ),

                const SizedBox(height: 6),

                
                const Text(
                  'Join MealShare!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
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
                                'Create Your Account',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
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

                              
                              SizedBox(
                                height: 48,

                                child: ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : _register,

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
                                          'Create Account',
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

  
  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

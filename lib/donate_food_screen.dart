
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DonateFoodScreen extends StatefulWidget {
  const DonateFoodScreen({super.key});

  @override
  State<DonateFoodScreen> createState() => _DonateFoodScreenState();
}

class _DonateFoodScreenState extends State<DonateFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  final _foodNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isLoading = false;

  final supabase = Supabase.instance.client;

  // Theme Colors
  static const Color primaryBlue = Color(0xFFB4D1E0);
  static const Color buttonBlue = Color(0xFF83AEC5);
  static const Color backgroundColor = Color(0xFFF5F6F7);
  static const Color textColor = Color(0xFF526D7D);

  // Submit Food
  Future<void> _donateFood() async {
    if (!_formKey.currentState!.validate()) return;

    final user = supabase.auth.currentUser;

    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await supabase.from('foods').insert({
        'donor_id': user.id,
        'food_name': _foodNameController.text.trim(),
        'quantity': _quantityController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food donated successfully!'),
          backgroundColor: buttonBlue,
        ),
      );

      Navigator.pop(context);

    } on PostgrestException catch (e) {
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
    _foodNameController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text(
          'Donate Food',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        foregroundColor: textColor,
        elevation: 0,
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1050,
                ),

                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 28,
                  ),

                  child: Form(
                    key: _formKey,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        // Header Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 28,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFB4D1E0),
                                Color(0xFFDCEAF1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(22),
                          ),

                          child: Column(
                            children: [
                              Container(
                                height: 85,
                                width: 85,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(
                                    alpha: 0.8,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.volunteer_activism,
                                  size: 43,
                                  color: buttonBlue,
                                ),
                              ),

                              const SizedBox(height: 16),

                              const Text(
                                'Share Food, Spread Happiness',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),

                              const SizedBox(height: 9),

                              const Text(
                                'Your extra food can make someone smile.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Food Information Card
                        Card(
                          color: Colors.white,
                          elevation: 3,
                          shadowColor: Colors.black12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                            side: const BorderSide(
                              color: Color(0xFFE8EDF0),
                            ),
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(30),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [

                                const Row(
                                  children: [
                                    Icon(
                                      Icons.restaurant_menu,
                                      color: buttonBlue,
                                      size: 28,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Food Information',
                                      style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                const Text(
                                  'Please provide the details of the food.',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // Food Name
                                TextFormField(
                                  controller: _foodNameController,
                                  decoration: _decoration(
                                    'Food Name',
                                    Icons.restaurant,
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Please enter food name';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 22),

                                // Quantity
                                TextFormField(
                                  controller: _quantityController,
                                  decoration: _decoration(
                                    'Quantity (e.g. 5 plates)',
                                    Icons.shopping_basket_outlined,
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Please enter quantity';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 22),

                                // Description
                                TextFormField(
                                  controller: _descriptionController,
                                  maxLines: 4,
                                  decoration: _decoration(
                                    'Food Description',
                                    Icons.description_outlined,
                                  ),
                                ),

                                const SizedBox(height: 22),

                                // Location
                                TextFormField(
                                  controller: _locationController,
                                  decoration: _decoration(
                                    'Pickup Location',
                                    Icons.location_on_outlined,
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Please enter pickup location';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 32),

                                // Submit Button
                                SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _donateFood,

                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: buttonBlue,
                                      foregroundColor: Colors.white,
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),

                                    child: _isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.volunteer_activism,
                                                size: 22,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Submit Donation',
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Bottom Message
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF2F6),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite,
                                color: buttonBlue,
                                size: 21,
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  'Every donation makes a difference!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 20,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFD4D8DC),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: buttonBlue,
          width: 2,
        ),
      ),
    );
  }
}

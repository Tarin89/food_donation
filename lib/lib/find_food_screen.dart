
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:food_donation/guest_mode.dart';

class FindFoodScreen extends StatefulWidget {
  const FindFoodScreen({super.key});

  @override
  State<FindFoodScreen> createState() => _FindFoodScreenState();
}

class _FindFoodScreenState extends State<FindFoodScreen> {
  final supabase = Supabase.instance.client;

  static const Color primaryBlue = Color(0xFFB4D1E0);
  static const Color buttonBlue = Color(0xFF83AEC5);
  static const Color backgroundColor = Color(0xFFF5F6F7);
  static const Color textColor = Color(0xFF526D7D);

  final Set<String> requestingFoods = {};

  late Future<List<Map<String, dynamic>>> foodsFuture;

  @override
  void initState() {
    super.initState();
    foodsFuture = _getFoods();
  }

  Future<List<Map<String, dynamic>>> _getFoods() async {
    final response = await supabase
        .from('foods')
        .select()
        .eq('status', 'Available')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _refreshFoods() async {
    final newFuture = _getFoods();

    setState(() {
      foodsFuture = newFuture;
    });

    await newFuture;
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: buttonBlue,
      ),
    );
  }

  // Guest Login Prompt
  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          icon: const Icon(
            Icons.lock_outline,
            color: buttonBlue,
            size: 45,
          ),
          title: const Text(
            'Login Required',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Please login or create an account to request food.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 15,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Not Now',
                style: TextStyle(color: textColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                guestMode.value = false;

                Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Login / Register'),
            ),
          ],
        );
      },
    );
  }

  // Request Food
  Future<void> _requestFood(String foodId) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      showMessage('Please login first!');
      return;
    }

    setState(() {
      requestingFoods.add(foodId);
    });

    try {
      final existingRequest = await supabase
          .from('food_requests')
          .select('id')
          .eq('food_id', foodId)
          .eq('receiver_id', user.id)
          .limit(1);

      if (existingRequest.isNotEmpty) {
        showMessage('You have already requested this food!');
        return;
      }

      await supabase.from('food_requests').insert({
        'food_id': foodId,
        'receiver_id': user.id,
      });

      showMessage('Food request sent successfully!');
    } on PostgrestException catch (error) {
      showMessage(error.message);
    } catch (error) {
      showMessage('Something went wrong!');
    } finally {
      if (mounted) {
        setState(() {
          requestingFoods.remove(foodId);
        });
      }
    }
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: buttonBlue,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 15,
                color: textColor,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _foodCard(Map<String, dynamic> food) {
    final foodId = food['id'].toString();
    final foodName = food['food_name'] ?? 'Unknown Food';
    final quantity = food['quantity'] ?? 'Not specified';
    final description = food['description'] ?? '';
    final location = food['location'] ?? 'Not specified';

    final isRequesting = requestingFoods.contains(foodId);

    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 62,
                  width: 62,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: buttonBlue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    foodName.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _infoRow(
              icon: Icons.inventory_2_outlined,
              title: 'Quantity',
              value: quantity.toString(),
            ),

            const SizedBox(height: 15),

            if (description.toString().isNotEmpty) ...[
              _infoRow(
                icon: Icons.description_outlined,
                title: 'Description',
                value: description.toString(),
              ),
              const SizedBox(height: 15),
            ],

            _infoRow(
              icon: Icons.location_on_outlined,
              title: 'Location',
              value: location.toString(),
            ),

            const SizedBox(height: 22),

            const Divider(
              color: Color(0xFFE5E9EC),
              thickness: 1,
            ),

            const SizedBox(height: 14),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 380) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _availableBadge(),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: _requestButton(
                          foodId,
                          isRequesting,
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    _availableBadge(),
                    const Spacer(),
                    SizedBox(
                      height: 52,
                      child: _requestButton(
                        foodId,
                        isRequesting,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _availableBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F3EA),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Text(
        'Available',
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // Guest and Registered User Request Button
  Widget _requestButton(String foodId, bool isRequesting) {
    final isGuest = guestMode.value;

    return ElevatedButton.icon(
      onPressed: isRequesting
          ? null
          : isGuest
              ? _showLoginPrompt
              : () => _requestFood(foodId),

      icon: isRequesting
          ? const SizedBox(
              width: 17,
              height: 17,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(
              isGuest ? Icons.login : Icons.send,
              size: 19,
            ),

      label: Text(
        isRequesting
            ? 'Sending...'
            : isGuest
                ? 'Login to Request'
                : 'Request Food',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),

      style: ElevatedButton.styleFrom(
        backgroundColor: buttonBlue,
        foregroundColor: Colors.white,
        disabledBackgroundColor: buttonBlue,
        disabledForegroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _emptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 55),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 85,
            color: buttonBlue,
          ),
          SizedBox(height: 20),
          Text(
            'No Food Available!',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Please check again later.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text(
          'Find Food',
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

                child: RefreshIndicator(
                  onRefresh: _refreshFoods,
                  color: buttonBlue,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 28,
                    ),

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
                                  Icons.search,
                                  size: 43,
                                  color: buttonBlue,
                                ),
                              ),

                              const SizedBox(height: 16),

                              const Text(
                                'Find Available Food',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),

                              const SizedBox(height: 9),

                              const Text(
                                'Explore food shared by generous donors.',
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

                        // Available Food Heading
                        const Row(
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              color: buttonBlue,
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Available Food',
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // Food List
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: foodsFuture,
                          builder: (context, snapshot) {

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(50),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: buttonBlue,
                                  ),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.all(25),
                                child: Text(
                                  'Something went wrong!\n${snapshot.error}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }

                            final foods = snapshot.data ?? [];

                            if (foods.isEmpty) {
                              return _emptyState();
                            }

                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: foods.map((food) {
                                return _foodCard(food);
                              }).toList(),
                            );
                          },
                        ),
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
}


import 'package:flutter/material.dart';
import 'package:food_donation/donate_food_screen.dart';
import 'package:food_donation/lib/find_food_screen.dart';
import 'package:food_donation/lib/food_requests_screen.dart';
import 'package:food_donation/my_donations_screen.dart';
import 'package:food_donation/my_requests_screen.dart';
import 'package:food_donation/profile_screen.dart';
import 'package:food_donation/guest_mode.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color primaryBlue = Color(0xFFB4D1E0);
  static const Color buttonBlue = Color(0xFF83AEC5);
  static const Color backgroundColor = Color(0xFFF5F6F7);
  static const Color softGrey = Color(0xFFD4D8DC);
  static const Color textColor = Color(0xFF526D7D);

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: buttonBlue,
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    if (guestMode.value) {
      guestMode.value = false;
    } else {
      await Supabase.instance.client.auth.signOut();
    }
  }

  Widget _actionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.all(3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFEAF2F6),
                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: buttonBlue,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    final isGuest = guestMode.value;

    final userName = isGuest
        ? 'Guest'
        : user?.userMetadata?['full_name'] ?? 'User';

    final role = isGuest
        ? 'Guest'
        : user?.userMetadata?['role'] ?? 'Donor';

    final isDonor = role == 'Donor';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: textColor,
        elevation: 0,
        title: const Text(
          'MealShare',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: Icon(
              isGuest ? Icons.login : Icons.logout,
            ),
            tooltip: isGuest ? 'Exit Guest Mode' : 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 700;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1150,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Welcome Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, $userName!',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isGuest
                                  ? 'Explore available food shared by generous donors.'
                                  : isDonor
                                      ? 'Share your extra food and make someone smile.'
                                      : 'Find available food and connect with donors.',
                              style: const TextStyle(
                                fontSize: 15,
                                color: textColor,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Role: $role',
                                style: const TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Food Banner
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            Image.asset(
                              'assets/images/food_banner.jpg',
                              width: double.infinity,
                              height: isWideScreen ? 250 : 190,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              width: double.infinity,
                              height: isWideScreen ? 250 : 190,
                              color: Colors.black.withValues(alpha: 0.25),
                            ),
                            Positioned(
                              left: 25,
                              right: 25,
                              bottom: 25,
                              child: Text(
                                'Sharing Food,\nCaring for People',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isWideScreen ? 30 : 24,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Quick Actions
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),

                      const SizedBox(height: 18),

                      GridView.count(
                        crossAxisCount: isWideScreen ? 3 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: isWideScreen ? 1.8 : 0.95,

                        children: [

                          // Guest: Find Food
                          // Donor: Donate Food
                          // Receiver: Find Food
                          _actionCard(
                            context: context,
                            title: isGuest
                                ? 'Find Food'
                                : isDonor
                                    ? 'Donate Food'
                                    : 'Find Food',
                            subtitle: isGuest
                                ? 'Explore available food'
                                : isDonor
                                    ? 'Share extra food'
                                    : 'Explore available food',
                            icon: isDonor && !isGuest
                                ? Icons.volunteer_activism
                                : Icons.search,
                            color: buttonBlue,
                            onTap: () {
                              if (isDonor && !isGuest) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const DonateFoodScreen(),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FindFoodScreen(),
                                  ),
                                );
                              }
                            },
                          ),

                          // Registered Users Only
                          if (!isGuest) ...[

                            // My Donations
                            _actionCard(
                              context: context,
                              title: 'My Donations',
                              subtitle: 'View your donations',
                              icon: Icons.inventory_2_outlined,
                              color: const Color(0xFF729DB5),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MyDonationsScreen(),
                                  ),
                                );
                              },
                            ),

                            // Food Requests
                            _actionCard(
                              context: context,
                              title: 'Food Requests',
                              subtitle: 'Manage food requests',
                              icon: Icons.volunteer_activism_outlined,
                              color: const Color(0xFF8CA8B8),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FoodRequestsScreen(),
                                  ),
                                );
                              },
                            ),

                            // Profile
                            _actionCard(
                              context: context,
                              title: 'Profile',
                              subtitle: 'Your account information',
                              icon: Icons.person_outline,
                              color: const Color(0xFF7895A5),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ProfileScreen(),
                                  ),
                                );
                              },
                            ),

                            // My Requests (Receiver Only)
                            if (!isDonor)
                              _actionCard(
                                context: context,
                                title: 'My Requests',
                                subtitle: 'Track your food requests',
                                icon: Icons.receipt_long_outlined,
                                color: const Color(0xFF7895A5),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const MyRequestsScreen(),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 35),

                      // Why MealShare
                      const Text(
                        'Why MealShare?',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),

                      const SizedBox(height: 22),

                      _featureItem(
                        icon: Icons.restaurant,
                        title: 'Reduce Food Waste',
                        description:
                            'Help prevent extra food from going to waste.',
                      ),

                      _featureItem(
                        icon: Icons.favorite_outline,
                        title: 'Help People in Need',
                        description:
                            'Share food with people who need support.',
                      ),

                      _featureItem(
                        icon: Icons.people_outline,
                        title: 'Build a Caring Community',
                        description:
                            'Connect donors and receivers through kindness.',
                      ),

                      const SizedBox(height: 12),

                      // Bottom Message
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF2F6),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          'Every meal shared is a step towards a better community.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),
                    ],
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

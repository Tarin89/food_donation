
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  static const Color primaryBlue = Color(0xFFB4D1E0);
  static const Color buttonBlue = Color(0xFF83AEC5);
  static const Color backgroundColor = Color(0xFFF5F6F7);
  static const Color textColor = Color(0xFF526D7D);

  late Future<List<Map<String, dynamic>>> requestsFuture;

  @override
  void initState() {
    super.initState();
    requestsFuture = getMyRequests();
  }

  Future<List<Map<String, dynamic>>> getMyRequests() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      return [];
    }

    final response = await supabase
        .from('food_requests')
        .select(
          'id, status, created_at, '
          'foods(food_name, quantity, location)',
        )
        .eq('receiver_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> refreshRequests() async {
    final newFuture = getMyRequests();

    setState(() {
      requestsFuture = newFuture;
    });

    await newFuture;
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Accepted':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Requests',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryBlue,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: requestsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: buttonBlue,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }

              final requests = snapshot.data ?? [];

              if (requests.isEmpty) {
                return RefreshIndicator(
                  onRefresh: refreshRequests,
                  color: buttonBlue,
                  child: ListView(
                    children: const [
                      SizedBox(height: 180),
                      Icon(
                        Icons.inbox_outlined,
                        size: 80,
                        color: buttonBlue,
                      ),
                      SizedBox(height: 18),
                      Center(
                        child: Text(
                          'No Food Requests Yet!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Your food requests will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: refreshRequests,
                color: buttonBlue,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1050,
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 28,
                      ),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        final food = request['foods'];

                        final status = request['status'] ?? 'Pending';

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
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEAF2F6),
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.restaurant,
                                        color: buttonBlue,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    Expanded(
                                      child: Text(
                                        food?['food_name'] ??
                                            'Food unavailable',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 22),

                                _infoRow(
                                  Icons.inventory_2_outlined,
                                  'Quantity',
                                  food?['quantity'] ?? 'N/A',
                                ),

                                const SizedBox(height: 15),

                                _infoRow(
                                  Icons.location_on_outlined,
                                  'Location',
                                  food?['location'] ?? 'N/A',
                                ),

                                const SizedBox(height: 22),

                                const Divider(
                                  color: Color(0xFFE5E9EC),
                                  thickness: 1,
                                ),

                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    const Text(
                                      'Request Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: textColor,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 9,
                                      ),
                                      decoration: BoxDecoration(
                                        color: getStatusColor(status)
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(25),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: getStatusColor(status),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: buttonBlue,
          size: 23,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
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
}

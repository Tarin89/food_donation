
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FoodRequestsScreen extends StatefulWidget {
  const FoodRequestsScreen({super.key});

  @override
  State<FoodRequestsScreen> createState() =>
      _FoodRequestsScreenState();
}

class _FoodRequestsScreenState extends State<FoodRequestsScreen> {
  final supabase = Supabase.instance.client;

  static const Color primaryBlue = Color(0xFFB4D1E0);
  static const Color buttonBlue = Color(0xFF83AEC5);
  static const Color backgroundColor = Color(0xFFF5F6F7);
  static const Color textColor = Color(0xFF526D7D);

  late Future<List<Map<String, dynamic>>> requestsFuture;

  final Set<String> updatingRequests = {};

  @override
  void initState() {
    super.initState();
    requestsFuture = _getRequests();
  }

  Future<List<Map<String, dynamic>>> _getRequests() async {
    final user = supabase.auth.currentUser;

    if (user == null) return [];

    final response = await supabase
        .from('food_requests')
        .select(
          'id, status, created_at, receiver_id, '
          'foods!inner(food_name, quantity, location, donor_id)',
        )
        .eq('foods.donor_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _refreshRequests() async {
    final newFuture = _getRequests();

    setState(() {
      requestsFuture = newFuture;
    });

    await newFuture;
  }

  // Accept or Reject a food request
  Future<void> _updateRequest(
    String requestId,
    String newStatus,
  ) async {
    if (updatingRequests.contains(requestId)) return;

    setState(() {
      updatingRequests.add(requestId);
    });

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Please login again.');
      }

      // Update request status in Supabase
      final response = await supabase
          .from('food_requests')
          .update({'status': newStatus})
          .eq('id', requestId)
          .eq('status', 'Pending')
          .select('id, status');

      if (response.isEmpty) {
        throw Exception(
          'Request was not updated. It may no longer be Pending, '
          'or database permission is missing.',
        );
      }

      final updatedStatus = response.first['status'];

      if (updatedStatus != newStatus) {
        throw Exception('Request status update could not be verified.');
      }

      if (!mounted) return;

      // Reload the updated requests
      await _refreshRequests();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Request $newStatus successfully!',
          ),
          backgroundColor: buttonBlue,
        ),
      );
    } on PostgrestException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Database Error: ${error.message}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          updatingRequests.remove(requestId);
        });
      }
    }
  }

  Color _statusColor(String status) {
    if (status == 'Accepted') return Colors.green;
    if (status == 'Rejected') return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Food Requests',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: requestsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
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
                      'Could not load requests:\n${snapshot.error}',
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
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 80,
                        color: buttonBlue,
                      ),
                      SizedBox(height: 18),
                      Text(
                        'No Food Requests Yet!',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'New requests will appear here.',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: buttonBlue,
                onRefresh: _refreshRequests,
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

                        final food =
                            request['foods'] as Map<String, dynamic>;

                        final requestId =
                            request['id'].toString();

                        final status =
                            request['status']?.toString() ?? 'Pending';

                        final isUpdating =
                            updatingRequests.contains(requestId);

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
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
                                        food['food_name'] ??
                                            'Unknown Food',
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
                                  food['quantity']?.toString() ?? 'N/A',
                                ),

                                const SizedBox(height: 15),

                                _infoRow(
                                  Icons.location_on_outlined,
                                  'Location',
                                  food['location']?.toString() ?? 'N/A',
                                ),

                                const SizedBox(height: 15),

                                _infoRow(
                                  Icons.person_outline,
                                  'Receiver ID',
                                  request['receiver_id'].toString(),
                                ),

                                const SizedBox(height: 22),

                                const Divider(
                                  color: Color(0xFFE5E9EC),
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
                                        color: _statusColor(status)
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(25),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: _statusColor(status),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                if (status == 'Pending') ...[
                                  const SizedBox(height: 22),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 50,
                                          child: ElevatedButton.icon(
                                            onPressed: isUpdating
                                                ? null
                                                : () => _updateRequest(
                                                      requestId,
                                                      'Accepted',
                                                    ),
                                            icon: isUpdating
                                                ? const SizedBox(
                                                    height: 18,
                                                    width: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.check_circle_outline,
                                                  ),
                                            label: const Text(
                                              'Accept',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            style:
                                                ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.green.shade600,
                                              foregroundColor: Colors.white,
                                              shape:
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 15),

                                      Expanded(
                                        child: SizedBox(
                                          height: 50,
                                          child: ElevatedButton.icon(
                                            onPressed: isUpdating
                                                ? null
                                                : () => _updateRequest(
                                                      requestId,
                                                      'Rejected',
                                                    ),
                                            icon: const Icon(
                                              Icons.cancel_outlined,
                                            ),
                                            label: const Text(
                                              'Reject',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            style:
                                                ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.red.shade600,
                                              foregroundColor: Colors.white,
                                              shape:
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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


import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyDonationsScreen extends StatefulWidget {
  const MyDonationsScreen({super.key});

  @override
  State<MyDonationsScreen> createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends State<MyDonationsScreen> {
  final supabase = Supabase.instance.client;

  static const Color primaryBlue = Color(0xFFB4D1E0);
  static const Color buttonBlue = Color(0xFF83AEC5);
  static const Color backgroundColor = Color(0xFFF5F6F7);
  static const Color textColor = Color(0xFF526D7D);

  Future<List<Map<String, dynamic>>> _getDonations() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return [];
    }

    final response = await supabase
        .from('foods')
        .select()
        .eq('donor_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // EDIT DONATION
  Future<void> _editDonation(Map<String, dynamic> food) async {
    final foodNameController =
        TextEditingController(text: food['food_name']?.toString() ?? '');

    final quantityController =
        TextEditingController(text: food['quantity']?.toString() ?? '');

    final descriptionController =
        TextEditingController(text: food['description']?.toString() ?? '');

    final locationController =
        TextEditingController(text: food['location']?.toString() ?? '');

    final shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Edit Donation',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _editTextField(
                  controller: foodNameController,
                  label: 'Food Name',
                  icon: Icons.restaurant,
                ),
                const SizedBox(height: 15),
                _editTextField(
                  controller: quantityController,
                  label: 'Quantity',
                  icon: Icons.inventory_2_outlined,
                ),
                const SizedBox(height: 15),
                _editTextField(
                  controller: descriptionController,
                  label: 'Description',
                  icon: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 15),
                _editTextField(
                  controller: locationController,
                  label: 'Location',
                  icon: Icons.location_on_outlined,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBlue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (foodNameController.text.trim().isEmpty ||
                    quantityController.text.trim().isEmpty ||
                    locationController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields.'),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, true);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (shouldUpdate == true) {
      try {
        final user = supabase.auth.currentUser;

        if (user == null) {
          throw Exception('User not logged in');
        }

        await supabase.from('foods').update({
          'food_name': foodNameController.text.trim(),
          'quantity': quantityController.text.trim(),
          'description': descriptionController.text.trim(),
          'location': locationController.text.trim(),
        }).eq('id', food['id']).eq('donor_id', user.id);

        if (!mounted) return;

        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (error) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    foodNameController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    locationController.dispose();
  }

  // DELETE DONATION
  Future<void> _deleteDonation(Map<String, dynamic> food) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Delete Donation?',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${food['food_name']}?',
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      await supabase
          .from('foods')
          .delete()
          .eq('id', food['id'])
          .eq('donor_id', user.id);

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Donation deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // EDIT TEXT FIELD
  Widget _editTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: buttonBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: buttonBlue),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Donations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getDonations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: buttonBlue,
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Something went wrong!',
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            );
          }

          final donations = snapshot.data ?? [];

          if (donations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: buttonBlue,
                  ),
                  SizedBox(height: 18),
                  Text(
                    'No Donations Yet!',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your donated foods will appear here.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 28,
                ),
                itemCount: donations.length,
                itemBuilder: (context, index) {
                  final food = donations[index];

                  final foodName =
                      food['food_name'] ?? 'Unknown Food';
                  final quantity =
                      food['quantity'] ?? 'Not specified';
                  final description =
                      food['description'] ?? '';
                  final location =
                      food['location'] ?? 'Not specified';
                  final status =
                      food['status'] ?? 'Available';

                  final canModify = status == 'Available';

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
                                  borderRadius: BorderRadius.circular(16),
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

                          const SizedBox(height: 22),

                          _buildInfoRow(
                            Icons.inventory_2_outlined,
                            'Quantity',
                            quantity.toString(),
                          ),

                          const SizedBox(height: 15),

                          if (description.toString().isNotEmpty) ...[
                            _buildInfoRow(
                              Icons.description_outlined,
                              'Description',
                              description.toString(),
                            ),
                            const SizedBox(height: 15),
                          ],

                          _buildInfoRow(
                            Icons.location_on_outlined,
                            'Location',
                            location.toString(),
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
                                'Donation Status',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: status == 'Available'
                                      ? const Color(0xFFE4F3EA)
                                      : const Color(0xFFEAF2F6),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  status.toString(),
                                  style: TextStyle(
                                    color: status == 'Available'
                                        ? Colors.green.shade700
                                        : textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // EDIT AND DELETE BUTTONS
                          if (canModify)
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _editDonation(food),
                                    icon: const Icon(Icons.edit_outlined),
                                    label: const Text('Edit'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: buttonBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 13,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _deleteDonation(food),
                                    icon: const Icon(Icons.delete_outline),
                                    label: const Text('Delete'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(
                                        color: Colors.red,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 13,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            const Text(
                              'This donation cannot be edited or deleted '
                              'because its status is not Available.',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(
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

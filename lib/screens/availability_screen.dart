import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healtime_app/models/auth_provider.dart';
import 'package:healtime_app/utils/api_service.dart';
import 'package:provider/provider.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  bool _isLoading = false;
  // Dummy slots for UI demonstration
  final List<String> _slots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
  ];
  final Set<String> _selectedSlots = {'09:00 AM', '10:00 AM'};

  Future<void> _saveAvailability() async {
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();

      // Convert selected slots set into a comma separated string
      final availabilityString = _selectedSlots.join(', ');

      final response = await ApiService.updateAvailability(auth.userId!, {
        'availability': availabilityString,
      });

      if (response != null && mounted) {
        // Update local auth provider state so changes are reflected globally
        final updatedUser = auth.user!.copyWith(
          availability: availabilityString,
        );
        auth.updateUser(updatedUser);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Availability updated successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error updating availability: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Availability'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/doctor-dashboard');
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select your available time slots',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _slots.length,
                itemBuilder: (context, index) {
                  final slot = _slots[index];
                  final isSelected = _selectedSlots.contains(slot);
                  return FilterChip(
                    label: Text(slot),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSlots.add(slot);
                        } else {
                          _selectedSlots.remove(slot);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAvailability,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

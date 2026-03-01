import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healtime_app/models/doctor.dart';
import 'package:provider/provider.dart';
import 'package:healtime_app/theme/app_theme.dart';
import 'package:healtime_app/widgets/appointment_card.dart';
import 'package:healtime_app/widgets/custom_bottom_nav.dart';
import 'package:healtime_app/widgets/doctor_card.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:healtime_app/models/auth_provider.dart';
import 'package:healtime_app/models/appointment.dart';
import 'package:healtime_app/utils/api_service.dart';
import 'package:healtime_app/widgets/quick_action_tile.dart';
import 'package:healtime_app/widgets/safe_image_widget.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  List<Doctor> _doctors = [];
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final auth = context.read<AuthProvider>();
      final List<dynamic> docsData = await ApiService.get('/doctors');
      final List<dynamic> appsData = await ApiService.get(
        '/appointments',
        queryParams: {'userId': auth.userId!, 'role': 'patient'},
      );

      setState(() {
        _doctors = docsData.map((d) => Doctor.fromMap(d)).toList();
        _appointments = appsData.map((a) => Appointment.fromMap(a)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelAppointment(String id) async {
    try {
      await ApiService.patch('/appointments/$id', {'status': 'Cancelled'});
      _fetchData();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Appointment cancelled')));
      }
    } catch (e) {
      debugPrint('Error cancelling appointment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primary.withValues(alpha: 0.2),
                                width: 2,
                              ),
                            ),
                            child: const SafeImageWidget(
                              image:
                                  "https://lh3.googleusercontent.com/aida-public/AB6AXuBCYcTz-z8q2y7zY9z9z9z9z9z9z9z9z9z9z9z9z9z9z9z9z9z9z9z9z9z9z9z9z9z9z9z9",
                              fit: BoxFit.cover,
                              borderRadius: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, ${auth.userName ?? 'User'}!',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'How are you feeling today?',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => auth.logout(),
                            icon: const Icon(Symbols.logout, size: 20),
                            tooltip: 'Logout',
                          ),
                          GestureDetector(
                            onTap: () => context.push('/notifications'),
                            child: Stack(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey[800]
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Symbols.notifications,
                                    size: 22,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                Positioned(
                                  right: 12,
                                  top: 12,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.05),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Symbols.search, color: Colors.grey),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search doctors, clinics...',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          QuickActionTile(
                            icon: Symbols.calendar_add_on,
                            label: 'Book',
                            onTap: () => context.push('/doctor-discovery'),
                            color: AppTheme.primary,
                          ),
                          QuickActionTile(
                            icon: Symbols.description,
                            label: 'Records',
                            onTap: () => context.push('/records'),
                            color: Colors.blue,
                          ),
                          QuickActionTile(
                            icon: Symbols.chat_bubble,
                            label: 'Chat',
                            onTap: () => context.push('/chat'),
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),

                    // Upcoming Appointments
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Upcoming',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/doctor-discovery'),
                            child: const Text(
                              'See All',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_appointments.isNotEmpty)
                      SizedBox(
                        height: 160,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _appointments.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final app = _appointments[index];
                            return Stack(
                              children: [
                                AppointmentCard(
                                  doctor: app.doctor,
                                  date: app.date,
                                  time: app.time,
                                  isPrimary: index == 0,
                                ),
                                if (app.status != 'Cancelled')
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: IconButton(
                                      icon: Icon(
                                        Symbols.cancel,
                                        size: 16,
                                        color: index == 0
                                            ? Colors.white70
                                            : Colors.red[300],
                                      ),
                                      onPressed: () =>
                                          _cancelAppointment(app.id),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'No upcoming appointments',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),

                    // Recommended Doctors
                    const SizedBox(height: 32),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Recommended Doctors',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_doctors.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: _doctors
                              .map(
                                (doctor) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: DoctorCard(
                                    doctor: doctor,
                                    onBook: () =>
                                        context.push('/booking', extra: doctor),
                                    onChat: () => context.push(
                                      '/chat-room',
                                      extra: doctor,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text('No recommendations available'),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:healtime_app/theme/app_theme.dart';
import 'package:healtime_app/widgets/custom_app_bar.dart';
import 'package:healtime_app/widgets/custom_bottom_nav.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:healtime_app/models/auth_provider.dart';
import 'package:healtime_app/models/appointment.dart';
import 'package:healtime_app/utils/api_service.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:healtime_app/models/doctor.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      final auth = context.read<AuthProvider>();
      final String roleStr = auth.role == UserRole.doctor
          ? 'doctor'
          : 'patient';
      final List<dynamic> appsData = await ApiService.get(
        '/appointments',
        queryParams: {'userId': auth.userId!, 'role': roleStr},
      );

      if (mounted) {
        setState(() {
          _appointments = appsData.map((a) => Appointment.fromMap(a)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching agenda: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    try {
      final response = await ApiService.patch('/appointments/$appointmentId', {
        'status': status,
      });
      if (response != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment $status successfully')),
        );
        _fetchAppointments();
      }
    } catch (e) {
      debugPrint('Error updating appointment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Agenda',
        actions: [Icon(Symbols.calendar_today, color: AppTheme.primary)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.calendar_month,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Agenda is Empty',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your scheduled appointments will appear here.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _appointments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final app = _appointments[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            app.date,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              app.status,
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (context.read<AuthProvider>().role ==
                              UserRole.doctor &&
                          app.status == 'Pending') ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () =>
                                  _updateAppointmentStatus(app.id, 'Declined'),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 16,
                              ),
                              label: const Text(
                                'Decline',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _updateAppointmentStatus(app.id, 'Confirmed'),
                              icon: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                              label: const Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Symbols.schedule,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            app.time,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            app.type.contains('Video')
                                ? Symbols.videocam
                                : Symbols.person,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            app.type,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Symbols.medical_services,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.read<AuthProvider>().role ==
                                      UserRole.doctor
                                  ? app.patientName
                                  : app.doctor.name,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Symbols.chat,
                              color: AppTheme.primary,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              final isDoctor =
                                  context.read<AuthProvider>().role ==
                                  UserRole.doctor;
                              final dummyDoc = Doctor(
                                id: isDoctor ? app.patientId : app.doctor.id,
                                name: isDoctor
                                    ? app.patientName
                                    : app.doctor.name,
                                specialty: '',
                                clinic: '',
                                imageUrl: '',
                                rating: 0,
                                reviews: 0,
                                experience: 0,
                                nextAvailable: '',
                              );
                              context.push('/chat-room', extra: dummyDoc);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:healtime_app/models/auth_provider.dart';
import 'package:healtime_app/widgets/stats_tile.dart';
import 'package:healtime_app/widgets/quick_action_tile.dart';
import 'package:healtime_app/models/appointment.dart';
import 'package:go_router/go_router.dart';
import 'package:healtime_app/theme/app_theme.dart';
import 'package:healtime_app/utils/api_service.dart';
import 'package:healtime_app/widgets/custom_bottom_nav.dart';
import 'package:healtime_app/widgets/safe_image_widget.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:healtime_app/models/doctor.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  bool _isLoading = true;
  int _activeAppointments = 0;
  int _pendingRequests = 0;
  int _totalPatients = 0;
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final auth = context.read<AuthProvider>();
      final stats = await ApiService.get(
        '/stats',
        queryParams: {'userId': auth.userId!, 'role': 'doctor'},
      );
      final List<dynamic> appsData = await ApiService.get(
        '/appointments',
        queryParams: {'userId': auth.userId!, 'role': 'doctor'},
      );

      setState(() {
        _activeAppointments = stats['activeAppointments'] ?? 0;
        _pendingRequests = stats['pendingRequests'] ?? 0;
        _totalPatients = stats['totalPatients'] ?? 0;
        _appointments = appsData.map((a) => Appointment.fromMap(a)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching doctor dashboard data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAppointmentStatus(String id, String status) async {
    try {
      await ApiService.patch('/appointments/$id', {'status': status});
      _fetchData();
    } catch (e) {
      debugPrint('Error updating appointment status: $e');
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
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primary.withValues(alpha: 0.2),
                                width: 2,
                              ),
                            ),
                            child: const SafeImageWidget(
                              image:
                                  "https://lh3.googleusercontent.com/aida-public/AB6AXuBWxhXiVEPsDlaSlmnrqrzu5Q__jJyhsG815_f5A5-c4Nc5pwWw-tTw2JdbWoWv0TvTn4P-Q5vvBP9Zsv32tPULk1b34qrkkGMWZF8IHCD8dMYb9s8FekoXjyjSoQ4rC_9M1kdaAIAJbW96pzO47TQVVPnqu_0KJOuH5yhpzMOxUplsDfZ21JBBX0b_J0NqK3JdSsc5u6PuSLueDtmHhPAi2wFziP59H88Ggo8Yhu5Jo-Xms2UqwxwlnzbljGYRoeSK7X_o1z8oLyU",
                              fit: BoxFit.cover,
                              borderRadius: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Welcome back,',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  auth.userName ?? 'Doctor',
                                  style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
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
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey[800]
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Symbols.notifications,
                                    size: 24,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark
                                            ? AppTheme.backgroundDark
                                            : Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Stats Overview
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children: [
                          StatsTile(
                            label: 'Today',
                            value: _activeAppointments.toString(),
                            icon: Symbols.calendar_today,
                            color: AppTheme.primary,
                          ),
                          StatsTile(
                            label: 'Pending',
                            value: _pendingRequests.toString(),
                            icon: Symbols.pending_actions,
                            color: Colors.orange,
                          ),
                          StatsTile(
                            label: 'Total Patients',
                            value: _totalPatients.toString(),
                            icon: Symbols.groups,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),

                    // Quick Actions
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                      child: Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          QuickActionTile(
                            icon: Symbols.event_available,
                            label: 'Availability',
                            onTap: () => context.push('/availability'),
                            color: Colors.blue,
                          ),
                          QuickActionTile(
                            icon: Symbols.folder_shared,
                            label: 'Records',
                            onTap: () => context.push('/records'),
                            color: Colors.orange,
                          ),
                          QuickActionTile(
                            icon: Symbols.videocam,
                            label: 'Consult',
                            onTap: () => context.push('/consult'),
                            color: AppTheme.primary,
                          ),
                        ],
                      ),
                    ),

                    // Today's Schedule
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Today's Schedule",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'View All',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _appointments.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text(
                                  'No appointments scheduled for today',
                                ),
                              ),
                            )
                          : Column(
                              children: _appointments.map((app) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildScheduleCard(
                                    app.id,
                                    app.patientName,
                                    app.time,
                                    app.type,
                                    app.status,
                                    app.status == 'Confirmed'
                                        ? Colors.green
                                        : app.status == 'Pending'
                                        ? Colors.orange
                                        : AppTheme.primary,
                                    isActive: app.status == 'In Progress',
                                    onChat: () {
                                      final dummyDoc = Doctor(
                                        id: app.patientId,
                                        name: app.patientName,
                                        specialty: '',
                                        clinic: '',
                                        imageUrl: '',
                                        rating: 0,
                                        reviews: 0,
                                        experience: 0,
                                        nextAvailable: '',
                                      );
                                      context.push(
                                        '/chat-room',
                                        extra: dummyDoc,
                                      );
                                    },
                                    onViewRecords: () {
                                      context.push(
                                        '/records',
                                        extra: {
                                          'patientId': app.patientId,
                                          'patientName': app.patientName,
                                        },
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildScheduleCard(
    String id,
    String name,
    String time,
    String type,
    String status,
    Color statusColor, {
    bool isActive = false,
    VoidCallback? onChat,
    VoidCallback? onViewRecords,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              Colors.grey[Theme.of(context).brightness == Brightness.dark
                  ? 800
                  : 100]!,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isActive)
            Container(width: 4, height: 48, color: AppTheme.primary),
          if (isActive) const SizedBox(width: 12),
          Column(
            children: [
              Text(
                time.split(' ')[0],
                style: TextStyle(
                  color: isActive ? AppTheme.primary : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                time.split(' ')[1],
                style: TextStyle(
                  color: isActive ? AppTheme.primary : Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onViewRecords != null)
                          IconButton(
                            icon: const Icon(
                              Symbols.folder_shared,
                              color: AppTheme.primary,
                              size: 20,
                            ),
                            padding: const EdgeInsets.only(right: 8),
                            constraints: const BoxConstraints(),
                            onPressed: onViewRecords,
                            tooltip: 'View Records',
                          ),
                        if (onChat != null)
                          IconButton(
                            icon: const Icon(
                              Symbols.chat,
                              color: AppTheme.primary,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: onChat,
                            tooltip: 'Chat',
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      type.contains('Video')
                          ? Symbols.videocam
                          : Symbols.person,
                      color: Colors.grey,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      type,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                if (status == 'Pending')
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              onPressed: () =>
                                  _updateAppointmentStatus(id, 'Confirmed'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                elevation: 0,
                              ),
                              child: const Text(
                                'Confirm',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 32,
                            child: OutlinedButton(
                              onPressed: () =>
                                  _updateAppointmentStatus(id, 'Cancelled'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

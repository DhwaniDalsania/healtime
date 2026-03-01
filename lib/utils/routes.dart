import 'package:go_router/go_router.dart';
import 'package:healtime_app/models/auth_provider.dart';
import 'package:healtime_app/models/doctor.dart';
import 'package:healtime_app/screens/login_signup_screen.dart';
import 'package:healtime_app/screens/patient_dashboard_screen.dart';
import 'package:healtime_app/screens/doctor_discovery_screen.dart';
import 'package:healtime_app/screens/doctor_dashboard_screen.dart';
import 'package:healtime_app/screens/booking_screen.dart';
import 'package:healtime_app/screens/patient_records_screen.dart';
import 'package:healtime_app/screens/availability_screen.dart';
import 'package:healtime_app/screens/chat_list_screen.dart';
import 'package:healtime_app/screens/chat_screen.dart';
import 'package:healtime_app/screens/profile_screen.dart';
import 'package:healtime_app/screens/settings_screen.dart';
import 'package:healtime_app/screens/doctor_profile_screen.dart';
import 'package:healtime_app/screens/agenda_screen.dart';
import 'package:healtime_app/screens/admin_dashboard_screen.dart';
import 'package:healtime_app/screens/edit_profile_screen.dart';
import 'package:healtime_app/screens/notifications_screen.dart';
import 'package:healtime_app/screens/security_screen.dart';
import 'package:healtime_app/screens/help_center_screen.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login';

      if (!authProvider.isAuthenticated && !loggingIn) {
        return '/login';
      }
      if (authProvider.isAuthenticated && loggingIn) {
        if (authProvider.role == UserRole.admin) return '/admin-dashboard';
        return authProvider.role == UserRole.doctor
            ? '/doctor-dashboard'
            : '/patient-dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginSignupScreen(),
      ),
      GoRoute(
        path: '/patient-dashboard',
        builder: (context, state) => const PatientDashboardScreen(),
      ),
      GoRoute(
        path: '/doctor-discovery',
        builder: (context, state) => const DoctorDiscoveryScreen(),
      ),
      GoRoute(
        path: '/doctor-dashboard',
        builder: (context, state) => const DoctorDashboardScreen(),
      ),
      GoRoute(
        path: '/booking',
        builder: (context, state) {
          final doctor = state.extra as Doctor;
          return BookingScreen(doctor: doctor);
        },
      ),
      GoRoute(
        path: '/records',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return PatientRecordsScreen(
            patientId: extras?['patientId'],
            patientName: extras?['patientName'],
          );
        },
      ),
      GoRoute(
        path: '/availability',
        builder: (context, state) => const AvailabilityScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/doctor-profile',
        builder: (context, state) {
          final doctor = state.extra as Doctor;
          return DoctorProfileScreen(doctor: doctor);
        },
      ),
      GoRoute(
        path: '/consult',
        builder: (context, state) =>
            const ChatListScreen(), // Placeholder for consult/chat
      ),
      GoRoute(
        path: '/agenda',
        builder: (context, state) => const AgendaScreen(),
      ),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/chat-room',
        builder: (context, state) {
          final doctor = state.extra as Doctor;
          return ChatScreen(peerId: doctor.id, peerName: doctor.name);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/security',
        builder: (context, state) => const SecurityScreen(),
      ),
      GoRoute(
        path: '/help-center',
        builder: (context, state) => const HelpCenterScreen(),
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:healtime_app/theme/app_theme.dart';
import 'package:material_symbols_icons/symbols.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockNotifications = [
      {
        'title': 'Appointment Confirmed',
        'body': 'Your appointment with Dr. Smith is confirmed for tomorrow.',
        'time': '10 mins ago',
        'icon': Symbols.check_circle,
        'color': AppTheme.primary,
      },
      {
        'title': 'New Lab Results',
        'body': 'Your blood test results are ready to be viewed.',
        'time': '2 hours ago',
        'icon': Symbols.science,
        'color': AppTheme.accent,
      },
      {
        'title': 'System Update',
        'body': 'The app will undergo maintenance tonight at 2 AM.',
        'time': 'Yesterday',
        'icon': Symbols.info,
        'color': AppTheme.secondary,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), centerTitle: true),
      body: mockNotifications.isEmpty
          ? const Center(
              child: Text(
                'No new notifications',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.separated(
              itemCount: mockNotifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notif = mockNotifications[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: (notif['color'] as Color).withValues(
                      alpha: 0.1,
                    ),
                    child: Icon(
                      notif['icon'] as IconData,
                      color: notif['color'] as Color,
                    ),
                  ),
                  title: Text(
                    notif['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(notif['body'] as String),
                  ),
                  trailing: Text(
                    notif['time'] as String,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tapped: ${notif['title']}')),
                    );
                  },
                );
              },
            ),
    );
  }
}

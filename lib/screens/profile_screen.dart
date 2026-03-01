import 'package:flutter/material.dart';
import 'package:healtime_app/models/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/pw/AP1GczM_...',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              auth.userName ?? 'User Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              auth.role?.name.toUpperCase() ?? 'Patient',
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            _buildProfileItem(Symbols.person, 'Account Info', () {
              context.push('/edit-profile');
            }),
            _buildProfileItem(Symbols.notifications, 'Notifications', () {
              context.push('/notifications');
            }),
            _buildProfileItem(Symbols.security, 'Privacy & Security', () {
              context.push('/security');
            }),
            _buildProfileItem(Symbols.help, 'Help Center', () {
              context.push('/help-center');
            }),
            const Divider(height: 48),
            _buildProfileItem(
              Symbols.logout,
              'Logout',
              () => auth.logout(),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      trailing: const Icon(Symbols.chevron_right),
      onTap: onTap,
    );
  }
}

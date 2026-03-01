import 'package:flutter/material.dart';
import 'package:healtime_app/theme/app_theme.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSettingsSection('General', [
            _buildSettingsItem(
              context,
              Symbols.language,
              'Language',
              'English',
            ),
            _buildSettingsItem(
              context,
              Symbols.palette,
              'Theme Mode',
              'System',
            ),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection('Security', [
            _buildSettingsItem(
              context,
              Symbols.lock,
              'Change Password',
              '',
              onTap: () {
                context.push('/security');
              },
            ),
            _buildSettingsItem(
              context,
              Symbols.fingerprint,
              'Biometric Login',
              'Enabled',
              onTap: () {
                context.push('/security');
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection('About', [
            _buildSettingsItem(context, Symbols.info, 'App Version', '1.0.0'),
            _buildSettingsItem(context, Symbols.policy, 'Privacy Policy', ''),
          ]),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value.isNotEmpty)
            Text(
              value,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          const SizedBox(width: 8),
          const Icon(Symbols.chevron_right, size: 16),
        ],
      ),
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('$label settings tapped')));
          },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:healtime_app/theme/app_theme.dart';
import 'package:material_symbols_icons/symbols.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _biometricEnabled = true;
  bool _twoFactorEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Authentication',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Symbols.lock),
            title: const Text('Change Password'),
            trailing: const Icon(Symbols.chevron_right),
            onTap: () {
              // Usually opens a password change dialog or screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Change Password tapped')),
              );
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Biometric Login'),
            secondary: const Icon(Symbols.fingerprint),
            value: _biometricEnabled,
            activeColor: AppTheme.primary,
            onChanged: (val) {
              setState(() {
                _biometricEnabled = val;
              });
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Two-Factor Authentication'),
            secondary: const Icon(Symbols.phonelink_lock),
            value: _twoFactorEnabled,
            activeColor: AppTheme.primary,
            onChanged: (val) {
              setState(() {
                _twoFactorEnabled = val;
              });
            },
          ),
          const SizedBox(height: 32),
          const Text(
            'Data Privacy',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Symbols.analytics),
            title: const Text('Share Analytics'),
            trailing: const Icon(Symbols.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Analytics settings tapped')),
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Symbols.delete_forever, color: Colors.red),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete Account taped')),
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:healtime_app/theme/app_theme.dart';
import 'package:material_symbols_icons/symbols.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'How do I book an appointment?',
        'a':
            'Go to the Discover tab, find a doctor, and tap Book Appointment to select an available time.',
      },
      {
        'q': 'How do I cancel an appointment?',
        'a':
            'You can cancel an appointment from the Home tab. Tap on the upcoming appointment and select Cancel.',
      },
      {
        'q': 'Are my medical records secure?',
        'a':
            'Yes, all your medical records and chat messages are encrypted and stored securely.',
      },
      {
        'q': 'How do I contact my doctor?',
        'a':
            'You can use the Chat feature in the app to securely message your doctor once an appointment is booked.',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Help Center'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          ...faqs.map((faq) {
            return ExpansionTile(
              title: Text(
                faq['q']!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              childrenPadding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
              children: [
                Text(
                  faq['a']!,
                  style: const TextStyle(color: Colors.grey, height: 1.5),
                ),
              ],
            );
          }),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),
          const Text(
            'Still need help?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Support Chat...')),
              );
            },
            icon: const Icon(Symbols.support_agent, color: Colors.white),
            label: const Text(
              'Contact Support',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healtime_app/models/auth_provider.dart';
import 'package:healtime_app/theme/app_theme.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomBottomNavBar({super.key, required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.backgroundDark : Colors.white).withValues(
          alpha: 0.9,
        ),
        border: Border(
          top: BorderSide(color: Colors.grey[isDark ? 800 : 100]!),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 24, top: 12, left: 24, right: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(context, Symbols.home, 'Home', 0),
          _buildNavItem(context, Symbols.calendar_month, 'Agenda', 1),
          _buildFab(context),
          _buildNavItem(context, Symbols.description, 'Reports', 2),
          _buildNavItem(context, Symbols.person, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    final isSelected = currentIndex == index;
    final auth = context.read<AuthProvider>();
    final isDoctor = auth.role == UserRole.doctor;

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(index);
        } else {
          switch (index) {
            case 0:
              context.go(isDoctor ? '/doctor-dashboard' : '/patient-dashboard');
              break;
            case 1:
              context.go('/agenda');
              break;
            case 2:
              context.go('/records');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.primary : Colors.grey[400],
            size: 28,
            fill: isSelected ? 1 : 0,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primary : Colors.grey[400],
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: GestureDetector(
        onTap: () {
          context.go('/chat');
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Symbols.chat, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

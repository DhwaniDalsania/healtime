import 'package:flutter/material.dart';
import 'package:healtime_app/models/doctor.dart';
import 'package:healtime_app/theme/app_theme.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:healtime_app/widgets/safe_image_widget.dart';

class AppointmentCard extends StatelessWidget {
  final Doctor doctor;
  final String date;
  final String time;
  final bool isPrimary;

  const AppointmentCard({
    super.key,
    required this.doctor,
    required this.date,
    required this.time,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrimary ? AppTheme.primary : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isPrimary ? null : Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: (isPrimary ? AppTheme.primary : Colors.black).withValues(
              alpha: 0.1,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isPrimary
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.grey[100]!,
                    width: 2,
                  ),
                ),
                child: SafeImageWidget(
                  image: doctor.imageUrl,
                  fit: BoxFit.cover,
                  borderRadius: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: TextStyle(
                        color: isPrimary ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      doctor.specialty,
                      style: TextStyle(
                        color: isPrimary
                            ? Colors.white.withValues(alpha: 0.8)
                            : Colors.grey[500],
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isPrimary
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey[50]!,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfo(Symbols.calendar_today, date, isPrimary),
                _buildInfo(Symbols.schedule, time, isPrimary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(IconData icon, String text, bool isPrimary) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isPrimary ? Colors.white : Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: isPrimary ? Colors.white : Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

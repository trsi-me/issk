import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
  });

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.secondary, size: 28),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.heading2,
            ),
          ),
        ],
      ),
    );
  }
}

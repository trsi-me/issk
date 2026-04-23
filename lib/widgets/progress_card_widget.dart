import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_radius.dart';
import '../utils/app_text_styles.dart';

/// ملخص بيانات بسيط بدون استخدام Card.
class ProgressCardWidget extends StatelessWidget {
  const ProgressCardWidget({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.heading2,
          ),
        ],
      ),
    );
  }
}

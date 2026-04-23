import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../models/parent_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_radius.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/progress_card_widget.dart';

class ParentDashboardTab extends StatelessWidget {
  const ParentDashboardTab({super.key, required this.parent});

  final ParentModel parent;

  @override
  Widget build(BuildContext context) {
    final db = DatabaseHelper.instance;
    return FutureBuilder<int>(
      future: db.getChildrenForParent(parent.id).then((c) => c.length),
      builder: (context, snap) {
        final n = snap.data ?? 0;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'مرحباً ${parent.name}',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 8),
              if (parent.email != null && parent.email!.trim().isNotEmpty)
                Text(
                  parent.email!,
                  style: AppTextStyles.caption,
                ),
              const SizedBox(height: 24),
              ProgressCardWidget(
                title: 'عدد الأبناء المسجّلين',
                value: '$n',
              ),
              const SizedBox(height: 16),
              Text(
                'من هنا يمكنك متابعة الأبناء، إدارة الحسابات، ومراجعة التقدم والتقارير من الشريط السفلي.',
                style: AppTextStyles.bodyText,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_rounded, color: AppColors.primary, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'يُنصح بمراجعة تقدم الطفل بشكل دوري ومناقشة ما يتعلّمه على الإنترنت.',
                        style: AppTextStyles.bodyText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

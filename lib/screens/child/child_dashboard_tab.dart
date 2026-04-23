import 'package:flutter/material.dart';

import '../../models/child_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_radius.dart';
import '../../utils/app_text_styles.dart';
import 'videos_screen.dart';

/// لوحة الرئيسية للطفل — بطاقات عالية الوضوح.
class ChildDashboardTab extends StatelessWidget {
  const ChildDashboardTab({
    super.key,
    required this.child,
    required this.onNavigateToGames,
    required this.onNavigateToQuizzes,
  });

  final ChildModel child;
  final VoidCallback onNavigateToGames;
  final VoidCallback onNavigateToQuizzes;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'مرحباً ${child.name}',
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'تعلّم كيف تبقى آمناً على الإنترنت من خلال الفيديوهات والألعاب والاختبارات.',
            style: AppTextStyles.bodyText.copyWith(
              height: 1.45,
              color: AppColors.textDark.withValues(alpha: 0.85),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          _DashTile(
            icon: Icons.play_circle_rounded,
            iconColor: AppColors.primary,
            accent: AppColors.secondary,
            title: 'الفيديوهات التعليمية',
            subtitle: 'بحث، تصنيفات، ومواضيع منظّمة في صفحة واحدة',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => VideosScreen(childId: child.id),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _DashTile(
            icon: Icons.extension_rounded,
            iconColor: AppColors.success,
            accent: AppColors.success,
            title: 'الألعاب التعليمية',
            subtitle: 'مستويات متتابعة وتحديات تفاعلية',
            onTap: onNavigateToGames,
          ),
          const SizedBox(height: 14),
          _DashTile(
            icon: Icons.fact_check_rounded,
            iconColor: AppColors.quizOrange,
            accent: AppColors.quizOrange,
            title: 'الاختبارات',
            subtitle: 'أربع مجموعات أسئلة مع شريط تقدّم',
            onTap: onNavigateToQuizzes,
          ),
        ],
      ),
    );
  }
}

class _DashTile extends StatelessWidget {
  const _DashTile({
    required this.icon,
    required this.iconColor,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final outer = BorderRadius.circular(AppRadius.xl);
    return Material(
      color: Colors.white,
      borderRadius: outer,
      elevation: 0,
      child: InkWell(
        borderRadius: outer,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: outer,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.07),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: accent.withValues(alpha: 0.35)),
                ),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.heading2.copyWith(
                        fontSize: 17,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 13,
                        color: AppColors.textDark.withValues(alpha: 0.72),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left,
                color: AppColors.primary.withValues(alpha: 0.65),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

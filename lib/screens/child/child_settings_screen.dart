import 'package:flutter/material.dart';

import '../../models/child_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_radius.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../about/about_project_screen.dart';
import '../home_screen.dart';
import '../settings/privacy_policy_screen.dart';

/// إعدادات الطفل — تسجيل الخروج هنا فقط وليس في شريط التطبيق.
class ChildSettingsScreen extends StatelessWidget {
  const ChildSettingsScreen({super.key, required this.child});

  final ChildModel child;

  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('الإعدادات', style: AppTextStyles.heading1),
          const SizedBox(height: 8),
          Text(
            'إدارة الجلسة والمعلومات العامة',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الطفل المسجّل', style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Text(child.name, style: AppTextStyles.heading2.copyWith(fontSize: 20)),
                      if (child.age != null)
                        Text('العمر: ${child.age}', style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SettingsTile(
            icon: Icons.menu_book_outlined,
            title: 'عن التطبيق',
            subtitle: 'فكرة المشروع والخصوصية',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AboutProjectScreen()),
              );
            },
          ),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'سياسة الخصوصية',
            subtitle: 'كيف نتعامل مع بياناتك',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
          ),
          const SizedBox(height: 28),
          CustomButton(
            text: 'تسجيل الخروج',
            onPressed: () => _logout(context),
            width: double.infinity,
            color: AppColors.error,
          ),
          const SizedBox(height: 24),
          Text(
            '© 2026 درع الإنترنت للأطفال',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(AppRadius.xl);
    return Material(
      color: Colors.white,
      borderRadius: r,
      child: InkWell(
        borderRadius: r,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: r,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.heading2.copyWith(fontSize: 16)),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

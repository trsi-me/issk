import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_radius.dart';
import '../utils/app_text_styles.dart';
import '../utils/constants.dart';
import '../widgets/pressable_scale.dart';
import 'child/child_login_screen.dart';
import 'parent/parent_login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _opacity = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(AppRadius.xl);
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('درع الانترنت للأطفال'),
        centerTitle: true,
      ),
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Image.asset(
                AppConstants.logoAsset,
                height: 140,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.shield_moon,
                  size: 100,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'مرحباً! من أنت؟',
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              _HomeRoleButton(
                label: 'طفل',
                icon: Icons.child_care_rounded,
                color: AppColors.primary,
                borderRadius: r,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ChildLoginScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _HomeRoleButton(
                label: 'ولي الأمر',
                icon: Icons.admin_panel_settings_rounded,
                color: AppColors.parentButton,
                borderRadius: r,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ParentLoginScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeRoleButton extends StatelessWidget {
  const _HomeRoleButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.borderRadius,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: Material(
        elevation: 4,
        shadowColor: color.withValues(alpha: 0.35),
        borderRadius: borderRadius,
        color: color,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: SizedBox(
            width: double.infinity,
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: AppTextStyles.buttonText.copyWith(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

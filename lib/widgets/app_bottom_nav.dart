import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_radius.dart';
import '../utils/app_text_styles.dart';

class NavBarItemData {
  const NavBarItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// شريط تنقل سفلي بحدود واضحة وحالة تبويب مميزة.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.light = true,
  });

  final List<NavBarItemData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final bg = light ? Colors.white : const Color(0xFFF0F2F5);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.22),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final sel = i == currentIndex;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Material(
                    color: sel
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      onTap: () => onTap(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              sel ? item.activeIcon : item.icon,
                              color: sel
                                  ? AppColors.primary
                                  : AppColors.textDark.withValues(alpha: 0.45),
                              size: sel ? 28 : 26,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                fontSize: sel ? 12.5 : 11.5,
                                fontWeight: sel ? FontWeight.bold : FontWeight.w600,
                                color: sel
                                    ? AppColors.primary
                                    : AppColors.textDark.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

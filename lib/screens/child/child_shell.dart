import 'package:flutter/material.dart';

import '../../models/child_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import 'child_dashboard_tab.dart';
import 'child_settings_screen.dart';
import 'games_screen.dart';
import 'quiz_menu_screen.dart';

/// هيكل الطفل — لا يوجد زر خروج في AppBar؛ الخروج من صفحة الإعدادات فقط.
class ChildShell extends StatefulWidget {
  const ChildShell({super.key, required this.child});

  final ChildModel child;

  @override
  State<ChildShell> createState() => _ChildShellState();
}

class _ChildShellState extends State<ChildShell> {
  int _index = 0;

  static const _titles = [
    'الرئيسية',
    'الألعاب',
    'الاختبارات',
    'الإعدادات',
  ];

  @override
  Widget build(BuildContext context) {
    final c = widget.child;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          _index == 0 ? 'أهلاً ${c.name}' : _titles[_index],
          style: AppTextStyles.buttonText.copyWith(fontSize: 18),
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: [
          ChildDashboardTab(
            child: c,
            onNavigateToGames: () => setState(() => _index = 1),
            onNavigateToQuizzes: () => setState(() => _index = 2),
          ),
          GamesScreen(childId: c.id, embedded: true),
          QuizMenuScreen(childId: c.id, embedded: true),
          ChildSettingsScreen(child: c),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        light: true,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          NavBarItemData(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'الرئيسية',
          ),
          NavBarItemData(
            icon: Icons.extension_outlined,
            activeIcon: Icons.extension_rounded,
            label: 'ألعاب',
          ),
          NavBarItemData(
            icon: Icons.fact_check_outlined,
            activeIcon: Icons.fact_check_rounded,
            label: 'اختبارات',
          ),
          NavBarItemData(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
            label: 'إعدادات',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../models/parent_model.dart';
import '../../services/app_session.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../about/about_project_screen.dart';
import '../settings/parent_settings_screen.dart';
import 'child_progress_screen.dart';
import 'parent_children_tab.dart';
import 'parent_dashboard_tab.dart';

/// واجهة ولي الأمر مع شريط تنقل سفلي.
class ParentShell extends StatefulWidget {
  const ParentShell({super.key, required this.parentId});

  final int parentId;

  @override
  State<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends State<ParentShell> {
  final _db = DatabaseHelper.instance;
  int _index = 0;
  ParentModel? _parent;

  static const _titles = [
    'لوحة التحكم',
    'الأبناء',
    'التقدم',
    'عن التطبيق',
    'الإعدادات',
  ];

  @override
  void initState() {
    super.initState();
    AppSession.setParent(widget.parentId);
    _loadParent();
  }

  Future<void> _loadParent() async {
    final p = await _db.getParentById(widget.parentId);
    setState(() => _parent = p);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          _titles[_index],
          style: AppTextStyles.buttonText.copyWith(fontSize: 18),
        ),
      ),
      body: _parent == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : IndexedStack(
              index: _index,
              children: [
                ParentDashboardTab(parent: _parent!),
                ParentChildrenTab(parentId: widget.parentId),
                ChildProgressScreen(parentId: widget.parentId, embedded: true),
                const AboutProjectScreen(),
                ParentSettingsScreen(parentId: widget.parentId),
              ],
            ),
      bottomNavigationBar: AppBottomNav(
        light: false,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          NavBarItemData(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'الرئيسية',
          ),
          NavBarItemData(
            icon: Icons.family_restroom_outlined,
            activeIcon: Icons.family_restroom,
            label: 'الأبناء',
          ),
          NavBarItemData(
            icon: Icons.insights_outlined,
            activeIcon: Icons.insights,
            label: 'التقدم',
          ),
          NavBarItemData(
            icon: Icons.menu_book_outlined,
            activeIcon: Icons.menu_book,
            label: 'حول',
          ),
          NavBarItemData(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'إعدادات',
          ),
        ],
      ),
    );
  }
}

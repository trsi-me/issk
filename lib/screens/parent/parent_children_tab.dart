import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../database/database_helper.dart';
import '../../models/child_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_radius.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/custom_button.dart';

class ParentChildrenTab extends StatefulWidget {
  const ParentChildrenTab({super.key, required this.parentId});

  final int parentId;

  @override
  State<ParentChildrenTab> createState() => _ParentChildrenTabState();
}

class _ParentChildrenTabState extends State<ParentChildrenTab> {
  final _db = DatabaseHelper.instance;
  List<ChildModel> _list = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await _db.getChildrenForParent(widget.parentId);
    setState(() => _list = c);
  }

  Future<void> _addChild() async {
    final name = TextEditingController();
    final age = TextEditingController();
    final pin = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('إضافة طفل', style: AppTextStyles.heading2),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'الاسم',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: age,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'العمر (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pin,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'رمز الطفل (4 أرقام)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
    if (ok != true || !mounted) return;
    final n = name.text.trim();
    final p = pin.text.trim();
    if (n.isEmpty || p.length != 4) {
      _msg('أدخل اسماً صحيحاً ورمزاً من 4 أرقام');
      return;
    }
    int? ag;
    if (age.text.trim().isNotEmpty) ag = int.tryParse(age.text.trim());
    await _db.insertChild(
      parentId: widget.parentId,
      name: n,
      age: ag,
      pin: p,
    );
    await _load();
  }

  Future<void> _editChild(ChildModel ch) async {
    final name = TextEditingController(text: ch.name);
    final age = TextEditingController(text: ch.age?.toString() ?? '');
    final pin = TextEditingController(text: ch.pin);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('تعديل ${ch.name}', style: AppTextStyles.heading2),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'الاسم',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: age,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'العمر',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pin,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'الرمز',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حفظ')),
          ],
        );
      },
    );
    if (ok != true || !mounted) return;
    final n = name.text.trim();
    final p = pin.text.trim();
    if (n.isEmpty || p.length != 4) {
      _msg('بيانات غير صحيحة');
      return;
    }
    int? ag;
    if (age.text.trim().isNotEmpty) ag = int.tryParse(age.text.trim());
    await _db.updateChild(
      ch.id,
      name: n,
      age: ag,
      pin: p,
    );
    await _load();
  }

  Future<void> _toggleSuspend(ChildModel ch) async {
    final next = ch.status == 'active' ? 'suspended' : 'active';
    await _db.updateChild(ch.id, status: next);
    await _load();
  }

  Future<void> _deleteChild(ChildModel ch) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف ${ch.name}', style: AppTextStyles.heading2),
        content: const Text('سيتم حذف التقدم المرتبط بهذا الطفل نهائياً.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _db.deleteChild(ch.id);
    await _load();
  }

  void _msg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CustomButton(
            text: 'إضافة طفل',
            onPressed: _addChild,
            width: double.infinity,
            color: AppColors.success,
          ),
          const SizedBox(height: 20),
          if (_list.isEmpty)
            Text('لا يوجد أبناء بعد. أضف طفلاً لبدء المتابعة.', style: AppTextStyles.bodyText)
          else
            for (final ch in _list)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            ch.isActive ? Icons.child_care : Icons.child_care_outlined,
                            color: ch.isActive ? AppColors.primary : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ch.name,
                              style: AppTextStyles.heading2.copyWith(fontSize: 18),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: ch.isActive
                                  ? AppColors.success.withValues(alpha: 0.15)
                                  : AppColors.warning.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              ch.isActive ? 'نشط' : 'معلّق',
                              style: AppTextStyles.caption.copyWith(
                                color: ch.isActive ? AppColors.success : AppColors.warning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (ch.age != null)
                        Text('العمر: ${ch.age}', style: AppTextStyles.caption),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () => _editChild(ch),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('تعديل'),
                          ),
                          TextButton.icon(
                            onPressed: () => _toggleSuspend(ch),
                            icon: Icon(ch.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline, size: 18),
                            label: Text(ch.isActive ? 'تعليق' : 'تفعيل'),
                          ),
                          TextButton.icon(
                            onPressed: () => _deleteChild(ch),
                            icon: Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            label: Text('حذف', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

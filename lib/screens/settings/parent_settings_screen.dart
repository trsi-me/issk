import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../database/database_helper.dart';
import '../../services/app_session.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../home_screen.dart';
import 'privacy_policy_screen.dart';

class ParentSettingsScreen extends StatefulWidget {
  const ParentSettingsScreen({super.key, required this.parentId});

  final int parentId;

  @override
  State<ParentSettingsScreen> createState() => _ParentSettingsScreenState();
}

class _ParentSettingsScreenState extends State<ParentSettingsScreen> {
  final _db = DatabaseHelper.instance;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pin = TextEditingController();
  final _pin2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await _db.getParentById(widget.parentId);
    if (p != null && mounted) {
      _name.text = p.name;
      _email.text = p.email ?? '';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pin.dispose();
    _pin2.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final n = _name.text.trim();
    if (n.isEmpty) {
      _msg('أدخل الاسم');
      return;
    }
    await _db.updateParent(
      widget.parentId,
      name: n,
      email: _email.text.trim(),
    );
    _msg('تم حفظ البيانات');
  }

  Future<void> _changePin() async {
    final a = _pin.text.trim();
    final b = _pin2.text.trim();
    if (a.length != 4 || int.tryParse(a) == null) {
      _msg('رمز من 4 أرقام');
      return;
    }
    if (a != b) {
      _msg('تأكيد الرمز غير متطابق');
      return;
    }
    final other = await _db.loginParentByPin(a);
    if (other != null && other.id != widget.parentId) {
      _msg('هذا الرمز مستخدم لحساب آخر');
      return;
    }
    await _db.updateParent(widget.parentId, pin: a);
    _pin.clear();
    _pin2.clear();
    _msg('تم تغيير الرمز');
  }

  void _msg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('الملف الشخصي', style: AppTextStyles.heading2),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'الاسم',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'البريد (اختياري)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'حفظ بيانات الحساب',
            onPressed: _saveProfile,
            width: double.infinity,
          ),
          const SizedBox(height: 32),
          Text('تغيير رمز الدخول', style: AppTextStyles.heading2),
          const SizedBox(height: 12),
          TextField(
            controller: _pin,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            decoration: const InputDecoration(
              labelText: 'رمز جديد',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pin2,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            decoration: const InputDecoration(
              labelText: 'تأكيد الرمز',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'تحديث الرمز',
            onPressed: _changePin,
            width: double.infinity,
            color: AppColors.textDark,
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
            title: Text('سياسة الخصوصية', style: AppTextStyles.bodyText),
            trailing: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
          ),
          const SizedBox(height: 28),
          CustomButton(
            text: 'تسجيل الخروج',
            onPressed: () {
              AppSession.clearParent();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
                (_) => false,
              );
            },
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

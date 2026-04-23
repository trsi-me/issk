import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../database/database_helper.dart';
import '../../services/app_session.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import 'parent_shell.dart';

class ParentLoginScreen extends StatefulWidget {
  const ParentLoginScreen({super.key});

  @override
  State<ParentLoginScreen> createState() => _ParentLoginScreenState();
}

class _ParentLoginScreenState extends State<ParentLoginScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseHelper.instance;
  late TabController _tabController;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pinReg = TextEditingController();
  final _pinReg2 = TextEditingController();
  final _pinLogin = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _name.dispose();
    _email.dispose();
    _pinReg.dispose();
    _pinReg2.dispose();
    _pinLogin.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final n = _name.text.trim();
    final p = _pinReg.text.trim();
    final p2 = _pinReg2.text.trim();
    if (n.length < 2) {
      _msg('أدخل اسماً صحيحاً');
      return;
    }
    if (p.length != 4 || int.tryParse(p) == null) {
      _msg('الرمز يجب أن يكون 4 أرقام');
      return;
    }
    if (p != p2) {
      _msg('تأكيد الرمز غير متطابق');
      return;
    }
    if (await _db.isParentPinTaken(p)) {
      _msg('هذا الرمز مستخدم. اختر رمزاً آخراً');
      return;
    }
    final id = await _db.registerParent(
      name: n,
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      pin: p,
    );
    AppSession.setParent(id);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => ParentShell(parentId: id)),
    );
  }

  Future<void> _login() async {
    final p = _pinLogin.text.trim();
    if (p.length != 4 || int.tryParse(p) == null) {
      _msg('أدخل 4 أرقام');
      return;
    }
    final parent = await _db.loginParentByPin(p);
    if (!mounted) return;
    if (parent == null) {
      _msg('الرمز غير صحيح');
      return;
    }
    AppSession.setParent(parent.id);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => ParentShell(parentId: parent.id)),
    );
  }

  void _msg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ولي الأمر'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          labelStyle: AppTextStyles.caption.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: AppTextStyles.caption.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(text: 'تسجيل الدخول'),
            Tab(text: 'حساب جديد'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _loginTab(),
          _registerTab(),
        ],
      ),
    );
  }

  Widget _loginTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Icon(Icons.admin_panel_settings_outlined, size: 56, color: AppColors.primary),
        const SizedBox(height: 16),
        Text(
          'أدخل رمزك المكوّن من 4 أرقام',
          style: AppTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _pinLogin,
          obscureText: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          decoration: const InputDecoration(
            labelText: 'رمز الدخول',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'إذا لم يكن لديك حساب، انتقل إلى تبويب «حساب جديد».',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 24),
        CustomButton(text: 'دخول', onPressed: _login, width: double.infinity),
      ],
    );
  }

  Widget _registerTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('أنشئ حساب ولي أمر', style: AppTextStyles.heading2),
        const SizedBox(height: 16),
        TextField(
          controller: _name,
          decoration: const InputDecoration(
            labelText: 'الاسم الكامل',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'البريد الإلكتروني (اختياري)',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _pinReg,
          obscureText: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          decoration: const InputDecoration(
            labelText: 'رمز الدخول (4 أرقام) — فريد ولا يُشارك',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _pinReg2,
          obscureText: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          decoration: const InputDecoration(
            labelText: 'تأكيد الرمز',
          ),
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: 'إنشاء الحساب والمتابعة',
          onPressed: _register,
          width: double.infinity,
          color: AppColors.success,
        ),
      ],
    );
  }
}

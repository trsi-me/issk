import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../database/database_helper.dart';
import '../../models/child_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_radius.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import 'child_shell.dart';

class ChildLoginScreen extends StatefulWidget {
  const ChildLoginScreen({super.key});

  @override
  State<ChildLoginScreen> createState() => _ChildLoginScreenState();
}

class _ChildLoginScreenState extends State<ChildLoginScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseHelper.instance;
  late TabController _tabController;

  List<ChildModel> _children = [];
  int? _selectedId;
  final _pinController = TextEditingController();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _newPinController = TextEditingController();
  final _parentPinController = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final list = await _db.getActiveChildrenForLogin();
    setState(() {
      _children = list;
      _selectedId = list.isNotEmpty ? list.first.id : null;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pinController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _newPinController.dispose();
    _parentPinController.dispose();
    super.dispose();
  }

  Future<void> _loginExisting() async {
    if (_selectedId == null) {
      _showMsg('لا يوجد أطفال نشطون. سجّل حساباً جديداً.');
      return;
    }
    final ok = await _db.verifyChildPin(_selectedId!, _pinController.text.trim());
    if (!mounted) return;
    if (!ok) {
      _showMsg('رمز الدخول غير صحيح أو الحساب معلّق');
      return;
    }
    final child = await _db.getChildById(_selectedId!);
    if (child == null || !mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ChildShell(child: child),
      ),
    );
  }

  Future<void> _createNew() async {
    final name = _nameController.text.trim();
    final pin = _newPinController.text.trim();
    final pp = _parentPinController.text.trim();
    if (name.isEmpty || pin.length != 4 || int.tryParse(pin) == null) {
      _showMsg('أدخل الاسم ورمزاً مكوناً من 4 أرقام');
      return;
    }
    if (pp.length != 4 || int.tryParse(pp) == null) {
      _showMsg('أدخل رمز ولي الأمر (4 أرقام) لربط حسابك');
      return;
    }
    final parent = await _db.getParentByPin(pp);
    if (parent == null) {
      _showMsg('رمز ولي الأمر غير صحيح');
      return;
    }
    int? age;
    final ageText = _ageController.text.trim();
    if (ageText.isNotEmpty) {
      age = int.tryParse(ageText);
    }
    final id = await _db.insertChild(
      parentId: parent.id,
      name: name,
      age: age,
      pin: pin,
    );
    final child = await _db.getChildById(id);
    if (!mounted || child == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ChildShell(child: child),
      ),
    );
  }

  void _showMsg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الطفل'),
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
        const Icon(Icons.child_care_outlined, size: 56, color: AppColors.primary),
        const SizedBox(height: 12),
        Text(
          'اختر اسمك وأدخل رمزك',
          style: AppTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        if (_children.isEmpty)
          Text(
            'لا يوجد أطفال نشطون بعد. أنشئ حساباً من التبويب الثاني.',
            style: AppTextStyles.bodyText,
          )
        else ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: _selectedId,
                items: _children
                    .map(
                      (c) => DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(c.name, style: AppTextStyles.bodyText),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedId = v),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            decoration: const InputDecoration(
              labelText: 'رمز الطفل (4 أرقام)',
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'دخول',
            onPressed: _loginExisting,
            width: double.infinity,
          ),
        ],
      ],
    );
  }

  Widget _registerTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'ربط الحساب بـ ولي الأمر',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 8),
        Text(
          'اطلب من ولي أمرك رمز حسابه (4 أرقام) لربط حسابك بعائلتك.',
          style: AppTextStyles.bodyText,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _parentPinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          decoration: const InputDecoration(
            labelText: 'رمز ولي الأمر',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'اسمك',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'العمر (اختياري)',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _newPinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          decoration: const InputDecoration(
            labelText: 'رمزك (4 أرقام)',
          ),
        ),
        const SizedBox(height: 20),
        CustomButton(
          text: 'إنشاء الحساب والدخول',
          onPressed: _createNew,
          width: double.infinity,
          color: AppColors.success,
        ),
      ],
    );
  }
}

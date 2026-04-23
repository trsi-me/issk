import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('سياسة الخصوصية')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'التزامنا تجاهك',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 12),
            Text(
              'يُصمَّم «درع الإنترنت للأطفال» ليعمل بأقل قدر من جمع البيانات. المعلومات التي تُدخلها (مثل اسم ولي الأمر والطفل والرموز) تُحفظ محلياً على جهازك ضمن قاعدة بيانات SQLite ولا تُرسل إلى خوادم نحن نشغّلها.',
              style: AppTextStyles.bodyText,
            ),
            const SizedBox(height: 16),
            Text(
              'الاتصال بالشبكة',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              'عند تشغيل فيديوهات من يوتيوب، يتصل التطبيق بخدمات يوتيوب/جوجل لعرض المحتوى وفق سياساتهم. لا نتحكم في بيانات التتبع التي قد تجمعها تلك الخدمات.',
              style: AppTextStyles.bodyText,
            ),
            const SizedBox(height: 16),
            Text(
              'مسؤولية ولي الأمر',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              'يُنصح بمرافقة الطفل أثناء التعلّم، وتغيير الرموز بشكل دوري، وعدم مشاركة رمز ولي الأمر مع الغير.',
              style: AppTextStyles.bodyText,
            ),
            const SizedBox(height: 24),
            Text(
              '© 2026',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

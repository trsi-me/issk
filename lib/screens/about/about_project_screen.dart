import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

/// صفحة تعريف مفصّلة بالمشروع.
class AboutProjectScreen extends StatelessWidget {
  const AboutProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'درع الإنترنت للأطفال',
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'ISSK — Internet Safety Shield for Kids',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'لماذا هذا التطبيق؟',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'الأطفال يقضون وقتاً متزايداً على الشبكة. هذا التطبيق يقدّم لهم تجربة تعليمية باللغة العربية حول مخاطر الإنترنت — من التحرش والتنمر إلى الخصوصية وكلمات المرور — دون إرهاق تقني، وبأسلوب يشبه البرامج التوعوية الحكومية والمدرسية.',
            style: AppTextStyles.bodyText,
          ),
          const SizedBox(height: 20),
          Text(
            'ماذا يجد الطفل؟',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),
          _bullet(Icons.play_circle_outline, 'فيديوهات تعليمية مرتبطة بمواضيع السلامة، مع مشغّل يعرض محتوى يوتيوب المناسب للتصنيف.'),
          _bullet(Icons.extension_outlined, 'ألعاب بمستويات متتابعة: صح وخطأ، ترتيب خطوات، أسئلة من قاعدة البيانات، وإكمال جمل.'),
          _bullet(Icons.fact_check_outlined, 'اختبارات منظّمة مع شريط تقدّم وتغذية راجعة فورية.'),
          const SizedBox(height: 20),
          Text(
            'ماذا يجد ولي الأمر؟',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'حساب ولي أمر يتيح إضافة الأبناء وتعديل بياناتهم أو تعليق حساباتهم أو حذفها، مع لوحة لمتابعة التقدم والأنشطة بشكل منظم — كل ذلك محلياً على الجهاز دون إرسال بياناتك إلى خوادم خارجية.',
            style: AppTextStyles.bodyText,
          ),
          const SizedBox(height: 20),
          Text(
            'الخصوصية والأمان',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'البيانات تُخزَّن في قاعدة SQLite على جهازك فقط. تشغيل فيديوهات يوتيوب يتطلّب اتصالاً بالإنترنت لعرض المحتوى، بينما بقية الأنشطة يمكن استخدامها دون اتصال بعد التحميل الأول.',
            style: AppTextStyles.bodyText,
          ),
          const SizedBox(height: 24),
          Text(
            '© 2026 درع الإنترنت للأطفال — جميع الحقوق محفوظة.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _bullet(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.secondary, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.bodyText)),
        ],
      ),
    );
  }
}

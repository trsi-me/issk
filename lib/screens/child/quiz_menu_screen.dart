import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_radius.dart';
import '../../utils/app_text_styles.dart';
import 'quiz_screen.dart';

/// قائمة الاختبارات الأربعة — يمكن عرضها داخل هيكل بلا AppBar مكرر.
class QuizMenuScreen extends StatelessWidget {
  const QuizMenuScreen({
    super.key,
    required this.childId,
    this.embedded = false,
  });

  final int childId;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(AppRadius.xl);
    final body = ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        if (!embedded) const SizedBox.shrink() else const SizedBox(height: 8),
        Text(
          'اختر مجموعة الأسئلة',
          style: AppTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        for (var i = 1; i <= 4; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Material(
              elevation: 2,
              shadowColor: AppColors.primary.withValues(alpha: 0.25),
              color: AppColors.primary,
              borderRadius: br,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                borderRadius: br,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => QuizScreen(
                          childId: childId,
                          quizIndex: i,
                        ),
                      ),
                    );
                  },
                  child: SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_turned_in_rounded,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'اختبار $i',
                          style: AppTextStyles.buttonText.copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ),
      ],
    );

    if (embedded) {
      return ColoredBox(color: AppColors.background, child: body);
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('الاختبارات')),
      body: body,
    );
  }
}

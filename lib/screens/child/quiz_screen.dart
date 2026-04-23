import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../models/quiz_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_radius.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.childId,
    required this.quizIndex,
  });

  final int childId;
  /// من 1 إلى 4 يطابق مستوى الأسئلة
  final int quizIndex;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _db = DatabaseHelper.instance;
  List<QuizModel> _questions = [];
  int _index = 0;
  int _correct = 0;
  String? _selected;
  bool? _wasCorrect;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final level = widget.quizIndex.clamp(1, 4);
    final list = await _db.getQuizSetForLevel(level, AppConstants.questionsPerQuiz);
    setState(() => _questions = list);
  }

  void _pick(String opt) {
    final q = _questions[_index];
    final ok = opt == q.correctAnswer;
    if (ok) _correct++;
    setState(() {
      _selected = opt;
      _wasCorrect = ok;
    });
  }

  void _next() {
    if (_index < _questions.length - 1) {
      setState(() {
        _index++;
        _selected = null;
        _wasCorrect = null;
      });
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await _db.insertProgress(
      childId: widget.childId,
      activityType: AppConstants.activityQuiz,
      activityId: widget.quizIndex,
      score: _correct,
      completed: 1,
    );
    if (!mounted) return;
    final stars = _stars(_correct, _questions.length);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => QuizResultScreen(
          childId: widget.childId,
          quizIndex: widget.quizIndex,
          correct: _correct,
          total: _questions.length,
          stars: stars,
        ),
      ),
    );
  }

  int _stars(int c, int t) {
    if (t == 0) return 1;
    if (c == t) return 3;
    if (c >= 3) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text('اختبار ${widget.quizIndex}')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final q = _questions[_index];
    final progress = (_index + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('اختبار ${widget.quizIndex}')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surface,
                color: AppColors.primary,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'السؤال ${_index + 1} من ${_questions.length}',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 12),
            Text(q.question, style: AppTextStyles.heading2),
            const SizedBox(height: 16),
            for (final o in q.options)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: _bgForOption(o, q),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    onTap: _selected == null ? () => _pick(o) : null,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(o, style: AppTextStyles.bodyText),
                    ),
                  ),
                ),
              ),
            if (_selected != null) ...[
              const Spacer(),
              CustomButton(
                text: _index < _questions.length - 1 ? 'التالي' : 'عرض النتيجة',
                onPressed: _next,
                width: double.infinity,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _bgForOption(String o, QuizModel q) {
    if (_selected == null) return AppColors.surface;
    if (o == q.correctAnswer) return AppColors.success.withValues(alpha: 0.25);
    if (o == _selected && _wasCorrect == false) return AppColors.error.withValues(alpha: 0.25);
    return AppColors.surface;
  }
}

import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../models/quiz_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_radius.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

class GamePlayScreen extends StatefulWidget {
  const GamePlayScreen({
    super.key,
    required this.childId,
    required this.level,
    required this.title,
    required this.gameType,
  });

  final int childId;
  final int level;
  final String title;
  final String gameType;

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  final _db = DatabaseHelper.instance;

  // صح أم خطأ
  int _tfIndex = 0;
  int _tfScore = 0;
  bool? _lastCorrect;
  String _tfFeedback = '';

  // ترتيب
  final List<String> _orderPool = [
    'أخبر ولي الأمر أو معلماً',
    'لا ترد بعنف',
    'احتفظ بلقطات شاشة إن أمكن',
    'استخدم أزرار الإبلاغ في التطبيق',
  ];
  final List<int> _orderTaps = [];
  bool _orderDone = false;

  // اختيار من قاعدة البيانات
  List<QuizModel> _quizzes = [];
  int _mqIndex = 0;
  int _mqScore = 0;
  String? _mqSelected;

  // أكمل الجملة
  int _csIndex = 0;
  int _csScore = 0;

  final List<Map<String, dynamic>> _csData = [
    {
      's': 'لا أشارك ___ مع الغرباء على الإنترنت.',
      'o': ['عنوان منزلي ورقم هاتفي', 'لوني المفضل', 'اسم لعبتي فقط'],
      'c': 0,
    },
    {
      's': 'عند رؤية رابط مجهول يجب أن ___',
      'o': ['أخبر ولي الأمر ولا أضغط بتهور', 'أضغط لأرى', 'أرسله للجميع'],
      'c': 0,
    },
    {
      's': 'كلمة المرور القوية تتكون من ___',
      'o': ['أحرف وأرقام ورموز متنوعة', 'اسمي فقط', 'أرقام متتابعة'],
      'c': 0,
    },
    {
      's': 'التنمر الإلكتروني يجب ___',
      'o': ['الإبلاغ عنه لشخص بالغ', 'تجاهله دائماً دون إخبار أحد', 'الرد بعنف'],
      'c': 0,
    },
    {
      's': 'الخصوصية تعني ___',
      'o': ['حماية معلوماتي وحدودي', 'نشر كل شيء', 'إخفاء الواجب'],
      'c': 0,
    },
  ];

  final List<Map<String, dynamic>> _tfData = [
    {
      'q': 'صديقك على الإنترنت طلب عنوان منزلك لإرسال هدية.',
      'ok': false,
      'f': 'صحيح: لا تشارك عنوانك مع غرباء؛ أخبر ولي الأمر.',
    },
    {
      'q': 'يمكنك مشاركة كلمة مرور حسابك مع صديقك المقرّب في اللعبة.',
      'ok': false,
      'f': 'خطأ: لا تشارك كلمات المرور أبداً.',
    },
    {
      'q': 'إذا شعرت بعدم الأمان يجب أن تخبر شخصاً بالغاً تثق به.',
      'ok': true,
      'f': 'صحيح: طلب المساعدة أمرٌ جيد.',
    },
    {
      'q': 'الضغط لإرسال صور خاصة يُعد طلباً عادياً يجب تنفيذه.',
      'ok': false,
      'f': 'خطأ: رفض أي ضغط وإبلاغ ولي الأمر.',
    },
    {
      'q': 'الإبلاغ عن محتوى غير لائق يساعد على حمايتك وحماية الآخرين.',
      'ok': true,
      'f': 'صحيح: الإبلاغ أداة مهمة للسلامة.',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.gameType == 'mcq') {
      _loadMcq();
    }
  }

  Future<void> _loadMcq() async {
    final list = await _db.getQuizSetForLevel(3, AppConstants.questionsPerQuiz);
    setState(() => _quizzes = list);
  }

  int _starsFromPoints(int points, int max) {
    if (max <= 0) return 1;
    final r = points / max;
    if (r >= 1) return 3;
    if (r >= 0.6) return 2;
    return 1;
  }

  Future<void> _finish(int points, int max) async {
    final stars = _starsFromPoints(points, max);
    await _db.insertProgress(
      childId: widget.childId,
      activityType: AppConstants.activityGame,
      activityId: widget.level,
      score: stars,
      completed: 1,
    );
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text('انتهت اللعبة', style: AppTextStyles.heading2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'النتيجة: $points من $max',
                style: AppTextStyles.bodyText,
              ),
              const SizedBox(height: 8),
              Text(
                '${List.filled(stars, '⭐').join()} ($stars من 3)',
                style: AppTextStyles.heading1,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('حسناً'),
            ),
          ],
        );
      },
    );
  }

  void _answerTf(bool choice) {
    final cur = _tfData[_tfIndex];
    final ok = cur['ok'] as bool;
    final correct = choice == ok;
    if (correct) _tfScore++;
    setState(() {
      _lastCorrect = correct;
      _tfFeedback = cur['f'] as String;
    });
  }

  void _nextTf() {
    if (_tfIndex < _tfData.length - 1) {
      setState(() {
        _tfIndex++;
        _lastCorrect = null;
        _tfFeedback = '';
      });
    } else {
      _finish(_tfScore, _tfData.length);
    }
  }

  void _tapOrder(int idx) {
    if (_orderDone) return;
    if (_orderTaps.contains(idx)) return;
    setState(() => _orderTaps.add(idx));
    if (_orderTaps.length == 4) {
      final good = _orderTaps[0] == 1 &&
          _orderTaps[1] == 0 &&
          _orderTaps[2] == 3 &&
          _orderTaps[3] == 2;
      setState(() {
        _orderDone = true;
        _lastCorrect = good;
        _tfFeedback = good
            ? 'ترتيب ممتاز! الخطوة الأولى: الهدوء وعدم الرد بعنف، ثم إبلاغ بالغ، ثم الإبلاغ في التطبيق، ثم الاحتفاظ بالدليل إن أمكن.'
            : 'حاول مجدداً: رتّب بدايةً من تهدئة الموقف ثم إبلاغ شخص بالغ.';
      });
      if (good) {
        Future<void>.delayed(const Duration(milliseconds: 600), () {
          if (mounted) _finish(5, 5);
        });
      }
    }
  }

  void _resetOrder() {
    setState(() {
      _orderTaps.clear();
      _orderDone = false;
      _lastCorrect = null;
      _tfFeedback = '';
    });
  }

  void _submitMcq(String opt) {
    final q = _quizzes[_mqIndex];
    final ok = opt == q.correctAnswer;
    if (ok) _mqScore++;
    setState(() {
      _mqSelected = opt;
      _lastCorrect = ok;
      _tfFeedback = ok ? 'إجابة صحيحة' : 'الصحيح: ${q.correctAnswer}';
    });
  }

  void _nextMcq() {
    if (_mqIndex < _quizzes.length - 1) {
      setState(() {
        _mqIndex++;
        _mqSelected = null;
        _lastCorrect = null;
        _tfFeedback = '';
      });
    } else {
      _finish(_mqScore, _quizzes.length);
    }
  }

  void _pickCs(int i) {
    final item = _csData[_csIndex];
    final ok = i == (item['c'] as int);
    if (ok) _csScore++;
    setState(() {
      _lastCorrect = ok;
      _tfFeedback = ok ? 'أحسنت' : 'جرّب إجابة أدق';
    });
  }

  void _nextCs() {
    if (_csIndex < _csData.length - 1) {
      setState(() {
        _csIndex++;
        _lastCorrect = null;
        _tfFeedback = '';
      });
    } else {
      _finish(_csScore, _csData.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: _buildBody(),
      ),
    );
  }

  Widget _tfChoice({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final br = BorderRadius.circular(AppRadius.lg);
    return Material(
      color: color,
      borderRadius: br,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: br,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.buttonText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (widget.gameType) {
      case 'true_false':
        return _buildTrueFalse();
      case 'order_steps':
        return _buildOrder();
      case 'mcq':
        if (_quizzes.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        return _buildMcq();
      case 'complete_sentence':
        return _buildCompleteSentence();
      default:
        return Text('نوع غير معروف', style: AppTextStyles.bodyText);
    }
  }

  Widget _buildTrueFalse() {
    final cur = _tfData[_tfIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'سؤال ${_tfIndex + 1} من ${_tfData.length}',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 8),
        Text(cur['q'] as String, style: AppTextStyles.heading2),
        const SizedBox(height: 20),
        if (_lastCorrect == null) ...[
          Row(
            children: [
              Expanded(
                child: _tfChoice(
                  icon: Icons.check_circle_outline,
                  label: 'صح',
                  color: AppColors.success,
                  onTap: () => _answerTf(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _tfChoice(
                  icon: Icons.cancel_outlined,
                  label: 'خطأ',
                  color: AppColors.error,
                  onTap: () => _answerTf(false),
                ),
              ),
            ],
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Text(
              _tfFeedback,
              style: AppTextStyles.bodyText.copyWith(
                color: _lastCorrect! ? AppColors.success : AppColors.error,
              ),
            ),
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: _tfIndex < _tfData.length - 1 ? 'التالي' : 'إنهاء',
            onPressed: _nextTf,
            width: double.infinity,
          ),
        ],
      ],
    );
  }

  Widget _buildOrder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'رتّب الخطوات المناسبة عند التعرّض للتنمر الإلكتروني (اضغط بالترتيب الصحيح)',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 16),
        ...List.generate(4, (i) {
          final label = _orderPool[i];
          final selectedPos = _orderTaps.indexOf(i);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: _orderDone ? null : () => _tapOrder(i),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      if (selectedPos >= 0)
                        CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text('${selectedPos + 1}', style: AppTextStyles.buttonText),
                        )
                      else
                        const Icon(Icons.touch_app, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(label, style: AppTextStyles.bodyText)),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        if (_orderDone && _lastCorrect == false) ...[
          const SizedBox(height: 8),
          CustomButton(text: 'إعادة المحاولة', onPressed: _resetOrder, color: AppColors.warning),
        ],
        if (_tfFeedback.isNotEmpty && _orderDone)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(_tfFeedback, style: AppTextStyles.bodyText),
          ),
      ],
    );
  }

  Widget _buildMcq() {
    final q = _quizzes[_mqIndex];
    final opts = q.options;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'سؤال ${_mqIndex + 1} من ${_quizzes.length}',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 8),
        Text(q.question, style: AppTextStyles.heading2),
        const SizedBox(height: 16),
        for (final o in opts)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: _mqSelected == o
                  ? (_lastCorrect == true
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.error.withValues(alpha: 0.2))
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: _mqSelected == null ? () => _submitMcq(o) : null,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(o, style: AppTextStyles.bodyText),
                ),
              ),
            ),
          ),
        if (_mqSelected != null) ...[
          const SizedBox(height: 8),
          CustomButton(
            text: _mqIndex < _quizzes.length - 1 ? 'التالي' : 'إنهاء',
            onPressed: _nextMcq,
            width: double.infinity,
          ),
        ],
      ],
    );
  }

  Widget _buildCompleteSentence() {
    final item = _csData[_csIndex];
    final opts = (item['o'] as List).cast<String>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'جملة ${_csIndex + 1} من ${_csData.length}',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 8),
        Text(item['s'] as String, style: AppTextStyles.heading2),
        const SizedBox(height: 16),
        for (var i = 0; i < opts.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: _lastCorrect == null ? () => _pickCs(i) : null,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(opts[i], style: AppTextStyles.bodyText),
                ),
              ),
            ),
          ),
        if (_lastCorrect != null) ...[
          Text(_tfFeedback, style: AppTextStyles.caption),
          const SizedBox(height: 8),
          CustomButton(
            text: _csIndex < _csData.length - 1 ? 'التالي' : 'إنهاء',
            onPressed: _nextCs,
            width: double.infinity,
          ),
        ],
      ],
    );
  }
}

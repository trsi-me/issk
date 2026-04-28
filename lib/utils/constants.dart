import 'cst_video_seed.dart';

/// ثوابت التطبيق — أسماء التصنيفات والمسارات.
class AppConstants {
  AppConstants._();

  static const String logoAsset = 'assets/images/Logo.jpeg';

  /// تصنيفات الفيديوهات المتطابقة مع مبادرة CST «توعية الأطفال عن مخاطر الإنترنت» (`CstVideoSeed`).
  static List<String> get videoCategories =>
      CstVideoSeed.clips.map((c) => c.title).toList();

  static const String activityVideo = 'video';
  static const String activityGame = 'game';
  static const String activityQuiz = 'quiz';

  static const int questionsPerQuiz = 5;
  static const int quizCount = 4;
}

/// ثوابت التطبيق — أسماء التصنيفات والمسارات.
class AppConstants {
  AppConstants._();

  static const String logoAsset = 'assets/images/Logo.jpeg';

  /// تصنيفات الفيديوهات (للتبويب والفلترة)
  static const List<String> videoCategories = [
    'التحرش',
    'الإلحاح والضغط',
    'برمجيات خانقة',
    'محتوى لأقل',
    'محتوى غير لائق',
    'تغيب عن الواقع',
    'أسرار على الإنترنت',
    'التنمر الإلكتروني',
  ];

  static const String activityVideo = 'video';
  static const String activityGame = 'game';
  static const String activityQuiz = 'quiz';

  static const int questionsPerQuiz = 5;
  static const int quizCount = 4;
}

/// جلسة التطبيق البسيطة (معرّف ولي الأمر الحالي).
class AppSession {
  AppSession._();

  static int? parentId;

  static void setParent(int id) => parentId = id;

  static void clearParent() => parentId = null;
}

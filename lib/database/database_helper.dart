import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/child_model.dart';
import '../models/game_model.dart';
import '../models/parent_model.dart';
import '../models/progress_model.dart';
import '../models/quiz_model.dart';
import '../models/video_model.dart';
import '../utils/constants.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  static const int _version = 2;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = p.join(await getDatabasesPath(), 'issk.db');
    return openDatabase(
      path,
      version: _version,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createV2(db);
        await _seed(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
CREATE TABLE IF NOT EXISTS parents (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT,
  pin TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now'))
);
''');
          final oldPins = await db.query('parent_pin');
          if (oldPins.isNotEmpty) {
            await db.insert('parents', {
              'name': 'ولي الأمر',
              'email': '',
              'pin': oldPins.first['pin'],
            });
          } else {
            await db.insert('parents', {
              'name': 'ولي الأمر',
              'email': '',
              'pin': '0000',
            });
          }

          try {
            await db.execute('ALTER TABLE children ADD COLUMN parent_id INTEGER');
          } catch (_) {}
          try {
            await db.execute("ALTER TABLE children ADD COLUMN status TEXT DEFAULT 'active'");
          } catch (_) {}

          await db.rawUpdate('UPDATE children SET parent_id = 1 WHERE parent_id IS NULL');
          await db.rawUpdate("UPDATE children SET status = 'active' WHERE status IS NULL");

          try {
            await db.execute('ALTER TABLE videos ADD COLUMN youtube_video_id TEXT');
          } catch (_) {}

          await _migrateYoutubeIds(db);
        }
      },
    );
  }

  Future<void> _createV2(Database db) async {
    await db.execute('''
CREATE TABLE parents (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT,
  pin TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now'))
);
''');
    await db.execute('''
CREATE TABLE children (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  parent_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  age INTEGER,
  pin TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active',
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (parent_id) REFERENCES parents(id)
);
''');
    await db.execute('''
CREATE TABLE videos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL,
  asset_path TEXT NOT NULL,
  youtube_video_id TEXT,
  order_index INTEGER DEFAULT 0
);
''');
    await db.execute('''
CREATE TABLE games (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  level INTEGER NOT NULL,
  game_type TEXT NOT NULL
);
''');
    await db.execute('''
CREATE TABLE quizzes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  question TEXT NOT NULL,
  option_a TEXT NOT NULL,
  option_b TEXT NOT NULL,
  option_c TEXT NOT NULL,
  option_d TEXT NOT NULL,
  correct_answer TEXT NOT NULL,
  category TEXT NOT NULL,
  level INTEGER DEFAULT 1
);
''');
    await db.execute('''
CREATE TABLE progress (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  child_id INTEGER NOT NULL,
  activity_type TEXT NOT NULL,
  activity_id INTEGER NOT NULL,
  score INTEGER DEFAULT 0,
  completed INTEGER DEFAULT 0,
  completed_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (child_id) REFERENCES children(id)
);
''');
  }

  /// معرّف فيديو يوتيوب توعوي (نفيش — الانترنت الآمن). يمكن توسيع القائمة لاحقاً.
  static const String _ytMain = 'pY3NJ6ukRyw';

  Future<void> _migrateYoutubeIds(Database db) async {
    final rows = await db.query('videos', orderBy: 'id ASC');
    final ids = List<String>.filled(rows.length, _ytMain);
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final vid = row['id'] as int;
      final yid = ids[i];
      await db.update(
        'videos',
        {'youtube_video_id': yid},
        where: 'id = ?',
        whereArgs: [vid],
      );
    }
  }

  Future<void> _seed(Database db) async {
    final games = [
      {
        'title': 'لعبة 1: صح أم خطأ - الإنترنت الآمن',
        'level': 1,
        'game_type': 'true_false',
      },
      {
        'title': 'لعبة 2: رتّب الخطوات الصحيحة',
        'level': 2,
        'game_type': 'order_steps',
      },
      {
        'title': 'لعبة 3: اختر الإجابة الصحيحة',
        'level': 3,
        'game_type': 'mcq',
      },
      {
        'title': 'لعبة 4: أكمل الجملة',
        'level': 4,
        'game_type': 'complete_sentence',
      },
    ];
    for (final g in games) {
      await db.insert('games', g);
    }

    var order = 0;
    for (final cat in AppConstants.videoCategories) {
      final idx = order++;
      await db.insert('videos', {
        'title': 'فيديو توعوي: $cat',
        'description': 'محتوى تعليمي من يوتيوب حول السلامة الرقمية.',
        'category': cat,
        'asset_path': 'assets/videos/video_$idx.mp4',
        'youtube_video_id': _ytMain,
        'order_index': idx,
      });
    }

    final quizRows = _seedQuizzes();
    for (final q in quizRows) {
      await db.insert('quizzes', q);
    }
  }

  List<Map<String, Object?>> _seedQuizzes() {
    return [
      _q(
        1,
        'ماذا تفعل إذا طلب منك شخص غريب على الإنترنت إرسال صورتك؟',
        'أرسل الصورة لأكون مهذباً',
        'أرفض وأخبر والديّ فوراً',
        'أرسل صورة لصديق آخر',
        'أتجاهل دون إخبار أحد',
        'أرفض وأخبر والديّ فوراً',
        'الغرباء على الإنترنت',
      ),
      _q(
        1,
        'ما هي المعلومات التي يجب ألا تشاركها مع الغرباء؟',
        'اسمك الأول فقط',
        'لونك المفضل',
        'عنوان منزلك ورقم هاتفك',
        'اسم مدرستك فقط',
        'عنوان منزلك ورقم هاتفك',
        'المعلومات الشخصية',
      ),
      _q(
        1,
        'ماذا تفعل إذا وجدت رابطاً مجهولاً؟',
        'أضغط عليه فوراً',
        'لا أضغط عليه وأخبر والديّ',
        'أرسله لأصدقائي',
        'أحفظه للمشاهدة لاحقاً',
        'لا أضغط عليه وأخبر والديّ',
        'الروابط المشبوهة',
      ),
      _q(
        1,
        'كيف تختار كلمة مرور قوية؟',
        '123456',
        'اسمك وتاريخ ميلادك',
        'مزيج من أحرف وأرقام ورموز لا يخمّن بسهولة',
        'كلمة "password"',
        'مزيج من أحرف وأرقام ورموز لا يخمّن بسهولة',
        'كلمة المرور',
      ),
      _q(
        1,
        'ماذا تفعل إذا سخر أحد منك على الإنترنت؟',
        'أرد بسخرية أقوى',
        'أخفي الأمر ولا أقول لأحد',
        'أخبر شخصاً بالغاً موثوقاً وأبلغ عن التنمر',
        'أحذف حسابي فوراً',
        'أخبر شخصاً بالغاً موثوقاً وأبلغ عن التنمر',
        'التنمر الإلكتروني',
      ),
      _q(
        1,
        'هل يجوز مشاركة موقعك الحالي مع أشخاص لا تعرفهم؟',
        'نعم إذا طلبوا بأدب',
        'لا، أبداً',
        'نعم في الألعاب فقط',
        'نعم للأصدقاء الجدد',
        'لا، أبداً',
        'الخصوصية',
      ),
      _q(
        2,
        'أيُّ سلوك آمن عند لعب الألعاب عبر الإنترنت؟',
        'قبول كل طلب صداقة',
        'عدم مشاركة معلومات شخصية مع لاعبين غرباء',
        'إعطاء رقم الهاتف للفريق',
        'مشاركة حساب الوالدين',
        'عدم مشاركة معلومات شخصية مع لاعبين غرباء',
        'مخاطر الألعاب',
      ),
      _q(
        2,
        'ماذا تفعل إذا طلب منك أحد داخل لعبة زيارة موقع خارجي؟',
        'أزور الموقع فوراً',
        'أسأل ولي الأمر قبل أي خطوة',
        'أرسل الرابط لأصدقائي',
        'أدخل بياناتي في الموقع',
        'أسأل ولي الأمر قبل أي خطوة',
        'مواقع غير آمنة',
      ),
      _q(
        2,
        'ما الصور التي يمكنك مشاركتها؟',
        'أي صورة يطلبها الغرباء',
        'صور خاصة بالمنزل مع اللوحة',
        'صور مناسبة وبعد موافقة ولي الأمر',
        'صور أصدقاء المدرسة دون إذن',
        'صور مناسبة وبعد موافقة ولي الأمر',
        'الصور',
      ),
      _q(
        2,
        'كيف تتصرف عند استلام رسالة مخيفة أو تهديد؟',
        'أرد بتهديد مماثل',
        'أحذف فقط دون إخبار أحد',
        'أخبر ولي الأمر أو معلماً وأحتفظ بالدليل',
        'أشاركها علناً',
        'أخبر ولي الأمر أو معلماً وأحتفظ بالدليل',
        'الإبلاغ عن المشاكل',
      ),
      _q(
        2,
        'هل يمكنك الوثوق بشخص تعرفه من الإنترنت فقط دون لقاء حقيقي؟',
        'نعم دائماً',
        'لا، قد لا يكون هويته الحقيقية',
        'نعم إذا كان لطيفاً',
        'نعم في مجموعات الألعاب',
        'لا، قد لا يكون هويته الحقيقية',
        'الغرباء على الإنترنت',
      ),
      _q(
        2,
        'ماذا تعني الخصوصية الرقمية؟',
        'نشر كل شيء عن حياتك',
        'حماية معلوماتك وحدودك الشخصية',
        'إخفاء الهاتف عن الوالدين',
        'حذف الإنترنت',
        'حماية معلوماتك وحدودك الشخصية',
        'الخصوصية',
      ),
      _q(
        3,
        'أيُّ معلومات تعتبر حساسة ولا يجب نشرها؟',
        'اسم لعبة مفضلة',
        'رقم الهاتف والعنوان والرقم السري',
        'لونك المفضل',
        'اسم حيوانك الأليف',
        'رقم الهاتف والعنوان والرقم السري',
        'المعلومات الشخصية',
      ),
      _q(
        3,
        'ماذا تفعل عند رؤية محتوى غير لائق بالخطأ؟',
        'أتابع المشاهدة',
        'أغلق فوراً وأخبر ولي الأمر',
        'أصوّت له',
        'أرسله لأصدقائي',
        'أغلق فوراً وأخبر ولي الأمر',
        'محتوى غير لائق',
      ),
      _q(
        3,
        'ما الهدف من الإبلاغ عن التنمر الإلكتروني؟',
        'زيادة المشاكل',
        'طلب المساعدة وحماية نفسك والآخرين',
        'إخفاء الأدلة',
        'مكافأة المتنمر',
        'طلب المساعدة وحماية نفسك والآخرين',
        'التنمر الإلكتروني',
      ),
      _q(
        3,
        'لماذا قد تكون الروابط في رسائل مجهولة خطيرة؟',
        'لأنها ملونة',
        'قد توصل لمواقع احتيال أو فيروسات',
        'لأنها طويلة',
        'لأنها بالعربية',
        'قد توصل لمواقع احتيال أو فيروسات',
        'الروابط المشبوهة',
      ),
      _q(
        3,
        'من يمكنه مساعدتك عند شعورك بعدم الأمان على الإنترنت؟',
        'أي غريب يعدك بالهدية',
        'ولي الأمر أو معلم موثوق',
        'أول من يرد في الدردشة',
        'لا أحد',
        'ولي الأمر أو معلم موثوق',
        'الإبلاغ عن المشاكل',
      ),
      _q(
        3,
        'ما أفضل استخدام لكلمة المرور؟',
        'مشاركتها مع الأصدقاء',
        'استخدامها لحساب واحد فقط وعدم مشاركتها',
        'كتابتها على ورقة في المدرسة',
        'استخدام نفسها لكل المواقع',
        'استخدامها لحساب واحد فقط وعدم مشاركتها',
        'كلمة المرور',
      ),
      _q(
        4,
        'الالتزام بحدود زمنية للشاشات يساعد على:',
        'زيادة الإدمان',
        'التوازن بين الحياة الواقعية والرقمية',
        'تجاهل الواجبات',
        'إخفاء الهاتف',
        'التوازن بين الحياة الواقعية والرقمية',
        'تغيب عن الواقع',
      ),
      _q(
        4,
        'عند طلب معلومات سرّية في رسالة، يجب أن:',
        'تجيب بسرعة',
        'ترفض وتتحقق مع ولي الأمر',
        'ترسل معلومات جزئية',
        'تثق بالمرسل',
        'ترفض وتتحقق مع ولي الأمر',
        'أسرار على الإنترنت',
      ),
      _q(
        4,
        'التحرش عبر الرسائل يجب أن يُبلّغ عنه لأنّه:',
        'سلوك طبيعي',
        'انتهاك وقد يضر بك ولغيرك',
        'مزحة فقط',
        'مسؤوليتك وحدك',
        'انتهاك وقد يضر بك ولغيرك',
        'التحرش',
      ),
      _q(
        4,
        'الضغط لإرسال صور أو مقاطع يُعد:',
        'لطفاً من الطرف الآخر',
        'إلحاحاً خطيراً يجب رفضه وإخبار ولي الأمر',
        'موافقة ضمنية',
        'تحدياً يجب قبوله',
        'إلحاحاً خطيراً يجب رفضه وإخبار ولي الأمر',
        'الإلحاح والضغط',
      ),
      _q(
        4,
        'البرمجيات الخانقة قد تطلب منك:',
        'دفع فدية أو تعطيل جهازك',
        'تحديث النظام فقط',
        'تغيير الخلفية',
        'زيادة الصوت',
        'دفع فدية أو تعطيل جهازك',
        'برمجيات خانقة',
      ),
      _q(
        4,
        'عند التعرض لمحتوى للكبار وأنت طفل، الأصح أن:',
        'تكمل المشاهدة سراً',
        'تغلق وتخبر ولي الأمر',
        'تشاركها مع أصدقائك',
        'تصوّر الشاشة للاحتفاظ',
        'تغلق وتخبر ولي الأمر',
        'محتوى لأقل',
      ),
    ];
  }

  Map<String, Object?> _q(
    int level,
    String question,
    String a,
    String b,
    String c,
    String d,
    String correct,
    String category,
  ) {
    return {
      'question': question,
      'option_a': a,
      'option_b': b,
      'option_c': c,
      'option_d': d,
      'correct_answer': correct,
      'category': category,
      'level': level,
    };
  }

  Future<bool> isParentPinTaken(String pin) async {
    final db = await database;
    final r = await db.query('parents', where: 'pin = ?', whereArgs: [pin]);
    return r.isNotEmpty;
  }

  Future<int> registerParent({
    required String name,
    String? email,
    required String pin,
  }) async {
    final db = await database;
    return db.insert('parents', {
      'name': name,
      'email': email ?? '',
      'pin': pin,
    });
  }

  Future<ParentModel?> getParentById(int id) async {
    final db = await database;
    final rows = await db.query('parents', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return ParentModel.fromMap(rows.first);
  }

  Future<ParentModel?> loginParentByPin(String pin) async {
    final db = await database;
    final rows = await db.query('parents', where: 'pin = ?', whereArgs: [pin]);
    if (rows.isEmpty) return null;
    return ParentModel.fromMap(rows.first);
  }

  Future<ParentModel?> getParentByPin(String pin) async {
    return loginParentByPin(pin);
  }

  Future<void> updateParent(
    int id, {
    String? name,
    String? email,
    String? pin,
  }) async {
    final db = await database;
    final map = <String, Object?>{};
    if (name != null) map['name'] = name;
    if (email != null) map['email'] = email;
    if (pin != null) map['pin'] = pin;
    if (map.isEmpty) return;
    await db.update('parents', map, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countParents() async {
    final db = await database;
    final r = await db.rawQuery('SELECT COUNT(*) as c FROM parents');
    return Sqflite.firstIntValue(r) ?? 0;
  }

  Future<int> insertChild({
    required int parentId,
    required String name,
    int? age,
    required String pin,
  }) async {
    final db = await database;
    return db.insert('children', {
      'parent_id': parentId,
      'name': name,
      'age': age,
      'pin': pin,
      'status': 'active',
    });
  }

  Future<List<ChildModel>> getChildrenForParent(int parentId) async {
    final db = await database;
    final rows = await db.query(
      'children',
      where: 'parent_id = ?',
      whereArgs: [parentId],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(ChildModel.fromMap).toList();
  }

  Future<List<ChildModel>> getActiveChildrenForLogin() async {
    final db = await database;
    final rows = await db.query(
      'children',
      where: "status = 'active'",
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(ChildModel.fromMap).toList();
  }

  Future<List<ChildModel>> getAllChildren() async {
    final db = await database;
    final rows = await db.query('children', orderBy: 'name COLLATE NOCASE');
    return rows.map(ChildModel.fromMap).toList();
  }

  Future<ChildModel?> getChildById(int id) async {
    final db = await database;
    final rows = await db.query('children', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return ChildModel.fromMap(rows.first);
  }

  Future<void> updateChild(
    int id, {
    String? name,
    int? age,
    String? pin,
    String? status,
  }) async {
    final db = await database;
    final map = <String, Object?>{};
    if (name != null) map['name'] = name;
    if (age != null) map['age'] = age;
    if (pin != null) map['pin'] = pin;
    if (status != null) map['status'] = status;
    if (map.isEmpty) return;
    await db.update('children', map, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteChild(int id) async {
    final db = await database;
    await db.delete('progress', where: 'child_id = ?', whereArgs: [id]);
    await db.delete('children', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> verifyChildPin(int childId, String pin) async {
    final child = await getChildById(childId);
    return child != null &&
        child.pin == pin &&
        child.status == 'active';
  }

  Future<List<VideoModel>> getVideosByCategory(String? category) async {
    final db = await database;
    final rows = category == null || category.isEmpty
        ? await db.query('videos', orderBy: 'order_index ASC')
        : await db.query(
            'videos',
            where: 'category = ?',
            whereArgs: [category],
            orderBy: 'order_index ASC',
          );
    return rows.map(VideoModel.fromMap).toList();
  }

  Future<List<VideoModel>> getAllVideos() async {
    return getVideosByCategory(null);
  }

  Future<List<GameModel>> getAllGames() async {
    final db = await database;
    final rows = await db.query('games', orderBy: 'level ASC');
    return rows.map(GameModel.fromMap).toList();
  }

  Future<List<QuizModel>> getQuizzesByLevel(int level, {int limit = 100}) async {
    final db = await database;
    final rows = await db.query(
      'quizzes',
      where: 'level = ?',
      whereArgs: [level],
      limit: limit,
    );
    return rows.map(QuizModel.fromMap).toList();
  }

  Future<List<QuizModel>> getQuizSetForLevel(int level, int count) async {
    final all = await getQuizzesByLevel(level);
    if (all.length <= count) return all;
    all.shuffle();
    return all.take(count).toList();
  }

  Future<void> insertProgress({
    required int childId,
    required String activityType,
    required int activityId,
    int score = 0,
    int completed = 1,
  }) async {
    final db = await database;
    await db.insert('progress', {
      'child_id': childId,
      'activity_type': activityType,
      'activity_id': activityId,
      'score': score,
      'completed': completed,
    });
  }

  Future<bool> isGameLevelCompleted(int childId, int level) async {
    final db = await database;
    final r = await db.query(
      'progress',
      where: 'child_id = ? AND activity_type = ? AND activity_id = ? AND completed = 1',
      whereArgs: [childId, AppConstants.activityGame, level],
    );
    return r.isNotEmpty;
  }

  Future<bool> isVideoCompleted(int childId, int videoId) async {
    final db = await database;
    final r = await db.query(
      'progress',
      where: 'child_id = ? AND activity_type = ? AND activity_id = ? AND completed = 1',
      whereArgs: [childId, AppConstants.activityVideo, videoId],
    );
    return r.isNotEmpty;
  }

  Future<bool> isQuizCompleted(int childId, int quizIndex) async {
    final db = await database;
    final r = await db.query(
      'progress',
      where: 'child_id = ? AND activity_type = ? AND activity_id = ? AND completed = 1',
      whereArgs: [childId, AppConstants.activityQuiz, quizIndex],
    );
    return r.isNotEmpty;
  }

  Future<int> countVideosWatched(int childId) async {
    final db = await database;
    final r = await db.rawQuery(
      'SELECT COUNT(*) as c FROM progress WHERE child_id = ? AND activity_type = ? AND completed = 1',
      [childId, AppConstants.activityVideo],
    );
    return Sqflite.firstIntValue(r) ?? 0;
  }

  Future<Map<String, dynamic>> getGameStats(int childId) async {
    final db = await database;
    final rows = await db.query(
      'progress',
      where: 'child_id = ? AND activity_type = ? AND completed = 1',
      whereArgs: [childId, AppConstants.activityGame],
    );
    final count = rows.length;
    var sumStars = 0;
    for (final m in rows) {
      sumStars += (m['score'] as int?) ?? 0;
    }
    final avg = count == 0 ? 0.0 : sumStars / count;
    return {'count': count, 'avgStars': avg};
  }

  Future<Map<String, dynamic>> getQuizStats(int childId) async {
    final db = await database;
    final rows = await db.query(
      'progress',
      where: 'child_id = ? AND activity_type = ? AND completed = 1',
      whereArgs: [childId, AppConstants.activityQuiz],
    );
    final count = rows.length;
    var sumScore = 0;
    for (final m in rows) {
      sumScore += (m['score'] as int?) ?? 0;
    }
    final avg = count == 0 ? 0.0 : sumScore / count;
    return {'count': count, 'avgScore': avg};
  }

  Future<String?> getLastActivityTime(int childId) async {
    final db = await database;
    final rows = await db.query(
      'progress',
      where: 'child_id = ?',
      whereArgs: [childId],
      orderBy: 'completed_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['completed_at'] as String?;
  }

  Future<List<ProgressModel>> getProgressForChild(int childId) async {
    final db = await database;
    final rows = await db.query(
      'progress',
      where: 'child_id = ?',
      whereArgs: [childId],
      orderBy: 'completed_at DESC',
    );
    return rows.map(ProgressModel.fromMap).toList();
  }
}

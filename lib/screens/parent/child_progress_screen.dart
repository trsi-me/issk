import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/database_helper.dart';
import '../../models/child_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

class ChildProgressScreen extends StatefulWidget {
  const ChildProgressScreen({
    super.key,
    this.parentId,
    this.embedded = false,
  });

  /// عند التمرير يعرض أبناء هذا الولي فقط.
  final int? parentId;
  final bool embedded;

  @override
  State<ChildProgressScreen> createState() => _ChildProgressScreenState();
}

class _ChildProgressScreenState extends State<ChildProgressScreen> {
  final _db = DatabaseHelper.instance;
  List<ChildModel> _children = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = widget.parentId != null
        ? await _db.getChildrenForParent(widget.parentId!)
        : await _db.getAllChildren();
    setState(() => _children = c);
  }

  @override
  Widget build(BuildContext context) {
    final content = RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final ch in _children)
            FutureBuilder<_Stats>(
              future: _buildStats(ch),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  );
                }
                final s = snap.data!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(ch.name, style: AppTextStyles.heading1.copyWith(fontSize: 22)),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Table(
                          border: TableBorder.all(color: AppColors.textSecondary),
                          columnWidths: const {
                            0: FixedColumnWidth(140),
                            1: FixedColumnWidth(160),
                          },
                          children: [
                            TableRow(
                              children: [
                                _cell('البند', header: true),
                                _cell('القيمة', header: true),
                              ],
                            ),
                            TableRow(
                              children: [
                                _cell('فيديوهات مشاهدة'),
                                _cell('${s.videos}'),
                              ],
                            ),
                            TableRow(
                              children: [
                                _cell('ألعاب مكتملة'),
                                _cell('${s.games}'),
                              ],
                            ),
                            TableRow(
                              children: [
                                _cell('متوسط النجوم (ألعاب)'),
                                _cell(s.gamesAvgStars.toStringAsFixed(1)),
                              ],
                            ),
                            TableRow(
                              children: [
                                _cell('اختبارات مؤداة'),
                                _cell('${s.quizzes}'),
                              ],
                            ),
                            TableRow(
                              children: [
                                _cell('متوسط الدرجات (اختبارات)'),
                                _cell(s.quizAvg.toStringAsFixed(1)),
                              ],
                            ),
                            TableRow(
                              children: [
                                _cell('آخر نشاط'),
                                _cell(s.lastActivity),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
            ),
          if (_children.isEmpty)
            Text('لا بيانات لعرضها.', style: AppTextStyles.bodyText),
        ],
      ),
    );

    if (widget.embedded) {
      return ColoredBox(color: AppColors.surface, child: content);
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('متابعة تقدم الطفل')),
      body: content,
    );
  }

  Widget _cell(String text, {bool header = false}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: header
            ? AppTextStyles.buttonText.copyWith(color: AppColors.primary, fontSize: 14)
            : AppTextStyles.bodyText,
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<_Stats> _buildStats(ChildModel ch) async {
    final videos = await _db.countVideosWatched(ch.id);
    final g = await _db.getGameStats(ch.id);
    final q = await _db.getQuizStats(ch.id);
    final last = await _db.getLastActivityTime(ch.id);
    String lastStr = '—';
    if (last != null) {
      try {
        final dt = DateTime.parse(last);
        lastStr = DateFormat('yyyy-MM-dd HH:mm').format(dt);
      } catch (_) {
        lastStr = last;
      }
    }
    return _Stats(
      videos: videos,
      games: g['count'] as int,
      gamesAvgStars: (g['avgStars'] as num).toDouble(),
      quizzes: q['count'] as int,
      quizAvg: (q['avgScore'] as num).toDouble(),
      lastActivity: lastStr,
    );
  }
}

class _Stats {
  _Stats({
    required this.videos,
    required this.games,
    required this.gamesAvgStars,
    required this.quizzes,
    required this.quizAvg,
    required this.lastActivity,
  });

  final int videos;
  final int games;
  final double gamesAvgStars;
  final int quizzes;
  final double quizAvg;
  final String lastActivity;
}

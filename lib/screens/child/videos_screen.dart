import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../models/video_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_radius.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/section_header.dart';
import 'video_player_screen.dart';

/// صفحة واحدة للفيديوهات: بحث، تصنيفات، وأقسام حسب الموضوع.
class VideosScreen extends StatefulWidget {
  const VideosScreen({
    super.key,
    required this.childId,
  });

  final int childId;

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final _db = DatabaseHelper.instance;
  final _search = TextEditingController();
  List<VideoModel> _all = [];
  /// null = عرض الكل مع التجميع حسب الموضوع
  String? _categoryFilter;

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final v = await _db.getAllVideos();
    setState(() => _all = v);
  }

  List<VideoModel> _applyFilters() {
    var list = List<VideoModel>.from(_all);
    final q = _search.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((v) {
        final t = v.title.toLowerCase();
        final d = (v.description ?? '').toLowerCase();
        return t.contains(q) || d.contains(q);
      }).toList();
    }
    if (_categoryFilter != null) {
      list = list.where((v) => v.category == _categoryFilter).toList();
    }
    return list;
  }

  /// تجميع حسب التصنيف مع احترام ترتيب CST، وأي تصنيفات قديمة أو إضافية تُعرض في النهاية.
  Map<String, List<VideoModel>> _groupByCategory(List<VideoModel> items) {
    final byCat = <String, List<VideoModel>>{};
    for (final v in items) {
      byCat.putIfAbsent(v.category, () => []).add(v);
    }
    final out = <String, List<VideoModel>>{};
    for (final c in AppConstants.videoCategories) {
      if (byCat.containsKey(c)) {
        out[c] = List<VideoModel>.from(byCat[c]!);
      }
    }
    for (final e in byCat.entries) {
      if (!out.containsKey(e.key)) {
        out[e.key] = List<VideoModel>.from(e.value);
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _applyFilters();
    final grouped = _groupByCategory(filtered);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الفيديوهات التعليمية'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _search,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'بحث في العناوين والوصف…',
                        hintStyle: AppTextStyles.caption,
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'تصنيف المواضيع',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _FilterChip(
                          label: 'الكل',
                          selected: _categoryFilter == null,
                          onTap: () => setState(() => _categoryFilter = null),
                        ),
                        for (final c in AppConstants.videoCategories)
                          _FilterChip(
                            label: c,
                            selected: _categoryFilter == c,
                            onTap: () => setState(() {
                              _categoryFilter = _categoryFilter == c ? null : c;
                            }),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_library_outlined, size: 56, color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        Text(
                          'لا توجد نتائج مطابقة.',
                          style: AppTextStyles.heading2.copyWith(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'جرّب تغيير البحث أو التصنيف.',
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_categoryFilter == null && _search.text.trim().isEmpty)
              ..._sliverSectionsGrouped(grouped)
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final v = filtered[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _VideoTile(
                          video: v,
                          onWatch: () => _openPlayer(v),
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _sliverSectionsGrouped(Map<String, List<VideoModel>> grouped) {
    final widgets = <Widget>[];
    for (final entry in grouped.entries) {
      widgets.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SectionHeader(title: entry.key, icon: Icons.folder_outlined),
          ),
        ),
      );
      widgets.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final v = entry.value[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _VideoTile(
                    video: v,
                    onWatch: () => _openPlayer(v),
                  ),
                );
              },
              childCount: entry.value.length,
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  void _openPlayer(VideoModel v) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => VideoPlayerScreen(
          childId: widget.childId,
          video: v,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: selected ? Colors.white : AppColors.textDark,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({
    required this.video,
    required this.onWatch,
  });

  final VideoModel video;
  final VoidCallback onWatch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.play_circle_fill, color: AppColors.primary, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: AppTextStyles.heading2.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    video.category,
                    style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                  ),
                ),
                if (video.description != null && video.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    video.description!,
                    style: AppTextStyles.caption,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          TextButton(
            onPressed: onWatch,
            child: Text('مشاهدة', style: AppTextStyles.bodyText.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

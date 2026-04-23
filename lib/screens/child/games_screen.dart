import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../models/game_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_radius.dart';
import '../../utils/app_text_styles.dart';
import 'game_play_screen.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({
    super.key,
    required this.childId,
    this.embedded = false,
  });

  final int childId;
  final bool embedded;

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  final _db = DatabaseHelper.instance;
  List<GameModel> _games = [];
  final Map<int, bool> _unlocked = {};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final g = await _db.getAllGames();
    for (final game in g) {
      if (game.level == 1) {
        _unlocked[game.level] = true;
      } else {
        final prev = await _db.isGameLevelCompleted(widget.childId, game.level - 1);
        _unlocked[game.level] = prev;
      }
    }
    setState(() => _games = g);
  }

  @override
  Widget build(BuildContext context) {
    final list = RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: _games.length,
        itemBuilder: (context, index) {
            final g = _games[index];
            final open = _unlocked[g.level] ?? false;
            final br = BorderRadius.circular(AppRadius.xl);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Material(
                elevation: open ? 2 : 0,
                shadowColor: AppColors.primary.withValues(alpha: 0.25),
                color: open ? AppColors.primary : AppColors.textSecondary,
                borderRadius: br,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  borderRadius: br,
                    onTap: open
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => GamePlayScreen(
                                  childId: widget.childId,
                                  level: g.level,
                                  title: g.title,
                                  gameType: g.gameType,
                                ),
                              ),
                            ).then((_) => _refresh());
                          }
                        : null,
                    child: SizedBox(
                      height: 72,
                      child: Row(
                        children: [
                          const SizedBox(width: 18),
                          Icon(
                            open ? Icons.sports_esports_rounded : Icons.lock_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  g.title,
                                  style: AppTextStyles.buttonText.copyWith(fontSize: 16),
                                ),
                                Text(
                                  'المستوى ${g.level}',
                                  style: AppTextStyles.caption.copyWith(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            );
          },
        ),
    );

    if (widget.embedded) {
      return ColoredBox(
        color: AppColors.background,
        child: list,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('الألعاب التعليمية')),
      body: list,
    );
  }
}

class GameModel {
  const GameModel({
    required this.id,
    required this.title,
    required this.level,
    required this.gameType,
  });

  final int id;
  final String title;
  final int level;
  final String gameType;

  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      id: map['id'] as int,
      title: map['title'] as String,
      level: map['level'] as int,
      gameType: map['game_type'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'level': level,
      'game_type': gameType,
    };
  }
}

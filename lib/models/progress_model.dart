class ProgressModel {
  const ProgressModel({
    required this.id,
    required this.childId,
    required this.activityType,
    required this.activityId,
    this.score = 0,
    this.completed = 0,
    this.completedAt,
  });

  final int id;
  final int childId;
  final String activityType;
  final int activityId;
  final int score;
  final int completed;
  final String? completedAt;

  factory ProgressModel.fromMap(Map<String, dynamic> map) {
    return ProgressModel(
      id: map['id'] as int,
      childId: map['child_id'] as int,
      activityType: map['activity_type'] as String,
      activityId: map['activity_id'] as int,
      score: (map['score'] as int?) ?? 0,
      completed: (map['completed'] as int?) ?? 0,
      completedAt: map['completed_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'child_id': childId,
      'activity_type': activityType,
      'activity_id': activityId,
      'score': score,
      'completed': completed,
      'completed_at': completedAt,
    };
  }
}

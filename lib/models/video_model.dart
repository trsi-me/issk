class VideoModel {
  const VideoModel({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.assetPath,
    this.youtubeVideoId,
    this.orderIndex = 0,
  });

  final int id;
  final String title;
  final String? description;
  final String category;
  final String assetPath;
  final String? youtubeVideoId;
  final int orderIndex;

  bool get hasYoutube =>
      youtubeVideoId != null && youtubeVideoId!.trim().isNotEmpty;

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      category: map['category'] as String,
      assetPath: map['asset_path'] as String,
      youtubeVideoId: map['youtube_video_id'] as String?,
      orderIndex: (map['order_index'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'asset_path': assetPath,
      'youtube_video_id': youtubeVideoId,
      'order_index': orderIndex,
    };
  }
}

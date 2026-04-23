import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../database/database_helper.dart';
import '../../models/video_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({
    super.key,
    required this.childId,
    required this.video,
  });

  final int childId;
  final VideoModel video;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;
  bool _loading = true;
  bool _unavailable = false;
  final _db = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    if (widget.video.hasYoutube) {
      _initYoutube();
    } else {
      _initAsset();
    }
  }

  void _initYoutube() {
    final id = widget.video.youtubeVideoId!.trim();
    _youtubeController = YoutubePlayerController(
      initialVideoId: id,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        hideControls: false,
      ),
    );
    setState(() => _loading = false);
  }

  Future<void> _initAsset() async {
    try {
      final c = VideoPlayerController.asset(widget.video.assetPath);
      await c.initialize();
      if (!mounted) return;
      _videoController = c;
      _chewieController = ChewieController(
        videoPlayerController: c,
        autoPlay: false,
        looping: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.secondary,
          handleColor: AppColors.primary,
          backgroundColor: AppColors.textSecondary,
          bufferedColor: AppColors.surface,
        ),
      );
      setState(() => _loading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _unavailable = true;
      });
    }
  }

  Future<void> _markWatched() async {
    await _db.insertProgress(
      childId: widget.childId,
      activityType: AppConstants.activityVideo,
      activityId: widget.video.id,
      score: 1,
      completed: 1,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تسجيل المشاهدة')),
    );
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  /// يحسب أبعاد 16:9 لتناسب المساحة دون قصّ المحتوى.
  Widget _fittedVideoArea(Widget player) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;
        var w = maxW;
        var h = w * 9 / 16;
        if (h > maxH) {
          h = maxH;
          w = h * 16 / 9;
        }
        return Center(
          child: SizedBox(
            width: w,
            height: h,
            child: player,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.video.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.buttonText.copyWith(fontSize: 16),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
          : _unavailable
              ? ColoredBox(
                  color: AppColors.background,
                  child: _unavailableMsg(),
                )
              : _youtubeController != null
                  ? Column(
                      children: [
                        Expanded(
                          child: ColoredBox(
                            color: Colors.black,
                            child: _fittedVideoArea(
                              YoutubePlayer(
                                controller: _youtubeController!,
                                showVideoProgressIndicator: true,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          color: AppColors.background,
                          padding: const EdgeInsets.all(16),
                          child: SafeArea(
                            top: false,
                            child: CustomButton(
                              text: 'أنهيت المشاهدة',
                              onPressed: _markWatched,
                              width: double.infinity,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    )
                  : _chewieController != null
                      ? Column(
                          children: [
                            Expanded(
                              child: ColoredBox(
                                color: Colors.black,
                                child: _fittedVideoArea(
                                  Chewie(controller: _chewieController!),
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              color: AppColors.background,
                              padding: const EdgeInsets.all(16),
                              child: SafeArea(
                                top: false,
                                child: CustomButton(
                                  text: 'أنهيت المشاهدة',
                                  onPressed: _markWatched,
                                  width: double.infinity,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ColoredBox(
                          color: AppColors.background,
                          child: _unavailableMsg(),
                        ),
    );
  }

  Widget _unavailableMsg() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          Text(
            'الفيديو غير متاح حالياً',
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'تحقق من الاتصال أو جرّب لاحقاً.',
            style: AppTextStyles.bodyText,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

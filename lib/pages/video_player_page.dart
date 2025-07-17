import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../providers/app_provider.dart';
import '../models/video_model.dart';
import '../utils/constants.dart';
import '../widgets/custom_app_bar.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoId;

  const VideoPlayerPage({super.key, required this.videoId});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _controller;
  VideoModel? video;
  // bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    video = provider.videos.firstWhere(
      (v) => v.id == widget.videoId,
      orElse: () => VideoModel(
        id: '',
        title: 'Video tidak ditemukan',
        description: '',
        youtubeId: '',
        thumbnailUrl: '',
        duration: '',
        category: '',
      ),
    );

    if (video!.youtubeId.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: video!.youtubeId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          captionLanguage: 'id',
        ),
      );
    }
  }

  @override
  void dispose() {
    if (video?.youtubeId.isNotEmpty == true) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (video == null || video!.youtubeId.isEmpty) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Video Player', maxLines: 1),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Video tidak dapat dimuat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Periksa koneksi internet atau coba lagi nanti',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        // Handle exit fullscreen
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppConstants.primaryColor,
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              video!.title,
              style: const TextStyle(color: Colors.white, fontSize: 18.0),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
        onReady: () {
          setState(() {
            // Remove this line since _isPlayerReady is commented out and unused
          });
        },
        onEnded: (data) {
          // Handle video end
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video selesai diputar'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
      builder: (context, player) => Scaffold(
        appBar: CustomAppBar(title: video!.title, maxLines: 1),
        body: Column(
          children: [
            // Video player
            player,

            // Video details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      video!.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Category and duration
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppConstants.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            video!.category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingMedium),
                        if (video!.duration.isNotEmpty)
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                video!.duration,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),

                    // Description
                    const Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      video!.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Share functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Fitur berbagi akan segera tersedia',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.share),
                            label: const Text('Bagikan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingMedium),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Bookmark functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Video ditambahkan ke bookmark',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.bookmark_add),
                            label: const Text('Simpan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

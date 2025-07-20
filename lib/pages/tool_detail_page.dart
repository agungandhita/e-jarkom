import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/custom_app_bar.dart';

class ToolDetailPage extends StatefulWidget {
  final String toolId;

  const ToolDetailPage({super.key, required this.toolId});

  @override
  State<ToolDetailPage> createState() => _ToolDetailPageState();
}

class _ToolDetailPageState extends State<ToolDetailPage> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
  }

  void _initializeVideoPlayer(String videoUrl) {
    if (videoUrl.isNotEmpty) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoUrl,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return FutureBuilder(
          future: provider.getToolById(widget.toolId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: CustomAppBar(title: 'Detail Alat', maxLines: 1),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            final tool = snapshot.data;
            if (tool == null) {
              return Scaffold(
                appBar: CustomAppBar(title: 'Detail Alat', maxLines: 1),
                body: const Center(child: Text('Alat tidak ditemukan')),
              );
            }

            // Initialize video player when tool data is available
            if (_youtubeController == null && tool.videoUrl.isNotEmpty) {
              _initializeVideoPlayer(tool.videoUrl);
            }

            return Scaffold(
              backgroundColor: Colors.grey[50],
              appBar: CustomAppBar(
                maxLines: 1,
                title: tool.name,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      AppHelpers.showSnackBar(
                        context,
                        'Fitur berbagi akan segera tersedia!',
                      );
                    },
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tool image
                    Container(
                      width: double.infinity,
                      height: 250,
                      color: Colors.grey[200],
                      child: tool.imageUrl.isNotEmpty
                          ? Image.network(
                              tool.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderImage();
                              },
                            )
                          : _buildPlaceholderImage(),
                    ),

                    // Tool info
                    Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tool name and category
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  tool.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.paddingMedium,
                                  vertical: AppConstants.paddingSmall,
                                ),
                                decoration: BoxDecoration(
                                  color: AppConstants.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.radiusSmall,
                                  ),
                                ),
                                child: Text(
                                  tool.category,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppConstants.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppConstants.paddingLarge),

                          // Description section
                          _buildSection(
                            'Deskripsi',
                            tool.description,
                            Icons.description,
                          ),

                          const SizedBox(height: AppConstants.paddingLarge),

                          // Function section
                          _buildSection('Fungsi', tool.function, Icons.settings),

                          const SizedBox(height: AppConstants.paddingLarge),

                          // Video section
                          if (_youtubeController != null) ...[
                            _buildVideoSection(),
                            const SizedBox(height: AppConstants.paddingLarge),
                          ],

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    AppHelpers.showSnackBar(
                                      context,
                                      'Alat ditambahkan ke favorit!',
                                    );
                                  },
                                  icon: const Icon(Icons.favorite_border),
                                  label: const Text('Favorit'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppConstants.primaryColor,
                                    side: const BorderSide(
                                      color: AppConstants.primaryColor,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.radiusMedium,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppConstants.paddingMedium),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    AppHelpers.showSnackBar(
                                      context,
                                      'Fitur bookmark akan segera tersedia!',
                                    );
                                  },
                                  icon: const Icon(Icons.bookmark_border),
                                  label: const Text('Simpan'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppConstants.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.radiusMedium,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[100],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.build, size: 80, color: Colors.grey),
          SizedBox(height: AppConstants.paddingSmall),
          Text(
            'Gambar tidak tersedia',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppConstants.primaryColor, size: 20),
              const SizedBox(width: AppConstants.paddingSmall),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.play_circle,
                color: AppConstants.primaryColor,
                size: 20,
              ),
              SizedBox(width: AppConstants.paddingSmall),
              Text(
                'Video Tutorial',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            child: YoutubePlayer(
              controller: _youtubeController!,
              showVideoProgressIndicator: true,
              onReady: () {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}

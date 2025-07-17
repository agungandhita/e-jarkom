import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/video_card.dart';
import 'video_player_page.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  String _selectedCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(title: 'Video Pembelajaran', maxLines: 1),
      body: Column(
        children: [
          // Category filter
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kategori Video',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                SizedBox(
                  height: 40,
                  child: Consumer<AppProvider>(
                    builder: (context, provider, child) {
                      final categories = [
                        'Semua',
                        ...AppConstants.toolCategories,
                      ];
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = _selectedCategory == category;

                          return Padding(
                            padding: const EdgeInsets.only(
                              right: AppConstants.paddingSmall,
                            ),
                            child: FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: AppConstants.primaryColor
                                  .withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? AppConstants.primaryColor
                                    : Colors.black54,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Videos list
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, provider, child) {
                var videos = provider.videos;

                // Filter by category
                if (_selectedCategory != 'Semua') {
                  videos = videos
                      .where((video) => video.category == _selectedCategory)
                      .toList();
                }

                if (videos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.video_library_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        Text(
                          'Belum ada video tersedia',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          'Video pembelajaran akan segera ditambahkan',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.paddingMedium,
                      ),
                      child: VideoCard(
                        video: video,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VideoPlayerPage(videoId: video.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

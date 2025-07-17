import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../utils/constants.dart';

class VideoCard extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onTap;

  const VideoCard({super.key, required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppConstants.borderRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.radiusMedium),
              ),
              child: Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      image: video.thumbnailUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(video.thumbnailUrl),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                // Handle image loading error
                              },
                            )
                          : null,
                    ),
                    child: video.thumbnailUrl.isEmpty
                        ? const Center(
                            child: Icon(
                              Icons.video_library,
                              size: 50,
                              color: Colors.grey,
                            ),
                          )
                        : null,
                  ),
                  // Play button overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: const Center(
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.play_arrow,
                            size: 40,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Duration badge
                  if (video.duration.isNotEmpty)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video.duration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Video info
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    video.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),

                  // Description
                  Text(
                    video.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // Category badge
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
                          video.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.play_circle_outline,
                        color: AppConstants.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tonton',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
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
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';

class UserProfileCard extends StatelessWidget {
  final VoidCallback? onTap;

  const UserProfileCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final user = provider.currentUser;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              gradient: AppConstants.primaryGradient,
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Profile picture
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                    child: user.profileImageUrl.isNotEmpty
                        ? Image.network(
                            user.profileImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 30,
                                color: AppConstants.primaryColor,
                              );
                            },
                          )
                        : const Icon(
                            Icons.person,
                            size: 30,
                            color: AppConstants.primaryColor,
                          ),
                  ),
                ),

                const SizedBox(width: AppConstants.paddingMedium),

                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.className,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      // Progress bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progress: ${user.completedQuizzes}/${user.totalQuizzes}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: user.progressPercentage / 100,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppConstants.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                if (onTap != null)
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                    size: 16,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

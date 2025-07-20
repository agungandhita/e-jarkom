import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/menu_card.dart';
// import '../widgets/user_profile_card.dart';
import 'encyclopedia_page.dart';
import 'profile_page.dart';
import 'videos_page.dart';
import 'quiz_page.dart';
import 'about_page.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        maxLines: 1,
        title: 'Menu Utama',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Consumer<AppProvider>(
              builder: (context, provider, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  decoration: BoxDecoration(
                    gradient: AppConstants.primaryGradient,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusLarge,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang, ${provider.currentUser?.name ?? 'Pengguna'}!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        'Kelas: ${provider.currentUser?.className ?? 'Tidak tersedia'}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Row(
                        children: [
                          const Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: AppConstants.paddingSmall),
                          Text(
                            'Progress: ${provider.currentUser?.completedQuizzes ?? 0}/${provider.currentUser?.totalQuizzes ?? 0} Kuis',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Section title
            const Text(
              'Pilih Menu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Menu grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppConstants.paddingMedium,
                mainAxisSpacing: AppConstants.paddingMedium,
                childAspectRatio: 1.1,
              ),
              itemCount: AppConstants.mainMenuItems.length,
              itemBuilder: (context, index) {
                final menuItem = AppConstants.mainMenuItems[index];
                return MenuCard(
                  title: menuItem['title'],
                  subtitle: menuItem['subtitle'],
                  icon: menuItem['icon'],
                  color: menuItem['color'],
                  onTap: () => _navigateToPage(context, menuItem['route']),
                );
              },
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Quick stats
            Container(
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
                  const Text(
                    'Statistik Pembelajaran',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Consumer<AppProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        children: [
                          _buildStatRow(
                            'Total Alat',
                            '${provider.tools.length}',
                            Icons.build,
                            Colors.blue,
                          ),
                          const SizedBox(height: AppConstants.paddingSmall),
                          _buildStatRow(
                            'Video Tersedia',
                            '${provider.videos.length}',
                            Icons.play_circle,
                            Colors.red,
                          ),
                          const SizedBox(height: AppConstants.paddingSmall),
                          _buildStatRow(
                            'Soal Kuis',
                            '${provider.quizQuestions.length}',
                            Icons.quiz,
                            Colors.green,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppConstants.paddingMedium),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _navigateToPage(BuildContext context, String route) {
    Widget page;
    switch (route) {
      case '/encyclopedia':
        page = const EncyclopediaPage();
        break;
      case '/videos':
        page = const VideosPage();
        break;
      case '/quiz':
        page = const QuizPage();
        break;
      case '/about':
        page = const AboutPage();
        break;
      default:
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}

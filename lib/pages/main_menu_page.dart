import 'package:e_jarkom/presentation/widgets/common/custom_app_bar.dart';
import 'package:e_jarkom/presentation/widgets/common/menu_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/providers/tool_provider.dart';
import '../core/constants/app_constants.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/tools/tools_list_screen.dart';
import '../screens/video/video_list_screen.dart';
import '../screens/quiz/quiz_level_screen.dart';

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
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMediumValue),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Consumer<AuthProvider>(
              builder: (context, provider, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.paddingLargeValue),
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
                      const SizedBox(height: AppConstants.paddingSmallValue),
                      Text(
                        'Kelas: ${provider.currentUser?.kelas ?? 'Tidak tersedia'}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMediumValue),
                      Row(
                        children: [
                          const Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: AppConstants.paddingSmallValue),
                          Text(
                            'Progress: ${provider.currentUser?.completedQuiz ?? 0}/${provider.currentUser?.totalQuiz ?? 0} Kuis',
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

            const SizedBox(height: AppConstants.paddingLargeValue),

            // Section title
            const Text(
              'Pilih Menu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: AppConstants.paddingMediumValue),

            // Menu grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppConstants.paddingMediumValue,
                mainAxisSpacing: AppConstants.paddingMediumValue,
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

            const SizedBox(height: AppConstants.paddingLargeValue),

            // Quick stats
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingLargeValue),
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
                  const SizedBox(height: AppConstants.paddingMediumValue),
                  Consumer<ToolProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        children: [
                          _buildStatRow(
                            'Total Alat',
                            '${provider.tools.length}',
                            Icons.build,
                            Colors.blue,
                          ),
                          const SizedBox(height: AppConstants.paddingSmallValue),
                          _buildStatRow(
                            'Video Tersedia',
                            '12',
                            Icons.play_circle,
                            Colors.red,
                          ),
                          const SizedBox(height: AppConstants.paddingSmallValue),
                          _buildStatRow(
                            'Soal Kuis',
                            '25',
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
        const SizedBox(width: AppConstants.paddingMediumValue),
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
        page = const ToolsListScreen(); // Changed from EncyclopediaPage
        break;
      case '/videos':
        page = const VideoListScreen(); // Changed from VideosPage
        break;
      case '/quiz':
        page = const QuizLevelScreen(); // Changed from QuizPage
        break;
      case '/about':
        page = const ProfileScreen(); // Changed from AboutPage to ProfileScreen
        break;
      default:
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}

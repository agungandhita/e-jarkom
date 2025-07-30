import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/tool_provider.dart';
import '../../presentation/providers/quiz_provider.dart';
import '../../presentation/providers/video_provider.dart';
import '../../presentation/providers/dashboard_provider.dart';
import '../../models/user_model.dart';
import '../tools/tool_detail_screen.dart';
import '../quiz/quiz_level_screen.dart';
import '../tools/tools_list_screen.dart';
import '../video/video_list_screen.dart';
import '../video/video_player_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDashboardData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  Future<void> _loadDashboardData() async {
    final toolProvider = context.read<ToolProvider>();
    final quizProvider = context.read<QuizProvider>();
    final videoProvider = context.read<VideoProvider>();
    final dashboardProvider = context.read<DashboardProvider>();

    await Future.wait(
      [
            quizProvider.loadQuizLevel(),
            quizProvider.loadUserScores(
              refresh: true,
            ), // Load user-specific quiz scores
            // videoProvider.loadFeaturedVideos(),
            dashboardProvider.loadDashboardStats(),
          ]
          as Iterable<Future>,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          return RefreshIndicator(
            onRefresh: _loadDashboardData,
            color: theme.colorScheme.primary,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(theme, isDark, user),
                SliverPadding(
                  padding: const EdgeInsets.all(AppConstants.spacingLarge),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Welcome Section
                              _buildWelcomeSection(theme, user),

                              const SizedBox(height: AppConstants.spacingLarge),

                              // Statistics Cards
                              _buildStatisticsSection(theme),

                              const SizedBox(height: AppConstants.spacingLarge),

                              // Quick Actions
                              _buildQuickActionsSection(context, theme),

                              const SizedBox(height: AppConstants.spacingLarge),

                              // Featured Tools
                              _buildFeaturedToolsSection(theme),

                              const SizedBox(height: AppConstants.spacingLarge),

                              // Recent Quiz Results
                              _buildRecentQuizSection(theme),

                              const SizedBox(height: AppConstants.spacingLarge),

                              // Featured Videos
                              _buildFeaturedVideosSection(theme),

                              const SizedBox(
                                height: AppConstants.spacingXXLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme, bool isDark, User? user) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              child: Row(
                children: [
                  // App Logo
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        AppConstants.logoPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 30,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: AppConstants.spacingMedium),

                  // App Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'E-Jarkom SMK',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Ensiklopedia Alat Jaringan',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Notification Icon
                  IconButton(
                    onPressed: () {
                      // TODO: Navigate to notifications
                    },
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme, User? user) {
    // Menggunakan zona waktu Indonesia (WIB)
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final hour = now.hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Selamat Pagi';
    } else if (hour < 15) {
      greeting = 'Selamat Siang';
    } else if (hour < 18) {
      greeting = 'Selamat Sore';
    } else {
      greeting = 'Selamat Malam';
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // User Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            backgroundImage: user?.foto != null
                ? NetworkImage(user!.foto!)
                : null,
            child: user?.foto == null
                ? Text(
                    user?.initials ?? 'U',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),

          const SizedBox(width: AppConstants.spacingMedium),

          // Welcome Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                Text(
                  user?.name ?? 'Pengguna',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (user?.kelas != null)
                  Text(
                    user!.kelas!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.6,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(ThemeData theme) {
    return Consumer4<
      ToolProvider,
      QuizProvider,
      VideoProvider,
      DashboardProvider
    >(
      builder: (context, toolProvider, quizProvider, videoProvider, dashboardProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistik Pembelajaran',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppConstants.spacingMedium),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Total Alat',
                    '${dashboardProvider.userStatistics?.totalToolsViewed ?? 0}',
                    Icons.build,
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMedium),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Quiz Selesai',
                    '${dashboardProvider.userStatistics?.totalQuizTaken ?? 0}',
                    Icons.quiz,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingMedium),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Rata-rata Skor',
                    '${dashboardProvider.userStatistics?.averageScore.toStringAsFixed(1) ?? '0.0'}%',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMedium),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Video Ditonton',
                    '${dashboardProvider.userStatistics?.totalVideosWatched ?? 0}',
                    Icons.play_circle,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusSmall,
                  ),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(Icons.trending_up, color: color, size: 16),
            ],
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, ThemeData theme) {
    final quickActions = [
      {
        'title': 'Mulai Quiz',
        'subtitle': 'Uji pengetahuan Anda',
        'icon': Icons.quiz,
        'color': theme.colorScheme.primary,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QuizLevelScreen()),
        ),
      },
      {
        'title': 'Cari Alat',
        'subtitle': 'Temukan alat yang Anda butuhkan',
        'icon': Icons.search,
        'color': Colors.green,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ToolsListScreen()),
        ),
      },
      {
        'title': 'Tonton Video',
        'subtitle': 'Tutorial dan pembelajaran',
        'icon': Icons.play_circle,
        'color': Colors.orange,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VideoListScreen()),
        ),
      },
      {
        'title': 'Leaderboard',
        'subtitle': 'Lihat ranking Anda',
        'icon': Icons.leaderboard,
        'color': Colors.blue,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        ),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppConstants.spacingMedium),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppConstants.spacingMedium,
            mainAxisSpacing: AppConstants.spacingMedium,
            childAspectRatio: 1.5,
          ),
          itemCount: quickActions.length,
          itemBuilder: (context, index) {
            final action = quickActions[index];
            return _buildQuickActionCard(theme, action);
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(ThemeData theme, Map<String, dynamic> action) {
    return GestureDetector(
      onTap: action['onTap'],
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (action['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusSmall,
                ),
              ),
              child: Icon(action['icon'], color: action['color'], size: 24),
            ),

            const Spacer(),

            Text(
              action['title'],
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              action['subtitle'],
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedToolsSection(ThemeData theme) {
    return Consumer<ToolProvider>(
      builder: (context, toolProvider, child) {
        final featuredTools = toolProvider.tools;

        if (featuredTools.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Alat Unggulan',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ToolsListScreen(),
                    ),
                  ),
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingMedium),

            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: featuredTools.length,
                itemBuilder: (context, index) {
                  final tool = featuredTools[index];
                  return Container(
                    width: 160,
                    margin: EdgeInsets.only(
                      right: index < featuredTools.length - 1
                          ? AppConstants.spacingMedium
                          : 0,
                    ),
                    child: _buildToolCard(context, theme, tool),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToolCard(BuildContext context, ThemeData theme, dynamic tool) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ToolDetailScreen(tool: tool)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tool Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.borderRadiusMedium),
              ),
              child: Container(
                height: 100,
                width: double.infinity,
                color: theme.colorScheme.primary.withOpacity(0.1),
                child: tool.imageUrl != null
                    ? Image.network(
                        tool.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.build,
                            size: 40,
                            color: theme.colorScheme.primary,
                          );
                        },
                      )
                    : Icon(
                        Icons.build,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
              ),
            ),

            // Tool Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: AppConstants.spacingSmall),

                    Text(
                      tool.shortDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          tool.formattedRating,
                          style: theme.textTheme.bodySmall,
                        ),
                        const Spacer(),
                        Text(
                          tool.formattedViewCount,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.6),
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

  Widget _buildRecentQuizSection(ThemeData theme) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        final recentScores =
            (quizProvider.userStatistics?['recentScores'] as List?) ??
            <dynamic>[];

        if (recentScores.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quiz Terbaru',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QuizLevelScreen(),
                    ),
                  ),
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingMedium),

            ...recentScores.map((score) => _buildQuizResultCard(theme, score)),
          ],
        );
      },
    );
  }

  Widget _buildQuizResultCard(ThemeData theme, dynamic score) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getGradeColor(score.grade).withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusSmall,
              ),
            ),
            child: Icon(
              Icons.quiz,
              color: _getGradeColor(score.grade),
              size: 24,
            ),
          ),

          const SizedBox(width: AppConstants.spacingMedium),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quiz ${score.level.displayName}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${score.formattedScore} • ${score.formattedDuration}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingSmall,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _getGradeColor(score.grade),
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusSmall,
              ),
            ),
            child: Text(
              score.grade,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedVideosSection(ThemeData theme) {
    return Consumer<VideoProvider>(
      builder: (context, videoProvider, child) {
        final featuredVideos = videoProvider.videos;

        if (featuredVideos.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Video Unggulan',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VideoListScreen(),
                    ),
                  ),
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingMedium),

            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: featuredVideos.length,
                itemBuilder: (context, index) {
                  final video = featuredVideos[index];
                  return Container(
                    width: 280,
                    margin: EdgeInsets.only(
                      right: index < featuredVideos.length - 1
                          ? AppConstants.spacingMedium
                          : 0,
                    ),
                    child: _buildVideoCard(context, theme, video),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVideoCard(BuildContext context, ThemeData theme, dynamic video) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(video: video),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.borderRadiusMedium),
              ),
              child: Container(
                height: 120,
                width: double.infinity,
                color: Colors.black,
                child: Stack(
                  children: [
                    // YouTube Thumbnail
                    _buildYouTubeThumbnail(video.youtubeUrl ?? ''),
                    // Play Button Overlay
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Play Button Overlay
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),

                    // Video Badge
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Video',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Video Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.judul,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: AppConstants.spacingSmall),

                    Text(
                      video.deskripsi.length > 50
                          ? '${video.deskripsi.substring(0, 50)}...'
                          : video.deskripsi,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            0.6,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          video.createdAt?.toString().split(' ')[0] ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.play_circle_outline,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text('Video', style: theme.textTheme.bodySmall),
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

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
      case 'E':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildYouTubeThumbnail(String youtubeUrl) {
    if (youtubeUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[300],
        child: const Icon(
          Icons.play_circle_outline,
          size: 50,
          color: Colors.grey,
        ),
      );
    }

    final videoId = _extractYouTubeVideoId(youtubeUrl);
    if (videoId == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[300],
        child: const Icon(
          Icons.play_circle_outline,
          size: 50,
          color: Colors.grey,
        ),
      );
    }

    final thumbnailUrl =
        'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';

    return Image.network(
      thumbnailUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey[300],
          child: const Icon(
            Icons.play_circle_outline,
            size: 50,
            color: Colors.grey,
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  String? _extractYouTubeVideoId(String url) {
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }
}

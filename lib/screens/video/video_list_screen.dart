import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/video_provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/video.dart';
import 'video_player_screen.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({Key? key}) : super(key: key);

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String selectedCategory = 'Semua';
  final List<String> categories = [
    'Semua',
    'Dasar Jaringan',
    'Protokol',
    'Keamanan',
    'Troubleshooting',
    'Hardware',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

    // Load videos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VideoProvider>().loadVideos();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Remove mock data - will use VideoProvider instead

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Video Pembelajaran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showSearchDialog(),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Consumer<VideoProvider>(
        builder: (context, videoProvider, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Header Section
                  _buildHeaderSection(theme),

                  // Category Filter
                  _buildCategoryFilter(theme),

                  // Video List
                  Expanded(child: _buildVideoList(theme)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        return Container(
          margin: const EdgeInsets.all(AppConstants.spacingL),
          padding: const EdgeInsets.all(AppConstants.spacingL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // User greeting row
              if (user != null)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, ${user.name}!',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Kelas ${user.kelas}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              
              if (user != null) const SizedBox(height: AppConstants.spacingM),
              
              // Main content row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
                    ),
                    child: const Icon(
                      Icons.play_circle_filled,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Video Pembelajaran',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingS),
                        Text(
                          'Pelajari jaringan komputer melalui video interaktif',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryFilter(ThemeData theme) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return Container(
            margin: const EdgeInsets.only(right: AppConstants.spacingS),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = category;
                });
                // Apply filter when category changes
                _applyFilters();
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
              checkmarkColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoList(ThemeData theme) {
    return Consumer<VideoProvider>(
      builder: (context, videoProvider, child) {
        if (videoProvider.isLoading && videoProvider.videos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Apply category filter
        final allVideos = videoProvider.videos;
        final filteredVideos = _getFilteredVideos(allVideos);

        if (filteredVideos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.video_library_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                SizedBox(height: AppConstants.spacingM),
                Text(
                  'Tidak ada video',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: AppConstants.spacingS),
                Text(
                  selectedCategory == 'Semua' 
                    ? 'Belum ada video yang tersedia'
                    : 'Video untuk kategori "$selectedCategory" belum tersedia',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await context.read<VideoProvider>().refresh();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            itemCount: filteredVideos.length + (videoProvider.hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == filteredVideos.length) {
                // Load more indicator
                if (videoProvider.isLoadingMore) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppConstants.spacingM),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  // Load more button
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spacingM),
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<VideoProvider>().loadMoreVideos();
                        },
                        child: const Text('Muat Lebih Banyak'),
                      ),
                    ),
                  );
                }
              }
              
              final video = filteredVideos[index];
              return _buildVideoCard(theme, video);
            },
          ),
        );
      },
    );
  }

  Widget _buildVideoCard(ThemeData theme, Video video) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingL),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(video: video),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppConstants.borderRadiusL),
                      topRight: Radius.circular(AppConstants.borderRadiusL),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppConstants.borderRadiusL),
                      topRight: Radius.circular(AppConstants.borderRadiusL),
                    ),
                    child: video.youtubeThumbnailUrl != null
                        ? Stack(
                            children: [
                              Image.network(
                                video.youtubeThumbnailUrl!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: theme.colorScheme.primary.withOpacity(0.1),
                                    child: Center(
                                      child: Icon(
                                        Icons.play_circle_filled,
                                        size: 64,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            child: Center(
                              child: Icon(
                                Icons.play_circle_filled,
                                size: 64,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                  ),
                ),

                // Duration Badge
                Positioned(
                  bottom: AppConstants.spacingS,
                  right: AppConstants.spacingS,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusS,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Video',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Category Badge
                Positioned(
                  top: AppConstants.spacingS,
                  left: AppConstants.spacingS,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusS,
                      ),
                    ),
                    child: Text(
                      _getCategoryFromTitle(video.judul),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    video.judul,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: AppConstants.spacingS),

                  // Description
                  Text(
                    video.deskripsi,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: AppConstants.spacingM),

                  // Stats
                  Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      SizedBox(width: AppConstants.spacingS),
                      Text(
                        'Video',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      SizedBox(width: AppConstants.spacingS),
                      Text(
                        video.createdAt.toString().split(' ')[0],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
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

  // Apply category filter to videos
  void _applyFilters() {
    setState(() {
      // This will trigger a rebuild and apply the filter in _getFilteredVideos
    });
  }

  // Get filtered videos based on selected category
  List<Video> _getFilteredVideos(List<Video> videos) {
    if (selectedCategory == 'Semua') {
      return videos;
    }
    
    // Filter videos based on category
    // Note: This assumes the Video model has a category field or similar
    // You may need to adjust this based on your actual Video model structure
    return videos.where((video) {
      // For now, we'll use a simple title/description matching
      // You should replace this with proper category field matching
      final searchTerm = selectedCategory.toLowerCase();
      final title = video.judul.toLowerCase();
      final description = video.deskripsi.toLowerCase();
      
      switch (selectedCategory) {
        case 'Dasar Jaringan':
          return title.contains('dasar') || title.contains('basic') || 
                 description.contains('dasar') || description.contains('basic');
        case 'Protokol':
          return title.contains('protokol') || title.contains('protocol') ||
                 description.contains('protokol') || description.contains('protocol');
        case 'Keamanan':
          return title.contains('keamanan') || title.contains('security') ||
                 description.contains('keamanan') || description.contains('security');
        case 'Troubleshooting':
          return title.contains('troubleshoot') || title.contains('problem') ||
                 description.contains('troubleshoot') || description.contains('problem');
        case 'Hardware':
          return title.contains('hardware') || title.contains('perangkat') ||
                 description.contains('hardware') || description.contains('perangkat');
        default:
          return true;
      }
    }).toList();
  }

  // Get category from video title for display
  String _getCategoryFromTitle(String title) {
    final titleLower = title.toLowerCase();
    
    if (titleLower.contains('dasar') || titleLower.contains('basic')) {
      return 'Dasar';
    } else if (titleLower.contains('protokol') || titleLower.contains('protocol')) {
      return 'Protokol';
    } else if (titleLower.contains('keamanan') || titleLower.contains('security')) {
      return 'Keamanan';
    } else if (titleLower.contains('troubleshoot') || titleLower.contains('problem')) {
      return 'Troubleshoot';
    } else if (titleLower.contains('hardware') || titleLower.contains('perangkat')) {
      return 'Hardware';
    } else {
      return 'Video';
    }
  }

  void _showSearchDialog() {
    final TextEditingController searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pencarian Video'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Masukkan kata kunci...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final query = searchController.text.trim();
              if (query.isNotEmpty) {
                context.read<VideoProvider>().searchVideos(query);
              }
              Navigator.pop(context);
            },
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }
}

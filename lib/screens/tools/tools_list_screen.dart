import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../presentation/providers/tool_provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/widgets/common/custom_text_field.dart';
import '../../models/tool_model.dart';
import '../../widgets/custom_network_image.dart';
import 'tool_detail_screen.dart';

class ToolsListScreen extends StatefulWidget {
  const ToolsListScreen({Key? key}) : super(key: key);

  @override
  State<ToolsListScreen> createState() => _ToolsListScreenState();
}

class _ToolsListScreenState extends State<ToolsListScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
    _setupScrollListener();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final toolProvider = context.read<ToolProvider>();

    // Check if user is authenticated
    if (!authProvider.isAuthenticated) {
      // Set a specific error message for unauthenticated users
      toolProvider.setError(
        'Anda perlu login terlebih dahulu untuk melihat daftar alat',
      );
      return;
    }

    await Future.wait([
      toolProvider.loadTools(),
      toolProvider.loadCategories(),
    ]);
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final toolProvider = context.read<ToolProvider>();
        if (toolProvider.hasMoreTools && !toolProvider.isLoadingMore) {
          toolProvider.loadMoreTools();
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: Consumer<ToolProvider>(
        builder: (context, toolProvider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await toolProvider.refreshTools();
            },
            color: AppConstants.primaryColor,
            child: Column(
              children: [
                // Search and Filter Section
                _buildSearchAndFilterSection(theme, toolProvider),

                // Filter Chips (if visible)
    

                // Tools List/Grid
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildToolsList(theme, toolProvider),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: const Text('Daftar Alat'),
      backgroundColor: AppConstants.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
            });
          },
          icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
          tooltip: _isGridView ? 'Tampilan List' : 'Tampilan Grid',
        ),

        PopupMenuButton<String>(
          onSelected: (value) {
            final toolProvider = context.read<ToolProvider>();
            switch (value) {
              case 'sort_name':
                toolProvider.setSortBy(ToolSortBy.name);
                break;
              case 'sort_rating':
                toolProvider.setSortBy(ToolSortBy.rating);
                break;
              case 'sort_views':
                toolProvider.setSortBy(ToolSortBy.views);
                break;
              case 'order_asc':
                toolProvider.setSortBy(ToolSortBy.asc);
                break;
              case 'order_desc':
                toolProvider.setSortBy(ToolSortBy.asc);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'sort_name',
              child: Text('Urutkan berdasarkan Nama'),
            ),
            const PopupMenuItem(
              value: 'sort_rating',
              child: Text('Urutkan berdasarkan Rating'),
            ),
            const PopupMenuItem(
              value: 'sort_views',
              child: Text('Urutkan berdasarkan Views'),
            ),
            const PopupMenuItem(
              value: 'sort_date',
              child: Text('Urutkan berdasarkan Tanggal'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'order_asc', child: Text('Urutan Naik')),
            const PopupMenuItem(
              value: 'order_desc',
              child: Text('Urutan Turun'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterSection(
    ThemeData theme,
    ToolProvider toolProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Field
          SearchTextField(
            controller: _searchController,
            placeholder: 'Cari alat...',
            onChanged: (value) {
              toolProvider.setSearchQuery(value);
            },
            onClear: () {
              _searchController.clear();
              toolProvider.setSearchQuery('');
            },
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatChip(
                  theme,
                  'Total: ${toolProvider.filteredTools.length}',
                  Icons.build,
                  AppConstants.primaryColor,
                ),
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Expanded(
                child: _buildStatChip(
                  theme,
                  'Kategori: ${toolProvider.categories.length}',
                  Icons.category,
                  AppConstants.successColor,
                ),
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Expanded(
                child: _buildStatChip(
                  theme,
                  'Unggulan: ${toolProvider.featuredTools.length}',
                  Icons.star,
                  AppConstants.warningColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    ThemeData theme,
    String text,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme, ToolProvider toolProvider) {
    // Filter section removed - showing all tools without filters
    return const SizedBox.shrink();
  }

  Widget _buildToolsList(ThemeData theme, ToolProvider toolProvider) {
    if (toolProvider.isLoading && toolProvider.tools.isEmpty) {
      return _buildLoadingState();
    }

    if (toolProvider.hasError && toolProvider.tools.isEmpty) {
      return _buildErrorState(theme, toolProvider);
    }

    final tools = toolProvider.filteredTools;

    if (tools.isEmpty) {
      return _buildEmptyState(theme);
    }

    return _isGridView
        ? _buildGridView(theme, tools, toolProvider)
        : _buildListView(theme, tools, toolProvider);
  }

  Widget _buildLoadingState() {
    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppConstants.spacingMedium,
          mainAxisSpacing: AppConstants.spacingMedium,
          childAspectRatio: 0.8,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => _buildLoadingCard(),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        itemCount: 6,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
          child: _buildLoadingCard(),
        ),
      );
    }
  }

  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(ThemeData theme, ToolProvider toolProvider) {
    final authProvider = context.read<AuthProvider>();
    final isAuthError =
        toolProvider.errorMessage?.contains('401') == true ||
        toolProvider.errorMessage?.contains('Sesi Anda telah berakhir') ==
            true ||
        !authProvider.isAuthenticated;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAuthError ? Icons.lock_outline : Icons.error_outline,
              size: 64,
              color: isAuthError
                  ? AppConstants.warningColor
                  : AppConstants.errorColor,
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              isAuthError ? 'Perlu Login' : 'Terjadi Kesalahan',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              isAuthError
                  ? 'Anda perlu login terlebih dahulu untuk melihat daftar alat'
                  : toolProvider.errorMessage ?? 'Gagal memuat data alat',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            if (isAuthError)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                icon: const Icon(Icons.login),
                label: const Text('Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => toolProvider.refreshTools(),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              'Tidak Ada Alat Ditemukan',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              'Coba ubah kata kunci pencarian atau filter yang digunakan',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildGridView(
    ThemeData theme,
    List<Tool> tools,
    ToolProvider toolProvider,
  ) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppConstants.spacingMedium,
        mainAxisSpacing: AppConstants.spacingMedium,
        childAspectRatio: 0.8,
      ),
      itemCount: tools.length + (toolProvider.isLoadingMore ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= tools.length) {
          return _buildLoadingCard();
        }

        final tool = tools[index];
        return _buildToolGridCard(theme, tool);
      },
    );
  }

  Widget _buildListView(
    ThemeData theme,
    List<Tool> tools,
    ToolProvider toolProvider,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      itemCount: tools.length + (toolProvider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= tools.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacingMedium,
            ),
            child: _buildLoadingCard(),
          );
        }

        final tool = tools[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
          child: _buildToolListCard(theme, tool),
        );
      },
    );
  }

  Widget _buildToolGridCard(ThemeData theme, Tool tool) {
    return GestureDetector(
      onTap: () => _navigateToToolDetail(tool),
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
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.borderRadiusMedium),
                ),
                child: Container(
                  width: double.infinity,
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  child: Stack(
                    children: [
                      ToolImage(
                        imageUrl: tool.gambar,
                        toolName: tool.nama,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        showDebugInfo: false,
                      ),

                      // Status Badges
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Featured Badge
                            if (tool.isFeatured)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppConstants.warningColor,
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadiusSmall,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Unggulan',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Inactive Badge
                            if (!tool.isActive)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppConstants.errorColor,
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadiusSmall,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.block,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Nonaktif',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Media Indicators
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Row(
                          children: [
                            if (tool.hasVideo)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.play_circle_outline,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            if (tool.hasVideo && tool.hasPdf)
                              const SizedBox(width: 4),
                            if (tool.hasPdf)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.picture_as_pdf,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Tool Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.name ?? 'Nama Alat',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      tool.categoryName ?? 'Kategori',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const Spacer(),

                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: AppConstants.warningColor,
                        ),
                        const SizedBox(width: 2),
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

  Widget _buildToolListCard(ThemeData theme, Tool tool) {
    return GestureDetector(
      onTap: () => _navigateToToolDetail(tool),
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
        child: Row(
          children: [
            // Tool Image
            ClipRRect(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusSmall,
              ),
              child: Container(
                width: 80,
                height: 80,
                color: AppConstants.primaryColor.withOpacity(0.1),
                child: ToolImage(
                  imageUrl: tool.gambar,
                  toolName: tool.nama,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  showDebugInfo: false,
                ),
              ),
            ),

            const SizedBox(width: AppConstants.spacingMedium),

            // Tool Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tool.name ?? 'Nama Alat',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (tool.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.warningColor,
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusSmall,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Unggulan',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    tool.categoryName ?? 'Kategori',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

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

                  const SizedBox(height: AppConstants.spacingSmall),

                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: AppConstants.warningColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tool.formattedRating,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: AppConstants.spacingMedium),
                      Icon(
                        Icons.visibility,
                        size: 16,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.6,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tool.formattedViewCount,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            0.6,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (tool.hasVideo)
                        Icon(
                          Icons.play_circle_outline,
                          size: 20,
                          color: AppConstants.infoColor,
                        ),
                      if (tool.hasVideo && tool.hasPdf)
                        const SizedBox(width: 4),
                      if (tool.hasPdf)
                        Icon(
                          Icons.picture_as_pdf,
                          size: 20,
                          color: AppConstants.errorColor,
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

  Widget _buildPlaceholderImage(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppConstants.primaryColor.withOpacity(0.1),
      child: Icon(Icons.build, size: 40, color: AppConstants.primaryColor),
    );
  }

  void _navigateToToolDetail(Tool tool) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ToolDetailScreen(tool: tool)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../presentation/providers/tool_provider.dart';
import '../../models/tool_model.dart';
import '../../widgets/custom_network_image.dart';
import '../../services/pdf_service.dart';
import 'pdf_viewer_screen.dart';

class ToolDetailScreen extends StatefulWidget {
  final Tool tool;

  const ToolDetailScreen({Key? key, required this.tool}) : super(key: key);

  @override
  State<ToolDetailScreen> createState() => _ToolDetailScreenState();
}

class _ToolDetailScreenState extends State<ToolDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  YoutubePlayerController? _youtubeController;
  bool _showFullDescription = false;

  @override
  void initState() {
    super.initState();

    // Debug tool data
    print('=== TOOL DEBUG INFO ===');
    print('Tool ID: ${widget.tool.id}');
    print('Tool Name: ${widget.tool.nama}');
    print('Has Image: ${widget.tool.hasImage}');
    print('Image URL (gambar): ${widget.tool.gambar}');
    print('Display Image URL: ${widget.tool.displayImageUrl}');
    print('Has PDF: ${widget.tool.hasPdf}');
    print('PDF URL: ${widget.tool.filePdf}');
    print('Has Video: ${widget.tool.hasVideo}');
    print('Video URL: ${widget.tool.urlVideo}');
    print('=====================');

    _initializeAnimations();
    _initializeYoutubePlayer();
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

  void _initializeYoutubePlayer() {
    if (widget.tool.hasVideo && widget.tool.youtubeVideoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: widget.tool.youtubeVideoId!,
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
    _animationController.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tool Info Section
                    _buildToolInfoSection(theme),

                    // Description Section
                    _buildDescriptionSection(theme),

                    // Video Section
                    if (widget.tool.hasVideo) _buildVideoSection(theme),

                    // PDF Section
                    if (widget.tool.hasPdf) _buildPdfSection(theme),

                    // Function Section
                    if (widget.tool.function!.isNotEmpty)
                      _buildFunctionSection(theme),

                    // Tags Section
                    if (widget.tool.tags.isNotEmpty) _buildTagsSection(theme),

                    // Statistics Section
                    _buildStatisticsSection(theme),

                    // Related Tools Section
                    _buildRelatedToolsSection(theme),

                    const SizedBox(height: AppConstants.spacingXLarge),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: AppConstants.primaryColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.tool.name ?? 'Detail Alat',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Tool Image with enhanced loading
            ToolImage(
              imageUrl: widget.tool.gambar,
              toolName: widget.tool.nama,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              showDebugInfo: true, // Enable for debugging
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),

            // Featured Badge
            if (widget.tool.isFeatured)
              Positioned(
                top: 60,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.warningColor,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusMedium,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'Unggulan',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'share':
                _shareToolInfo();
                break;
              case 'favorite':
                _toggleFavorite();
                break;
              case 'report':
                _reportTool();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Bagikan'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'favorite',
              child: ListTile(
                leading: Icon(
                  widget.tool.isFavorited == true 
                      ? Icons.favorite 
                      : Icons.favorite_border,
                  color: widget.tool.isFavorited == true 
                      ? AppConstants.errorColor 
                      : null,
                ),
                title: Text(
                  widget.tool.isFavorited == true 
                      ? 'Hapus dari Favorit' 
                      : 'Tambah ke Favorit'
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'report',
              child: ListTile(
                leading: Icon(Icons.report_outlined),
                title: Text('Laporkan'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppConstants.primaryColor.withOpacity(0.3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build, size: 80, color: Colors.white.withOpacity(0.7)),
            const SizedBox(height: 8),
            Text(
              widget.tool.hasImage
                  ? 'Gambar tidak dapat dimuat'
                  : 'Tidak ada gambar',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.tool.hasImage) ...[
              const SizedBox(height: 4),
              Text(
                'URL: ${widget.tool.gambar}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToolInfoSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category and Rating
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusSmall,
                  ),
                  border: Border.all(
                    color: AppConstants.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  widget.tool.categoryName ?? 'Kategori',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(),

              // Rating
              GestureDetector(
                onTap: _showRatingDialog,
                child: Row(
                  children: [
                    Icon(Icons.star, size: 20, color: AppConstants.warningColor),
                    const SizedBox(width: 4),
                    Text(
                      widget.tool.formattedRating,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ' (${widget.tool.ratingCount})',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.edit,
                      size: 16,
                      color: AppConstants.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // View Count and Created Info
          Row(
            children: [
              Icon(
                Icons.visibility,
                size: 16,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.tool.formattedViewCount} views',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),

              const SizedBox(width: AppConstants.spacingMedium),

              Icon(
                Icons.person,
                size: 16,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                'Oleh ${widget.tool.createdBy}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Media Indicators
          Row(
            children: [
              if (widget.tool.hasVideo)
                _buildMediaChip(
                  theme,
                  'Video Tutorial',
                  Icons.play_circle_outline,
                  AppConstants.infoColor,
                ),
              if (widget.tool.hasVideo && widget.tool.hasPdf)
                const SizedBox(width: AppConstants.spacingSmall),
              if (widget.tool.hasPdf)
                _buildMediaChip(
                  theme,
                  'Manual PDF',
                  Icons.picture_as_pdf,
                  AppConstants.errorColor,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaChip(
    ThemeData theme,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: 4,
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
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLarge,
        vertical: AppConstants.spacingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deskripsi',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          AnimatedCrossFade(
            firstChild: Text(
              widget.tool.shortDescription,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
            secondChild: Text(
              widget.tool.description ?? widget.tool.deskripsi,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
            crossFadeState: _showFullDescription
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),

          if ((widget.tool.description ?? widget.tool.deskripsi).length >
              widget.tool.shortDescription.length)
            TextButton(
              onPressed: () {
                setState(() {
                  _showFullDescription = !_showFullDescription;
                });
              },
              child: Text(
                _showFullDescription
                    ? 'Tampilkan Lebih Sedikit'
                    : 'Baca Selengkapnya',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLarge,
        vertical: AppConstants.spacingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Video Tutorial',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          if (_youtubeController != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              child: YoutubePlayer(
                controller: _youtubeController!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: AppConstants.primaryColor,
                onReady: () {
                  setState(() {});
                },
                onEnded: (metaData) {
                  // Handle video end
                },
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusMedium,
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Video tidak dapat dimuat',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPdfSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLarge,
        vertical: AppConstants.spacingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manual PDF',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          GestureDetector(
            onTap: () => _openPdfViewer(),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.spacingLarge),
              decoration: BoxDecoration(
                color: AppConstants.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusMedium,
                ),
                border: Border.all(
                  color: AppConstants.errorColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    size: 48,
                    color: AppConstants.errorColor,
                  ),

                  const SizedBox(width: AppConstants.spacingMedium),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manual ${widget.tool.name ?? 'Alat'}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ketuk untuk membuka manual PDF',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: AppConstants.errorColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLarge,
        vertical: AppConstants.spacingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fungsi Alat',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          Container(
            padding: const EdgeInsets.all(AppConstants.spacingLarge),
            decoration: BoxDecoration(
              color: AppConstants.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              border: Border.all(
                color: AppConstants.successColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              widget.tool.function ?? widget.tool.fungsi,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLarge,
        vertical: AppConstants.spacingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tags',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          Wrap(
            spacing: AppConstants.spacingSmall,
            runSpacing: AppConstants.spacingSmall,
            children: widget.tool.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusSmall,
                  ),
                  border: Border.all(
                    color: AppConstants.infoColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '#$tag',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppConstants.infoColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLarge,
        vertical: AppConstants.spacingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik',
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
                  'Views',
                  widget.tool.formattedViewCount,
                  Icons.visibility,
                  AppConstants.infoColor,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Rating',
                  widget.tool.formattedRating,
                  Icons.star,
                  AppConstants.warningColor,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Reviews',
                  '${widget.tool.ratingCount}',
                  Icons.rate_review,
                  AppConstants.successColor,
                ),
              ),
            ],
          ),
        ],
      ),
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
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedToolsSection(ThemeData theme) {
    return Consumer<ToolProvider>(
      builder: (context, toolProvider, child) {
        final relatedTools = toolProvider.tools
            .where(
              (tool) =>
                  tool.id != widget.tool.id &&
                  tool.categoryId == widget.tool.categoryId,
            )
            .take(3)
            .toList();

        if (relatedTools.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLarge,
            vertical: AppConstants.spacingMedium,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alat Terkait',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: AppConstants.spacingMedium),

              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: relatedTools.length,
                  itemBuilder: (context, index) {
                    final tool = relatedTools[index];
                    return Container(
                      width: 160,
                      margin: EdgeInsets.only(
                        right: index < relatedTools.length - 1
                            ? AppConstants.spacingMedium
                            : 0,
                      ),
                      child: _buildRelatedToolCard(theme, tool),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRelatedToolCard(ThemeData theme, tool) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
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
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.borderRadiusMedium),
                ),
                child: Container(
                  width: double.infinity,
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  child: tool.displayImageUrl != null
                      ? Image.network(
                          tool.displayImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.build,
                              size: 40,
                              color: AppConstants.primaryColor,
                            );
                          },
                        )
                      : Icon(
                          Icons.build,
                          size: 40,
                          color: AppConstants.primaryColor,
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

  void _shareToolInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur berbagi akan segera tersedia')),
    );
  }

  void _toggleFavorite() async {
    final toolProvider = context.read<ToolProvider>();
    final success = await toolProvider.toggleFavorite(widget.tool);
    
    if (success) {
      final isFavorited = !(widget.tool.isFavorited ?? false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorited 
                ? 'Alat ditambahkan ke favorit' 
                : 'Alat dihapus dari favorit'
          ),
          backgroundColor: isFavorited 
              ? AppConstants.successColor 
              : AppConstants.warningColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengubah status favorit'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  void _reportTool() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Laporkan Alat'),
        content: const Text(
          'Apakah Anda yakin ingin melaporkan alat ini? '
          'Tim kami akan meninjau laporan Anda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Laporan telah dikirim')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Laporkan'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    double userRating = 0.0;
    String userComment = '';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Beri Rating'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bagaimana pengalaman Anda dengan ${widget.tool.nama}?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        userRating = index + 1.0;
                      });
                    },
                    child: Icon(
                      Icons.star,
                      size: 32,
                      color: index < userRating
                          ? AppConstants.warningColor
                          : Colors.grey.shade300,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Tulis komentar (opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  userComment = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: userRating > 0
                  ? () {
                      Navigator.of(context).pop();
                      _submitRating(userRating, userComment);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Kirim Rating'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitRating(double rating, String comment) async {
     try {
       final toolProvider = context.read<ToolProvider>();
       final success = await toolProvider.rateTool(
         widget.tool,
         rating,
       );
       
       if (success) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('Rating berhasil dikirim'),
             backgroundColor: AppConstants.successColor,
           ),
         );
       } else {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('Gagal mengirim rating'),
             backgroundColor: AppConstants.errorColor,
           ),
         );
       }
     } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('Error: $e'),
           backgroundColor: AppConstants.errorColor,
         ),
       );
     }
   }

  void _openPdfViewer() async {
    if (!widget.tool.hasPdf || widget.tool.displayPdfUrl.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('File PDF tidak tersedia')));
      return;
    }

    // Show enhanced loading dialog with progress
    double downloadProgress = 0.0;
    bool isDownloading = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                value: downloadProgress > 0 ? downloadProgress : null,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                isDownloading
                    ? 'Mengunduh PDF... ${(downloadProgress * 100).toInt()}%'
                    : 'Mempersiapkan PDF...',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Manual ${widget.tool.nama}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Use the enhanced PDF service
      final pdfService = PdfService();
      final fileName = 'manual_${widget.tool.id}.pdf';

      final result = await pdfService.downloadPdf(
        url: widget.tool.displayPdfUrl,
        fileName: fileName,
        useCache: true,
        onProgress: (progress) {
          // Update progress in dialog
          if (mounted) {
            downloadProgress = progress;
            // Note: setState is not available here, but the dialog will update
            // when the download completes
          }
        },
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (result.isSuccess) {
        // Show success message if from cache
        if (result.fromCache && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF dimuat dari cache'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }

        // Navigate to PDF viewer
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PDFViewerScreen(
                filePath: result.filePath!,
                title: 'Manual ${widget.tool.nama}',
              ),
            ),
          );
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengunduh PDF: ${result.errorMessage}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Coba Lagi',
                textColor: Colors.white,
                onPressed: () => _openPdfViewer(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error tidak terduga: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: Colors.white,
              onPressed: () => _openPdfViewer(),
            ),
          ),
        );
      }
    }
  }
}

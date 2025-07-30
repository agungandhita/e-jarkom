import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../presentation/providers/tool_provider.dart';
import '../../models/tool_model.dart';
import '../../widgets/custom_network_image.dart';
import 'tool_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Tool> _favoriteTools = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavoriteTools();
  }

  Future<void> _loadFavoriteTools() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final toolProvider = context.read<ToolProvider>();
      final favorites = await toolProvider.getFavoriteTools();
      setState(() {
        _favoriteTools = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat tools favorit';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tools Favorit'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState(theme);
    }

    if (_favoriteTools.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: _loadFavoriteTools,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        itemCount: _favoriteTools.length,
        itemBuilder: (context, index) {
          final tool = _favoriteTools[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
            child: _buildFavoriteToolCard(theme, tool),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppConstants.errorColor,
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            _errorMessage!,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          ElevatedButton(
            onPressed: _loadFavoriteTools,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            'Belum ada tools favorit',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            'Tambahkan tools ke favorit untuk melihatnya di sini',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Jelajahi Tools'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteToolCard(ThemeData theme, Tool tool) {
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
                          tool.nama,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeFavorite(tool),
                        icon: Icon(
                          Icons.favorite,
                          color: AppConstants.errorColor,
                        ),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spacingSmall),

                  Text(
                    tool.shortDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppConstants.spacingSmall),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingSmall,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusSmall,
                          ),
                        ),
                        child: Text(
                          tool.displayCategory,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const Spacer(),

                      Icon(
                        Icons.star,
                        size: 16,
                        color: AppConstants.warningColor,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        tool.formattedRating,
                        style: theme.textTheme.bodySmall,
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

  void _navigateToToolDetail(Tool tool) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ToolDetailScreen(tool: tool),
      ),
    ).then((_) {
      // Refresh favorites when returning from detail screen
      _loadFavoriteTools();
    });
  }

  void _removeFavorite(Tool tool) async {
    final toolProvider = context.read<ToolProvider>();
    final success = await toolProvider.toggleFavorite(tool);
    
    if (success) {
      setState(() {
        _favoriteTools.removeWhere((t) => t.id == tool.id);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tool dihapus dari favorit'),
          backgroundColor: AppConstants.warningColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus dari favorit'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }
}
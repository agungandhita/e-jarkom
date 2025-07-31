import 'package:flutter/foundation.dart';
import '../../domain/entities/video.dart';
import '../../data/repositories/video_repository.dart';
import '../../core/constants/app_constants.dart';

class VideoProvider extends ChangeNotifier {
  final VideoRepository _videoRepository;

  VideoProvider(this._videoRepository);

  // State variables
  List<Video> _videos = [];
  List<Video> _filteredVideos = [];
  List<Video> _featuredVideos = [];
  List<Video> _popularVideos = [];

  Video? _selectedVideo;
  String _searchQuery = '';
  VideoSortBy _sortBy = VideoSortBy.newest;
  SortOrder _sortOrder = SortOrder.descending;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _errorMessage;
  Map<String, String> _validationErrors = {};

  int _currentPage = 1;
  final int _pageSize = AppConstants.defaultPageSize;

  // Getters
  List<Video> get videos => _videos;
  List<Video> get filteredVideos => _filteredVideos;
  List<Video> get featuredVideos => _featuredVideos;
  List<Video> get popularVideos => _popularVideos;

  Video? get selectedVideo => _selectedVideo;
  String get searchQuery => _searchQuery;
  VideoSortBy get sortBy => _sortBy;
  SortOrder get sortOrder => _sortOrder;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  String? get errorMessage => _errorMessage;
  Map<String, String> get validationErrors => _validationErrors;

  int get currentPage => _currentPage;
  bool get hasVideos => _videos.isNotEmpty;
  bool get hasFilteredVideos => _filteredVideos.isNotEmpty;
  bool get hasFeaturedVideos => _featuredVideos.isNotEmpty;
  bool get hasPopularVideos => _popularVideos.isNotEmpty;

  // Initialize data
  Future<void> initialize() async {
    await Future.wait([
      loadVideos(),
      loadFeaturedVideos(),
      loadPopularVideos(),
    ]);
  }

  // Load all videos
  Future<void> loadVideos({bool refresh = false, String? search}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _videos.clear();
    }

    if (_isLoading || (!_hasMoreData && !refresh)) return;

    _setLoading(true);
    _clearError();

    try {
        final result = await _videoRepository.getVideosPaginated(
          page: _currentPage,
          limit: _pageSize,
          search: search,
          sortBy: _sortBy.value,
          sortOrder: _sortOrder.value,
        );

        if (refresh) {
          _videos = result.videos;
        } else {
          _videos.addAll(result.videos);
        }

        _hasMoreData = result.currentPage < result.lastPage;
        _currentPage++;

      _applyFilters();
    } catch (e) {
      _setError('Gagal memuat data video: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load more videos (pagination)
  Future<void> loadMoreVideos() async {
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _videoRepository.getVideosPaginated(
          page: _currentPage,
          limit: _pageSize,
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
          sortBy: _sortBy.value,
          sortOrder: _sortOrder.value,
        );

        _videos.addAll(result.videos);
        _hasMoreData = result.currentPage < result.lastPage;
        _currentPage++;

      _applyFilters();
    } catch (e) {
      _setError('Gagal memuat data tambahan: ${e.toString()}');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Load featured videos
  Future<void> loadFeaturedVideos() async {
    try {
      _featuredVideos = await _videoRepository.getFeaturedVideos();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading featured videos: $e');
    }
  }

  // Load popular videos
  Future<void> loadPopularVideos() async {
    try {
      _popularVideos = await _videoRepository.getPopularVideos();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading popular videos: $e');
    }
  }

  // Get video by ID
  Future<Video?> getVideoById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final video = await _videoRepository.getVideoById(id);
      _selectedVideo = video;

      // Increment view count
      if (video != null) {
        await _videoRepository.incrementViewCount(id);
      }

      notifyListeners();
      return video;
    } catch (e) {
      _setError('Gagal memuat detail video: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Create new video (admin only)
  Future<bool> createVideo(Video video) async {
    _setLoading(true);
    _clearError();
    _clearValidationErrors();

    try {
      final newVideo = await _videoRepository.createVideo(video);
      _videos.insert(0, newVideo);
      _applyFilters();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update video (admin only)
  Future<bool> updateVideo(String id, Video video) async {
    _setLoading(true);
    _clearError();
    _clearValidationErrors();

    try {
      final updatedVideo = await _videoRepository.updateVideo(id, video);
      final index = _videos.indexWhere((v) => v.id == id);
      if (index != -1) {
        _videos[index] = updatedVideo;
      }
      if (_selectedVideo?.id == id) {
        _selectedVideo = updatedVideo;
      }
      _applyFilters();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete video (admin only)
  Future<bool> deleteVideo(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _videoRepository.deleteVideo(id);
      _videos.removeWhere((video) => video.id == id);
      if (_selectedVideo?.id == id) {
        _selectedVideo = null;
      }
      _applyFilters();
      return true;
    } catch (e) {
      _setError('Gagal menghapus video: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Note: Rating functionality removed due to simplified video model

  // Search videos
  void searchVideos(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // Sort videos
  void sortVideos(VideoSortBy sortBy, [SortOrder? sortOrder]) {
    _sortBy = sortBy;
    if (sortOrder != null) {
      _sortOrder = sortOrder;
    }
    _currentPage = 1;
    _hasMoreData = true;
    loadVideos(
      refresh: true,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    );
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _sortBy = VideoSortBy.newest;
    _sortOrder = SortOrder.descending;
    _currentPage = 1;
    _hasMoreData = true;
    loadVideos(refresh: true);
  }

  // Apply filters to videos list
  void _applyFilters() {
    List<Video> filtered = List.from(_videos);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((video) => video.matchesSearch(_searchQuery))
          .toList();
    }

    _filteredVideos = filtered;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refresh() async {
    _currentPage = 1;
    _hasMoreData = true;
    await Future.wait([
      loadVideos(refresh: true),
      // loadFeaturedVideos(),
      loadPopularVideos(),
    ]);
  }

  // Set selected video
  void setSelectedVideo(Video? video) {
    _selectedVideo = video;
    notifyListeners();
  }

  // Clear selected video
  void clearSelectedVideo() {
    _selectedVideo = null;
    notifyListeners();
  }

  // Note: Category and tag-based filtering removed due to simplified video model

  // Get related videos (basic implementation)
  List<Video> getRelatedVideos(String videoId, {int limit = 5}) {
    return _videos.where((v) => v.id != videoId).take(limit).toList();
  }

  // Get recommended videos based on user preferences
  List<Video> getRecommendedVideos({int limit = 5}) {
    // Simple recommendation: mix of featured and popular videos
    final Set<Video> recommended = {};

    // Add featured videos
    recommended.addAll(_featuredVideos.take(limit ~/ 2));

    // Add popular videos
    recommended.addAll(_popularVideos.take(limit - recommended.length));

    // Fill remaining with newest videos if needed
    if (recommended.length < limit) {
      final newest = _videos
          .where((v) => !recommended.contains(v))
          .take(limit - recommended.length);
      recommended.addAll(newest);
    }

    return recommended.toList();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _clearValidationErrors() {
    _validationErrors.clear();
    notifyListeners();
  }

  void _handleError(dynamic error) {
    if (error is Map<String, dynamic> &&
        error.containsKey('validation_errors')) {
      _validationErrors = Map<String, String>.from(error['validation_errors']);
    } else {
      _setError(error.toString());
    }
  }

  // Validation helpers
  bool get hasValidationErrors => _validationErrors.isNotEmpty;

  String? getValidationError(String field) {
    return _validationErrors[field];
  }

  // Loading state helpers
  bool get isLoadingVideos => _isLoading;
  bool get isLoadingFeatured => _featuredVideos.isEmpty;
  bool get isLoadingPopular => _popularVideos.isEmpty;

  // Clear cache
  Future<void> clearCache() async {
    await _videoRepository.clearCache();
  }
}

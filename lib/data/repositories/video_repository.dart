import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/video.dart';
import '../datasources/local_storage.dart';
import '../../services/api_service.dart';

class VideoRepository {
  final Dio _dio;
  final LocalStorage? _localStorage;

  VideoRepository(this._dio, this._localStorage);

  VideoRepository.fromApiService(ApiService apiService)
    : _dio = apiService.dio,
      _localStorage = null;

  // Get all videos with pagination and filters
  Future<List<Video>> getVideos({
    int page = 1,
    int limit = 10,
    String? search,
    VideoSortBy sortBy = VideoSortBy.newest,
    SortOrder sortOrder = SortOrder.descending,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        'sort_by': _getSortByString(sortBy),
        'sort_order': sortOrder == SortOrder.ascending ? 'asc' : 'desc',
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get('/videos', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> videosJson = response.data['data'] ?? [];
        final videos = videosJson.map((json) => Video.fromJson(json)).toList();

        // Cache videos for offline access
        await _cacheVideos(videos, page);

        return videos;
      } else {
        throw Exception('Failed to load videos: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        // Try to load from cache when offline
        return await _getCachedVideos(page);
      }
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unknown error occurred: $e');
    }
  }

  // Get featured videos
  Future<List<Video>> getFeaturedVideos({int limit = 5}) async {
    try {
      final response = await _dio.get(
        '/videos/featured',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> videosJson = response.data['data'] ?? [];
        final videos = videosJson.map((json) => Video.fromJson(json)).toList();

        // Cache featured videos
        await _localStorage!.cacheData(
          'featured_videos',
          videos.map((v) => v.toJson()).toList(),
        );

        return videos;
      } else {
        throw Exception(
          'Failed to load featured videos: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        // Try to load from cache when offline
        return await _getCachedFeaturedVideos();
      }
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unknown error occurred: $e');
    }
  }

  // Get popular videos
  Future<List<Video>> getPopularVideos({int limit = 5}) async {
    try {
      final response = await _dio.get(
        '/videos/popular',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> videosJson = response.data['data'] ?? [];
        final videos = videosJson.map((json) => Video.fromJson(json)).toList();

        // Cache popular videos
        await _localStorage!.cacheData(
          'popular_videos',
          videos.map((v) => v.toJson()).toList(),
        );

        return videos;
      } else {
        throw Exception(
          'Failed to load popular videos: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        // Try to load from cache when offline
        return await _getCachedPopularVideos();
      }
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unknown error occurred: $e');
    }
  }

  // Get video by ID
  Future<Video?> getVideoById(String id) async {
    try {
      final response = await _dio.get('/videos/$id');

      if (response.statusCode == 200) {
        final videoJson = response.data['data'];
        if (videoJson != null) {
          final video = Video.fromJson(videoJson);

          // Cache video details
          await _localStorage!.cacheData('video_$id', video.toJson());

          return video;
        }
      }
      return null;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        // Try to load from cache when offline
        return await _getCachedVideoById(id);
      }
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unknown error occurred: $e');
    }
  }

  // Create new video (admin only)
  Future<Video> createVideo(Video video) async {
    try {
      final response = await _dio.post('/videos', data: video.toJson());

      if (response.statusCode == 201) {
        final videoJson = response.data['data'];
        return Video.fromJson(videoJson);
      } else {
        throw Exception('Failed to create video: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unknown error occurred: $e');
    }
  }

  // Update video (admin only)
  Future<Video> updateVideo(String id, Video video) async {
    try {
      final response = await _dio.put('/videos/$id', data: video.toJson());

      if (response.statusCode == 200) {
        final videoJson = response.data['data'];
        final updatedVideo = Video.fromJson(videoJson);

        // Update cache
        await _localStorage!.cacheData('video_$id', updatedVideo.toJson());

        return updatedVideo;
      } else {
        throw Exception('Failed to update video: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unknown error occurred: $e');
    }
  }

  // Delete video (admin only)
  Future<void> deleteVideo(String id) async {
    try {
      final response = await _dio.delete('/videos/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete video: ${response.statusMessage}');
      }

      // Remove from cache
      await _localStorage!.removeData('video_$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unknown error occurred: $e');
    }
  }

  // Increment view count
  Future<void> incrementViewCount(String id) async {
    try {
      await _dio.post('/videos/$id/view');
    } on DioException catch (e) {
      // Don't throw error for view count increment
      // This is not critical functionality
      debugPrint('Failed to increment view count: ${e.message}');
    } catch (e) {
      debugPrint('Failed to increment view count: $e');
    }
  }

  // Note: Rating functionality removed due to simplified video model

  // Search videos
  Future<List<Video>> searchVideos(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    return getVideos(
      page: page,
      limit: limit,
      search: query,
    );
  }

  // Note: Category-based video filtering removed due to simplified video model

  // Cache management methods
  Future<void> _cacheVideos(List<Video> videos, int page) async {
    if (_localStorage == null) return;
    try {
      final cacheKey = 'videos_page_$page';
      final videosJson = videos.map((v) => v.toJson()).toList();
      await _localStorage.cacheData(cacheKey, videosJson);
    } catch (e) {
      print('Failed to cache videos: $e');
    }
  }

  Future<List<Video>> _getCachedVideos(int page) async {
    if (_localStorage == null) return [];
    try {
      final cacheKey = 'videos_page_$page';
      final cachedData = await _localStorage.getCachedData(cacheKey);
      if (cachedData != null) {
        final List<dynamic> videosJson = cachedData;
        return videosJson.map((json) => Video.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Failed to get cached videos: $e');
    }
    return [];
  }

  Future<List<Video>> _getCachedFeaturedVideos() async {
    try {
      final cachedData = await _localStorage!.getCachedData('featured_videos');
      if (cachedData != null) {
        final List<dynamic> videosJson = cachedData;
        return videosJson.map((json) => Video.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Failed to get cached featured videos: $e');
    }
    return [];
  }

  Future<List<Video>> _getCachedPopularVideos() async {
    try {
      final cachedData = await _localStorage!.getCachedData('popular_videos');
      if (cachedData != null) {
        final List<dynamic> videosJson = cachedData;
        return videosJson.map((json) => Video.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Failed to get cached popular videos: $e');
    }
    return [];
  }

  Future<Video?> _getCachedVideoById(String id) async {
    try {
      final cachedData = await _localStorage!.getCachedData('video_$id');
      if (cachedData != null) {
        return Video.fromJson(cachedData);
      }
    } catch (e) {
      debugPrint('Failed to get cached video: $e');
    }
    return null;
  }

  // Helper methods
  String _getSortByString(VideoSortBy sortBy) {
    switch (sortBy) {
      case VideoSortBy.newest:
        return 'created_at';
      case VideoSortBy.oldest:
        return 'created_at';
      case VideoSortBy.judul:
        return 'judul';
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception(
          'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.sendTimeout:
        return Exception('Send timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return Exception('Receive timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message =
            e.response?.data?['message'] ?? 'Unknown error occurred';

        switch (statusCode) {
          case 400:
            return Exception('Bad request: $message');
          case 401:
            return Exception('Unauthorized. Please login again.');
          case 403:
            return Exception('Forbidden. You don\'t have permission.');
          case 404:
            return Exception('Video not found.');
          case 422:
            // Validation errors
            final errors = e.response?.data?['errors'];
            if (errors != null) {
              throw {'validation_errors': errors};
            }
            return Exception('Validation error: $message');
          case 500:
            return Exception('Server error. Please try again later.');
          default:
            return Exception('Error $statusCode: $message');
        }
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network.');
      case DioExceptionType.badCertificate:
        return Exception('Certificate error. Please check your connection.');
      default:
        return Exception('Unknown error occurred: ${e.message}');
    }
  }

  // Clear all video cache
  Future<void> clearCache() async {
    try {
      // Clear all video-related cache
      await _localStorage!.removeData('featured_videos');
      await _localStorage.removeData('popular_videos');

      // Clear paginated video cache (assuming max 10 pages)
      for (int i = 1; i <= 10; i++) {
        await _localStorage.removeData('videos_page_$i');
      }
    } catch (e) {
      debugPrint('Failed to clear video cache: $e');
    }
  }
}

import 'package:flutter/material.dart';
import '../services/url_service.dart';
import '../core/constants/app_constants.dart';

class CustomNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? placeholder;
  final Widget? errorWidget;
  final bool enableRetry;
  final int maxRetries;
  final Duration retryDelay;
  final bool showDebugInfo;
  final VoidCallback? onImageLoaded;
  final Function(Object error)? onImageError;

  const CustomNetworkImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableRetry = true,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
    this.showDebugInfo = false,
    this.onImageLoaded,
    this.onImageError,
  }) : super(key: key);

  @override
  State<CustomNetworkImage> createState() => _CustomNetworkImageState();
}

class _CustomNetworkImageState extends State<CustomNetworkImage> {
  int _retryCount = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  late String _processedUrl;

  @override
  void initState() {
    super.initState();
    _processedUrl = UrlService.constructImageUrl(widget.imageUrl);
    _logDebugInfo('Image widget initialized');
  }

  void _logDebugInfo(String message) {
    if (widget.showDebugInfo) {
      print('CustomNetworkImage: $message');
      print('URL: $_processedUrl');
      print('Retry count: $_retryCount');
      print('---');
    }
  }

  Future<void> _retryLoad() async {
    if (_retryCount < widget.maxRetries) {
      setState(() {
        _retryCount++;
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });
      
      _logDebugInfo('Retrying image load (attempt $_retryCount)');
      
      await Future.delayed(widget.retryDelay);
      
      // Force rebuild to retry image loading
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: AppConstants.primaryColor.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppConstants.primaryColor,
            strokeWidth: 2,
          ),
          if (widget.showDebugInfo) ...[
            const SizedBox(height: 8),
            Text(
              'Loading... (${_retryCount + 1}/${widget.maxRetries + 1})',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      color: AppConstants.primaryColor.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 40,
            color: AppConstants.primaryColor.withOpacity(0.7),
          ),
          const SizedBox(height: 8),
          Text(
            'Gambar tidak dapat dimuat',
            style: TextStyle(
              color: AppConstants.primaryColor.withOpacity(0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.enableRetry && _retryCount < widget.maxRetries) ...[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _retryLoad,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 0),
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(fontSize: 10),
              ),
            ),
          ],
          if (widget.showDebugInfo) ...[
            const SizedBox(height: 4),
            Text(
              'Error: $_errorMessage',
              style: const TextStyle(fontSize: 8, color: Colors.red),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'URL: $_processedUrl',
              style: const TextStyle(fontSize: 8, color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholderWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: AppConstants.primaryColor.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: 40,
            color: AppConstants.primaryColor.withOpacity(0.7),
          ),
          if (widget.placeholder != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.placeholder!,
              style: TextStyle(
                color: AppConstants.primaryColor.withOpacity(0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If URL is empty or invalid, show placeholder
    if (_processedUrl.isEmpty || !UrlService.isValidUrl(_processedUrl)) {
      _logDebugInfo('Invalid URL, showing placeholder');
      return _buildPlaceholderWidget();
    }

    return Image.network(
      _processedUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      headers: UrlService.getImageHeaders(_processedUrl),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          // Image loaded successfully
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = false;
              });
              widget.onImageLoaded?.call();
              _logDebugInfo('Image loaded successfully');
            }
          });
          return child;
        }
        
        // Show loading progress
        return Container(
          width: widget.width,
          height: widget.height,
          color: AppConstants.primaryColor.withOpacity(0.1),
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: AppConstants.primaryColor,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        _logDebugInfo('Image load error: $error');
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = error.toString();
            });
            widget.onImageError?.call(error);
          }
        });
        
        return _buildErrorWidget();
      },
    );
  }
}

// Convenience widget for tool images
class ToolImage extends StatelessWidget {
  final String? imageUrl;
  final String toolName;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool showDebugInfo;

  const ToolImage({
    Key? key,
    required this.imageUrl,
    required this.toolName,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.showDebugInfo = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomNetworkImage(
      imageUrl: imageUrl ?? '',
      width: width,
      height: height,
      fit: fit,
      placeholder: toolName,
      showDebugInfo: showDebugInfo,
      errorWidget: Container(
        width: width,
        height: height,
        color: AppConstants.primaryColor.withOpacity(0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build,
              size: 40,
              color: AppConstants.primaryColor.withOpacity(0.7),
            ),
            const SizedBox(height: 8),
            Text(
              toolName,
              style: TextStyle(
                color: AppConstants.primaryColor.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
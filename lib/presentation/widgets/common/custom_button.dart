import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final bool isSmall;
  final bool isLarge;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Widget? child;
  final bool showShadow;
  final Gradient? gradient;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.isSmall = false,
    this.isLarge = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.child,
    this.showShadow = true,
    this.gradient,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() {});
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _resetAnimation();
  }

  void _handleTapCancel() {
    _resetAnimation();
  }

  void _resetAnimation() {
    setState(() {});
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: widget.onPressed,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: widget.width,
                height: widget.height ?? _getButtonHeight(),
                padding: widget.padding ?? _getButtonPadding(),
                decoration: BoxDecoration(
                  gradient: widget.gradient ?? _getGradient(isDark),
                  color: widget.gradient == null
                      ? _getBackgroundColor(theme, isDark)
                      : null,
                  border: widget.isOutlined
                      ? Border.all(
                          color:
                              widget.borderColor ?? AppConstants.primaryColor,
                          width: 2,
                        )
                      : null,
                  borderRadius:
                      widget.borderRadius ??
                      BorderRadius.circular(AppConstants.borderRadiusMedium),
                  boxShadow:
                      widget.showShadow &&
                          !widget.isOutlined &&
                          widget.onPressed != null
                      ? [
                          BoxShadow(
                            color:
                                (widget.backgroundColor ??
                                        AppConstants.primaryColor)
                                    .withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: widget.child ?? _buildButtonContent(theme),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (widget.isLoading) {
      return _buildLoadingContent(theme);
    }

    if (widget.icon != null) {
      return _buildIconButtonContent(theme);
    }

    return _buildTextButtonContent(theme);
  }

  Widget _buildLoadingContent(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _getLoadingSize(),
          height: _getLoadingSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(_getTextColor(theme)),
          ),
        ),
        const SizedBox(width: AppConstants.spacingSmall),
        Text('Loading...', style: _getTextStyle(theme)),
      ],
    );
  }

  Widget _buildIconButtonContent(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(widget.icon, size: _getIconSize(), color: _getTextColor(theme)),
        const SizedBox(width: AppConstants.spacingSmall),
        Text(widget.text, style: _getTextStyle(theme)),
      ],
    );
  }

  Widget _buildTextButtonContent(ThemeData theme) {
    return Text(
      widget.text,
      style: _getTextStyle(theme),
      textAlign: TextAlign.center,
    );
  }

  double _getButtonHeight() {
    if (widget.isSmall) return 40;
    if (widget.isLarge) return 60;
    return 50;
  }

  EdgeInsetsGeometry _getButtonPadding() {
    if (widget.isSmall) {
      return const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMedium,
        vertical: AppConstants.spacingSmall,
      );
    }
    if (widget.isLarge) {
      return const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingXLarge,
        vertical: AppConstants.spacingLarge,
      );
    }
    return const EdgeInsets.symmetric(
      horizontal: AppConstants.spacingLarge,
      vertical: AppConstants.spacingMedium,
    );
  }

  double _getLoadingSize() {
    if (widget.isSmall) return 16;
    if (widget.isLarge) return 24;
    return 20;
  }

  double _getIconSize() {
    if (widget.isSmall) return 18;
    if (widget.isLarge) return 28;
    return 24;
  }

  Color _getBackgroundColor(ThemeData theme, bool isDark) {
    if (widget.onPressed == null) {
      return theme.disabledColor;
    }

    if (widget.isOutlined) {
      return Colors.transparent;
    }

    return widget.backgroundColor ?? AppConstants.primaryColor;
  }

  Color _getTextColor(ThemeData theme) {
    if (widget.onPressed == null) {
      return theme.disabledColor;
    }

    if (widget.isOutlined) {
      return widget.textColor ?? AppConstants.primaryColor;
    }

    return widget.textColor ?? Colors.white;
  }

  TextStyle _getTextStyle(ThemeData theme) {
    TextStyle baseStyle;

    if (widget.isSmall) {
      baseStyle = theme.textTheme.bodyMedium ?? const TextStyle();
    } else if (widget.isLarge) {
      baseStyle = theme.textTheme.titleMedium ?? const TextStyle();
    } else {
      baseStyle = theme.textTheme.bodyLarge ?? const TextStyle();
    }

    return baseStyle.copyWith(
      color: _getTextColor(theme),
      fontWeight: FontWeight.w600,
    );
  }

  Gradient? _getGradient(bool isDark) {
    if (widget.isOutlined || widget.onPressed == null) {
      return null;
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        widget.backgroundColor ?? AppConstants.primaryColor,
        (widget.backgroundColor ?? AppConstants.primaryColor).withOpacity(0.8),
      ],
    );
  }
}

// Specialized button variants
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isSmall;
  final bool isLarge;
  final double? width;

  const PrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isSmall = false,
    this.isLarge = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      isSmall: isSmall,
      isLarge: isLarge,
      width: width,
      backgroundColor: AppConstants.primaryColor,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isSmall;
  final bool isLarge;
  final double? width;

  const SecondaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isSmall = false,
    this.isLarge = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      isSmall: isSmall,
      isLarge: isLarge,
      width: width,
      isOutlined: true,
      showShadow: false,
    );
  }
}

class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isSmall;
  final bool isLarge;
  final double? width;

  const DangerButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isSmall = false,
    this.isLarge = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      isSmall: isSmall,
      isLarge: isLarge,
      width: width,
      backgroundColor: AppConstants.errorColor,
    );
  }
}

class SuccessButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isSmall;
  final bool isLarge;
  final double? width;

  const SuccessButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isSmall = false,
    this.isLarge = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      isSmall: isSmall,
      isLarge: isLarge,
      width: width,
      backgroundColor: AppConstants.successColor,
    );
  }
}

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isExtended;
  final String? label;

  const CustomFloatingActionButton({
    Key? key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.isExtended = false,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon, color: foregroundColor ?? Colors.white),
        label: Text(
          label!,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: foregroundColor ?? Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: backgroundColor ?? AppConstants.primaryColor,
        tooltip: tooltip,
        // Modern FloatingActionButton doesn't use these parameters anymore
        // elevation: 8,
        // highlightElevation: 12,
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        // ),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? AppConstants.primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      // Modern FloatingActionButton doesn't use these parameters anymore
      // elevation: 8,
      // highlightElevation: 12,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      // ),
      // child: Icon(
      //   icon,
      //   size: 28,
      // ),
      // Use the required icon parameter instead
      child: Icon(icon, size: 28),
    );
  }
}

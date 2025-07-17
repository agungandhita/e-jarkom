import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool centerTitle;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = true,
    this.leading,
    required int maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: backgroundColor != null ? null : AppConstants.primaryGradient,
        color: backgroundColor,
      ),
      child: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: foregroundColor ?? Colors.white,
          ),
        ),
        centerTitle: centerTitle,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: foregroundColor ?? Colors.white,
        leading: leading ?? (showBackButton ? _buildBackButton(context) : null),
        actions: actions,
        automaticallyImplyLeading: showBackButton,
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () => Navigator.of(context).pop(),
      tooltip: 'Kembali',
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

import 'dart:io';
import 'package:flutter/material.dart';
import '../ux_config.dart';

class CustomBottomNavBar extends StatelessWidget {
  final VoidCallback onLeftActionPressed;
  final VoidCallback onRightActionPressed;
  final VoidCallback onCenterActionPressed;
  final File? rightThumbnail;
  final bool isLoading;
  final IconData? centerIcon;

  const CustomBottomNavBar({
    super.key,
    required this.onLeftActionPressed,
    required this.onRightActionPressed,
    required this.onCenterActionPressed,
    this.rightThumbnail,
    this.isLoading = false,
    this.centerIcon,
  });

  // 스타일 관련 상수들을 UXConfig에서 관리하도록 변경
  static const double kBarWidth = UXConfig.kBottomBarWidth;
  static const double kBarHeight = UXConfig.kBottomBarHeight;
  static const double kBarRadius = UXConfig.kBottomBarBorderRadius;
  static const double kShutterSize = UXConfig.kBottomBarCenterButtonSize;
  static const double kInnerShutterSize = UXConfig.kBottomBarInnerRingSize;
  static const Color kShutterColor = UXConfig.kBottomBarCenterButtonColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kShutterSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. The White Capsule Bar
          Container(
            width: kBarWidth,
            height: kBarHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(kBarRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),

          // 2. The Content Row
          SizedBox(
            width: kBarWidth,
            height: kBarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: onLeftActionPressed,
                    icon: const Icon(
                      Icons.calendar_month_outlined,
                      color: Colors.black87,
                      size: 28,
                    ),
                  ),
                  GestureDetector(
                    onTap: onRightActionPressed,
                    child: _buildRightThumbnail(),
                  ),
                ],
              ),
            ),
          ),

          // 3. The Pop-out Action Button
          Positioned(
            bottom: 2,
            child: GestureDetector(
              onTap: isLoading ? null : onCenterActionPressed,
              child: _buildCenterButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightThumbnail() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 1),
        image: rightThumbnail != null
            ? DecorationImage(
                image: FileImage(rightThumbnail!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: rightThumbnail == null
          ? const Icon(
              Icons.photo_library_outlined,
              size: 24,
              color: Colors.black45,
            )
          : null,
    );
  }

  Widget _buildCenterButton() {
    return Container(
      width: kShutterSize,
      height: kShutterSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kShutterColor,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: kInnerShutterSize,
          height: kInnerShutterSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.85),
              width: 1.5,
            ),
          ),
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : (centerIcon != null
                    ? Icon(centerIcon, color: Colors.white, size: 44)
                    : null),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import '../services/app_settings_service.dart';
import '../services/app_localizations.dart';
import '../ux_config.dart';
import '../album_service.dart';

class CustomBottomNavBar extends StatelessWidget {
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onPhotoPickerPressed;
  final VoidCallback? onAlbumPressed;
  final VoidCallback? onStampManagementPressed;
  final VoidCallback onCenterActionPressed;
  final File? photoThumbnail;
  final bool isLoading;
  final IconData? centerIcon;
  final bool isVideoMode;
  final bool isRecording;
  final bool isReviewScreen;

  // Backward compatibility
  final VoidCallback? onLeftActionPressed;
  final VoidCallback? onRightActionPressed;
  final File? rightThumbnail;
  final File? leftThumbnail;

  const CustomBottomNavBar({
    super.key,
    this.onSettingsPressed,
    this.onPhotoPickerPressed,
    this.onAlbumPressed,
    this.onStampManagementPressed,
    required this.onCenterActionPressed,
    this.photoThumbnail,
    this.isLoading = false,
    this.centerIcon,
    this.isVideoMode = false,
    this.isRecording = false,
    this.isReviewScreen = false,
    this.onLeftActionPressed,
    this.onRightActionPressed,
    this.rightThumbnail,
    this.leftThumbnail,
  });

  // 스타일 관련 상수들을 SharedUX에서 관리
  static const double kShutterSize = SharedUX.centerButtonSize;

  Color get _shutterColor => AppSettingsService().accentColor;

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsService();
    // 촬영 후 리뷰 화면(PhotoReview, VideoReview)에서만 화이트 테마 적용 시 어두운 텍스트/아이콘을 사용합니다.
    // 첫 번째 카메라 화면은 항상 어두운 뷰파인더 배경이므로 언제나 흰색 아이콘/라벨을 유지합니다.
    final bool useDarkTheme = isReviewScreen && settings.isLight;

    final Color iconColor = useDarkTheme ? const Color(0xFF1E2026) : Colors.white;
    final Color labelColor = useDarkTheme ? const Color(0xFF4B5563) : Colors.white70;
    final Color lineColor = useDarkTheme
        ? Colors.black.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.35);

    final List<Shadow>? shadow = useDarkTheme
        ? null
        : const [
            Shadow(
              blurRadius: 8,
              color: Colors.black45,
              offset: Offset(0, 2),
            )
          ];

    final VoidCallback? photoPickerAction =
        onPhotoPickerPressed ?? onLeftActionPressed;
    final VoidCallback? albumAction =
        onAlbumPressed ?? onRightActionPressed;
    final File? thumbnail = photoThumbnail ?? leftThumbnail ?? rightThumbnail;

    return SizedBox(
      height: SharedUX.containerHeight,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. Decorative Concave Line
          Positioned(
            left: 0,
            right: 0,
            bottom: SharedUX.linePosition,
            child: CustomPaint(
              size: const Size(double.infinity, 40),
              painter: _ConcaveLinePainter(
                shutterSize: kShutterSize,
                color: lineColor,
              ),
            ),
          ),

          // 2. The Content Row (Side Icons)
          Positioned(
            left: 0,
            right: 0,
            bottom: SharedUX.iconsPosition - 12.0, // adjusted for expanded hit area
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // Left side: Photo Picker ("사진선택") & Album ("앨범")
                  Expanded(
                    child: onSettingsPressed != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (photoPickerAction != null)
                                _labeledGalleryButton(
                                  label: AppStrings.navPickPhoto,
                                  thumbnail: thumbnail,
                                  onPressed: photoPickerAction,
                                  shadow: shadow,
                                  iconColor: iconColor,
                                  labelColor: labelColor,
                                ),
                              if (albumAction != null)
                                _labeledIconButton(
                                  icon: Icons.calendar_today_outlined,
                                  label: AppStrings.navAlbum,
                                  onPressed: albumAction,
                                  shadow: shadow,
                                  iconColor: iconColor,
                                  labelColor: labelColor,
                                ),
                            ],
                          )
                        : Center(
                            child: photoPickerAction != null
                                ? _labeledGalleryButton(
                                    label: AppStrings.navPickPhoto,
                                    thumbnail: thumbnail,
                                    onPressed: photoPickerAction,
                                    shadow: shadow,
                                    iconColor: iconColor,
                                    labelColor: labelColor,
                                  )
                                : const SizedBox.shrink(),
                          ),
                  ),

                  // Center space for floating Shutter Button
                  const SizedBox(width: kShutterSize + 20.0),

                  // Right side: Stamp Management ("스탬프 관리") & Settings ("설정")
                  Expanded(
                    child: onSettingsPressed != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (onStampManagementPressed != null)
                                _labeledIconButton(
                                  imageAsset: 'assets/icons/stamp_manage.png',
                                  label: AppStrings.navStampManage,
                                  onPressed: onStampManagementPressed!,
                                  shadow: shadow,
                                  iconColor: iconColor,
                                  labelColor: labelColor,
                                ),
                              _labeledIconButton(
                                icon: Icons.settings_outlined,
                                label: AppStrings.navSettings,
                                onPressed: onSettingsPressed!,
                                shadow: shadow,
                                iconColor: iconColor,
                                labelColor: labelColor,
                              ),
                            ],
                          )
                        : Center(
                            child: albumAction != null
                                ? _labeledIconButton(
                                    icon: Icons.calendar_today_outlined,
                                    label: AppStrings.navAlbum,
                                    onPressed: albumAction,
                                    shadow: shadow,
                                    iconColor: iconColor,
                                    labelColor: labelColor,
                                  )
                                : const SizedBox.shrink(),
                          ),
                  ),
                ],
              ),
            ),
          ),

          // 3. The Pop-out Action Button (Floating Shutter)
          Positioned(
            bottom: SharedUX.shutterPosition,
            child: GestureDetector(
              onTap: isLoading ? null : onCenterActionPressed,
              child: _buildCenterButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _labeledIconButton({
    IconData? icon,
    String? imageAsset,
    required String label,
    required VoidCallback onPressed,
    required List<Shadow>? shadow,
    Color iconColor = Colors.white,
    Color labelColor = Colors.white70,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageAsset != null)
              Image.asset(
                imageAsset,
                width: SharedUX.navIconSize,
                height: SharedUX.navIconSize,
                color: iconColor,
                fit: BoxFit.contain,
              )
            else if (icon != null)
              Icon(
                icon,
                color: iconColor,
                size: SharedUX.navIconSize,
                shadows: shadow,
              ),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                color: labelColor,
                fontSize: SharedUX.navLabelSize,
                fontWeight: FontWeight.w500,
                shadows: shadow,
                fontFamily: AppLocalizations.resolveFontFamily(
                  SharedUX.navLabelFontFamily,
                  label,
                ),
                fontFamilyFallback: AppLocalizations.fontFallbackChain,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _labeledGalleryButton({
    required String label,
    required File? thumbnail,
    required VoidCallback onPressed,
    required List<Shadow>? shadow,
    Color iconColor = Colors.white,
    Color labelColor = Colors.white70,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (thumbnail != null && !AlbumService.isVideo(thumbnail))
              Container(
                width: SharedUX.navThumbnailSize,
                height: SharedUX.navThumbnailSize,
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.2),
                  image: DecorationImage(
                    image: FileImage(thumbnail),
                    fit: BoxFit.cover,
                    onError: (e, s) {},
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              )
            else if (thumbnail != null && AlbumService.isVideo(thumbnail))
              Container(
                width: SharedUX.navThumbnailSize,
                height: SharedUX.navThumbnailSize,
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                  border: Border.all(color: Colors.white, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              )
            else
              Icon(
                Icons.photo_library_outlined,
                color: iconColor,
                size: SharedUX.navIconSize,
                shadows: shadow,
              ),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                color: labelColor,
                fontSize: SharedUX.navLabelSize,
                fontWeight: FontWeight.w500,
                shadows: shadow,
                fontFamily: AppLocalizations.resolveFontFamily(
                  SharedUX.navLabelFontFamily,
                  label,
                ),
                fontFamilyFallback: AppLocalizations.fontFallbackChain,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    final color = _shutterColor;

    if (isLoading) {
      return Container(
        width: kShutterSize,
        height: kShutterSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: SharedUX.centerOpacity),
          border: Border.all(
            color: color,
            width: SharedUX.centerRingWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          ),
        ),
      );
    }

    if (centerIcon != null) {
      return Container(
        width: kShutterSize,
        height: kShutterSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: SharedUX.centerOpacity),
          border: Border.all(
            color: color,
            width: SharedUX.centerRingWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Icon(centerIcon, color: Colors.white, size: SharedUX.centerIconSize),
        ),
      );
    }

    if (isVideoMode) {
      return Container(
        width: kShutterSize,
        height: kShutterSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.25),
          border: Border.all(
            color: Colors.white,
            width: 3.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: isRecording ? 24 : 46,
            height: isRecording ? 24 : 46,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(isRecording ? 6 : 23),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      width: kShutterSize,
      height: kShutterSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: SharedUX.centerOpacity),
        border: Border.all(
          color: color,
          width: SharedUX.centerRingWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    );
  }
}

class _ConcaveLinePainter extends CustomPainter {
  final double shutterSize;
  final Color color;

  _ConcaveLinePainter({required this.shutterSize, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    final centerY = 0.0;
    final centerX = size.width / 2;
    
    // Layout-specific parameters from SharedUX
    final dipWidth = shutterSize / 2 + SharedUX.lineDipWidthExtra;
    final dipDepth = SharedUX.lineDipDepth;
    final shoulderWidth = SharedUX.lineShoulderWidth;

    // Left straight line
    path.moveTo(0, centerY);
    path.lineTo(centerX - dipWidth - shoulderWidth, centerY);

    // Left smooth shoulder to dip
    path.cubicTo(
      centerX - dipWidth - shoulderWidth / 2, centerY, // Control point 1
      centerX - dipWidth, centerY,               // Control point 2
      centerX - dipWidth, centerY + dipDepth / 2, // End point
    );
    
    // Bottom curve around shutter
    path.arcToPoint(
      Offset(centerX + dipWidth, centerY + dipDepth / 2),
      radius: Radius.circular(dipWidth),
      clockwise: false,
    );

    // Right dip back to smooth shoulder
    path.cubicTo(
      centerX + dipWidth, centerY,               // Control point 1
      centerX + dipWidth + shoulderWidth / 2, centerY, // Control point 2
      centerX + dipWidth + shoulderWidth, centerY, // End point
    );

    // Right straight line
    path.lineTo(size.width, centerY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'timestamp_overlays.dart';
import 'album_service.dart';
import 'calendar_album_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/ad_banner_widget.dart';
import 'widgets/unlock_timestamp_dialog.dart';
import 'services/timestamp_access_manager.dart';
import 'services/timestamp_deck_manager.dart';
import 'timestamp_metadata.dart';
import 'ux_config.dart';
import 'gallery_picker_screen.dart';
import 'stamp_management_screen.dart';
import 'settings_screen.dart';
import 'package:flutter/services.dart';
import 'services/app_settings_service.dart';

class PhotoReviewScreen extends StatefulWidget {
  final File imageFile;
  final TimestampDesign initialDesign;
  final String initialAlbum;
  final double aspectRatio;
  final DateTime captureTime;
  final Alignment initialAlignment;
  final int initialFontSizeIndex;

  /// Front camera captures are not mirrored by the sensor; flip them so the
  /// result matches what the user saw in the preview ("save as previewed").
  final bool mirrorHorizontally;

  const PhotoReviewScreen({
    super.key,
    required this.imageFile,
    required this.initialDesign,
    required this.initialAlbum,
    required this.aspectRatio,
    required this.captureTime,
    this.initialAlignment = CameraUX.defaultAlignment,
    this.initialFontSizeIndex = 0,
    this.mirrorHorizontally = false,
  });

  @override
  State<PhotoReviewScreen> createState() => _PhotoReviewScreenState();
}

class _PhotoReviewScreenState extends State<PhotoReviewScreen> {

  late TimestampDesign _selectedDesign;
  late Alignment _selectedAlignment;
  late double _selectedFontSize;
  late int _fontSizeIndex;
  late String _selectedAlbum;
  List<String> _availableAlbums = [];
  bool _isSaving = false;

  File? _latestPhoto;

  final GlobalKey _repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedDesign = widget.initialDesign;
    _selectedAlignment = widget.initialAlignment;
    _fontSizeIndex = widget.initialFontSizeIndex;
    
    final steps = TimestampMetadata.getFontSizeSteps(_selectedDesign);
    _selectedFontSize = steps[_fontSizeIndex.clamp(0, steps.length - 1)];

    _selectedAlbum = widget.initialAlbum;
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    final albums = await AlbumService.getAlbums();
    final allPhotos = await AlbumService.getAllPhotos(albumName: '전체');
    if (mounted) {
      setState(() {
        _availableAlbums = albums;
        if (allPhotos.isNotEmpty) {
          _latestPhoto = allPhotos.first;
        }
      });
    }
  }

  Future<void> _savePhoto() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();

        // 1. Temporary file for Gal
        final tempDir = Directory.systemTemp;
        final tempPath =
            '${tempDir.path}/timenow_final_${DateTime.now().millisecondsSinceEpoch}.png';
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(bytes);

        // 2. Save to System Gallery
        await Gal.putImage(tempPath, album: 'Timenow');

        // 3. Save to App Album
        await AlbumService.savePhoto(bytes, _selectedAlbum, originalDate: widget.captureTime);

        if (mounted) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CalendarAlbumScreen(initialAlbum: _selectedAlbum),
            ),
          );
          if (mounted) {
            Navigator.pop(context, result is String ? result : _selectedAlbum);
          }
        }
      }
    } catch (e) {
      debugPrint('Save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettingsService(),
      builder: (context, _) {
        final settings = AppSettingsService();
        return Scaffold(
          backgroundColor: settings.scaffoldBackgroundColor,
          body: Stack(
            fit: StackFit.expand,
            children: [
              _buildImageWithOverlay(),
              _buildTopBar(),
              _buildBottomControls(isFullAuto: widget.aspectRatio == 9.0 / 16.0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding,
      left: 0,
      right: 0,
      child: Container(
        // 상단 메뉴 영역(60) 안에 배너(50)가 들어가도록 세로 여백 5
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: const Center(
          child: AdBannerWidget(compact: true),
        ),
      ),
    );
  }

  Widget _buildImageWithOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenW = constraints.maxWidth;
        final screenH = constraints.maxHeight;

        final topPadding = MediaQuery.of(context).padding.top;
        final topMenuH = topPadding + 60;

        final bool isFullAuto = (widget.aspectRatio - (9.0 / 16.0)).abs() < 0.01;
        final bool is4x5 = (widget.aspectRatio - (4.0 / 5.0)).abs() < 0.01 ||
            (widget.aspectRatio - 0.8).abs() < 0.01;

        double clearW = screenW;
        double clearH;
        double clearTop;
        double clearLeft = 0;

        if (isFullAuto) {
          clearTop = topMenuH;
          clearW = screenW;
          clearH = screenW * (16.0 / 9.0);
          final maxH = screenH - topMenuH;
          if (clearH > maxH) {
            clearH = maxH;
            clearW = maxH * (9.0 / 16.0);
            clearLeft = (screenW - clearW) / 2;
          }
        } else if (is4x5) {
          clearW = screenW;
          clearH = screenW * 1.25;
          clearTop = topMenuH;
        } else {
          // 1:1
          clearW = screenW;
          clearH = screenW;
          clearTop = topMenuH;
        }

        return Stack(
          children: [
            Positioned(
              top: clearTop,
              left: clearLeft,
              child: RepaintBoundary(
                key: _repaintKey,
                child: SizedBox(
                  width: clearW,
                  height: clearH,
                  child: ClipRect(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Transform.flip(
                          flipX: widget.mirrorHorizontally,
                          child: Image.file(
                            widget.imageFile,
                            fit: BoxFit.cover,
                            cacheWidth: 2400,
                          ),
                        ),
                        if (_selectedDesign != TimestampDesign.none)
                          Positioned.fill(
                            child: TimestampOverlayWidget(
                              design: _selectedDesign,
                              alignment: _selectedAlignment,
                              fontSize: _selectedFontSize,
                              opacity: 1.0,
                              baseTime: widget.captureTime,
                              isLive: false,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: topMenuH + screenW - 110,
              child: Builder(
                builder: (context) {
                  final canAlign = TimestampMetadata.supportsAlignment(_selectedDesign);
                  final canResize = TimestampMetadata.supportsFontSize(_selectedDesign);
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _hoverButton(
                        icon: Icons.open_with,
                        enabled: canAlign,
                        onTap: canAlign ? _cycleAlignment : null,
                      ),
                      const SizedBox(height: 10),
                      _hoverButton(
                        label: "${_fontSizeIndex + 1}A",
                        enabled: canResize,
                        onTap: canResize ? _cycleFontSize : null,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _hoverButton({
    IconData? icon,
    String? label,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    final fgColor = Colors.white.withValues(alpha: enabled ? 1.0 : 0.4);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1.0 : 0.38,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: enabled ? 0.4 : 0.3),
            border: Border.all(
              color: Colors.white.withValues(alpha: enabled ? 0.24 : 0.12),
              width: 1,
            ),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, color: fgColor, size: 20)
                : Text(
                    label!,
                    style: TextStyle(
                      color: fgColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _cycleFontSize() {
    if (!TimestampMetadata.supportsFontSize(_selectedDesign)) return;
    setState(() {
      final steps = TimestampMetadata.getFontSizeSteps(_selectedDesign);
      _fontSizeIndex = (_fontSizeIndex + 1) % steps.length;
      _selectedFontSize = steps[_fontSizeIndex];
    });
  }

  void _cycleAlignment() {
    if (!TimestampMetadata.supportsAlignment(_selectedDesign)) return;
    setState(() {
      final index = CameraUX.alignments.indexOf(_selectedAlignment);
      final nextIndex = (index + 1) % CameraUX.alignments.length;
      _selectedAlignment = CameraUX.alignments[nextIndex];
    });
  }

  Widget _buildBottomControls({required bool isFullAuto}) {
    final pickerToShutterGap = (CameraUX.gapPickerToShutterTop -
            (SharedUX.containerHeight -
                (SharedUX.shutterPosition +
                    SharedUX.centerButtonSize)))
        .clamp(0.0, double.infinity);

    return Positioned(
      bottom: SharedUX.stackBottomOffset + MediaQuery.of(context).padding.bottom,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAlbumSelector(isOverlay: !isFullAuto),
          const SizedBox(height: CameraUX.gapRatioToPicker),
          _buildTimestampPicker(),
          SizedBox(height: pickerToShutterGap),
          _buildFloatingMenu(isOverlay: !isFullAuto),
        ],
      ),
    );
  }

  Widget _buildFloatingMenu({required bool isOverlay}) {
    return CustomBottomNavBar(
      onSettingsPressed: () async {
        HapticFeedback.lightImpact();
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        if (mounted) setState(() {});
      },
      onPhotoPickerPressed: () async {
        final GalleryResult? galleryResult = await Navigator.push<GalleryResult>(
          context,
          MaterialPageRoute(
            builder: (context) => const GalleryPickerScreen(),
          ),
        );
        if (galleryResult != null && mounted) {
          Navigator.pop(context, galleryResult);
        }
      },
      onAlbumPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CalendarAlbumScreen(initialAlbum: _selectedAlbum),
          ),
        );
        if (mounted && result is String) {
          Navigator.pop(context, result);
        }
      },
      onStampManagementPressed: () async {
        HapticFeedback.lightImpact();
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const StampManagementScreen(),
          ),
        );
        if (mounted) {
          setState(() {});
        }
      },
      onCenterActionPressed: _savePhoto,
      photoThumbnail: _latestPhoto,
      isLoading: _isSaving,
      centerIcon: Icons.check,
    );
  }

  Widget _buildAlbumSelector({required bool isOverlay}) {
    return SizedBox(
      height: ReviewUX.albumSelectorHeight,

      child: Center(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _availableAlbums.length,
          itemBuilder: (context, index) {
            final album = _availableAlbums[index];
            final isSelected = _selectedAlbum == album;
            return GestureDetector(
              onTap: () => setState(() => _selectedAlbum = album),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: ReviewUX.albumButtonMarginHorizontal),
                padding: const EdgeInsets.symmetric(
                  horizontal: ReviewUX.albumButtonHorizontalPadding,
                  vertical: ReviewUX.albumButtonVerticalPadding,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ReviewUX.albumButtonSelectedBg
                      : ReviewUX.albumButtonBg,
                  borderRadius: BorderRadius.circular(ReviewUX.albumButtonBorderRadius),
                  border: Border.all(
                    color: isSelected ? Colors.white24 : Colors.transparent,
                  ),
                ),
                child: Center(
                  child: Text(
                    album,
                    style: TextStyle(
                      color: isSelected
                          ? ReviewUX.albumButtonSelectedText
                          : ReviewUX.albumButtonText,
                      fontSize: ReviewUX.albumButtonFontSize,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),

                  ),
                ),

              ),
            );
          },
        ),
      ),
    );
  }

  void _selectDesign(TimestampDesign design) {
    setState(() {
      _selectedDesign = design;
      _selectedAlignment = CameraUX.defaultAlignment;
      _fontSizeIndex = TimestampMetadata.getDefaultFontSizeIndex(design);
      _selectedFontSize = TimestampMetadata.getDefaultFontSize(design);
    });
  }

  void _onDesignTapped(TimestampDesign design) {
    if (TimestampAccessManager().isUnlocked(design)) {
      _selectDesign(design);
    } else {
      UnlockTimestampDialog.show(
        context,
        design: design,
        onUnlocked: () {
          _selectDesign(design);
        },
      );
    }
  }

  Widget _buildTimestampPicker() {
    return ListenableBuilder(
      listenable: TimestampDeckManager(),
      builder: (context, _) {
        final designs = TimestampDeckManager().getMainScreenDesigns();

        return SizedBox(
          height: CameraUX.timestampPickerHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            // designs (최대 20개) + 맨 마지막 아이템: '스탬프 관리' 버튼
            itemCount: designs.length + 1,
            itemBuilder: (context, index) {
              if (index < designs.length) {
                final design = designs[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: TimestampThumbnail(
                    design: design,
                    isSelected: _selectedDesign == design,
                    onTap: () => _onDesignTapped(design),
                  ),
                );
              }

              // 맨 오른쪽 끝: 스탬프 관리 화면 진입 버튼
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StampManagementScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1D24),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppSettingsService().accentColor.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppSettingsService().accentColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.approval_rounded,
                                color: AppSettingsService().accentColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '스탬프\n관리',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'timestamp_overlays.dart';
import 'album_service.dart';
import 'calendar_album_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/unlock_timestamp_dialog.dart';
import 'services/timestamp_access_manager.dart';
import 'services/timestamp_deck_manager.dart';
import 'timestamp_metadata.dart';
import 'ux_config.dart';
import 'gallery_picker_screen.dart';
import 'stamp_management_screen.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFF0F1013),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildImageWithOverlay(),
          _buildTopBar(iconColor: CameraUX.getTopIconColor(widget.aspectRatio)),
          _buildBottomControls(isFullAuto: widget.aspectRatio == 9.0 / 16.0),
        ],
      ),
    );
  }

  Widget _buildTopBar({required Color iconColor}) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: iconColor, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 48), // Spacer
          ],
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
          clearW = screenW;
          clearH = screenH;
          clearTop = 0;
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
              top: clearTop,
              left: clearLeft,
              width: clearW,
              height: clearH,
              child: Container(
                padding: const EdgeInsets.only(right: 12, bottom: 12),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _hoverButton(
                      icon: Icons.open_with,
                      onTap: _cycleAlignment,
                    ),
                    const SizedBox(height: 12),
                    _hoverButton(
                      label: "${_fontSizeIndex + 1}A",
                      onTap: _cycleFontSize,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _hoverButton({IconData? icon, String? label, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.4),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Center(
          child: icon != null 
              ? Icon(icon, color: Colors.white, size: 20)
              : Text(
                  label!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  void _cycleFontSize() {
    setState(() {
      final steps = TimestampMetadata.getFontSizeSteps(_selectedDesign);
      _fontSizeIndex = (_fontSizeIndex + 1) % steps.length;
      _selectedFontSize = steps[_fontSizeIndex];
    });
  }

  void _cycleAlignment() {
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
      onLeftActionPressed: () async {
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
      onRightActionPressed: () async {
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
      onCenterActionPressed: _savePhoto,
      rightThumbnail: _latestPhoto,
      isLoading: _isSaving,
      centerIcon: Icons.keyboard_arrow_down,
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
                            color: const Color(0xFFC6FF00).withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC6FF00).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.tune_rounded,
                                color: Color(0xFFC6FF00),
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

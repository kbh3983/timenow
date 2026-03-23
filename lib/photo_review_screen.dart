import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'timestamp_overlays.dart';
import 'album_service.dart';
import 'calendar_album_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'timestamp_metadata.dart';
import 'ux_config.dart';

class PhotoReviewScreen extends StatefulWidget {
  final File imageFile;
  final TimestampDesign initialDesign;
  final String initialAlbum;
  final double aspectRatio;
  final DateTime captureTime;
  final Alignment initialAlignment;
  final int initialFontSizeIndex;

  const PhotoReviewScreen({
    super.key,
    required this.imageFile,
    required this.initialDesign,
    required this.initialAlbum,
    required this.aspectRatio,
    required this.captureTime,
    this.initialAlignment = CameraUX.defaultAlignment,
    this.initialFontSizeIndex = 0,
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
        await AlbumService.savePhoto(bytes, _selectedAlbum);

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
      backgroundColor: Colors.black,
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
        final targetRatio = widget.aspectRatio;

        double clearW, clearH;
        if (screenW / targetRatio <= screenH) {
          clearW = screenW;
          clearH = screenW / targetRatio;
        } else {
          clearH = screenH;
          clearW = screenH * targetRatio;
        }

        final topPadding = MediaQuery.of(context).padding.top;
        final topMenuH = topPadding + 60;

        // Synchronized with CameraScreen's layout logic
        final pickerToShutterGap = (CameraUX.gapPickerToShutterTop -
                (SharedUX.containerHeight -
                    (SharedUX.shutterPosition +
                        SharedUX.centerButtonSize)))
            .clamp(0.0, double.infinity);

        final bottomUIH = SharedUX.stackBottomOffset +
            SharedUX.containerHeight +
            pickerToShutterGap +
            CameraUX.timestampPickerHeight +
            CameraUX.gapRatioToPicker +
            CameraUX.ratioButtonsHeight; // Synchronized height

        final availableH = screenH - topMenuH - bottomUIH;

        final bool isFullAuto = widget.aspectRatio == 9.0 / 16.0;

        final clearTop =
            (isFullAuto ||
                widget.aspectRatio == 4.0 / 5.0 ||
                (widget.aspectRatio - 0.8).abs() < 0.01 ||
                (widget.aspectRatio - 1.0).abs() < 0.01)
            ? topMenuH
            : topMenuH + (availableH - clearH) / 2;
        final clearLeft = (screenW - clearW) / 2;

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
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(widget.imageFile, fit: BoxFit.cover),
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
      bottom: SharedUX.stackBottomOffset,
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
      onRightActionPressed: () {
        // TODO: Open Gallery
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

  Widget _buildTimestampPicker() {
    return SizedBox(
      height: CameraUX.timestampPickerHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: TimestampDesign.values.length,
        itemBuilder: (context, index) {
          final design = TimestampDesign.values[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: TimestampThumbnail(
              design: design,
              isSelected: _selectedDesign == design,
              onTap: () => setState(() {
                _selectedDesign = design;
                _selectedAlignment = CameraUX.defaultAlignment;
                _fontSizeIndex = TimestampMetadata.getDefaultFontSizeIndex(design);
                _selectedFontSize = TimestampMetadata.getDefaultFontSize(design);
              }),
            ),
          );
        },
      ),
    );
  }
}

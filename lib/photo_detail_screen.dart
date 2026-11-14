import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'album_service.dart';
import 'widgets/ad_banner_widget.dart';
import 'services/app_settings_service.dart';
import 'services/app_localizations.dart';

class PhotoDetailScreen extends StatefulWidget {
  final File? photoFile;
  final List<File>? photoFiles;
  final int initialIndex;

  const PhotoDetailScreen({
    super.key,
    this.photoFile,
    this.photoFiles,
    this.initialIndex = 0,
  }) : assert(
          photoFile != null || photoFiles != null,
          'Either photoFile or photoFiles must be provided.',
        );

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  late List<File> _photos;
  late int _currentIndex;
  late PageController _pageController;
  Map<String, String> _notes = {};
  bool _hasDeleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.photoFiles != null && widget.photoFiles!.isNotEmpty) {
      _photos = List<File>.from(widget.photoFiles!);
    } else {
      _photos = [widget.photoFile!];
    }
    _currentIndex = widget.initialIndex.clamp(0, _photos.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
    _loadNotes();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final notes = await AlbumService.getAllNotes();
    if (mounted) {
      setState(() {
        _notes = notes;
      });
    }
  }

  File get _currentPhoto => _photos[_currentIndex];

  String _getPhotoKey(File file) {
    return file.path.split(Platform.pathSeparator).last;
  }

  String? get _currentNote {
    final key = _getPhotoKey(_currentPhoto);
    return _notes[key];
  }

  DateTime _getPhotoDate(File file) {
    return AlbumService.getPhotoDate(file);
  }

  Future<void> _sharePhoto() async {
    try {
      final photo = _currentPhoto;
      final note = _currentNote;
      final text = (note != null && note.isNotEmpty)
          ? '$note\n\nJust Log it'
          : AppStrings.shareDefaultText;

      final box = context.findRenderObject() as RenderBox?;
      final screenSize = MediaQuery.of(context).size;
      final Rect origin = (box != null &&
              box.hasSize &&
              box.size.width > 0 &&
              box.size.height > 0)
          ? (box.localToGlobal(Offset.zero) & box.size)
          : Rect.fromLTWH(
              0,
              0,
              screenSize.width > 0 ? screenSize.width : 100,
              screenSize.height > 0 ? screenSize.height : 100,
            );

      await Share.shareXFiles(
        [XFile(photo.path)],
        text: text,
        sharePositionOrigin: origin,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.shareError(e))),
        );
      }
    }
  }

  /// Delete Memo Confirmation Bottom Sheet (matching runningapp style)
  Future<bool> _confirmDeleteMemo(BuildContext context) async {
    final settings = AppSettingsService();
    final isLight = settings.isLight;

    final res = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      showDragHandle: false,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF17191E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: isLight ? const Color(0xFFE2E4E8) : const Color(0xFF2E323A).withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isLight ? const Color(0xFFCBD5E1) : const Color(0xFF2E323A),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header (Icon + Title + Close button)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5252).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFFF5252),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.memoDeleteTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                          color: isLight ? const Color(0xFF111418) : Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: isLight ? const Color(0xFF64748B) : const Color(0xFF9AA1AC),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Warning message box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isLight ? const Color(0xFFFEF2F2) : const Color(0xFF22252C).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isLight ? const Color(0xFFFECACA) : const Color(0xFFFF5252).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    AppStrings.memoDeleteWarning,
                    style: TextStyle(
                      color: isLight ? const Color(0xFFDC2626) : const Color(0xFF9AA1AC),
                      fontSize: 13.5,
                      height: 1.5,
                      fontWeight: isLight ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Action buttons (Cancel / Delete)
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: isLight ? const Color(0xFFCBD5E1) : const Color(0xFF2E323A).withValues(alpha: 0.4),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          AppStrings.cancel,
                          style: TextStyle(
                            color: isLight ? const Color(0xFF475569) : const Color(0xFFF4F6F8),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5252),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(
                          AppStrings.delete,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return res ?? false;
  }

  /// RunningApp-inspired Memo Bottom Sheet (Lag-free & modern layout)
  Future<void> _showEditCaptionSheet() async {
    final currentNote = _currentNote ?? '';

    final savedNote = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      showDragHandle: false,
      sheetAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
      ),
      builder: (ctx) => _PhotoMemoSheet(
        initialNote: currentNote,
        onDeleteRequested: () async {
          final confirmed = await _confirmDeleteMemo(ctx);
          if (confirmed && ctx.mounted) {
            Navigator.pop(ctx, '__DELETE_NOTE__');
          }
        },
      ),
    );

    if (savedNote == '__DELETE_NOTE__') {
      final key = _getPhotoKey(_currentPhoto);
      await AlbumService.deleteNote(_currentPhoto.path);
      setState(() {
        _notes.remove(key);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.memoDeletedSnackbar),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (savedNote != null) {
      final key = _getPhotoKey(_currentPhoto);
      await AlbumService.saveNote(_currentPhoto.path, savedNote);
      setState(() {
        if (savedNote.trim().isEmpty) {
          _notes.remove(key);
        } else {
          _notes[key] = savedNote.trim();
        }
      });
    }
  }


  /// Delete Photo Confirmation Bottom Sheet (matching runningapp style)
  Future<bool> _confirmDeletePhoto() async {
    final settings = AppSettingsService();
    final isLight = settings.isLight;
    final isVideo = AlbumService.isVideo(_currentPhoto);

    final res = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      showDragHandle: false,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF17191E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: isLight ? const Color(0xFFE2E4E8) : const Color(0xFF2E323A).withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isLight ? const Color(0xFFCBD5E1) : const Color(0xFF2E323A),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header (Red Circle with Trash Icon + Title + Close Button)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5252).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFFF5252),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isVideo ? AppStrings.videoDeleteTitle : AppStrings.photoDeleteTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                          color: isLight ? const Color(0xFF111418) : Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: isLight ? const Color(0xFF64748B) : const Color(0xFF9AA1AC),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Warning Message Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isLight ? const Color(0xFFFEF2F2) : const Color(0xFF22252C).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isLight ? const Color(0xFFFECACA) : const Color(0xFFFF5252).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    isVideo
                        ? AppStrings.videoDeleteWarning
                        : AppStrings.photoDeleteWarning,
                    style: TextStyle(
                      color: isLight ? const Color(0xFFDC2626) : const Color(0xFF9AA1AC),
                      fontSize: 13.5,
                      height: 1.5,
                      fontWeight: isLight ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons (Cancel / Delete)
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: isLight ? const Color(0xFFCBD5E1) : const Color(0xFF2E323A).withValues(alpha: 0.4),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          AppStrings.cancel,
                          style: TextStyle(
                            color: isLight ? const Color(0xFF475569) : const Color(0xFFF4F6F8),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5252),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(
                          AppStrings.delete,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return res ?? false;
  }

  Future<void> _deletePhoto() async {
    final confirmed = await _confirmDeletePhoto();

    if (confirmed == true) {
      try {
        final photoToDelete = _currentPhoto;
        await AlbumService.deleteNote(photoToDelete.path);
        final thumbFile = File('${photoToDelete.path}_thumb.jpg');
        if (await thumbFile.exists()) {
          try {
            await thumbFile.delete();
          } catch (_) {}
        }
        if (await photoToDelete.exists()) {
          await photoToDelete.delete();
        }
        _hasDeleted = true;

        if (!mounted) return;

        // 1개만 남아있던 사진/영상이 삭제된 경우 즉시 상세 화면 종료
        if (_photos.length <= 1) {
          setState(() {
            _photos.clear();
          });
          Navigator.pop(context, true);
          return;
        }

        // 2개 이상일 때: 리스트에서 제거하고 인덱스 보정
        setState(() {
          _photos.removeAt(_currentIndex);
          if (_currentIndex >= _photos.length) {
            _currentIndex = _photos.length - 1;
          }
        });

        // PageView 위치를 안전하게 동기화
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_currentIndex);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.deleteError(e))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_photos.isEmpty) return const SizedBox.shrink();

    final date = _getPhotoDate(_currentPhoto);
    final dateStr = TimestampLocaleFormatter.formatDetailDateHeader(date);
    final timeStr = TimestampLocaleFormatter.formatRecordTime(date);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context, _hasDeleted);
      },
      child: Scaffold(
        backgroundColor: AppSettingsService().scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ───── 1. Photo PageView (Swipe Left / Right) ─────
            PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: _photos.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final photo = _photos[index];
                final photoKey = _getPhotoKey(photo);
                final note = _notes[photoKey];
                final hasNote = note != null && note.isNotEmpty;

                return SingleChildScrollView(
                  key: ValueKey('page_${photo.path}'),
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: MediaQuery.paddingOf(context).top + 60,
                    bottom: MediaQuery.paddingOf(context).bottom + 84,
                    left: 16,
                    right: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Photo or Video
                      if (AlbumService.isVideo(photo))
                        _VideoDetailPlayerItem(
                          key: ValueKey('video_${photo.path}'),
                          file: photo,
                        )
                      else
                        GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              opaque: false,
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  FullScreenImageViewer(file: photo),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: Hero(
                          tag: 'photo_fullscreen_${photo.path}',
                          child: RepaintBoundary(
                            child: Image.file(
                              photo,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 14),

                    // Memo Card placed directly BELOW the photo
                    GestureDetector(
                      onTap: _showEditCaptionSheet,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: hasNote
                              ? (AppSettingsService().isLight
                                  ? Colors.white
                                  : const Color(0xFF181A20))
                              : (AppSettingsService().isLight
                                  ? const Color(0xFFF1F3F5)
                                  : Colors.white.withValues(alpha: 0.05)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: hasNote
                                ? (AppSettingsService().isLight
                                    ? const Color(0xFFE2E4E8)
                                    : const Color(0xFF2B2E38))
                                : (AppSettingsService().isLight
                                    ? const Color(0xFFE2E4E8)
                                    : Colors.white.withValues(alpha: 0.08)),
                            width: 0.8,
                          ),
                          boxShadow: [
                            if (hasNote)
                              BoxShadow(
                                color: AppSettingsService().isLight
                                    ? Colors.black.withValues(alpha: 0.06)
                                    : Colors.black.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              )
                            else if (AppSettingsService().isLight)
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                          ],
                        ),
                        child: Text(
                          hasNote ? note : AppStrings.memoAddPlaceholder,
                          style: TextStyle(
                            color: hasNote
                                ? (AppSettingsService().isLight
                                    ? const Color(0xFF111418)
                                    : Colors.white)
                                : (AppSettingsService().isLight
                                    ? const Color(0xFF94A3B8)
                                    : Colors.white.withValues(alpha: 0.45)),
                            fontSize: 14.5,
                            height: 1.5,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),

                    // 메모 밑 배너 광고
                    const AdBannerWidget(
                      margin: EdgeInsets.only(top: 14),
                    ),
                  ],
                ),
              );
            },
          ),

          // ───── 2. Top Bar (Translucent Header matching Bottom Bar) ─────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: AppSettingsService().isLight
                      ? [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.75),
                          Colors.white.withValues(alpha: 0.95),
                        ]
                      : [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.30),
                          Colors.black.withValues(alpha: 0.65),
                        ],
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 6,
                bottom: 12,
                left: 12,
                right: 16,
              ),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.all(8),
                    minimumSize: Size.zero,
                    onPressed: () => Navigator.pop(context, _hasDeleted),
                    child: Icon(
                      CupertinoIcons.chevron_back,
                      color: AppSettingsService().textColor,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          dateStr,
                          style: TextStyle(
                            color: AppSettingsService().textColor,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          timeStr,
                          style: TextStyle(
                            color: AppSettingsService().subTextColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Photo counter badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppSettingsService().isLight
                          ? const Color(0xFFF1F3F5)
                          : Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppSettingsService().isLight
                            ? const Color(0xFFE2E4E8)
                            : Colors.white.withValues(alpha: 0.1),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${_photos.length}',
                      style: TextStyle(
                        color: AppSettingsService().isLight
                            ? const Color(0xFF64748B)
                            : Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ───── 4. Translucent Floating Action Buttons Toolbar ─────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 8,
                bottom: MediaQuery.paddingOf(context).bottom + 6,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppSettingsService().isLight
                      ? [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.75),
                          Colors.white.withValues(alpha: 0.95),
                        ]
                      : [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.30),
                          Colors.black.withValues(alpha: 0.65),
                        ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAppleIconButton(
                    icon: CupertinoIcons.share,
                    onTap: _sharePhoto,
                  ),
                  _buildAppleIconButton(
                    icon: CupertinoIcons.square_pencil,
                    onTap: _showEditCaptionSheet,
                  ),
                  _buildAppleIconButton(
                    icon: CupertinoIcons.trash,
                    isDestructive: true,
                    onTap: _deletePhoto,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildAppleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final settings = AppSettingsService();
    final isLight = settings.isLight;
    final color = isDestructive
        ? const Color(0xFFFF453A) // Apple System Red
        : settings.textColor;

    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      minimumSize: Size.zero,
      onPressed: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: isDestructive
              ? const Color(0xFFFF453A).withValues(alpha: isLight ? 0.12 : 0.16)
              : (isLight
                  ? const Color(0xFFF1F3F5)
                  : Colors.white.withValues(alpha: 0.12)),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDestructive
                ? const Color(0xFFFF453A).withValues(alpha: isLight ? 0.28 : 0.32)
                : (isLight
                    ? const Color(0xFFCBD5E1)
                    : Colors.white.withValues(alpha: 0.15)),
            width: 0.8,
          ),
          boxShadow: isLight
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Icon(
            icon,
            color: color,
            size: 21,
          ),
        ),
      ),
    );
  }
}

class _PhotoMemoSheet extends StatefulWidget {
  final String initialNote;
  final VoidCallback onDeleteRequested;

  const _PhotoMemoSheet({
    required this.initialNote,
    required this.onDeleteRequested,
  });

  @override
  State<_PhotoMemoSheet> createState() => _PhotoMemoSheetState();
}

class _PhotoMemoSheetState extends State<_PhotoMemoSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasNote = widget.initialNote.isNotEmpty;
    final hasText = _ctrl.text.trim().isNotEmpty;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final settings = AppSettingsService();
    final isLight = settings.isLight;

    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF17191E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.15 : 0.5),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border.all(
          color: isLight
              ? const Color(0xFFE2E4E8)
              : const Color(0xFF2E323A).withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag Indicator
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: isLight
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF2E323A),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header (Title, Subtitle, Trash delete button on the far right if hasNote)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.photoMemoTitle,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                              color: isLight
                                  ? const Color(0xFF111418)
                                  : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.photoMemoSubtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: isLight
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF9AA1AC),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasNote)
                      IconButton(
                        onPressed: widget.onDeleteRequested,
                        tooltip: AppStrings.memoDeleteTooltip,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFFF5252),
                          size: 22,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Quick Tags
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: AppStrings.memoQuickTags.map((tag) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () {
                            final cur = _ctrl.text;
                            if (cur.isEmpty) {
                              _ctrl.text = tag;
                            } else {
                              _ctrl.text = '$cur $tag';
                            }
                            _ctrl.selection = TextSelection.fromPosition(
                              TextPosition(offset: _ctrl.text.length),
                            );
                            setState(() {});
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isLight
                                  ? const Color(0xFFF1F3F5)
                                  : const Color(0xFF22252C),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isLight
                                    ? const Color(0xFFE2E4E8)
                                    : const Color(0xFF2E323A).withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 12,
                                color: isLight
                                    ? const Color(0xFF475569)
                                    : const Color(0xFF9AA1AC),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // Memo TextField (Opens on tap: zero lag, instant sheet display)
                TextField(
                  controller: _ctrl,
                  autofocus: false,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 500,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: isLight
                        ? const Color(0xFF111418)
                        : const Color(0xFFF4F6F8),
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings.photoMemoHint,
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: isLight
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF9AA1AC).withValues(alpha: 0.6),
                    ),
                    filled: true,
                    fillColor: isLight
                        ? const Color(0xFFF8FAFC)
                        : const Color(0xFF22252C),
                    counterStyle: TextStyle(
                      color: isLight
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF9AA1AC),
                      fontSize: 11,
                    ),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isLight
                            ? const Color(0xFFE2E4E8)
                            : const Color(0xFF2E323A).withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isLight
                            ? const Color(0xFFE2E4E8)
                            : const Color(0xFF2E323A).withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isLight
                            ? settings.accentColor
                            : const Color(0xFF9AA1AC).withValues(alpha: 0.6),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Bottom Action Buttons
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(
                            color: isLight
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF2E323A).withValues(alpha: 0.5),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          AppStrings.cancel,
                          style: TextStyle(
                            color: isLight
                                ? const Color(0xFF475569)
                                : const Color(0xFFF4F6F8),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: hasText
                              ? settings.accentColor
                              : (isLight
                                  ? const Color(0xFFF1F3F5)
                                  : const Color(0xFF22252C)),
                          foregroundColor: hasText
                              ? (isLight ? Colors.white : Colors.black)
                              : (isLight
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF9AA1AC)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: hasText
                            ? () => Navigator.pop(context, _ctrl.text.trim())
                            : null,
                        child: Text(
                          AppStrings.saveAction,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoDetailPlayerItem extends StatefulWidget {
  final File file;
  const _VideoDetailPlayerItem({super.key, required this.file});

  @override
  State<_VideoDetailPlayerItem> createState() => _VideoDetailPlayerItemState();
}

class _VideoDetailPlayerItemState extends State<_VideoDetailPlayerItem> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isCompleted = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(_VideoDetailPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.path != widget.file.path) {
      _cleanup();
      _initController();
    }
  }

  void _cleanup() {
    final c = _controller;
    _controller = null;
    _isInitialized = false;
    _isCompleted = false;
    if (c != null) {
      c.removeListener(_videoListener);
      c.pause();
      c.dispose();
    }
  }

  Future<void> _initController() async {
    if (!widget.file.existsSync()) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
        });
      }
      return;
    }

    final controller = VideoPlayerController.file(
      widget.file,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _controller = controller;

    try {
      await controller.initialize();
      if (!mounted || _controller != controller) {
        controller.dispose();
        return;
      }
      controller.addListener(_videoListener);
      // 처음 한 번만 재생하고 끝나면 다시 반복 재생하지 않음
      await controller.setLooping(false);
      await controller.setVolume(1.0);
      await controller.play();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('VideoDetailPlayer error: $e');
      if (mounted && _controller == controller) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
        });
      }
    }
  }

  void _videoListener() {
    final c = _controller;
    if (!mounted || c == null || !c.value.isInitialized) return;
    final pos = c.value.position;
    final dur = c.value.duration;
    final isDone = dur > Duration.zero && pos >= dur;

    if (isDone && !_isCompleted) {
      setState(() {
        _isCompleted = true;
      });
    } else if (!isDone && _isCompleted) {
      setState(() {
        _isCompleted = false;
      });
    }
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;

    if (_isCompleted) {
      c.seekTo(Duration.zero);
      c.play();
      setState(() {
        _isCompleted = false;
      });
    } else if (c.value.isPlaying) {
      c.pause();
      setState(() {});
    } else {
      c.play();
      setState(() {});
    }
  }

  Future<void> _openFullScreen() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;

    c.pause();
    final currentPos = c.value.position;

    final returnedPos = await Navigator.push<Duration>(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenVideoViewer(
          file: widget.file,
          initialPosition: currentPos,
        ),
      ),
    );

    if (returnedPos != null && mounted && _controller == c) {
      await c.seekTo(returnedPos);
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 250,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF1E2026),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_rounded, color: Colors.white38, size: 36),
            const SizedBox(height: 8),
            Text(
              AppStrings.videoPlayError,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final c = _controller;
    if (!_isInitialized || c == null) {
      return Container(
        height: 250,
        alignment: Alignment.center,
        child: CircularProgressIndicator(color: AppSettingsService().accentColor),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: c.value.aspectRatio > 0 ? c.value.aspectRatio : (9.0 / 16.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: _togglePlay,
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  VideoPlayer(c),
                  if (!c.value.isPlaying || _isCompleted)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isCompleted
                              ? Icons.replay_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 전체화면 보기 버튼 (우측 상단 캡슐 버튼)
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: _openFullScreen,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.fullscreen_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.fullscreen,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppLocalizations.uiFontFamily,
                          fontFamilyFallback:
                              AppLocalizations.fontFallbackChain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 하단 재생 진행 바
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                c,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: AppSettingsService().accentColor,
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.black38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 사진 터치 시 전체화면으로 볼 수 있는 뷰어
class FullScreenImageViewer extends StatelessWidget {
  final File file;

  const FullScreenImageViewer({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 핀치 줌 & 더블 탭 확대 가능한 인터랙티브 뷰어
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.5,
              clipBehavior: Clip.none,
              child: Center(
                child: Hero(
                  tag: 'photo_fullscreen_${file.path}',
                  child: Image.file(
                    file,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // 상단 닫기 버튼
          Positioned(
            top: topPadding + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 영상 전체화면 뷰어 (한 번 재생, 컨트롤러 오버레이, 나가기 버튼)
class FullScreenVideoViewer extends StatefulWidget {
  final File file;
  final Duration initialPosition;

  const FullScreenVideoViewer({
    super.key,
    required this.file,
    this.initialPosition = Duration.zero,
  });

  @override
  State<FullScreenVideoViewer> createState() => _FullScreenVideoViewerState();
}

class _FullScreenVideoViewerState extends State<FullScreenVideoViewer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isCompleted = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _controller = VideoPlayerController.file(
      widget.file,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    try {
      await _controller.initialize();
      _controller.addListener(_videoListener);
      await _controller.setLooping(false); // 처음 한 번만 재생
      if (widget.initialPosition > Duration.zero) {
        await _controller.seekTo(widget.initialPosition);
      }
      await _controller.setVolume(1.0);
      await _controller.play();

      if (mounted) {
        setState(() => _isInitialized = true);
      }
      _startHideTimer();
    } catch (e) {
      debugPrint('FullScreenVideo error: $e');
    }
  }

  void _videoListener() {
    if (!mounted || !_controller.value.isInitialized) return;
    final pos = _controller.value.position;
    final dur = _controller.value.duration;
    final isDone = dur > Duration.zero && pos >= dur;

    if (isDone && !_isCompleted) {
      setState(() {
        _isCompleted = true;
        _showControls = true;
      });
      _hideTimer?.cancel();
    } else if (!isDone && _isCompleted) {
      setState(() {
        _isCompleted = false;
      });
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying && !_isCompleted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls && _controller.value.isPlaying && !_isCompleted) {
      _startHideTimer();
    }
  }

  void _togglePlay() {
    if (_isCompleted) {
      _controller.seekTo(Duration.zero);
      _controller.play();
      setState(() => _isCompleted = false);
      _startHideTimer();
    } else if (_controller.value.isPlaying) {
      _controller.pause();
      setState(() => _showControls = true);
      _hideTimer?.cancel();
    } else {
      _controller.play();
      setState(() {});
      _startHideTimer();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _controller.value.position);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _toggleControls,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 중앙 비디오 재생 영역
              Center(
                child: _isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : CircularProgressIndicator(
                        color: AppSettingsService().accentColor),
              ),

              // 컨트롤 오버레이
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: Stack(
                    children: [
                      // 상단 닫기 / 나가기 버튼
                      Positioned(
                        top: topPadding + 10,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(
                              context, _controller.value.position),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),

                      // 중앙 재생 / 일시정지 / 다시보기 버튼
                      Center(
                        child: GestureDetector(
                          onTap: _togglePlay,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isCompleted
                                  ? Icons.replay_rounded
                                  : (_controller.value.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded),
                              color: Colors.white,
                              size: 44,
                            ),
                          ),
                        ),
                      ),

                      // 하단 재생 시간 및 진행 바
                      if (_isInitialized)
                        Positioned(
                          bottom: bottomPadding + 16,
                          left: 20,
                          right: 20,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ValueListenableBuilder(
                                    valueListenable: _controller,
                                    builder:
                                        (context, VideoPlayerValue value, _) {
                                      final pos = value.position;
                                      return Text(
                                        '${pos.inMinutes}:${(pos.inSeconds % 60).toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12),
                                      );
                                    },
                                  ),
                                  Text(
                                    '${_controller.value.duration.inMinutes}:${(_controller.value.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              VideoProgressIndicator(
                                _controller,
                                allowScrubbing: true,
                                colors: VideoProgressColors(
                                  playedColor: AppSettingsService().accentColor,
                                  bufferedColor: Colors.white24,
                                  backgroundColor: Colors.white12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'album_service.dart';

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
          : 'Just Log it - 나의 기록을 공유합니다.';

      await Share.shareXFiles([XFile(photo.path)], text: text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('공유 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  /// Delete Memo Confirmation Bottom Sheet (matching runningapp style)
  Future<bool> _confirmDeleteMemo(BuildContext context) async {
    final res = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      showDragHandle: false,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF17191E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: const Color(0xFF2E323A).withValues(alpha: 0.35),
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
                      color: const Color(0xFF2E323A),
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
                    const Expanded(
                      child: Text(
                        '메모를 삭제할까요?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: const Color(0xFF9AA1AC),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Warning message box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22252C).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFF5252).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Text(
                    '삭제된 메모는 복구할 수 없어요',
                    style: TextStyle(
                      color: Color(0xFF9AA1AC),
                      fontSize: 13.5,
                      height: 1.5,
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
                            color: const Color(0xFF2E323A).withValues(alpha: 0.4),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: Color(0xFFF4F6F8),
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
                        child: const Text(
                          '삭제',
                          style: TextStyle(
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
          const SnackBar(
            content: Text('메모가 삭제되었습니다.'),
            duration: Duration(seconds: 2),
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
    final res = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      showDragHandle: false,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF17191E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: const Color(0xFF2E323A).withValues(alpha: 0.35),
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
                      color: const Color(0xFF2E323A),
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
                    const Expanded(
                      child: Text(
                        '사진을 삭제할까요?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: const Color(0xFF9AA1AC),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Warning Message Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22252C).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFF5252).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Text(
                    '삭제된 사진은 보관함에서 완전히 삭제되며 복구할 수 없어요',
                    style: TextStyle(
                      color: Color(0xFF9AA1AC),
                      fontSize: 13.5,
                      height: 1.5,
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
                            color: const Color(0xFF2E323A).withValues(alpha: 0.4),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: Color(0xFFF4F6F8),
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
                        child: const Text(
                          '삭제',
                          style: TextStyle(
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
        await photoToDelete.delete();
        _hasDeleted = true;

        if (!mounted) return;

        setState(() {
          _photos.removeAt(_currentIndex);
          if (_photos.isEmpty) {
            Navigator.pop(context, true);
          } else {
            if (_currentIndex >= _photos.length) {
              _currentIndex = _photos.length - 1;
            }
          }
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_photos.isEmpty) return const SizedBox.shrink();

    final date = _getPhotoDate(_currentPhoto);
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    final dateStr = '${DateFormat('yyyy년 M월 d일').format(date)} ($weekday)';
    final timeStr = '${date.hour < 12 ? '오전' : '오후'} ${DateFormat('h:mm').format(date)}';
    return Scaffold(
      backgroundColor: const Color(0xFF0F1013),
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
                      _VideoDetailPlayerItem(file: photo)
                    else
                      RepaintBoundary(
                        child: Image.file(
                          photo,
                          fit: BoxFit.contain,
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
                              ? const Color(0xFF181A20)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: hasNote
                                ? const Color(0xFF2B2E38)
                                : Colors.white.withValues(alpha: 0.08),
                            width: 0.8,
                          ),
                          boxShadow: hasNote
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          hasNote ? note : '메모 추가...',
                          style: TextStyle(
                            color: hasNote
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.45),
                            fontSize: 14.5,
                            height: 1.5,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ───── 2. Top Bar (Apple Navigation, Fast Solid Dark Header) ─────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF16171B),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF232630),
                    width: 0.6,
                  ),
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 6,
                bottom: 10,
                left: 12,
                right: 16,
              ),
                  child: Row(
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.all(8),
                        minimumSize: Size.zero,
                        onPressed: () => Navigator.pop(context, _hasDeleted),
                        child: const Icon(
                          CupertinoIcons.chevron_back,
                          color: Colors.white,
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              timeStr,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
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
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          '${_currentIndex + 1} / ${_photos.length}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
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
                  colors: [
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
    );
  }

  Widget _buildAppleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? const Color(0xFFFF453A) // Apple System Red
        : Colors.white;

    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      minimumSize: Size.zero,
      onPressed: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: isDestructive
              ? const Color(0xFFFF453A).withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDestructive
                ? const Color(0xFFFF453A).withValues(alpha: 0.32)
                : Colors.white.withValues(alpha: 0.15),
            width: 0.8,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            color: isDestructive ? color : Colors.white.withValues(alpha: 0.95),
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

  static const _quickTags = [
    '☀️ 맑은 날',
    '☕ 일상',
    '🌿 힐링',
    '✨ 특별한 순간',
    '🏃 운동',
    '🍽️ 맛있는 하루',
    '🌅 풍경',
  ];

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

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF17191E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: const Color(0xFF2E323A).withValues(alpha: 0.35),
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
                      color: const Color(0xFF2E323A),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header (Title, Subtitle, Trash delete button on the far right if hasNote)
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '사진 메모',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '오늘의 사진에 대한 생각이나 메모를 남겨보세요',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9AA1AC),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasNote)
                      IconButton(
                        onPressed: widget.onDeleteRequested,
                        tooltip: '메모 삭제',
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
                    children: _quickTags.map((tag) {
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
                              color: const Color(0xFF22252C),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF2E323A).withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9AA1AC),
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
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFFF4F6F8),
                  ),
                  decoration: InputDecoration(
                    hintText: '이 사진에 대한 생각을 자유롭게 적어보세요.',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF9AA1AC).withValues(alpha: 0.6),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF22252C),
                    counterStyle: const TextStyle(
                      color: Color(0xFF9AA1AC),
                      fontSize: 11,
                    ),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: const Color(0xFF2E323A).withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: const Color(0xFF2E323A).withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: const Color(0xFF9AA1AC).withValues(alpha: 0.6),
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
                            color: const Color(0xFF2E323A).withValues(alpha: 0.5),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: Color(0xFFF4F6F8),
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
                              ? const Color(0xFFCCFF00)
                              : const Color(0xFF22252C),
                          foregroundColor: hasText
                              ? Colors.black
                              : const Color(0xFF9AA1AC),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: hasText
                            ? () => Navigator.pop(context, _ctrl.text.trim())
                            : null,
                        child: const Text(
                          '저장하기',
                          style: TextStyle(
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
  const _VideoDetailPlayerItem({required this.file});

  @override
  State<_VideoDetailPlayerItem> createState() => _VideoDetailPlayerItemState();
}

class _VideoDetailPlayerItemState extends State<_VideoDetailPlayerItem> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    _controller = VideoPlayerController.file(widget.file);
    try {
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.play();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('VideoDetailPlayer error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        height: 250,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Color(0xFFC6FF00)),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_controller),
              if (!_controller.value.isPlaying)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              // 하단 재생 진행 바
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Color(0xFFC6FF00),
                    bufferedColor: Colors.white24,
                    backgroundColor: Colors.black38,
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


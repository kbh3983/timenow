import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'album_service.dart';
import 'ux_config.dart';
import 'photo_detail_screen.dart';

enum CalendarViewMode { calendar, grid }

class CalendarAlbumScreen extends StatefulWidget {
  final String? initialAlbum;
  const CalendarAlbumScreen({super.key, this.initialAlbum});

  @override
  State<CalendarAlbumScreen> createState() => _CalendarAlbumScreenState();
}

class _CalendarAlbumScreenState extends State<CalendarAlbumScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String _selectedAlbum = '전체';
  List<String> _albums = ['일상'];
  final ValueNotifier<bool> _isExpanded = ValueNotifier(false);
  final ValueNotifier<double> _transitionExtent = ValueNotifier(0.0);
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  CalendarViewMode _viewMode = CalendarViewMode.calendar;
  Map<String, List<File>> _allPhotosGrouped = {};
  int _totalPhotoCount = 0;

  Map<DateTime, Set<String>> _photoDots = {};
  Map<DateTime, File> _photoThumbnails = {};
  List<File> _dayPhotos = [];
  Map<String, int> _albumColors = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialAlbum != null) {
      _selectedAlbum = widget.initialAlbum!;
    }
    _loadData();
  }

  Future<void> _loadData() async {
    final albums = await AlbumService.getAlbums();
    final albumColors = await AlbumService.getAlbumColors();
    final dots = await AlbumService.getPhotoDotsForMonth(
      _focusedDay,
      albumName: _selectedAlbum,
    );
    final thumbnails = await AlbumService.getPhotoThumbnailsForMonth(
      _focusedDay,
      albumName: _selectedAlbum,
    );
    final photos = await AlbumService.getPhotosByDate(
      _selectedDay,
      albumName: _selectedAlbum,
    );

    // Load all photos for grid view and grouping
    final allPhotos = await AlbumService.getAllPhotos(
      albumName: _selectedAlbum,
    );
    final Map<String, List<File>> grouped = {};
    for (var file in allPhotos) {
      final stats = file.statSync();
      final date = stats.changed;
      final key = "${date.year}.${date.month.toString().padLeft(2, '0')}";
      grouped.putIfAbsent(key, () => []).add(file);
    }

    if (mounted) {
      setState(() {
        _albums = albums;
        _albumColors = albumColors;
        _photoDots = dots;
        _photoThumbnails = thumbnails;
        _dayPhotos = photos;
        _allPhotosGrouped = grouped;
        _totalPhotoCount = allPhotos.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        bottom: false,
        child: _viewMode == CalendarViewMode.grid
            ? _buildPhotoGridView()
            : Stack(
                children: [_buildCalendarContent(), _buildDraggableSheet()],
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 20 + MediaQuery.of(context).padding.bottom),
        child: FloatingActionButton(
          onPressed: () => Navigator.pop(context, _selectedAlbum),
          backgroundColor: const Color(0xFF222222),
          elevation: 8,
          shape: const CircleBorder(),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent, // 스크롤 시 회색 틴트 제거
      scrolledUnderElevation: 0,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: GestureDetector(
        onTap: _showAlbumSelector,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _viewMode == CalendarViewMode.grid
                  ? "$_selectedAlbum ($_totalPhotoCount)"
                  : _selectedAlbum,
              style: const TextStyle(
                color: Colors.black,
                fontSize: CalendarUX.albumTitleFontSize,
                fontWeight: FontWeight.bold,
              ),

            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ],
        ),
      ),
      centerTitle: true,
      actions: [
        ValueListenableBuilder<bool>(
          valueListenable: _isExpanded,
          builder: (context, expanded, child) {
            return IconButton(
              icon: Icon(
                _viewMode == CalendarViewMode.grid
                    ? Icons.calendar_today
                    : (expanded ? Icons.grid_view : Icons.grid_view),
                color: Colors.black,
              ),
              onPressed: _toggleView,
            );
          }
        ),
      ],
    );
  }

  void _toggleView() {
    if (_viewMode == CalendarViewMode.grid) {
      setState(() {
        _viewMode = CalendarViewMode.calendar;
      });
      _isExpanded.value = false;
      _transitionExtent.value = 0.0;
      // Removed animateTo(0.35) because the sheet is not yet attached
      // and will render at initialChildSize (0.35) by default.
      return;
    }

    if (_isExpanded.value) {
      // If already week view (expanded), go to grid view
      setState(() {
        _viewMode = CalendarViewMode.grid;
      });
    } else {
      // If month view, expand to week view
      if (_sheetController.isAttached) {
        _sheetController.animateTo(
          0.95,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Widget _buildCalendarContent() {
    return ValueListenableBuilder<double>(
      valueListenable: _transitionExtent,
      builder: (context, extent, child) {
        return Opacity(
          opacity: (1.0 - extent).clamp(0.0, 1.0),
          child: child,
        );
      },
      child: ClipRect(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null) {
                if (details.primaryVelocity! < -300) {
                  _goToNextMonth();
                } else if (details.primaryVelocity! > 300) {
                  _goToPrevMonth();
                }
              }
            },
            child: Container(
              color: Colors.transparent, // Capture taps over empty space
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMonthHeader(),
                  _buildWeekdayHeader(),
                  _buildMonthGrid(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.grey),
            onPressed: _goToPrevMonth,
          ),
          Text(
            DateFormat('yyyy.MM').format(_focusedDay),
            style: const TextStyle(
              fontSize: CalendarUX.monthHeaderFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.grey),
            onPressed: _goToNextMonth,
          ),
        ],
      ),
    );
  }

  void _goToPrevMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
    _loadData();
  }

  void _goToNextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
    _loadData();
  }

  Widget _buildWeekdayHeader() {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: CalendarUX.weekdayVerticalPadding,
        horizontal: CalendarUX.calendarHorizontalPadding,
      ),
      child: Row(
        children: weekdays
            .map(
              (day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      color: day == '일' ? Colors.red : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildMonthGrid() {
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedDay.year,
      _focusedDay.month,
    );
    final firstDayOffset =
        DateTime(_focusedDay.year, _focusedDay.month, 1).weekday % 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: CalendarUX.calendarHorizontalPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: CalendarUX.weekSpacing,
        childAspectRatio: CalendarUX.calendarGridAspectRatio,
      ),
      itemCount: daysInMonth + firstDayOffset,
      itemBuilder: (context, index) {
        if (index < firstDayOffset) return const SizedBox.shrink();

        final day = index - firstDayOffset + 1;
        final date = DateTime(_focusedDay.year, _focusedDay.month, day);
        final isSelected = DateUtils.isSameDay(date, _selectedDay);
        final isToday = DateUtils.isSameDay(date, DateTime.now());

        return GestureDetector(
          onTap: () {
            setState(() => _selectedDay = date);
            _loadData();
          },
          child: _buildCalendarDay(date, isSelected, isToday),
        );
      },
    );
  }

  Widget _buildWeekStrip() {
    final firstDayOfWeek = _selectedDay.subtract(
      Duration(days: _selectedDay.weekday % 7),
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: CalendarUX.calendarHorizontalPadding,
      ), // Reduced vertical padding, added horizontal
      child: Row(
        children: List.generate(7, (index) {
          final date = firstDayOfWeek.add(Duration(days: index));
          final isSelected = DateUtils.isSameDay(date, _selectedDay);
          final isToday = DateUtils.isSameDay(date, DateTime.now());

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedDay = date);
                _loadData();
              },
              child: _buildCalendarDay(date, isSelected, isToday, mini: true),
            ),
          );
        }),
      ),
    );
  }

  Color _getAlbumColor(String albumName) {
    if (_albumColors.containsKey(albumName)) {
      return Color(_albumColors[albumName]!);
    }
    if (albumName == '일상') return const Color(0xFFEDED6D);
    if (albumName.toLowerCase() == 'workout') return Colors.blue;

    // Fallback pseudo-random but deterministic color
    final hash = albumName.hashCode;
    final r = (hash & 0xFF0000) >> 16;
    final g = (hash & 0x00FF00) >> 8;
    final b = (hash & 0x0000FF);
    return Color.fromARGB(
      255,
      r > 200 ? 200 : r,
      g > 200 ? 200 : g,
      b > 200 ? 200 : b,
    );
  }

  Widget _buildCalendarDay(
    DateTime date,
    bool isSelected,
    bool isToday, {
    bool mini = false,
  }) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final thumbnailFile = _photoThumbnails[dateKey];
    final hasPhoto = thumbnailFile != null;

    // Check if it's Sunday (weekday == 7)
    final bool isSunday = date.weekday == DateTime.sunday;
    final bool isHoliday = isSunday;

    // Determine text color based on state
    Color textColor;
    if (hasPhoto) {
      textColor = Colors.white;
    } else if (date.month != _focusedDay.month) {
      textColor = Colors.grey[300]!;
    } else if (isHoliday) {
      textColor = Colors.red;
    } else {
      textColor = Colors.black;
    }

    final cellSize = mini ? 32.0 : 42.0;
    final albumColor = _getAlbumColor(_selectedAlbum);

    return Container(
      width: cellSize,
      height: cellSize,
      decoration: BoxDecoration(
        border: isSelected
            ? Border.all(color: albumColor, width: 2.0)
            : null,
        color: Colors.transparent,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Thumbnail background
          if (hasPhoto)
            Positioned.fill(
              child: Opacity(
                opacity: 0.55,
                child: Image.file(
                  thumbnailFile,
                  fit: BoxFit.cover,
                  cacheWidth: 120,
                ),
              ),
            ),
          // Day number
          Text(
            '${date.day}',
            style: TextStyle(
              color: textColor,
              fontSize: mini ? 14 : CalendarUX.calendarDayFontSize,
              fontWeight: (isSelected || hasPhoto) ? FontWeight.bold : FontWeight.normal,
              shadows: hasPhoto
                  ? const [
                      Shadow(offset: Offset(0, 0.5), blurRadius: 3, color: Colors.black54),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: CalendarUX.initialSheetSize,
      minChildSize: CalendarUX.initialSheetSize,
      maxChildSize: 1.0,
      snap: false,
      builder: (context, scrollController) {
          return NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              const double minS = CalendarUX.initialSheetSize;
              const double maxS = 1.0;
              final newExtent = ((notification.extent - minS) / (maxS - minS)).clamp(0.0, 1.0);
              if (_transitionExtent.value != newExtent) {
                _transitionExtent.value = newExtent;
                _isExpanded.value = newExtent > 0.5;
              }
              return true;
            },
            child: ValueListenableBuilder<double>(
              valueListenable: _transitionExtent,
              builder: (context, extent, child) {
                final expanded = extent > 0.5;
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(expanded ? 0 : 32),
                    ),
                    boxShadow: expanded
                        ? null
                        : [const BoxShadow(blurRadius: 15, color: Colors.black12)],
                  ),
                  child: Column(
                    children: [
                      _buildHandle(expanded),
                      if (extent > 0.05)
                        Opacity(
                          opacity: extent,
                          child: ClipRect(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              heightFactor: extent,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 상단 메뉴와 달력 사이의 구분선
                                  if (expanded)
                                    Container(
                                      height: 1,
                                      color: Colors.grey[200],
                                      width: double.infinity,
                                    ),
                                  _buildWeekStrip(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      child!,
                    ],
                  ),
                );
              },
              child: Expanded(
                child: _dayPhotos.isEmpty
                    ? _buildEmptyState(scrollController)
                    : ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.only(
                          left: 24,
                          right: 24,
                          bottom: MediaQuery.of(context).padding.bottom + 80, // Space for FAB
                        ),
                        itemCount: _dayPhotos.length,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return ValueListenableBuilder<bool>(
                              valueListenable: _isExpanded,
                              builder: (context, expanded, child) => _buildRecordEntry(index, expanded),
                            );
                          }
                          return _buildRecordEntry(index, _isExpanded.value);
                        },
                      ),
              ),
            ),
          );
      },
    );
  }

  Widget _buildHandle(bool expanded) {
    if (expanded) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () {
        if (_sheetController.isAttached) {
          _sheetController.animateTo(
            0.95,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        width: double.infinity,
        child: Center(
          child: Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.photo_library_outlined,
                  size: 28,
                  color: Colors.grey[350],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '아직 기록이 없어요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '+ 버튼을 눌러 첫 기록을 남겨보세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[350],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordEntry(int index, bool expanded) {
    if (index >= _dayPhotos.length) return const SizedBox.shrink();
    final photoFile = _dayPhotos[index];
    final timeStr = DateFormat(
      'hh:mm a',
      'en_US',
    ).format(photoFile.statSync().changed);

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: _getAlbumColor(
                  _selectedAlbum == '전체'
                      ? photoFile.parent.path.split(Platform.pathSeparator).last
                      : _selectedAlbum,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stacked effect ONLY when NOT expanded and it's the first photo
          if (!expanded && index == 0 && _dayPhotos.length > 1)
            _buildStackedPhoto(photoFile)
          else
            _buildSinglePhoto(photoFile),
        ],
      ),
    );
  }

  Widget _buildStackedPhoto(File topPhoto) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoDetailScreen(photoFile: topPhoto),
          ),
        );
        if (result == true) {
          _loadData(); // Refresh if photo was deleted
        }
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 24, left: 48, right: 48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(blurRadius: 4, color: Colors.black12),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 12, left: 24, right: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(blurRadius: 4, color: Colors.black12),
              ],
            ),
          ),
          _buildSinglePhoto(topPhoto, tapEnabled: false),
        ],
      ),
    );
  }

  Widget _buildSinglePhoto(File file, {bool tapEnabled = true}) {
    return GestureDetector(
      onTap: tapEnabled
          ? () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoDetailScreen(photoFile: file),
                ),
              );
              if (result == true) {
                _loadData(); // Refresh if photo was deleted
              }
            }
          : null,
      child: Hero(
        tag: file.path,
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoGridView() {
    final sortedMonths = _allPhotosGrouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedMonths.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.photo_library_outlined,
                  size: 28,
                  color: Colors.grey[350],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '아직 기록이 없어요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '+ 버튼을 눌러 첫 기록을 남겨보세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[350],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: sortedMonths.expand((monthKey) {
        final monthPhotos = _allPhotosGrouped[monthKey] ?? [];
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
              child: Text(
                monthKey,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return _buildGridPhotoItem(monthPhotos[index]);
              }, childCount: monthPhotos.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ];
      }).toList(),
    );
  }

  Widget _buildGridPhotoItem(File file) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.file(
        file, 
        fit: BoxFit.cover,
        cacheWidth: 300, // 그리드뷰에서는 저해상도로 디코딩하여 스크롤 버벅임 해결
      ),
    );
  }

  void _showAlbumSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '폴더 선택',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildAlbumOption(context, '전체'),
                      ..._albums.map(
                        (album) => _buildAlbumOption(context, album),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 32),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _showAddFolderBottomSheet();
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '새 폴더 만들기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlbumOption(BuildContext context, String name) {
    final isSelected = _selectedAlbum == name;
    final Color color = name == '전체' ? Colors.grey : _getAlbumColor(name);

    return InkWell(
      onTap: () {
        setState(() => _selectedAlbum = name);
        _loadData();
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              name,
              style: TextStyle(
                fontSize: 17,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.black : Colors.black54,
              ),
            ),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  void _showAddFolderBottomSheet() {
    String newAlbumName = '';
    int selectedColorValue = 0xFF81C784; // Default Soft Green

    final List<int> palette = [
      0xFFEEEAE2,
      0xFFD9ED72,
      0xFFAFDE62,
      0xFFFFCB74,
      0xFFFFB7B2,
      0xFFBEE6FF,
      0xFF63B0F2,
      0xFFADADFA,
      0xFF8D775C,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '새 폴더 만들기',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '폴더 이름을 입력하세요 (예: 운동, 독서)',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                    onChanged: (value) => newAlbumName = value,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '폴더 색상',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.white,
                              surfaceTintColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              title: const Text(
                                '색상 테마 선택',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 16),
                                  HueRingPicker(
                                    pickerColor: Color(selectedColorValue),
                                    onColorChanged: (color) {
                                      setModalState(
                                        () => selectedColorValue = color.value,
                                      );
                                    },
                                    enableAlpha: false,
                                    displayThumbColor: true,
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    '취소',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(selectedColorValue),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('적용하기'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.colorize, size: 18),
                        label: const Text('직접 선택'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: palette.length,
                      itemBuilder: (context, index) {
                        final colorValue = palette[index];
                        final isColorSelected =
                            selectedColorValue == colorValue;
                        return GestureDetector(
                          onTap: () => setModalState(
                            () => selectedColorValue = colorValue,
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Color(colorValue),
                              shape: BoxShape.circle,
                              border: isColorSelected
                                  ? Border.all(color: Colors.black87, width: 2)
                                  : null,
                              boxShadow: [
                                if (isColorSelected)
                                  BoxShadow(
                                    color: Color(colorValue).withOpacity(0.4),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                              ],
                            ),
                            child: isColorSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = newAlbumName.trim();
                        if (name.isEmpty) return;
                        if (_albums.contains(name)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('이미 존재하는 폴더 이름입니다.')),
                          );
                          return;
                        }

                        await AlbumService.createAlbum(
                          name,
                          colorValue: selectedColorValue,
                        );
                        setState(() => _selectedAlbum = name);
                        await _loadData();
                        if (mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(selectedColorValue),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '폴더 만들기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const radius = 18.0;
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startAngle = -3.14 / 2;

    while (startAngle < 1.5 * 3.14) {
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: radius,
        ),
        startAngle,
        dashWidth / radius,
        false,
        paint,
      );
      startAngle += (dashWidth + dashSpace) / radius;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

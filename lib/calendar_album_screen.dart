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
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  CalendarViewMode _viewMode = CalendarViewMode.calendar;
  Map<String, List<File>> _allPhotosGrouped = {};
  int _totalPhotoCount = 0;

  MonthAlbumData? _monthData;
  Map<DateTime, File> _photoThumbnails = {};
  Map<DateTime, int> _photoCounts = {};
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
    final monthData = await AlbumService.getMonthAlbumData(
      _focusedDay,
      albumName: _selectedAlbum,
    );
    final dateKey = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final dayPhotos = monthData.photosByDate[dateKey] ?? [];

    if (mounted) {
      setState(() {
        _albums = albums;
        _albumColors = albumColors;
        _monthData = monthData;
        _photoThumbnails = monthData.thumbnails;
        _photoCounts = monthData.counts;
        _dayPhotos = dayPhotos;
      });
    }

    _loadGridPhotos();
  }

  Future<void> _loadGridPhotos() async {
    final grouped = await AlbumService.getAllPhotosGrouped(
      albumName: _selectedAlbum,
    );
    int total = 0;
    for (var list in grouped.values) {
      total += list.length;
    }
    if (mounted) {
      setState(() {
        _allPhotosGrouped = grouped;
        _totalPhotoCount = total;
      });
    }
  }

  void _onDaySelected(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    if (date.year == _focusedDay.year && date.month == _focusedDay.month) {
      // Same month: 0ms instant in-memory switch!
      setState(() {
        _selectedDay = date;
        _dayPhotos = _monthData?.photosByDate[dateKey] ?? [];
      });
    } else {
      // Month changed: update focused day and load
      setState(() {
        _selectedDay = date;
        _focusedDay = date;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1013),
      appBar: _buildAppBar(),
      body: SafeArea(
        bottom: false,
        child: _viewMode == CalendarViewMode.grid
            ? _buildPhotoGridView()
            : Stack(
                children: [_buildCalendarContent(), _buildDraggableSheet()],
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final pointColor = _getAlbumNeonPointColor(_selectedAlbum);

    return AppBar(
      backgroundColor: const Color(0xFF0F1013),
      surfaceTintColor: Colors.transparent, // 스크롤 시 회색 틴트 제거
      scrolledUnderElevation: 0,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: GestureDetector(
        onTap: _showAlbumSelector,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: pointColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: pointColor.withValues(alpha: 0.7),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
              Text(
                _viewMode == CalendarViewMode.grid
                    ? "$_selectedAlbum ($_totalPhotoCount)"
                    : _selectedAlbum,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: CalendarUX.albumTitleFontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 22),
            ],
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            _viewMode == CalendarViewMode.grid
                ? Icons.calendar_today_outlined
                : Icons.grid_view_rounded,
            color: Colors.white70,
            size: 20,
          ),
          onPressed: _toggleView,
          tooltip: _viewMode == CalendarViewMode.grid ? '달력 보기' : '모아보기',
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12, left: 2),
          child: GestureDetector(
            onTap: () => Navigator.pop(context, _selectedAlbum),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                color: pointColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: pointColor.withValues(alpha: 0.55),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: pointColor.withValues(alpha: 0.18),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.camera_alt_rounded,
                    color: pointColor,
                    size: 17,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '기록',
                    style: TextStyle(
                      color: pointColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleView() {
    setState(() {
      _viewMode = _viewMode == CalendarViewMode.grid
          ? CalendarViewMode.calendar
          : CalendarViewMode.grid;
    });
    if (_viewMode == CalendarViewMode.grid) {
      _loadGridPhotos();
    }
  }

  Widget _buildCalendarContent() {
    return RepaintBoundary(
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
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white70, size: 22),
            onPressed: _goToPrevMonth,
            splashRadius: 20,
          ),
          Text(
            DateFormat('yyyy년 M월', 'ko_KR').format(_focusedDay),
            style: const TextStyle(
              fontSize: CalendarUX.monthHeaderFontSize,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white70, size: 22),
            onPressed: _goToNextMonth,
            splashRadius: 20,
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
      padding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: CalendarUX.calendarHorizontalPadding,
      ),
      child: Row(
        children: weekdays
            .map(
              (day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      color: Color(0xFF8E929B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
    final prevMonth = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    final daysInPrevMonth = DateUtils.getDaysInMonth(
      prevMonth.year,
      prevMonth.month,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: CalendarUX.calendarHorizontalPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: CalendarUX.weekSpacing,
        childAspectRatio: CalendarUX.calendarGridAspectRatio,
      ),
      itemCount: daysInMonth + firstDayOffset,
      itemBuilder: (context, index) {
        if (index < firstDayOffset) {
          final prevDay = daysInPrevMonth - firstDayOffset + index + 1;
          return Center(
            child: Text(
              '$prevDay',
              style: const TextStyle(
                color: Color(0xFF383B44),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        final day = index - firstDayOffset + 1;
        final date = DateTime(_focusedDay.year, _focusedDay.month, day);
        final isSelected = DateUtils.isSameDay(date, _selectedDay);
        final isToday = DateUtils.isSameDay(date, DateTime.now());

        return GestureDetector(
          onTap: () => _onDaySelected(date),
          child: _buildCalendarDay(date, isSelected, isToday),
        );
      },
    );
  }

  Color _getAlbumColor(String albumName) {
    if (_albumColors.containsKey(albumName)) {
      return Color(_albumColors[albumName]!);
    }
    if (albumName == '일상') return const Color(0xFFEDED6D);
    if (albumName.toLowerCase() == 'workout') return Colors.blue;

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

  Color _getAlbumNeonPointColor(String albumName) {
    if (albumName == '전체') {
      return const Color(0xFFCCFF00); // 전체 앨범 기본 시그니처 네온 라임
    }
    final baseColor = _getAlbumColor(albumName);
    final hsl = HSLColor.fromColor(baseColor);

    // 앨범 고유의 색조(Hue)를 온전히 유지하면서,
    // 채도를 1.0(최대)으로 극대화하고, 다크 배경에서 형광으로 발광하도록 명도를 최적화
    double neonLightness = hsl.lightness;
    if (neonLightness < 0.52) {
      neonLightness = 0.60;
    } else if (neonLightness > 0.72) {
      neonLightness = 0.64;
    }

    return hsl
        .withSaturation(1.0)
        .withLightness(neonLightness)
        .toColor();
  }

  Widget _buildCalendarDay(
    DateTime date,
    bool isSelected,
    bool isToday, {
    bool mini = false,
  }) {
    final pointColor = _getAlbumNeonPointColor(_selectedAlbum);
    final dateKey = DateTime(date.year, date.month, date.day);
    final thumbnailFile = _photoThumbnails[dateKey];
    final hasPhoto = thumbnailFile != null;
    final photoCount = _photoCounts[dateKey] ?? (hasPhoto ? 1 : 0);
    final bool isCurrentMonth = date.month == _focusedDay.month;

    final numberWidget = Text(
      '${date.day}',
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: mini ? 10.5 : 12,
        color: hasPhoto
            ? Colors.white
            : (isToday
                ? pointColor
                : (!isCurrentMonth
                    ? const Color(0xFF383B44)
                    : Colors.white)),
        shadows: hasPhoto
            ? const [Shadow(blurRadius: 4, color: Colors.black)]
            : null,
      ),
    );

    return Container(
      margin: EdgeInsets.all(mini ? 1.5 : 2.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(mini ? 8 : 10),
        border: isSelected
            ? Border.all(color: pointColor, width: 2.0)
            : (isToday
                ? Border.all(color: pointColor.withValues(alpha: 0.35), width: 1.2)
                : null),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: pointColor.withValues(alpha: 0.25),
                  blurRadius: 6,
                  spreadRadius: 0,
                )
              ]
            : null,
      ),
      child: !hasPhoto
          ? Center(child: numberWidget)
          : ClipRRect(
              borderRadius: BorderRadius.circular(
                isSelected ? (mini ? 6.0 : 8.0) : (mini ? 6.5 : 8.5),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildMediaThumbnail(
                    thumbnailFile,
                    fit: BoxFit.cover,
                    cacheWidth: mini ? 70 : 110,
                    cacheHeight: mini ? 70 : 110,
                    showVideoIcon: true,
                  ),
                  Container(
                    color: Colors.black.withValues(alpha: 0.15),
                  ),
                  Positioned(
                    left: mini ? 3 : 5,
                    top: mini ? 2 : 3,
                    child: numberWidget,
                  ),
                  if (photoCount > 1)
                    Positioned(
                      right: mini ? 2 : 3,
                      bottom: mini ? 2 : 3,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: mini ? 3 : 4.5,
                          vertical: mini ? 0.5 : 1.0,
                        ),
                        decoration: BoxDecoration(
                          color: pointColor,
                          borderRadius: BorderRadius.circular(mini ? 4 : 6),
                          boxShadow: [
                            BoxShadow(
                              color: pointColor.withValues(alpha: 0.35),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          '$photoCount',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: mini ? 8.5 : 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: CalendarUX.initialSheetSize,
      minChildSize: CalendarUX.initialSheetSize,
      maxChildSize: 1.0,
      snap: true,
      snapSizes: const [CalendarUX.initialSheetSize, 1.0],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF17191E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: const Color(0xFF2A2D35).withValues(alpha: 0.6),
                width: 0.8,
              ),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHandle(),
              Expanded(
                child: _dayPhotos.isEmpty
                    ? _buildEmptyState(scrollController)
                    : ListView.builder(
                        controller: scrollController,
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 4,
                          bottom: MediaQuery.of(context).padding.bottom + 80,
                        ),
                        itemCount: _dayPhotos.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 2, bottom: 14, left: 2),
                              child: Text(
                                DateFormat('yyyy.MM.dd (E)', 'ko_KR').format(_selectedDay),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF8E929B),
                                  fontSize: 13.5,
                                ),
                              ),
                            );
                          }
                          return _buildRecordEntry(index - 1);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return GestureDetector(
      onTap: () {
        if (_sheetController.isAttached) {
          final target = _sheetController.size > 0.6
              ? CalendarUX.initialSheetSize
              : 1.0;
          _sheetController.animateTo(
            target,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        width: double.infinity,
        color: Colors.transparent, // Expand tap area
        child: Center(
          child: Container(
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF2E323A),
              borderRadius: BorderRadius.circular(2.5),
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('yyyy.MM.dd (E)', 'ko_KR').format(_selectedDay),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF8E929B),
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 36),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.photo_library_outlined,
                      size: 28,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '이 날은 기록이 없어요 📷',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '상단 "기록" 버튼을 눌러 첫 기록을 남겨보세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.38),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordEntry(int index) {
    if (index >= _dayPhotos.length) return const SizedBox.shrink();
    final photoFile = _dayPhotos[index];
    final photoDate = AlbumService.getPhotoDate(photoFile);
    final period = photoDate.hour < 12 ? '오전' : '오후';
    final timeStr = '$period ${DateFormat('h:mm').format(photoDate)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: _getAlbumNeonPointColor(
                  _selectedAlbum == '전체'
                      ? photoFile.parent.path.split(Platform.pathSeparator).last
                      : _selectedAlbum,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildSinglePhoto(photoFile, index: index),
        ],
      ),
    );
  }

  Widget _buildSinglePhoto(File file, {bool tapEnabled = true, int index = 0}) {
    return GestureDetector(
      onTap: tapEnabled
          ? () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoDetailScreen(
                    photoFiles: _dayPhotos,
                    initialIndex: index,
                  ),
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
              color: const Color(0xFF1E2026),
              border: Border.all(
                color: const Color(0xFF2A2D35),
                width: 0.8,
              ),
            ),
            child: _buildMediaThumbnail(file, fit: BoxFit.cover),
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
                  color: Colors.white.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.photo_library_outlined,
                  size: 28,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '아직 기록이 없어요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '상단 "기록" 버튼을 눌러 첫 기록을 남겨보세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.38),
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
                  color: Colors.white,
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
                return _buildGridPhotoItem(monthPhotos[index], monthPhotos, index);
              }, childCount: monthPhotos.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ];
      }).toList(),
    );
  }

  Widget _buildGridPhotoItem(File file, List<File> monthPhotos, int index) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoDetailScreen(
              photoFiles: monthPhotos,
              initialIndex: index,
            ),
          ),
        );
        if (result == true) {
          _loadData();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E2026),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF2A2D35).withValues(alpha: 0.6),
            width: 0.8,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildMediaThumbnail(file, fit: BoxFit.cover, cacheWidth: 300),
      ),
    );
  }

  Widget _buildMediaThumbnail(
    File file, {
    BoxFit fit = BoxFit.cover,
    int? cacheWidth,
    int? cacheHeight,
    bool showVideoIcon = true,
  }) {
    final isVideo = AlbumService.isVideo(file);
    final thumbFile = isVideo ? File('${file.path}_thumb.jpg') : file;

    Widget imageWidget;
    if (isVideo && !thumbFile.existsSync()) {
      imageWidget = FutureBuilder<File?>(
        future: AlbumService.getVideoThumbnail(file),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.file(
              snapshot.data!,
              fit: fit,
              cacheWidth: cacheWidth,
              cacheHeight: cacheHeight,
            );
          }
          return Container(
            color: const Color(0xFF1E2026),
            child: const Center(
              child: Icon(Icons.videocam_rounded, color: Colors.white38, size: 22),
            ),
          );
        },
      );
    } else {
      imageWidget = Image.file(
        thumbFile,
        fit: fit,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFF1E2026),
          child: const Icon(Icons.broken_image_rounded, color: Colors.white24),
        ),
      );
    }

    if (!isVideo || !showVideoIcon) return imageWidget;

    return Stack(
      fit: StackFit.expand,
      children: [
        imageWidget,
        Positioned(
          bottom: 5,
          right: 5,
          child: Container(
            padding: const EdgeInsets.all(3.5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 0.8,
              ),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 13,
            ),
          ),
        ),
      ],
    );
  }

  void _showAlbumSelector() {
    showModalBottomSheet(
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
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomInset = MediaQuery.of(context).padding.bottom;
            return Container(
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
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomInset),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Drag Handle
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
                      const Text(
                        '폴더 선택',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              _buildAlbumOption(context, '전체', setModalState),
                              ..._albums.where((a) => a != '전체').map(
                                (album) => _buildAlbumOption(context, album, setModalState),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(color: Color(0xFF2E323A), height: 24),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _showAddFolderBottomSheet();
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22252C),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF2E323A).withValues(alpha: 0.5),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 18,
                                  color: Color(0xFFF4F6F8),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                '새 폴더 만들기',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFF4F6F8),
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
          },
        );
      },
    );
  }

  Widget _buildAlbumOption(
    BuildContext context,
    String name, [
    StateSetter? setModalState,
  ]) {
    final isSelected = _selectedAlbum == name;
    final Color color = _getAlbumNeonPointColor(name);
    final canDelete = name != '전체' && name != '일상';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() => _selectedAlbum = name);
                _loadData();
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.horizontal(
                left: const Radius.circular(12),
                right: canDelete ? Radius.zero : const Radius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
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
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 5,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.white60,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: color, size: 20),
                  ],
                ),
              ),
            ),
          ),
          if (canDelete)
            IconButton(
              tooltip: '폴더 삭제',
              icon: Icon(
                Icons.delete_outline_rounded,
                color: Colors.white.withValues(alpha: 0.38),
                size: 20,
              ),
              splashRadius: 18,
              onPressed: () => _confirmDeleteAlbum(name, setModalState),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAlbum(String albumName, StateSetter? setModalState) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      showDragHandle: false,
      sheetAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).padding.bottom;
        return Container(
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
              padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
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
                  const Text(
                    '폴더 삭제',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\'$albumName\' 폴더를 삭제하시겠습니까?\n사진은 기기 앨범에 안전하게 유지되며 폴더만 삭제됩니다.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9AA1AC),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(
                              color: const Color(0xFF2E323A).withValues(alpha: 0.5),
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx, false),
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
                        flex: 1,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF453A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            '삭제',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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
        );
      },
    );

    if (confirmed == true && mounted) {
      await AlbumService.deleteAlbum(albumName);

      if (_selectedAlbum == albumName) {
        _selectedAlbum = '전체';
      }

      await _loadData();

      if (setModalState != null && mounted) {
        setModalState(() {});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '\'$albumName\' 폴더가 삭제되었습니다.',
              style: const TextStyle(
                color: Color(0xFFF4F6F8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: const Color(0xFF22252C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: const Color(0xFF2E323A).withValues(alpha: 0.6),
                width: 0.8,
              ),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      showDragHandle: false,
      sheetAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomPadding = MediaQuery.of(context).padding.bottom;
            final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
            final hasText = newAlbumName.trim().isNotEmpty;

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
                padding: EdgeInsets.only(
                  bottom: keyboardPadding > 0 ? keyboardPadding : bottomPadding,
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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

                        // Header
                        const Text(
                          '새 폴더 만들기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '사진을 분류할 새 폴더의 이름과 색상을 지정하세요',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9AA1AC),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // TextField
                        TextField(
                          autofocus: true,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFF4F6F8),
                          ),
                          decoration: InputDecoration(
                            hintText: '폴더 이름 입력 (예: 운동, 독서, 여행)',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: const Color(0xFF9AA1AC).withValues(alpha: 0.6),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF22252C),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: const Color(0xFF2E323A).withValues(alpha: 0.35),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: const Color(0xFF2E323A).withValues(alpha: 0.35),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color(selectedColorValue),
                                width: 1.2,
                              ),
                            ),
                          ),
                          onChanged: (value) => setModalState(() => newAlbumName = value),
                        ),
                        const SizedBox(height: 14),

                        // Color Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '폴더 색상 테마',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF9AA1AC),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _showCustomColorPickerBottomSheet(
                                  parentContext: context,
                                  currentColorValue: selectedColorValue,
                                  onColorSelected: (newColor) {
                                    setModalState(() => selectedColorValue = newColor);
                                  },
                                );
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.colorize, size: 14, color: Color(0xFF9AA1AC)),
                                  SizedBox(width: 4),
                                  Text(
                                    '직접 선택',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9AA1AC),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Palette Circles
                        SizedBox(
                          height: 36,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: palette.length,
                            itemBuilder: (context, index) {
                              final colorValue = palette[index];
                              final isColorSelected = selectedColorValue == colorValue;
                              return GestureDetector(
                                onTap: () => setModalState(
                                  () => selectedColorValue = colorValue,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Color(colorValue),
                                    shape: BoxShape.circle,
                                    border: isColorSelected
                                        ? Border.all(color: Colors.white, width: 2)
                                        : null,
                                    boxShadow: [
                                      if (isColorSelected)
                                        BoxShadow(
                                          color: Color(colorValue).withValues(alpha: 0.5),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        ),
                                    ],
                                  ),
                                  child: isColorSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Action Buttons (Cancel / Confirm matching runningapp style)
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 13),
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
                                      ? Color(selectedColorValue)
                                      : const Color(0xFF22252C),
                                  foregroundColor: hasText
                                      ? Colors.white
                                      : const Color(0xFF9AA1AC),
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
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
                                  if (context.mounted) Navigator.pop(context);
                                },
                                child: const Text(
                                  '폴더 만들기',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
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
          },
        );
      },
    );
  }

  Future<void> _showCustomColorPickerBottomSheet({
    required BuildContext parentContext,
    required int currentColorValue,
    required ValueChanged<int> onColorSelected,
  }) async {
    FocusScope.of(parentContext).unfocus();
    int tempColor = currentColorValue;
    HSVColor currentHsvColor = HSVColor.fromColor(Color(currentColorValue));

    await showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      showDragHandle: false,
      sheetAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setPickerState) {
            final bottomInset = MediaQuery.of(ctx).padding.bottom;
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.85,
              ),
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
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomInset),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
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

                        // Header
                        Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: Color(tempColor),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(tempColor).withValues(alpha: 0.5),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              '색상 선택',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Pure Ring & Area Picker (Zero HEX input field, exact 200px height)
                        Center(
                          child: SizedBox(
                            width: 200,
                            height: 200,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: ColorPickerHueRing(
                                    currentHsvColor,
                                    (hsv) {
                                      setPickerState(() {
                                        currentHsvColor = hsv;
                                        tempColor = hsv.toColor().toARGB32();
                                      });
                                    },
                                    displayThumbColor: true,
                                    strokeWidth: 18.0,
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: ColorPickerArea(
                                      currentHsvColor,
                                      (hsv) {
                                        setPickerState(() {
                                          currentHsvColor = hsv;
                                          tempColor = hsv.toColor().toARGB32();
                                        });
                                      },
                                      PaletteType.hsv,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Action Buttons (Cancel / Apply)
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: BorderSide(
                                    color: const Color(0xFF2E323A).withValues(alpha: 0.5),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(ctx),
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
                                  backgroundColor: Color(tempColor),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  onColorSelected(tempColor);
                                  Navigator.pop(ctx);
                                },
                                child: const Text(
                                  '적용하기',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
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

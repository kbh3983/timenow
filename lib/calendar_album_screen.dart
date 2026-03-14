import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'album_service.dart';
import 'ux_config.dart';

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
  bool _isExpanded = false;
  double _transitionExtent = 0.0; // 0.0 for month, 1.0 for week
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  CalendarViewMode _viewMode = CalendarViewMode.calendar;
  Map<String, List<File>> _allPhotosGrouped = {};
  int _totalPhotoCount = 0;

  Map<DateTime, Set<String>> _photoDots = {};
  List<File> _dayPhotos = [];

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
    final dots = await AlbumService.getPhotoDotsForMonth(
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
        _photoDots = dots;
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
        child: _viewMode == CalendarViewMode.grid
            ? _buildPhotoGridView()
            : Stack(
                children: [_buildCalendarContent(), _buildDraggableSheet()],
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
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
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ],
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            _viewMode == CalendarViewMode.grid
                ? Icons.calendar_today
                : (_isExpanded ? Icons.grid_view : Icons.grid_view),
            color: Colors.black,
          ),
          onPressed: _toggleView,
        ),
      ],
    );
  }

  void _toggleView() {
    if (_viewMode == CalendarViewMode.grid) {
      setState(() {
        _viewMode = CalendarViewMode.calendar;
        _isExpanded = false;
        _transitionExtent = 0.0;
      });
      // Removed animateTo(0.35) because the sheet is not yet attached
      // and will render at initialChildSize (0.35) by default.
      return;
    }

    if (_isExpanded) {
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
    return Opacity(
      opacity: (1.0 - _transitionExtent).clamp(0.0, 1.0),
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
                  _buildRecordStatus(),
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
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  Widget _buildRecordStatus() {
    final count = _photoDots.values.fold(
      0,
      (sum, albums) => sum + albums.length,
    );
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '기록 현황',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    const TextSpan(text: '이번 달에 총 '),
                    TextSpan(
                      text: '${count}번',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const TextSpan(text: '의 기록을 남겼어요! 화이팅!'),
                  ],
                ),
              ),
            ],
          ),
          // Character Placeholder - In real app use an Image asset
          Container(
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.face, size: 40, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: UXConfig.kCalendarWeekdayVerticalPadding,
        horizontal: 16,
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: UXConfig.kCalendarWeekSpacing,
        childAspectRatio:
            1.3, // Allows items to be wider than tall, bringing rows closer
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
        horizontal: 16,
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
    if (albumName == '일상') return Colors.red;
    if (albumName.toLowerCase() == 'workout') return Colors.blue;
    // Map other common names or fallback pseudo-random but deterministic color
    final hash = albumName.hashCode;
    final r = (hash & 0xFF0000) >> 16;
    final g = (hash & 0x00FF00) >> 8;
    final b = (hash & 0x0000FF);
    // ensure the color is not too light so it's visible on white
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
    final albums = _photoDots[DateTime(date.year, date.month, date.day)] ?? {};
    final dots = albums.map(_getAlbumColor).toList();

    // Check if it's Sunday (weekday == 7)
    final bool isSunday = date.weekday == DateTime.sunday;
    // Add holiday logic here if needed (for now, just Sunday is red)
    final bool isHoliday = isSunday;

    final dayCircle = Container(
      width: mini ? 32 : 36,
      height: mini ? 32 : 36,
      decoration: BoxDecoration(
        color: isSelected
            ? UXConfig.kCalendarSelectedDayColor
            : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (date.month != _focusedDay.month
                      ? Colors.grey[300]
                      : (isHoliday ? Colors.red : Colors.black)),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );

    if (mini) return dayCircle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [dayCircle, const SizedBox(height: 2), _buildDots(dots)],
    );
  }

  Widget _buildDots(List<Color> colors) {
    if (colors.isEmpty) return const SizedBox(height: 4);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: colors
          .take(5)
          .map(
            (color) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              width: 4,
              height: 4,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.35,
      minChildSize: 0.35,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.35, 0.95],
      builder: (context, scrollController) {
        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            setState(() {
              // Map extent [0.35, 0.95] to [0.0, 1.0] transition
              _transitionExtent = ((notification.extent - 0.35) / 0.6).clamp(
                0.0,
                1.0,
              );
              _isExpanded = _transitionExtent > 0.5;
            });
            return true;
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(_isExpanded ? 0 : 32),
              ),
              boxShadow: _isExpanded
                  ? null
                  : [const BoxShadow(blurRadius: 15, color: Colors.black12)],
            ),
            child: Column(
              children: [
                _buildHandle(),
                // Show Week Strip at the top of the sheet when transition starts
                if (_transitionExtent > 0.05)
                  Opacity(
                    opacity: _transitionExtent,
                    child: SizedBox(
                      height: _transitionExtent * 50, // More realistic height
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: _buildWeekStrip(),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _dayPhotos.length,
                    itemBuilder: (context, index) {
                      return _buildRecordEntry(index);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    if (_isExpanded) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildRecordEntry(int index) {
    if (index >= _dayPhotos.length) return const SizedBox.shrink();
    final photoFile = _dayPhotos[index];
    final timeStr = DateFormat('hh:mm a').format(photoFile.statSync().changed);

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: index % 2 == 0 ? Colors.yellow : Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.ios_share, size: 20, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stacked effect ONLY when NOT expanded and it's the first photo
          if (!_isExpanded && index == 0 && _dayPhotos.length > 1)
            _buildStackedPhoto(photoFile)
          else
            _buildSinglePhoto(photoFile),
        ],
      ),
    );
  }

  Widget _buildStackedPhoto(File topPhoto) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          width: 200,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          width: 220,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
          ),
        ),
        _buildSinglePhoto(topPhoto),
      ],
    );
  }

  Widget _buildSinglePhoto(File file) {
    return Container(
      width: double.infinity,
      height: 350,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildPhotoGridView() {
    final sortedMonths = _allPhotosGrouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedMonths.isEmpty) {
      return const Center(child: Text('사진이 없습니다.'));
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
      child: Image.file(file, fit: BoxFit.cover),
    );
  }

  void _showAlbumSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAlbumOption(context, '전체'),
                  ..._albums.map((album) => _buildAlbumOption(context, album)),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('폴더 추가'),
                    onTap: () {
                      Navigator.pop(context);
                      _showAddFolderDialog();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAlbumOption(BuildContext context, String name) {
    final isSelected = _selectedAlbum == name;
    return ListTile(
      title: Center(
        child: Text(
          name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
      ),
      onTap: () {
        setState(() => _selectedAlbum = name);
        _loadData();
        Navigator.pop(context);
      },
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.black)
          : null,
    );
  }

  void _showAddFolderDialog() {
    String newAlbumName = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('새 폴더 추가'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: '폴더 이름을 입력하세요'),
            onChanged: (value) => newAlbumName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                if (newAlbumName.trim().isNotEmpty) {
                  final name = newAlbumName.trim();
                  await AlbumService.createAlbum(name);
                  await _loadData();
                  setState(() => _selectedAlbum = name);
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('추가'),
            ),
          ],
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

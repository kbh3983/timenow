import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'ux_config.dart';
import 'services/app_settings_service.dart';

/// Result from gallery picker containing the selected file and its creation time.
class GalleryResult {
  final File file;
  final DateTime creationTime;
  const GalleryResult({required this.file, required this.creationTime});
}

class GalleryPickerScreen extends StatefulWidget {
  const GalleryPickerScreen({super.key});

  @override
  State<GalleryPickerScreen> createState() => _GalleryPickerScreenState();
}

enum PermissionStatusView {
  loading,
  authorized,
  limited,
  denied,
}

class _GalleryPickerScreenState extends State<GalleryPickerScreen>
    with WidgetsBindingObserver {
  List<AssetPathEntity> _albums = [];
  int _selectedAlbumIndex = 0;
  List<AssetEntity> _photos = [];
  int _currentPage = 0;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isInitialLoading = true;
  PermissionStatusView _permissionStatus = PermissionStatusView.loading;
  static const int _pageSize = 80;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissionAndLoad();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionAndReload();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMorePhotos();
    }
  }

  Future<void> _requestPermissionAndLoad() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (!mounted) return;

    if (permission.isAuth) {
      setState(() {
        _permissionStatus = PermissionStatusView.authorized;
      });
      await _loadAlbums();
    } else if (permission.isLimited) {
      setState(() {
        _permissionStatus = PermissionStatusView.limited;
        _isInitialLoading = false;
      });
    } else {
      setState(() {
        _permissionStatus = PermissionStatusView.denied;
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _checkPermissionAndReload() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (!mounted) return;

    if (permission.isAuth) {
      if (_permissionStatus != PermissionStatusView.authorized || _albums.isEmpty) {
        setState(() {
          _permissionStatus = PermissionStatusView.authorized;
          _isInitialLoading = true;
        });
        await _loadAlbums();
      }
    } else if (permission.isLimited) {
      setState(() {
        _permissionStatus = PermissionStatusView.limited;
      });
    } else {
      setState(() {
        _permissionStatus = PermissionStatusView.denied;
      });
    }
  }

  Future<void> _loadAlbums() async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: true,
      onlyAll: false, // 명시적으로 전체 폴더 검색
      filterOption: FilterOptionGroup(
        containsPathModified: true, // 일부 단말기 앨범 누락 방지
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );

    if (!mounted) return;

    // Filter out empty albums
    final validAlbums = <AssetPathEntity>[];
    for (final album in albums) {
      final count = await album.assetCountAsync;
      if (count > 0) {
        validAlbums.add(album);
      }
    }

    // Sort: "Recent" (isAll) first, then alphabetical
    validAlbums.sort((a, b) {
      if (a.isAll) return -1;
      if (b.isAll) return 1;
      return a.name.compareTo(b.name);
    });

    setState(() {
      _albums = validAlbums;
      _selectedAlbumIndex = 0;
    });

    if (validAlbums.isNotEmpty) {
      await _loadPhotosForAlbum(0);
    } else {
      setState(() => _isInitialLoading = false);
    }
  }

  Future<void> _loadPhotosForAlbum(int albumIndex) async {
    if (albumIndex >= _albums.length) return;

    setState(() {
      _isInitialLoading = true;
      _photos = [];
      _currentPage = 0;
      _hasMore = true;
      _selectedAlbumIndex = albumIndex;
    });

    // Scroll to top when switching albums
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    await _loadMorePhotos();
    if (mounted) {
      setState(() => _isInitialLoading = false);
    }
  }

  Future<void> _loadMorePhotos() async {
    if (_isLoadingMore || !_hasMore) return;
    if (_albums.isEmpty) return;

    _isLoadingMore = true;

    final album = _albums[_selectedAlbumIndex];
    final assets = await album.getAssetListPaged(
      page: _currentPage,
      size: _pageSize,
    );

    if (!mounted) {
      _isLoadingMore = false;
      return;
    }

    setState(() {
      _photos.addAll(assets);
      _currentPage++;
      _hasMore = assets.length >= _pageSize;
      _isLoadingMore = false;
    });
  }

  Future<void> _onPhotoSelected(AssetEntity asset) async {
    final file = await asset.file;
    if (file != null && mounted) {
      Navigator.pop(
        context,
        GalleryResult(file: file, creationTime: asset.createDateTime),
      );
    }
  }

  String _getAlbumDisplayName(AssetPathEntity album) {
    if (album.isAll) return '최근 항목';
    return album.name;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return ListenableBuilder(
      listenable: AppSettingsService(),
      builder: (context, _) {
        final settings = AppSettingsService();
        final accent = settings.accentColor;

        return Scaffold(
          backgroundColor: settings.scaffoldBackgroundColor,
          body: Column(
            children: [
              // Top bar
              _buildTopBar(topPadding),
              if (_permissionStatus == PermissionStatusView.authorized) ...[
                // Album tabs
                _buildAlbumTabs(),
                // Photo grid
                Expanded(child: _buildPhotoGrid()),
              ] else if (_permissionStatus == PermissionStatusView.limited ||
                  _permissionStatus == PermissionStatusView.denied) ...[
                Expanded(child: _buildPermissionDeniedView()),
              ] else ...[
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: accent,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPermissionDeniedView() {
    final isLimited = _permissionStatus == PermissionStatusView.limited;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SharedUX.centerButtonColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: SharedUX.centerButtonColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                color: SharedUX.centerButtonColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isLimited ? '모든 사진 접근 권한이 필요합니다' : '사진 접근 권한이 필요합니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppSettingsService().textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pretendard',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isLimited
                  ? '현재 일부 사진만 선택되어 있어 Log 앨범만 표시되고 있습니다.\n\n카메라, 다운로드, 스크린샷 등 기기의 모든 앨범을 확인하시려면 사진 접근 권한을 \'모두 허용\'으로 변경해주세요.'
                  : '기기에 저장된 모든 사진 앨범을 불러오고 타임스탬프를 적용하려면 사진 접근 권한이 필요합니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppSettingsService().subTextColor,
                fontSize: 14,
                height: 1.5,
                fontFamily: 'Pretendard',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => PhotoManager.openSetting(),
                icon: const Icon(Icons.settings, color: Colors.black, size: 20),
                label: Text(
                  isLimited ? '설정에서 \'모두 허용\'으로 변경' : '권한 설정하러 가기',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Pretendard',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppSettingsService().accentColor,
                  foregroundColor: AppSettingsService().isLight ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '설정 > 권한 > 사진 및 동영상 > \'모두 허용\' 선택 후 앱으로 돌아오시면 자동으로 모든 앨범이 나타납니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppSettingsService().subTextColor.withValues(alpha: 0.6),
                fontSize: 12,
                height: 1.4,
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(double topPadding) {
    final settings = AppSettingsService();
    return Container(
      padding: EdgeInsets.fromLTRB(4, topPadding + 4, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.chevron_left, color: settings.textColor, size: 28),
          ),
          Expanded(
            child: Text(
              '사진 고르기',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: settings.textColor,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildAlbumTabs() {
    if (_albums.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _albums.length,
        itemBuilder: (context, index) {
          final album = _albums[index];
          final isSelected = index == _selectedAlbumIndex;
          final displayName = _getAlbumDisplayName(album);

          return GestureDetector(
            onTap: () {
              if (index != _selectedAlbumIndex) {
                _loadPhotosForAlbum(index);
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppSettingsService().accentColor.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppSettingsService().accentColor.withValues(alpha: 0.5)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  displayName,
                  style: TextStyle(
                    color: isSelected
                        ? AppSettingsService().accentColor
                        : AppSettingsService().subTextColor,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotoGrid() {
    if (_isInitialLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: SharedUX.centerButtonColor,
          strokeWidth: 2,
        ),
      );
    }

    if (_photos.isEmpty) {
      return const Center(
        child: Text(
          '사진이 없습니다',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 14,
            fontFamily: 'Pretendard',
          ),
        ),
      );
    }

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(2, 2, 2, 2 + bottomPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1.0,
      ),
      itemCount: _photos.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _photos.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: SharedUX.centerButtonColor,
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        }

        final asset = _photos[index];
        return _PhotoThumbnailTile(
          asset: asset,
          onTap: () => _onPhotoSelected(asset),
        );
      },
    );
  }
}

/// Individual photo thumbnail tile with efficient loading
class _PhotoThumbnailTile extends StatefulWidget {
  final AssetEntity asset;
  final VoidCallback onTap;

  const _PhotoThumbnailTile({required this.asset, required this.onTap});

  @override
  State<_PhotoThumbnailTile> createState() => _PhotoThumbnailTileState();
}

class _PhotoThumbnailTileState extends State<_PhotoThumbnailTile> {
  Uint8List? _thumbData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(_PhotoThumbnailTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset.id != widget.asset.id) {
      _loadThumbnail();
    }
  }

  Future<void> _loadThumbnail() async {
    final data = await widget.asset.thumbnailDataWithSize(
      const ThumbnailSize(300, 300),
      quality: 80,
    );
    if (mounted) {
      setState(() {
        _thumbData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        color: const Color(0xFF1A1A1A),
        child: _isLoading || _thumbData == null
            ? const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white24,
                    strokeWidth: 1.5,
                  ),
                ),
              )
            : Image.memory(
                _thumbData!,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
      ),
    );
  }
}

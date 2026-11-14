import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'ux_config.dart';
import 'services/app_settings_service.dart';
import 'widgets/ad_banner_widget.dart';

/// Result from gallery picker containing the selected file and its creation time.
class GalleryResult {
  final File file;
  final DateTime creationTime;
  const GalleryResult({required this.file, required this.creationTime});
}

class GalleryPickerScreen extends StatefulWidget {
  const GalleryPickerScreen({super.key});

  /// 앱 시작 시 백그라운드에서 최근 사진 목록과 상단 썸네일을 미리 프리페치하여
  /// 첫 진입 시에도 0ms로 즉시 화면이 열리도록 워밍업합니다.
  static Future<void> warmUpCache() async {
    await _GalleryPickerScreenState.warmUp();
  }

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
  // Static cache for instant 0ms re-open
  static List<AssetPathEntity>? _cachedAlbums;
  static List<AssetEntity>? _cachedRecentPhotos;
  static final Map<String, Uint8List> _thumbCache = {};
  static PermissionStatusView? _cachedPermissionStatus;

  static Future<void> warmUp() async {
    try {
      if (_cachedRecentPhotos != null && _cachedRecentPhotos!.isNotEmpty) {
        return;
      }
      final filterOption = FilterOptionGroup(
        containsPathModified: true,
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      );
      final recentAlbums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
        onlyAll: true,
        filterOption: filterOption,
      );
      if (recentAlbums.isNotEmpty) {
        final recentAlbum = recentAlbums.first;
        final initialAssets = await recentAlbum.getAssetListPaged(
          page: 0,
          size: _pageSize,
        );
        _cachedRecentPhotos = initialAssets;
        _cachedAlbums ??= [recentAlbum];

        // 첫 화면에 보이는 상위 24개 썸네일 미리 캐싱
        final topAssets = initialAssets.take(24);
        await Future.wait(
          topAssets.map((asset) async {
            if (_thumbCache.containsKey(asset.id)) return;
            final data = await asset.thumbnailDataWithSize(
              const ThumbnailSize.square(240),
              quality: 75,
            );
            if (data != null) {
              _thumbCache[asset.id] = data;
            }
          }),
        );
      }
    } catch (_) {}
  }

  List<AssetPathEntity> _albums = [];
  int _selectedAlbumIndex = 0;
  List<AssetEntity> _photos = [];
  int _currentPage = 0;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isInitialLoading = true;
  bool _isSelectingPhoto = false;
  PermissionStatusView _permissionStatus = PermissionStatusView.loading;
  static const int _pageSize = 60;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_cachedPermissionStatus != null) {
      _permissionStatus = _cachedPermissionStatus!;
    }
    // 캐시가 있으면 첫 프레임부터 즉시 렌더링 (0ms 체감 속도)
    if (_cachedAlbums != null &&
        _cachedAlbums!.isNotEmpty &&
        _cachedRecentPhotos != null &&
        _cachedRecentPhotos!.isNotEmpty) {
      _albums = List<AssetPathEntity>.from(_cachedAlbums!);
      _photos = List<AssetEntity>.from(_cachedRecentPhotos!);
      _currentPage = 1;
      _hasMore = _photos.length >= _pageSize;
      _isInitialLoading = false;
    }
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

    final newStatus = permission.isAuth
        ? PermissionStatusView.authorized
        : (permission.isLimited
            ? PermissionStatusView.limited
            : PermissionStatusView.denied);

    _cachedPermissionStatus = newStatus;

    if (newStatus == PermissionStatusView.authorized ||
        newStatus == PermissionStatusView.limited) {
      setState(() {
        _permissionStatus = newStatus;
      });
      await _loadAlbums();
    } else {
      _cachedAlbums = null;
      _cachedRecentPhotos = null;
      setState(() {
        _permissionStatus = PermissionStatusView.denied;
        _photos = [];
        _albums = [];
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _checkPermissionAndReload() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (!mounted) return;

    final newStatus = permission.isAuth
        ? PermissionStatusView.authorized
        : (permission.isLimited
            ? PermissionStatusView.limited
            : PermissionStatusView.denied);

    _cachedPermissionStatus = newStatus;

    if (_permissionStatus != newStatus || _albums.isEmpty) {
      setState(() {
        _permissionStatus = newStatus;
        if (newStatus == PermissionStatusView.denied) {
          _photos = [];
          _albums = [];
          _isInitialLoading = false;
        } else {
          _isInitialLoading = true;
        }
      });
      if (newStatus != PermissionStatusView.denied) {
        await _loadAlbums();
      }
    }
  }

  Future<void> _loadAlbums() async {
    final filterOption = FilterOptionGroup(
      containsPathModified: true,
      orders: [
        const OrderOption(type: OrderOptionType.createDate, asc: false),
      ],
    );

    // 1단계: '최근 항목(전체)' 앨범만 먼저 초고속 조회하여 그리드 즉시 표시
    if (_photos.isEmpty) {
      final recentAlbums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
        onlyAll: true,
        filterOption: filterOption,
      );
      if (!mounted) return;

      if (recentAlbums.isNotEmpty) {
        final recentAlbum = recentAlbums.first;
        final initialAssets = await recentAlbum.getAssetListPaged(
          page: 0,
          size: _pageSize,
        );
        if (!mounted) return;

        _cachedRecentPhotos = initialAssets;
        setState(() {
          if (_albums.isEmpty) {
            _albums = [recentAlbum];
          }
          _selectedAlbumIndex = 0;
          _photos = List<AssetEntity>.from(initialAssets);
          _currentPage = 1;
          _hasMore = initialAssets.length >= _pageSize;
          _isInitialLoading = false;
        });
      }
    } else if (_selectedAlbumIndex == 0 && _albums.isNotEmpty) {
      // 캐시로 즉시 열렸을 때 최신 사진 목록만 백그라운드 갱신
      final latestAssets = await _albums.first.getAssetListPaged(
        page: 0,
        size: _pageSize,
      );
      if (!mounted) return;
      _cachedRecentPhotos = latestAssets;
      if (_selectedAlbumIndex == 0 && _currentPage <= 1) {
        setState(() {
          _photos = List<AssetEntity>.from(latestAssets);
          _hasMore = latestAssets.length >= _pageSize;
        });
      }
    }

    // 2단계: 전체 앨범 목록을 백그라운드에서 병렬(Future.wait)로 카운트하여 상단 탭 업데이트
    final allAlbums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: true,
      onlyAll: false,
      filterOption: filterOption,
    );
    if (!mounted) return;

    final counts = await Future.wait(
      allAlbums.map((album) => album.assetCountAsync),
    );
    if (!mounted) return;

    final validAlbums = <AssetPathEntity>[];
    for (int i = 0; i < allAlbums.length; i++) {
      if (counts[i] > 0) {
        validAlbums.add(allAlbums[i]);
      }
    }

    validAlbums.sort((a, b) {
      if (a.isAll) return -1;
      if (b.isAll) return 1;
      return a.name.compareTo(b.name);
    });

    _cachedAlbums = validAlbums;

    if (mounted) {
      setState(() {
        _albums = validAlbums;
        _isInitialLoading = false;
      });
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
    if (_isSelectingPhoto) return;
    _isSelectingPhoto = true;
    try {
      final file = await asset.file;
      if (file != null && mounted) {
        Navigator.pop(
          context,
          GalleryResult(file: file, creationTime: asset.createDateTime.toLocal()),
        );
      }
    } finally {
      _isSelectingPhoto = false;
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
              // 권한이 전체 허용이 아닌 경우(일부 허용 또는 허용 안함) 상단에 전체 허용 유도 배너 표시
              if (_permissionStatus == PermissionStatusView.limited ||
                  _permissionStatus == PermissionStatusView.denied)
                _buildLimitedBanner(),

              if (_permissionStatus == PermissionStatusView.authorized ||
                  _permissionStatus == PermissionStatusView.limited) ...[
                // Album tabs
                _buildAlbumTabs(),
                // Photo grid
                Expanded(child: _buildPhotoGrid()),
              ] else if (_permissionStatus == PermissionStatusView.denied) ...[
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
              // 하단 배너 광고
              SafeArea(
                top: false,
                child: const AdBannerWidget(
                  margin: EdgeInsets.fromLTRB(16, 6, 16, 6),
                ),
              ),
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

  Widget _buildLimitedBanner() {
    final settings = AppSettingsService();
    final isDenied = _permissionStatus == PermissionStatusView.denied;
    final text = isDenied
        ? '사진 접근 권한이 필요합니다 · 모든 사진 허용하기'
        : '일부 사진만 허용됨 · 모든 사진 허용하기';

    return GestureDetector(
      onTap: () => PhotoManager.openSetting(),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: settings.accentColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: settings.accentColor.withValues(alpha: 0.35),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: settings.accentColor, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: settings.accentColor,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: settings.accentColor, size: 18),
          ],
        ),
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
    final cached = _GalleryPickerScreenState._thumbCache[widget.asset.id];
    if (cached != null) {
      _thumbData = cached;
      _isLoading = false;
    } else {
      _loadThumbnail();
    }
  }

  @override
  void didUpdateWidget(_PhotoThumbnailTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset.id != widget.asset.id) {
      final cached = _GalleryPickerScreenState._thumbCache[widget.asset.id];
      if (cached != null) {
        _thumbData = cached;
        _isLoading = false;
      } else {
        _thumbData = null;
        _isLoading = true;
        _loadThumbnail();
      }
    }
  }

  Future<void> _loadThumbnail() async {
    final assetId = widget.asset.id;
    final data = await widget.asset.thumbnailDataWithSize(
      const ThumbnailSize.square(240),
      quality: 75,
    );
    if (data != null) {
      if (_GalleryPickerScreenState._thumbCache.length > 600) {
        _GalleryPickerScreenState._thumbCache.remove(
          _GalleryPickerScreenState._thumbCache.keys.first,
        );
      }
      _GalleryPickerScreenState._thumbCache[assetId] = data;
    }
    if (mounted && widget.asset.id == assetId) {
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
            ? const SizedBox.shrink()
            : Image.memory(
                _thumbData!,
                fit: BoxFit.cover,
                cacheWidth: 240,
                gaplessPlayback: true,
                filterQuality: FilterQuality.low,
              ),
      ),
    );
  }
}

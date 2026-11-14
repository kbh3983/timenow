import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/app_settings_service.dart';
import 'services/app_localizations.dart';
import 'services/timestamp_deck_manager.dart';
import 'services/timestamp_access_manager.dart';
import 'widgets/unlock_timestamp_dialog.dart';
import 'widgets/ad_banner_widget.dart';
import 'timestamp_overlays.dart';

class StampManagementScreen extends StatefulWidget {
  const StampManagementScreen({super.key});

  @override
  State<StampManagementScreen> createState() => _StampManagementScreenState();
}

class _StampManagementScreenState extends State<StampManagementScreen> {
  /// 스탬프 관리 페이지 진입 시점의 시각을 한 번만 고정 캡처하여,
  /// 90여 개 스탬프 스크롤 시 실시간 시간 업데이트로 인한 버벅임(프레임 드랍)을 방지합니다.
  late final DateTime _entryTime = TimestampThumbnail.currentMinuteTime();

  @override
  Widget build(BuildContext context) {
    final deckManager = TimestampDeckManager();

    return ListenableBuilder(
      listenable: AppSettingsService(),
      builder: (context, _) {
        final settings = AppSettingsService();
        final accentColor = settings.accentColor;

        return Scaffold(
          backgroundColor: settings.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: settings.appBarColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: settings.textColor,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              AppStrings.stampManagementTitle,
              style: TextStyle(
                color: settings.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  deckManager.resetToDefault();
                  await TimestampAccessManager().clearAllUnlocks();
                  HapticFeedback.mediumImpact();
                  messenger.hideCurrentSnackBar();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        AppStrings.favoritesResetSnackbar,
                        style: TextStyle(
                          color: settings.textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: settings.cardBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: settings.borderColor,
                          width: 1,
                        ),
                      ),
                    ),
                  );
                },
                child: Text(
                  AppStrings.reset,
                  style: TextStyle(
                    color: settings.subTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: ListenableBuilder(
            listenable: deckManager,
            builder: (context, _) {
              final deckSlots = deckManager.deckSlots;
              final filledCount = deckManager.filledCount;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // 1. 상단 Deck 섹션
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                        decoration: BoxDecoration(
                          color: settings.cardBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: settings.borderColor,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 섹션 헤더
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: settings.isLight
                                            ? Colors.black.withValues(alpha: 0.05)
                                            : Colors.white.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(
                                        Icons.star_rounded,
                                        color: accentColor,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppStrings.favoritesTitle,
                                      style: TextStyle(
                                        color: settings.textColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: settings.surfaceColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: settings.borderColor, width: 0.8),
                                  ),
                                  child: Text(
                                    '$filledCount / 8',
                                    style: TextStyle(
                                      color: settings.subTextColor,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppStrings.favoritesDesc,
                              style: TextStyle(
                                color: settings.subTextColor,
                                fontSize: 11.5,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // 8개 슬롯 (4개씩 2줄)
                            GridView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: TimestampDeckManager.maxDeckSize,
                              itemBuilder: (context, slotIndex) {
                                final design = deckSlots[slotIndex];
                                return _buildDeckSlot(
                                  context,
                                  settings: settings,
                                  slotIndex: slotIndex,
                                  design: design,
                                  onRemove: () {
                                    deckManager.removeFromSlot(slotIndex);
                                    HapticFeedback.lightImpact();
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 1-1. 배너 광고 (즐겨찾기 섹션 바로 밑)
                  const SliverToBoxAdapter(
                    child: AdBannerWidget(
                      margin: EdgeInsets.fromLTRB(18, 16, 18, 16),
                    ),
                  ),

                  // 2. 전체 스탬프 격자 목록 섹션 헤더
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.allStampsHeader,
                            style: TextStyle(
                              color: settings.textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            AppStrings.totalStampsCount(TimestampDeckManager.availableDesigns.length),
                            style: TextStyle(
                              color: settings.subTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. 전체 스탬프 격자 (한 줄에 4개씩)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final design = TimestampDeckManager.availableDesigns[index];
                          final isSelectedInDeck = deckManager.isInDeck(design);
                          final slotNumber = isSelectedInDeck
                              ? deckManager.getDeckSlotIndex(design) + 1
                              : null;

                          return _buildGridStampItem(
                            context,
                            accentColor: accentColor,
                            design: design,
                            isInDeck: isSelectedInDeck,
                            slotNumber: slotNumber,
                            onTap: () {
                              HapticFeedback.lightImpact();

                              // 이미 덱에 들어가 있는 스탬프는 누르면 덱에서 제거
                              if (isSelectedInDeck) {
                                deckManager.removeDesign(design);
                                return;
                              }

                              // 덱에 추가하려는 경우:
                              // 잠겨있는 스탬프라면 먼저 3일 광고 해금 다이얼로그 표시
                              if (!TimestampAccessManager().isUnlocked(design)) {
                                UnlockTimestampDialog.show(
                                  context,
                                  design: design,
                                  onUnlocked: () {
                                    final res = deckManager.addToDeck(design);
                                    if (!res) {
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline_rounded,
                                                color: accentColor,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  AppStrings.favoritesFullSnackbar,
                                                  style: TextStyle(
                                                    color: settings.textColor,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.35,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: settings.cardBackgroundColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: BorderSide(
                                              color: settings.borderColor,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                );
                                return;
                              }

                              final result = deckManager.toggleDeck(design);
                              if (result == null) {
                                // 덱이 꽉 참
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline_rounded,
                                          color: accentColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            AppStrings.favoritesFullSnackbar,
                                            style: TextStyle(
                                              color: settings.textColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              height: 1.35,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: settings.cardBackgroundColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: settings.borderColor,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                        childCount: TimestampDeckManager.availableDesigns.length,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.paddingOf(context).bottom + 48,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// 상단 Deck 슬롯 카드 위젯
  Widget _buildDeckSlot(
    BuildContext context, {
    required AppSettingsService settings,
    required int slotIndex,
    required TimestampDesign? design,
    required VoidCallback onRemove,
  }) {
    final slotLabel = '${slotIndex + 1}';

    if (design == null) {
      // 빈 슬롯: 네모반듯하게 직각 테두리 (화이트모드에서도 또렷한 테두리)
      return Container(
        decoration: BoxDecoration(
          color: settings.isLight ? const Color(0xFFF1F3F5) : settings.surfaceColor,
          borderRadius: BorderRadius.zero,
          border: Border.all(
            color: settings.isLight ? const Color(0xFFCBD5E1) : settings.borderColor,
            width: settings.isLight ? 1.2 : 1.0,
            style: BorderStyle.solid,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 4,
              left: 5,
              child: Text(
                slotLabel,
                style: TextStyle(
                  color: settings.isLight
                      ? const Color(0xFF94A3B8)
                      : settings.subTextColor.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Icons.add_rounded,
              color: settings.isLight
                  ? const Color(0xFF94A3B8)
                  : settings.subTextColor.withValues(alpha: 0.4),
              size: 22,
            ),
          ],
        ),
      );
    }

    // 채워진 슬롯: 라운드 없이 네모반듯하게 덱에 딱 맞게 채움 (TimestampThumbnail 자체 테두리 사용)
    return GestureDetector(
      onTap: onRemove,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 스탬프 썸네일 (여백 및 라운드 없이 슬롯 크기에 딱 맞춤, 진입 시각 고정)
          TimestampThumbnail(
            design: design,
            isSelected: false,
            onTap: onRemove,
            margin: EdgeInsets.zero,
            borderRadius: BorderRadius.zero,
            time: _entryTime,
          ),

          // 슬롯 번호 뱃지 (좌상단)
          Positioned(
            top: 2,
            left: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.zero,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 0.5,
                ),
              ),
              child: Text(
                slotLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 삭제 버튼 아이콘 (우상단)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 0.6,
                ),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white70,
                size: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 하단 전체 스탬프 격자 아이템 위젯
  Widget _buildGridStampItem(
    BuildContext context, {
    required Color accentColor,
    required TimestampDesign design,
    required bool isInDeck,
    required int? slotNumber,
    required VoidCallback onTap,
  }) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 기본 썸네일 (여백 없이 딱 맞게 표시, 진입 시각 고정)
            TimestampThumbnail(
              design: design,
              isSelected: false,
              onTap: onTap,
              margin: EdgeInsets.zero,
              borderRadius: BorderRadius.zero,
              time: _entryTime,
            ),

            // 덱에 이미 등록된 경우 음영 처리 + 체크 뱃지 오버레이
            if (isInDeck) ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.zero,
                  border: Border.all(
                    color: accentColor,
                    width: 2.0,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.black,
                        size: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${AppStrings.deckSlotPrefix} #$slotNumber',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

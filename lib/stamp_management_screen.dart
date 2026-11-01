import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/timestamp_deck_manager.dart';
import 'services/timestamp_access_manager.dart';
import 'widgets/unlock_timestamp_dialog.dart';
import 'timestamp_overlays.dart';

class StampManagementScreen extends StatelessWidget {
  const StampManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deckManager = TimestampDeckManager();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1013),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1013),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '스탬프 관리',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              deckManager.resetToDefault();
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('덱이 기본 순서로 초기화되었습니다.'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              '초기화',
              style: TextStyle(
                color: Colors.white60,
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
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16181D),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
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
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.dashboard_customize_rounded,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '타임스탬프 Deck',
                                  style: TextStyle(
                                    color: Colors.white,
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
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$filledCount / 8',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '메인에 우선 노출될 8개의 스탬프입니다. 슬롯을 탭하면 제거됩니다.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11.5,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // 8개 슬롯 (4개씩 2줄)
                        GridView.builder(
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

              // 2. 전체 스탬프 격자 목록 섹션 헤더
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '전체 스탬프 목록',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '총 ${TimestampDeckManager.availableDesigns.length}개',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. 전체 스탬프 격자 (한 줄에 4개씩)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        design: design,
                        isInDeck: isSelectedInDeck,
                        slotNumber: slotNumber,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          final result = deckManager.toggleDeck(design);
                          if (result == null) {
                            // 덱이 꽉 참
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Deck이 가득 찼습니다(최대 8개).\n상단 Deck에서 스탬프를 눌러 비운 후 추가해주세요.',
                                ),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: const Color(0xFF2A2D35),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
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

              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 상단 Deck 슬롯 카드 위젯
  Widget _buildDeckSlot(
    BuildContext context, {
    required int slotIndex,
    required TimestampDesign? design,
    required VoidCallback onRemove,
  }) {
    final slotLabel = '${slotIndex + 1}';

    if (design == null) {
      // 빈 슬롯: 네모반듯하게 직각 테두리
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.zero,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1.0,
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
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Icons.add_rounded,
              color: Colors.white.withValues(alpha: 0.25),
              size: 22,
            ),
          ],
        ),
      );
    }

    // 채워진 슬롯: 라운드 없이 네모반듯하게 덱에 딱 맞게 채움
    return GestureDetector(
      onTap: onRemove,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 스탬프 썸네일 (여백 및 라운드 없이 슬롯 크기에 딱 맞춤)
          TimestampThumbnail(
            design: design,
            isSelected: false,
            onTap: onRemove,
            margin: EdgeInsets.zero,
            borderRadius: BorderRadius.zero,
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
    required TimestampDesign design,
    required bool isInDeck,
    required int? slotNumber,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        // 잠긴 스탬프인 경우 길게 누르면 바로 3일 해금 다이얼로그 노출
        if (!TimestampAccessManager().isUnlocked(design)) {
          UnlockTimestampDialog.show(
            context,
            design: design,
            onUnlocked: () {},
          );
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 기본 썸네일 (여백 없이 딱 맞게 표시)
          TimestampThumbnail(
            design: design,
            isSelected: false,
            onTap: onTap,
            margin: EdgeInsets.zero,
            borderRadius: BorderRadius.zero,
          ),

          // 덱에 이미 등록된 경우 음영 처리 + 체크 뱃지 오버레이
          if (isInDeck) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.zero,
                border: Border.all(
                  color: const Color(0xFFC6FF00),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFC6FF00),
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
                      'Deck #$slotNumber',
                      style: const TextStyle(
                        color: Color(0xFFC6FF00),
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timenow/services/timestamp_deck_manager.dart';
import 'package:timenow/stamps/sample_stamp_renderer.dart';
import 'package:timenow/stamps/stamp_text_store.dart';
import 'package:timenow/timestamp_metadata.dart';
import 'package:timenow/timestamp_overlays.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StampTextStore().init();
  });

  test('샘플 스탬프 80종(D-day 제외)이 모든 크기 단계에서 장면을 구성할 수 있다', () {
    final sampleDesigns = TimestampDesign.values
        .where((d) => d.isSampleStamp)
        .toList();
    expect(sampleDesigns.length, 80);
    expect(sampleDesigns.any((d) => d.name.startsWith('d')), isFalse);

    final now = DateTime(2026, 11, 3, 9, 41);
    for (final d in sampleDesigns) {
      final count = SampleStampLibrary.scaleCount(d.name);
      expect(count, inInclusiveRange(1, 3), reason: d.name);
      for (var i = 0; i < count; i++) {
        for (final h in [390.0, 487.5, 693.3]) {
          final scene = SampleStampLibrary.buildScene(
            d.name,
            scaleIndex: i,
            now: now,
            canvasHeight: h,
          );
          expect(scene.elements, isNotEmpty, reason: '${d.name} scale $i');
          expect(scene.contentBounds.width, greaterThan(0), reason: d.name);
        }
      }
    }
  });

  test('D-day 그룹은 샘플 렌더러 대상이 아니다', () {
    for (var i = 1; i <= 8; i++) {
      expect(SampleStampLibrary.isSampleGroup('d$i'), isFalse);
    }
  });

  test('기존에 직접 구현된 13종은 샘플 렌더러 대상이 아니다', () {
    for (final id in SampleStampLibrary.legacyGroupIds) {
      expect(SampleStampLibrary.isSampleGroup(id), isFalse, reason: id);
    }
  });

  test('날짜 외 텍스트가 있는 모든 스탬프의 문구 영역을 탭할 수 있다', () {
    const area = Rect.fromLTWH(0, 0, 390, 390);
    Set<String> keysOf(String id, {int scaleIndex = 0}) =>
        SampleStampLibrary.buildScene(
              id,
              scaleIndex: scaleIndex,
              now: DateTime(2026, 11, 3, 12),
            )
            .editableRegions(
              area,
              alignment: Alignment.center,
              marginDesign: 16,
            )
            .map((r) => r.key)
            .toSet();

    expect(keysOf('f4', scaleIndex: 0), {'f4_txt1'});
    expect(keysOf('f4', scaleIndex: 1), {'f4_txt1'});
    expect(keysOf('f4', scaleIndex: 2), {'f4_txt1'});
    expect(keysOf('style2'), {'style2_txt1'});
    expect(keysOf('style3'), {'style3_txt1', 'style3_txt2'});
    expect(keysOf('style4'), {'style4_txt1', 'style4_txt2', 'style4_txt3'});
    expect(keysOf('style5'), {'style5_rtxt1', 'style5_txt1'});
    expect(keysOf('style6'), isEmpty);
    expect(keysOf('style7'), {'style7_txt1', 'style7_txt2', 'style7_txt3'});
    expect(keysOf('style8'), {'style8_txt1', 'style8_txt2', 'style8_rtxt1'});
    expect(keysOf('style9'), isEmpty);
    expect(keysOf('style10'), isEmpty);
    expect(keysOf('style11'), {'style11_txt1'});
  });

  test('바꾼 문구가 저장되고, 비우면 기본값으로 돌아간다', () async {
    await StampTextStore().saveAll({
      'style2_txt1': '우리집 식탁',
      'style3_txt1': '야식',
      'f4_txt1_x2': '오늘의 기록! 한강 나들이 :)',
    });
    expect(StampTextStore().customText('style2_txt1'), '우리집 식탁');
    expect(StampTextStore().customText('style3_txt1'), '야식');
    // f4 는 크기 단계(x0/x1/x2)에 관계없이 같은 문구를 공유
    expect(StampTextStore().customText('f4_txt1_x0'), '오늘의 기록! 한강 나들이 :)');
    expect(StampTextStore().customText('f4_txt1'), '오늘의 기록! 한강 나들이 :)');

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString('timenow_stamp_custom_texts_v1'),
      contains('우리집 식탁'),
    );

    await StampTextStore().saveAll({
      'style2_txt1': '  ',
      'style3_txt1': '',
      'f4_txt1': '',
    });
    expect(StampTextStore().customText('style2_txt1'), isNull);
    expect(StampTextStore().customText('style3_txt1'), isNull);
    expect(StampTextStore().customText('f4_txt1'), isNull);

    // 기본 문구와 같게 입력해도 기본값 취급
    await StampTextStore().saveAll({'style4_txt1': 'Good'});
    expect(StampTextStore().customText('style4_txt1'), isNull);
  });

  test('긴 문구로 바꿔도 사진 폭(390) 밖으로 나가지 않는다', () async {
    await StampTextStore().saveAll({
      'f4_txt1': '오늘 친구들과 함께 한강 공원에서 즐거운 피크닉 시간을 보냈다!',
      'style2_txt1':
          'A very very long caption that would overflow the photo width',
      'style4_txt1': 'Good afternoon everyone, have a nice day',
      'style4_txt3': '우리가 함께 기록한 소중한 날,',
      'style5_rtxt1':
          'Every moment is a fresh beginning and full of possibilities',
      'style5_txt1': 'Wonderful Sunday Morning Vibes With Coffee',
      'style7_txt1': '별이 아름다운 이유는 보이지 않는 꽃이 있기 때문이다',
      'style7_txt3': '오늘 읽은 책 한 구절 기록하기',
      'style8_txt1': '오늘의 아침 러닝',
      'style8_txt2': '오운완 성공!',
      'style8_rtxt1': 'Every single day workout activity record',
      'style11_txt1': '일요일 아침 홈카페 브런치 플레이트',
    });
    for (final id in [
      'f4',
      'style2',
      'style4',
      'style5',
      'style7',
      'style8',
      'style11',
    ]) {
      final scene = SampleStampLibrary.buildScene(
        id,
        scaleIndex: 0,
        now: DateTime(2026, 11, 3, 12),
      );
      final regions = scene.editableRegions(
        const Rect.fromLTWH(0, 0, 390, 390),
        alignment: Alignment.center,
        marginDesign: 16,
      );
      for (final r in regions) {
        expect(r.rect.left, greaterThanOrEqualTo(0), reason: '$id ${r.key}');
        expect(r.rect.right, lessThanOrEqualTo(390), reason: '$id ${r.key}');
      }
    }
  });

  test('위치 및 크기 조정 지원 여부가 스탬프 특성에 맞게 판단된다', () {
    // style1은 위치·크기 조정 모두 활성화
    expect(TimestampMetadata.supportsAlignment(TimestampDesign.style1), isTrue);
    expect(TimestampMetadata.supportsFontSize(TimestampDesign.style1), isTrue);

    // style2, style3, style4, style5, style7, style9는 크기 조정(3단계)만 활성화
    for (final d in [
      TimestampDesign.style2,
      TimestampDesign.style3,
      TimestampDesign.style4,
      TimestampDesign.style5,
      TimestampDesign.style7,
      TimestampDesign.style9,
    ]) {
      expect(TimestampMetadata.supportsAlignment(d), isFalse, reason: d.name);
      expect(TimestampMetadata.supportsFontSize(d), isTrue, reason: d.name);
      expect(TimestampMetadata.getFontSizeSteps(d).length, 3, reason: d.name);
    }

    // style8은 위치 조정(위/가운데/아래)만 활성화
    expect(TimestampMetadata.supportsAlignment(TimestampDesign.style8), isTrue);
    expect(TimestampMetadata.supportsFontSize(TimestampDesign.style8), isFalse);
    expect(
      TimestampMetadata.getSupportedAlignments(TimestampDesign.style8),
      equals(const [
        Alignment.center,
        Alignment.topCenter,
        Alignment.bottomCenter,
      ]),
    );

    // 나머지 스타일 스탬프(style6, style10, style11)는 위치·크기 조정 모두 비활성화
    for (final d in [
      TimestampDesign.style6,
      TimestampDesign.style10,
      TimestampDesign.style11,
    ]) {
      expect(TimestampMetadata.supportsAlignment(d), isFalse, reason: d.name);
      expect(TimestampMetadata.supportsFontSize(d), isFalse, reason: d.name);
    }

    // 프레임 스탬프(f1~f9)는 위치 조정은 비활성화, 크기 조정(3단계)은 활성화
    expect(TimestampMetadata.supportsAlignment(TimestampDesign.f1), isFalse);
    expect(TimestampMetadata.supportsFontSize(TimestampDesign.f1), isTrue);

    // 스탬프 없음(none)은 위치·크기 조정 모두 비활성화
    expect(TimestampMetadata.supportsAlignment(TimestampDesign.none), isFalse);
    expect(TimestampMetadata.supportsFontSize(TimestampDesign.none), isFalse);

    // 일반/스탬프/아날로그 3단계 스탬프는 위치·크기 조정 모두 활성화
    expect(TimestampMetadata.supportsAlignment(TimestampDesign.n1_1), isTrue);
    expect(TimestampMetadata.supportsFontSize(TimestampDesign.n1_1), isTrue);
  });

  test('날짜·요일·월 이름 길이가 달라도 style4 하단 문구 및 다중 요소 스탬프 정렬이 유지된다', () async {
    final testDates = [
      DateTime(2026, 5, 1, 1, 11), // 짧은 월(May), 좁은 숫자(01:11), 금요일(Friday)
      DateTime(
        2026,
        9,
        30,
        8,
        48,
      ), // 긴 월(September), 넓은 숫자(08:48), 수요일(Wednesday)
      DateTime(2026, 11, 23, 12, 5), // 월요일(Monday)
    ];

    for (final d in testDates) {
      // 1) style4: 하단 "Recorded in <MMMM dd, yyyy>" 전체 가로 중심이 항상 195.0
      final style4Scene = SampleStampLibrary.buildScene(
        'style4',
        scaleIndex: 0,
        now: d,
      );
      final bottomBounds = style4Scene.elements
          .where((e) => e.bounds.top >= 330)
          .map((e) => e.bounds)
          .reduce((a, b) => a.expandToInclude(b));
      expect(bottomBounds.center.dx, closeTo(kSampleBaseWidth / 2, 0.01));

      // 2) s1_10: 양옆 꽃 장식을 포함한 전체 가로 중심이 모든 크기 단계에서 195.0
      for (var s = 0; s < 3; s++) {
        final s110Scene = SampleStampLibrary.buildScene(
          's1_10',
          scaleIndex: s,
          now: d,
        );
        expect(
          s110Scene.contentBounds.center.dx,
          closeTo(kSampleBaseWidth / 2, 0.01),
        );
      }

      // 3) n1_16, n1_17, n2_6, n2_8, n2_9, n3_5:
      //    왼쪽(또는 기본) 위치에서는 왼쪽 끝이 일치하고, 오른쪽 위치에서는 오른쪽 끝이 일치
      for (final groupId in [
        'n1_16',
        'n1_17',
        'n2_6',
        'n2_8',
        'n2_9',
        'n3_5',
      ]) {
        for (var s = 0; s < 3; s++) {
          final leftScene = SampleStampLibrary.buildScene(
            groupId,
            scaleIndex: s,
            now: d,
            alignment: Alignment.bottomLeft,
          );
          final firstLeft = leftScene.elements.first.bounds.left;
          for (final e in leftScene.elements) {
            expect(
              e.bounds.left,
              closeTo(firstLeft, 0.01),
              reason: '$groupId left s=$s',
            );
          }

          final rightScene = SampleStampLibrary.buildScene(
            groupId,
            scaleIndex: s,
            now: d,
            alignment: Alignment.bottomRight,
          );
          final firstRight = rightScene.elements.first.bounds.right;
          for (final e in rightScene.elements) {
            expect(
              e.bounds.right,
              closeTo(firstRight, 0.01),
              reason: '$groupId right s=$s',
            );
          }
        }
      }

      // 4) n2_7: 상단 날짜("yyyy.MM.dd (E)")와 하단 시간("a hh:mm")이 모든 배율에서 항상 가운데 정렬 유지
      for (var s = 0; s < 3; s++) {
        final n27Scene = SampleStampLibrary.buildScene(
          'n2_7',
          scaleIndex: s,
          now: d,
        );
        expect(n27Scene.elements.length, 2);
        expect(
          n27Scene.elements[0].bounds.center.dx,
          closeTo(n27Scene.elements[1].bounds.center.dx, 0.01),
        );
      }

      // 5) s1_8: 밑줄(1자 막대)은 항상 가로 중앙(195.0) 고정, 타임스탬프만 좌/가운데/우 위치에 따라 정렬
      for (var s = 0; s < 3; s++) {
        final s18Left = SampleStampLibrary.buildScene(
          's1_8',
          scaleIndex: s,
          now: d,
          alignment: Alignment.bottomLeft,
        );
        expect(s18Left.lockHorizontalCenter, isTrue);
        expect(
          s18Left.elements[1].bounds.center.dx,
          closeTo(kSampleBaseWidth / 2, 0.01),
        );
        expect(
          s18Left.elements[0].bounds.left,
          closeTo(s18Left.elements[1].bounds.left, 0.01),
        );

        final s18Center = SampleStampLibrary.buildScene(
          's1_8',
          scaleIndex: s,
          now: d,
          alignment: Alignment.bottomCenter,
        );
        expect(s18Center.lockHorizontalCenter, isTrue);
        expect(
          s18Center.elements[1].bounds.center.dx,
          closeTo(kSampleBaseWidth / 2, 0.01),
        );
        expect(
          s18Center.elements[0].bounds.center.dx,
          closeTo(s18Center.elements[1].bounds.center.dx, 0.01),
        );

        final s18Right = SampleStampLibrary.buildScene(
          's1_8',
          scaleIndex: s,
          now: d,
          alignment: Alignment.bottomRight,
        );
        expect(s18Right.lockHorizontalCenter, isTrue);
        expect(
          s18Right.elements[1].bounds.center.dx,
          closeTo(kSampleBaseWidth / 2, 0.01),
        );
        expect(
          s18Right.elements[0].bounds.right,
          closeTo(s18Right.elements[1].bounds.right, 0.01),
        );
      }
    }

    // style4 의 Recorded in 문구를 사용자가 변경해도 전체 하단 문장의 중심은 항상 195.0
    await StampTextStore().saveAll({'style4_txt3': 'Taken on'});
    final customStyle4 = SampleStampLibrary.buildScene(
      'style4',
      scaleIndex: 0,
      now: DateTime(2026, 9, 30, 8, 48),
    );
    final customBottom = customStyle4.elements
        .where((e) => e.bounds.top >= 330)
        .map((e) => e.bounds)
        .reduce((a, b) => a.expandToInclude(b));
    expect(customBottom.center.dx, closeTo(kSampleBaseWidth / 2, 0.01));
  });

  test('홈화면 타임스탬프 목록은 최대 8개이며 빈 즐겨찾기 슬롯만큼 전체 목록에서 채운다', () async {
    final deck = TimestampDeckManager();
    await deck.init();

    // 1) 기본 즐겨찾기 8개가 모두 차 있을 때: 즐겨찾기 8개가 그대로 반환됨
    final full = deck.getMainScreenDesigns();
    expect(full.length, 8);
    expect(full, deck.deckSlots.whereType<TimestampDesign>().toList());

    // 2) 즐겨찾기를 모두 비웠을 때: 전체 스탬프 목록 앞에서부터 8개를 채워 반환함
    for (var i = 0; i < TimestampDeckManager.maxDeckSize; i++) {
      deck.removeFromSlot(i);
    }
    expect(deck.filledCount, 0);
    final fromAll = deck.getMainScreenDesigns();
    expect(fromAll.length, 8);
    expect(fromAll, TimestampDeckManager.availableDesigns.take(8).toList());

    // 3) 즐겨찾기에 2개만 등록했을 때: 등록한 2개 + 전체 목록에서 중복 없이 6개 = 총 8개
    deck.addToDeck(TimestampDesign.style4);
    deck.addToDeck(TimestampDesign.f1);
    final mixed = deck.getMainScreenDesigns();
    expect(mixed.length, 8);
    expect(mixed[0], TimestampDesign.style4);
    expect(mixed[1], TimestampDesign.f1);
  });

  test('n1_11 3A 를 포함한 모든 스탬프가 배율(1A/2A/3A) 및 긴 날짜에서도 다음 줄로 넘어가지 않는다', () {
    final longDates = [
      DateTime(2026, 9, 30, 23, 48), // September, Wednesday
      DateTime(2026, 11, 25, 23, 21), // November, Wednesday
    ];

    for (final d in longDates) {
      final s0 = SampleStampLibrary.buildScene('n1_11', scaleIndex: 0, now: d);
      final s1 = SampleStampLibrary.buildScene('n1_11', scaleIndex: 1, now: d);
      final s2 = SampleStampLibrary.buildScene('n1_11', scaleIndex: 2, now: d);

      // 3A(scaleIndex: 2, fontSize: 32)에서도 절대 2줄로 줄바꿈되지 않아야 함 (1줄 높이 유지)
      expect(s0.contentBounds.height, lessThan(30));
      expect(s1.contentBounds.height, lessThan(36));
      expect(s2.contentBounds.height, lessThan(42));
    }
  });

  test('s1_4, s1_10, s1_11, s1_12 는 가로 중앙 고정이며 위/가운데/아래만 위치 변경된다', () {
    const verticalOnlyDesigns = [
      TimestampDesign.s1_4,
      TimestampDesign.s1_10,
      TimestampDesign.s1_11,
      TimestampDesign.s1_12,
    ];

    for (final design in verticalOnlyDesigns) {
      expect(
        TimestampMetadata.getSupportedAlignments(design),
        equals(const [
          Alignment.center,
          Alignment.topCenter,
          Alignment.bottomCenter,
        ]),
      );

      // 위치 순환 검증: center -> topCenter -> bottomCenter -> center
      final next1 = TimestampMetadata.nextAlignment(design, Alignment.center);
      final next2 = TimestampMetadata.nextAlignment(design, next1);
      final next3 = TimestampMetadata.nextAlignment(design, next2);
      expect(next1, Alignment.topCenter);
      expect(next2, Alignment.bottomCenter);
      expect(next3, Alignment.center);

      // 좌/우 정렬 상태에서 전환되더라도 normalize 되어 수직 중앙 정렬로만 순환
      final fromLeft = TimestampMetadata.nextAlignment(
        design,
        Alignment.bottomLeft,
      );
      expect(fromLeft, Alignment.center);

      // 씬 렌더링 시 가로 중앙 고정이 활성화되어 있는지 확인
      final scene = SampleStampLibrary.buildScene(
        design.name,
        scaleIndex: 1,
        now: DateTime(2026, 9, 30, 8, 48),
        alignment: Alignment.topRight,
      );
      expect(scene.lockHorizontalCenter, isTrue);
      expect(scene.contentBounds.center.dx, closeTo(kSampleBaseWidth / 2, 0.5));
    }
  });

  test('s2_5, s2_6, s3_3, s3_4, s3_5, s3_6 은 1A~3A 모두 축소된 크기로 균형 있게 렌더링된다', () {
    const scaledGroups = ['s2_5', 's2_6', 's3_3', 's3_4', 's3_5', 's3_6'];
    final now = DateTime(2026, 9, 30, 8, 48);

    for (final id in scaledGroups) {
      expect(SampleStampLibrary.groupSizeScale[id], lessThan(1.0));
      final s0 = SampleStampLibrary.buildScene(id, scaleIndex: 0, now: now);
      final s1 = SampleStampLibrary.buildScene(id, scaleIndex: 1, now: now);
      final s2 = SampleStampLibrary.buildScene(id, scaleIndex: 2, now: now);

      // 1A < 2A < 3A 단계별 크기 증가 유지 및 가로 중앙 정렬 유지
      expect(s0.contentBounds.width, lessThan(s1.contentBounds.width));
      expect(s1.contentBounds.width, lessThan(s2.contentBounds.width));
      expect(s0.contentBounds.height, lessThan(s1.contentBounds.height));
      expect(s1.contentBounds.height, lessThan(s2.contentBounds.height));
      expect(s0.contentBounds.center.dx, closeTo(kSampleBaseWidth / 2, 0.5));
      expect(s1.contentBounds.center.dx, closeTo(kSampleBaseWidth / 2, 0.5));
      expect(s2.contentBounds.center.dx, closeTo(kSampleBaseWidth / 2, 0.5));
    }
  });

  test(
    'style4 는 4:5, 9:16 비율에서도 상단 글자와 시간 간격을 1:1과 동일하게 유지하며 3단계 크기 변경이 가능하다',
    () {
      final now = DateTime(2026, 9, 30, 8, 48);
      for (var s = 0; s < 3; s++) {
        final scene1x1 = SampleStampLibrary.buildScene(
          'style4',
          scaleIndex: s,
          now: now,
          canvasHeight: 390.0,
        );
        final scene4x5 = SampleStampLibrary.buildScene(
          'style4',
          scaleIndex: s,
          now: now,
          canvasHeight: 487.5,
        );
        final scene9x16 = SampleStampLibrary.buildScene(
          'style4',
          scaleIndex: s,
          now: now,
          canvasHeight: 693.3,
        );

        // 상단 요소들(Good, Morning., hh:mm, a)의 y 좌표가 1:1, 4:5, 9:16 모두 동일
        final top1x1 = scene1x1.elements
            .where((e) => e.bounds.top < 260)
            .toList();
        final top4x5 = scene4x5.elements
            .where((e) => e.bounds.top < 260)
            .toList();
        final top9x16 = scene9x16.elements
            .where((e) => e.bounds.top < 260)
            .toList();
        expect(top1x1.length, 4);
        expect(top4x5.length, 4);
        expect(top9x16.length, 4);
        for (var i = 0; i < 4; i++) {
          expect(top4x5[i].bounds.top, closeTo(top1x1[i].bounds.top, 0.01));
          expect(top9x16[i].bounds.top, closeTo(top1x1[i].bounds.top, 0.01));
        }
      }
    },
  );

  test('style8 은 위, 가운데, 아래 3단계로만 세로 위치가 변경된다', () {
    final now = DateTime(2026, 9, 30, 8, 48);
    final topScene = SampleStampLibrary.buildScene(
      'style8',
      scaleIndex: 0,
      now: now,
      canvasHeight: 487.5,
      alignment: Alignment.topCenter,
    );
    final centerScene = SampleStampLibrary.buildScene(
      'style8',
      scaleIndex: 0,
      now: now,
      canvasHeight: 487.5,
      alignment: Alignment.center,
    );
    final bottomScene = SampleStampLibrary.buildScene(
      'style8',
      scaleIndex: 0,
      now: now,
      canvasHeight: 487.5,
      alignment: Alignment.bottomCenter,
    );

    expect(topScene.contentBounds.top, lessThan(centerScene.contentBounds.top));
    expect(
      centerScene.contentBounds.top,
      lessThan(bottomScene.contentBounds.top),
    );
    expect(
      topScene.contentBounds.left,
      closeTo(centerScene.contentBounds.left, 0.01),
    );
    expect(
      centerScene.contentBounds.left,
      closeTo(bottomScene.contentBounds.left, 0.01),
    );
  });
}

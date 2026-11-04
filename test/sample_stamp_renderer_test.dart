import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final sampleDesigns =
        TimestampDesign.values.where((d) => d.isSampleStamp).toList();
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
    Set<String> keysOf(String id, {int scaleIndex = 0}) => SampleStampLibrary.buildScene(
          id,
          scaleIndex: scaleIndex,
          now: DateTime(2026, 11, 3, 12),
        )
        .editableRegions(area, alignment: Alignment.center, marginDesign: 16)
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
    expect(keysOf('style11'), {
      'style11_txt1',
      'style11_txt2',
      'style11_txt3',
      'style11_txt4',
      'style11_txt5',
    });
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
    expect(prefs.getString('timenow_stamp_custom_texts_v1'), contains('우리집 식탁'));

    await StampTextStore().saveAll({'style2_txt1': '  ', 'style3_txt1': '', 'f4_txt1': ''});
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
      'style2_txt1': 'A very very long caption that would overflow the photo width',
      'style4_txt1': 'Good afternoon everyone, have a nice day',
      'style4_txt3': '우리가 함께 기록한 소중한 날,',
      'style5_rtxt1': 'Every moment is a fresh beginning and full of possibilities',
      'style5_txt1': 'Wonderful Sunday Morning Vibes With Coffee',
      'style7_txt1': '별이 아름다운 이유는 보이지 않는 꽃이 있기 때문이다',
      'style7_txt3': '오늘 읽은 책 한 구절 기록하기',
      'style8_txt1': '오늘의 아침 러닝',
      'style8_txt2': '오운완 성공!',
      'style8_rtxt1': 'Every single day workout activity record',
      'style11_txt1': '일요일 아침 홈카페 브런치 플레이트',
    });
    for (final id in ['f4', 'style2', 'style4', 'style5', 'style7', 'style8', 'style11']) {
      final scene = SampleStampLibrary.buildScene(id, scaleIndex: 0, now: DateTime(2026, 11, 3, 12));
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
    // 스타일 스탬프(style1~style11)는 위치·크기 조정 모두 비활성화
    for (final d in [
      TimestampDesign.style1,
      TimestampDesign.style2,
      TimestampDesign.style3,
      TimestampDesign.style4,
      TimestampDesign.style5,
      TimestampDesign.style6,
      TimestampDesign.style7,
      TimestampDesign.style8,
      TimestampDesign.style9,
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
      DateTime(2026, 9, 30, 8, 48), // 긴 월(September), 넓은 숫자(08:48), 수요일(Wednesday)
      DateTime(2026, 11, 23, 12, 5), // 월요일(Monday)
    ];

    for (final d in testDates) {
      // 1) style4: 하단 "Recorded in <MMMM dd, yyyy>" 전체 가로 중심이 항상 195.0
      final style4Scene = SampleStampLibrary.buildScene('style4', scaleIndex: 0, now: d);
      final bottomBounds = style4Scene.elements
          .where((e) => e.bounds.top >= 330)
          .map((e) => e.bounds)
          .reduce((a, b) => a.expandToInclude(b));
      expect(bottomBounds.center.dx, closeTo(kSampleBaseWidth / 2, 0.01));

      // 2) s1_10: 양옆 꽃 장식을 포함한 전체 가로 중심이 모든 크기 단계에서 195.0
      for (var s = 0; s < 3; s++) {
        final s110Scene = SampleStampLibrary.buildScene('s1_10', scaleIndex: s, now: d);
        expect(s110Scene.contentBounds.center.dx, closeTo(kSampleBaseWidth / 2, 0.01));
      }

      // 3) n1_17: 상단 "EEEE a hh:mm" 과 하단 "yyyy.MM.dd" 의 오른쪽 끝이 일치
      for (var s = 0; s < 3; s++) {
        final n117Scene = SampleStampLibrary.buildScene('n1_17', scaleIndex: s, now: d);
        expect(n117Scene.elements.length, 2);
        expect(
          n117Scene.elements[1].bounds.right,
          closeTo(n117Scene.elements[0].bounds.right, 0.01),
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
}

// GENERATED FILE - DO NOT EDIT BY HAND.
// 원본: timestamp_sample/now/lib/repo/TimestampRepository.dart (saveTemp* 메서드, 한국어 로케일)
// 생성기: tool/gen_sample_stamps.py
//
// 샘플 앱의 스탬프 좌표/폰트/크기 정의를 한 글자도 바꾸지 않고 그대로 옮긴 데이터입니다.
// (영어 로케일 분기만 제거, ratio 는 1.0 고정 → 390 기준 디자인 좌표)
//
// ignore_for_file: non_constant_identifier_names, prefer_const_declarations, unused_local_variable, prefer_interpolation_to_compose_strings, unnecessary_brace_in_string_interps, prefer_final_locals, omit_local_variable_types, curly_braces_in_flow_control_structures
import 'dart:math';

import 'sample_stamp_compat.dart';
import 'sample_stamp_entities.dart';

class SampleStampRepository {
  static final SampleBox<TextEntity> textBox = SampleBox<TextEntity>();
  static final SampleBox<RoundTextEntity> roundTextBox = SampleBox<RoundTextEntity>();
  static final SampleBox<TimestampEntity> timestampBox = SampleBox<TimestampEntity>();
  static final SampleBox<ImageEntity> timestampImageBox = SampleBox<ImageEntity>();
  static final SampleBox<TimestampGroupEntity> timestampGroupBox = SampleBox<TimestampGroupEntity>();
  static final SampleBox<AnalogTimestampEntity> analogTimestampBox = SampleBox<AnalogTimestampEntity>();
  static final SampleBox<DdayTimestampEntity> ddayTimestampBox = SampleBox<DdayTimestampEntity>();
  static final SampleBox<StyleTimestampEntity> styleTimestampBox = SampleBox<StyleTimestampEntity>();

  static bool _loaded = false;

  /// 샘플 앱의 초기 데이터 적재 순서를 그대로 따라 메모리에 적재합니다.
  static void ensureLoaded() {
    if (_loaded) return;
    _loaded = true;
    saveTempNormal();
    saveTempStamp();
    saveTempFrame();
    saveTempAnalog();
    saveTempDday();
    saveTempStyle();
  }

  static void saveTempNormal() {
    // 원본: ratio = logicalWidth / 390. 이 앱에서는 렌더러가 390 기준 스케일을 적용합니다.
    const double ratio = 1.0;

    TimestampGroupEntity n1_1 = TimestampGroupEntity("n1_1", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n1_1.png", null, Colors.black.value, 1);
    TimestampEntity n1_1_t1_x0 = TimestampEntity.init(ratio, "n1_1_t1_x0", "n1_1", "rubber_nipple_factory", "yyyy.MM.dd a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 55, 170, 280, 50, 22, null, 0);
    TimestampEntity n1_1_t1_x1 = TimestampEntity.init(ratio, "n1_1_t1_x1", "n1_1", "rubber_nipple_factory", "yyyy.MM.dd a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 42.5, 170, 305, 50, 25, null, 1);
    TimestampEntity n1_1_t1_x2 = TimestampEntity.init(ratio, "n1_1_t1_x2", "n1_1", "rubber_nipple_factory", "yyyy.MM.dd a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 30, 170, 330, 50, 28, null, 2);

    TimestampGroupEntity n1_2 = TimestampGroupEntity("n1_2", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n1_2.png", null, Colors.black.value, 4);
    TimestampEntity n1_2_t1_x0 = TimestampEntity.init(ratio, "n1_2_t1_x0", "n1_2", "nixie_one", "yyyy/MM/dd a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 10, 230, 40, 21, null, 0);
    TimestampEntity n1_2_t1_x1 = TimestampEntity.init(ratio, "n1_2_t1_x1", "n1_2", "nixie_one", "yyyy/MM/dd a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 11, 270, 40, 25, null, 1);
    TimestampEntity n1_2_t1_x2 = TimestampEntity.init(ratio, "n1_2_t1_x2", "n1_2", "nixie_one", "yyyy/MM/dd a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 12, 310, 40, 29, null, 2);

    TimestampGroupEntity n1_3 = TimestampGroupEntity("n1_3", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/en/n1_3.png", null, Colors.black.value, 5);
    TimestampEntity n1_3_t1_x0 = TimestampEntity.init(ratio, "n1_3_t1_x0", "n1_3", "kangwon_all_study", "yyyy/MM/dd HH:mm", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 170, 345, 200, 40, 24, null, 0);
    TimestampEntity n1_3_t1_x1 = TimestampEntity.init(ratio, "n1_3_t1_x1", "n1_3", "kangwon_all_study", "yyyy/MM/dd HH:mm", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 125, 342.5, 245, 40, 30, null, 1);
    TimestampEntity n1_3_t1_x2 = TimestampEntity.init(ratio, "n1_3_t1_x2", "n1_3", "kangwon_all_study", "yyyy/MM/dd HH:mm", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 80, 340, 290, 40, 36, null, 2);

    TimestampGroupEntity n1_4 = TimestampGroupEntity("n1_4", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n1_4.png", null, Colors.black.value, 8);
    TimestampEntity n1_4_t1_x0 = TimestampEntity.init(ratio, "n1_4_t1_x0", "n1_4", "tvn_fun_story", "a hh:mm MMMM dd, yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 70, 170, 250, 50, 32, null, 0);
    TimestampEntity n1_4_t1_x1 = TimestampEntity.init(ratio, "n1_4_t1_x1", "n1_4", "tvn_fun_story", "a hh:mm MMMM dd, yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 50, 170, 290, 50, 36, null, 1);
    TimestampEntity n1_4_t1_x2 = TimestampEntity.init(ratio, "n1_4_t1_x2", "n1_4", "tvn_fun_story", "a hh:mm MMMM dd, yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 30, 170, 330, 50, 40, null, 2);

    TimestampGroupEntity n1_5 = TimestampGroupEntity("n1_5", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n1_5.png", null, Colors.black.value, 9);
    TimestampEntity n1_5_t1_x0 = TimestampEntity.init(ratio, "n1_5_t1_x0", "n1_5", "lee_seoyun", "yyyy/MM/dd (E) a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR, 20, 339, 240, 40, 19, RegexUtil.TYPE_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 0);
    TimestampEntity n1_5_t1_x1 = TimestampEntity.init(ratio, "n1_5_t1_x1", "n1_5", "lee_seoyun", "yyyy/MM/dd (E) a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR, 20, 338, 280, 40, 22, RegexUtil.TYPE_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 1);
    TimestampEntity n1_5_t1_x2 = TimestampEntity.init(ratio, "n1_5_t1_x2", "n1_5", "lee_seoyun", "yyyy/MM/dd (E) a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR, 20, 337, 320, 40, 25, RegexUtil.TYPE_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 2);

    TimestampGroupEntity n1_6 = TimestampGroupEntity("n1_6", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n1_6.png", null, Colors.black.value, 12);
    TimestampEntity n1_6_t1_x0 = TimestampEntity.init(ratio, "n1_6_t1_x0", "n1_6", "nanum_mago", "yyyy/MM/dd (E) a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 65, 340, 260, 40, 30, RegexUtil.TYPE_DAY_TO_KR, 0);
    TimestampEntity n1_6_t1_x1 = TimestampEntity.init(ratio, "n1_6_t1_x1", "n1_6", "nanum_mago", "yyyy/MM/dd (E) a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 50, 339, 290, 40, 36, RegexUtil.TYPE_DAY_TO_KR, 1);
    TimestampEntity n1_6_t1_x2 = TimestampEntity.init(ratio, "n1_6_t1_x2", "n1_6", "nanum_mago", "yyyy/MM/dd (E) a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 35, 338, 320, 40, 42, RegexUtil.TYPE_DAY_TO_KR, 2);

    TimestampGroupEntity n1_7 = TimestampGroupEntity("n1_7", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n1_7.png", null, Colors.black.value, 13);
    TimestampEntity n1_7_t1_x0 = TimestampEntity.initWithFontWeight(ratio, "n1_7_t1_x0", "n1_7", "gmarket_sans", "HH:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 170, 165, 120, 60, 38, null, "w900", 0);
    TimestampEntity n1_7_t2_x0 = TimestampEntity.init(ratio, "n1_7_t2_x0", "n1_7", "gmarket_sans", "yyyy", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 115, 171, 50, 30, 14, null, 0);
    TimestampEntity n1_7_t3_x0 = TimestampEntity.init(ratio, "n1_7_t3_x0", "n1_7", "gmarket_sans", "MM/dd", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 115, 189, 50, 30, 14, null, 0);
    TimestampEntity n1_7_t1_x1 = TimestampEntity.initWithFontWeight(ratio, "n1_7_t1_x1", "n1_7", "gmarket_sans", "HH:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 160, 165, 145, 60, 48, null, "w900", 1);
    TimestampEntity n1_7_t2_x1 = TimestampEntity.init(ratio, "n1_7_t2_x1", "n1_7", "gmarket_sans", "yyyy", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 100, 169, 55, 30, 18, null, 1);
    TimestampEntity n1_7_t3_x1 = TimestampEntity.init(ratio, "n1_7_t3_x1", "n1_7", "gmarket_sans", "MM/dd", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 95, 191, 60, 30, 18, null, 1);
    TimestampEntity n1_7_t1_x2 = TimestampEntity.initWithFontWeight(ratio, "n1_7_t1_x2", "n1_7", "gmarket_sans", "HH:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 150, 165, 170, 60, 58, null, "w900", 2);
    TimestampEntity n1_7_t2_x2 = TimestampEntity.init(ratio, "n1_7_t2_x2", "n1_7", "gmarket_sans", "yyyy", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 85, 167, 60, 30, 22, null, 2);
    TimestampEntity n1_7_t3_x2 = TimestampEntity.init(ratio, "n1_7_t3_x2", "n1_7", "gmarket_sans", "MM/dd", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 75, 193, 70, 30, 22, null, 2);


    TimestampGroupEntity n1_8 = TimestampGroupEntity("n1_8", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n1_8.png", null, Colors.black.value, 16);
    TimestampEntity n1_8_t1_x0 = TimestampEntity.init(ratio, "n1_8_t1_x0", "n1_8", "datcub", "E hh:mma yy.MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 45, 345, 300, 40, 24, null, 0);
    TimestampEntity n1_8_t1_x1 = TimestampEntity.init(ratio, "n1_8_t1_x1", "n1_8", "datcub", "E hh:mma yy.MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 37.5, 343, 315, 40, 27, null, 1);
    TimestampEntity n1_8_t1_x2 = TimestampEntity.init(ratio, "n1_8_t1_x2", "n1_8", "datcub", "E hh:mma yy.MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 30, 341, 330, 40, 30, null, 2);

    TimestampGroupEntity n1_9 = TimestampGroupEntity("n1_9", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n1_9.png", null, Colors.black.value, 17);
    TimestampEntity n1_9_t1_x0 = TimestampEntity.init(ratio, "n1_9_t1_x0", "n1_9", "e1234", "yyyy-MM-d HH:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 55, 345, 280, 40, 19, null, 0);
    TimestampEntity n1_9_t1_x1 = TimestampEntity.init(ratio, "n1_9_t1_x1", "n1_9", "e1234", "yyyy-MM-d HH:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 45, 344, 300, 40, 22, null, 1);
    TimestampEntity n1_9_t1_x2 = TimestampEntity.init(ratio, "n1_9_t1_x2", "n1_9", "e1234", "yyyy-MM-d HH:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 35, 343, 320, 40, 25, null, 2);

    TimestampGroupEntity n1_10 = TimestampGroupEntity("n1_10", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n1_10.png", null, Colors.black.value, 20);
    TimestampEntity n1_10_t1_x0 = TimestampEntity.init(ratio, "n1_10_t1_x0", "n1_10", "bebas_neue", "hh:mm", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 99, 168, 120, 60, 60, null, 0);
    TimestampEntity n1_10_t3_x0 = TimestampEntity.init(ratio, "n1_10_t3_x0", "n1_10", "bebas_neue", "a EEE", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 225, 163, 80, 40, 24, null, 0);
    TimestampEntity n1_10_t2_x0 = TimestampEntity.init(ratio, "n1_10_t2_x0", "n1_10", "bebas_neue", "MMM dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 225, 187, 80, 40, 24, null, 0);
    TimestampEntity n1_10_t1_x1 = TimestampEntity.init(ratio, "n1_10_t1_x1", "n1_10", "bebas_neue", "hh:mm", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 81, 168, 140, 60, 72, null, 1);
    TimestampEntity n1_10_t3_x1 = TimestampEntity.init(ratio, "n1_10_t3_x1", "n1_10", "bebas_neue", "a EEE", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 226, 158.5, 80, 45, 31, null, 1);
    TimestampEntity n1_10_t2_x1 = TimestampEntity.init(ratio, "n1_10_t2_x1", "n1_10", "bebas_neue", "MMM dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 226, 186.5, 80, 45, 31, null, 1);
    TimestampEntity n1_10_t1_x2 = TimestampEntity.init(ratio, "n1_10_t1_x2", "n1_10", "bebas_neue", "hh:mm", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 86, 158, 140, 80, 85, null, 2);
    TimestampEntity n1_10_t3_x2 = TimestampEntity.init(ratio, "n1_10_t3_x2", "n1_10", "bebas_neue", "a EEE", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 231, 153, 90, 50, 38, null, 2);
    TimestampEntity n1_10_t2_x2 = TimestampEntity.init(ratio, "n1_10_t2_x2", "n1_10", "bebas_neue", "MMM dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 231, 186, 90, 50, 38, null, 2);


    TimestampGroupEntity n1_11 = TimestampGroupEntity("n1_11", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n1_11.png", null, Colors.black.value, 21);
    TimestampEntity n1_11_t1_x0 = TimestampEntity.init(ratio, "n1_11_t1_x0", "n1_11", "dita_sweet", "hh:mm a. MMMM dd. yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 55, 170, 280, 50, 24, null, 0);
    TimestampEntity n1_11_t1_x1 = TimestampEntity.init(ratio, "n1_11_t1_x1", "n1_11", "dita_sweet", "hh:mm a. MMMM dd. yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 35, 170, 320, 50, 28, null, 1);
    TimestampEntity n1_11_t1_x2 = TimestampEntity.init(ratio, "n1_11_t1_x2", "n1_11", "dita_sweet", "hh:mm a. MMMM dd. yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 20, 170, 350, 50, 32, null, 2);

    TimestampGroupEntity n1_12 = TimestampGroupEntity("n1_12", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n1_12.png", null, Colors.black.value, 24);
    TimestampEntity n1_12_t1_x0 = TimestampEntity.init(ratio, "n1_12_t1_x0", "n1_12", "nanum_yuni_ddingddang", "hh:mm a, MMM dd, yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 75, 340, 240, 40, 32, RegexUtil.TYPE_ALL_TO_CAPITAL, 0);
    TimestampEntity n1_12_t1_x1 = TimestampEntity.init(ratio, "n1_12_t1_x1", "n1_12", "nanum_yuni_ddingddang", "hh:mm a, MMM dd, yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 65, 338, 270, 40, 38, RegexUtil.TYPE_ALL_TO_CAPITAL, 1);
    TimestampEntity n1_12_t1_x2 = TimestampEntity.init(ratio, "n1_12_t1_x2", "n1_12", "nanum_yuni_ddingddang", "hh:mm a, MMM dd, yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 45, 336, 300, 40, 44, RegexUtil.TYPE_ALL_TO_CAPITAL, 2);

    TimestampGroupEntity n1_13 = TimestampGroupEntity("n1_13", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n1_13.png", null, Colors.black.value, 25);
    TimestampEntity n1_13_t1_x0 = TimestampEntity.init(ratio, "n1_13_t1_x0", "n1_13", "rabanera_outline_shadow", "hh:mm a", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 35, 160, 180, 70, 40, null, 0);
    TimestampEntity n1_13_t2_x0 = TimestampEntity.init(ratio, "n1_13_t2_x0", "n1_13", "rabanera_outline_shadow", "MMM dd, yyyy", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 220, 180, 140, 40, 20, null, 0);
    TimestampEntity n1_13_t1_x1 = TimestampEntity.init(ratio, "n1_13_t1_x1", "n1_13", "rabanera_outline_shadow", "hh:mm a", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 35, 160, 180, 70, 43, null, 1);
    TimestampEntity n1_13_t2_x1 = TimestampEntity.init(ratio, "n1_13_t2_x1", "n1_13", "rabanera_outline_shadow", "MMM dd, yyyy", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 220, 180, 150, 40, 23, null, 1);
    TimestampEntity n1_13_t1_x2 = TimestampEntity.init(ratio, "n1_13_t1_x2", "n1_13", "rabanera_outline_shadow", "hh:mm a", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 35, 160, 180, 70, 46, null, 2);
    TimestampEntity n1_13_t2_x2 = TimestampEntity.init(ratio, "n1_13_t2_x2", "n1_13", "rabanera_outline_shadow", "MMM dd, yyyy", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 220, 180, 160, 40, 26, null, 2);

    TimestampGroupEntity n1_14 = TimestampGroupEntity("n1_14", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n1_14.png", null, Colors.black.value, 28);
    TimestampEntity n1_14_t1_x0 = TimestampEntity.init(ratio, "n1_14_t1_x0", "n1_14", "cafe24_danjunghae", "yy년 M월 dd일 a h시 m분", Constants.ALIGN_RIGHT, Constants.LOCALE_KR, 98, 335, 280, 50, 22, RegexUtil.TYPE_AMPM_TO_KR, 0);
    TimestampEntity n1_14_t1_x1 = TimestampEntity.init(ratio, "n1_14_t1_x1", "n1_14", "cafe24_danjunghae", "yy년 M월 dd일 a h시 m분", Constants.ALIGN_RIGHT, Constants.LOCALE_KR, 73, 334, 305, 50, 25, RegexUtil.TYPE_AMPM_TO_KR, 1);
    TimestampEntity n1_14_t1_x2 = TimestampEntity.init(ratio, "n1_14_t1_x2", "n1_14", "cafe24_danjunghae", "yy년 M월 dd일 a h시 m분", Constants.ALIGN_RIGHT, Constants.LOCALE_KR, 48, 333, 330, 50, 28, RegexUtil.TYPE_AMPM_TO_KR, 2);

    TimestampGroupEntity n1_15 = TimestampGroupEntity("n1_15", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n1_15.png", null, Colors.black.value, 29);
    TimestampEntity n1_15_t1_x0 = TimestampEntity.init(ratio, "n1_15_t1_x0", "n1_15", "cafe24_simplehae", "yy년 M월 d일 (E) H시 m분", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 55, 335, 280, 50, 20, RegexUtil.TYPE_DAY_TO_KR, 0);
    TimestampEntity n1_15_t1_x1 = TimestampEntity.init(ratio, "n1_15_t1_x1", "n1_15", "cafe24_simplehae", "yy년 M월 d일 (E) H시 m분", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 50, 334, 290, 50, 23, RegexUtil.TYPE_DAY_TO_KR, 1);
    TimestampEntity n1_15_t1_x2 = TimestampEntity.init(ratio, "n1_15_t1_x2", "n1_15", "cafe24_simplehae", "yy년 M월 d일 (E) H시 m분", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 45, 333, 300, 50, 26, RegexUtil.TYPE_DAY_TO_KR, 2);


    TimestampGroupEntity n1_16 = TimestampGroupEntity("n1_16", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n1_16.png", null, Colors.black.value, 32);
    TimestampEntity n1_16_t2_x0 = TimestampEntity.init(ratio, "n1_16_t2_x0", "n1_16", "trs_million", "MM.dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 320, 50, 30, 18, null, 0);
    TimestampEntity n1_16_t1_x0 = TimestampEntity.init(ratio, "n1_16_t1_x0", "n1_16", "trs_million", "EEEE a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 335, 280, 50, 30, null, 0);
    TimestampEntity n1_16_t2_x1 = TimestampEntity.init(ratio, "n1_16_t2_x1", "n1_16", "trs_million", "MM.dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 315, 60, 30, 22, null, 1);
    TimestampEntity n1_16_t1_x1 = TimestampEntity.init(ratio, "n1_16_t1_x1", "n1_16", "trs_million", "EEEE a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 333, 280, 50, 33, null, 1);
    TimestampEntity n1_16_t2_x2 = TimestampEntity.init(ratio, "n1_16_t2_x2", "n1_16", "trs_million", "MM.dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 307, 70, 30, 26, null, 2);
    TimestampEntity n1_16_t1_x2 = TimestampEntity.init(ratio, "n1_16_t1_x2", "n1_16", "trs_million", "EEEE a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 331, 280, 50, 36, null, 2);

    TimestampGroupEntity n1_17 = TimestampGroupEntity("n1_17", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n1_17.png", null, Colors.black.value, 33);
    TimestampEntity n1_17_t1_x0 = TimestampEntity.init(ratio, "n1_17_t1_x0", "n1_17", "brewsky", "EEEE a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 55, 170, 280, 50, 32, null, 0);
    TimestampEntity n1_17_t2_x0 = TimestampEntity.init(ratio, "n1_17_t2_x0", "n1_17", "brewsky", "yyyy.MM.dd", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 230, 202, 80, 40, 18, null, 0);
    TimestampEntity n1_17_t1_x1 = TimestampEntity.init(ratio, "n1_17_t1_x1", "n1_17", "brewsky", "EEEE a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 50, 170, 290, 50, 36, null, 1);
    TimestampEntity n1_17_t2_x1 = TimestampEntity.init(ratio, "n1_17_t2_x1", "n1_17", "brewsky", "yyyy.MM.dd", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 223, 205, 100, 40, 22, null, 1);
    TimestampEntity n1_17_t1_x2 = TimestampEntity.init(ratio, "n1_17_t1_x2", "n1_17", "brewsky", "EEEE a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 45, 170, 300, 50, 40, null, 2);
    TimestampEntity n1_17_t2_x2 = TimestampEntity.init(ratio, "n1_17_t2_x2", "n1_17", "brewsky", "yyyy.MM.dd", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 217, 208, 120, 40, 26, null, 2);


    TimestampGroupEntity n1_18 = TimestampGroupEntity("n1_18", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n1_18.png", null, Colors.black.value, 36);
    TimestampEntity n1_18_t1_x0 = TimestampEntity.init(ratio, "n1_18_t1_x0", "n1_18", "nanum_left_hand_also_good", "yyyy.MM.dd", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 65, 160, 190, 60, 58, null, 0);
    TimestampEntity n1_18_t2_x0 = TimestampEntity.init(ratio, "n1_18_t2_x0", "n1_18", "nanum_left_hand_also_good", "EEEE", Constants.ALIGN_LEFT, Constants.LOCALE_KR, 265, 169, 40, 30, 22, RegexUtil.TYPE_FULL_DAY_TO_KR, 0);
    TimestampEntity n1_18_t3_x0 = TimestampEntity.init(ratio, "n1_18_t3_x0", "n1_18", "nanum_left_hand_also_good", "hh:mm a", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 265, 191, 80, 30, 22, null, 0);
    TimestampEntity n1_18_t1_x1 = TimestampEntity.init(ratio, "n1_18_t1_x1", "n1_18", "nanum_left_hand_also_good", "yyyy.MM.dd", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 52, 160, 205, 60, 62, null, 1);
    TimestampEntity n1_18_t2_x1 = TimestampEntity.init(ratio, "n1_18_t2_x1", "n1_18", "nanum_left_hand_also_good", "EEEE", Constants.ALIGN_LEFT, Constants.LOCALE_KR, 267, 169, 40, 30, 25, RegexUtil.TYPE_FULL_DAY_TO_KR, 1);
    TimestampEntity n1_18_t3_x1 = TimestampEntity.init(ratio, "n1_18_t3_x1", "n1_18", "nanum_left_hand_also_good", "hh:mm a", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 267, 192, 80, 30, 25, null, 1);
    TimestampEntity n1_18_t1_x2 = TimestampEntity.init(ratio, "n1_18_t1_x2", "n1_18", "nanum_left_hand_also_good", "yyyy.MM.dd", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 40, 160, 220, 60, 66, null, 2);
    TimestampEntity n1_18_t2_x2 = TimestampEntity.init(ratio, "n1_18_t2_x2", "n1_18", "nanum_left_hand_also_good", "EEEE", Constants.ALIGN_LEFT, Constants.LOCALE_KR, 270, 169, 50, 30, 28, RegexUtil.TYPE_FULL_DAY_TO_KR, 2);
    TimestampEntity n1_18_t3_x2 = TimestampEntity.init(ratio, "n1_18_t3_x2", "n1_18", "nanum_left_hand_also_good", "hh:mm a", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 270, 193, 80, 30, 28, null, 2);



    TimestampGroupEntity n2_3 = TimestampGroupEntity("n2_3", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n2_3.png", null, Colors.black.value, 2);
    TimestampEntity n2_3_t1_x0 = TimestampEntity.init(ratio, "n2_3_t1_x0", "n2_3", "nanum_barunpen", "a h:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 100, 155, 190, 54, 38, RegexUtil.TYPE_AMPM_TO_KR, 0);
    TimestampEntity n2_3_t2_x0 = TimestampEntity.init(ratio, "n2_3_t2_x0", "n2_3", "nanum_barunpen", "yy년 M월 d일 EEEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 100, 197, 190, 40, 20, RegexUtil.TYPE_FULL_DAY_TO_KR, 0);
    TimestampEntity n2_3_t1_x1 = TimestampEntity.init(ratio, "n2_3_t1_x1", "n2_3", "nanum_barunpen", "a h:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 100, 152, 190, 54, 45, RegexUtil.TYPE_AMPM_TO_KR, 1);
    TimestampEntity n2_3_t2_x1 = TimestampEntity.init(ratio, "n2_3_t2_x1", "n2_3", "nanum_barunpen", "yy년 M월 d일 EEEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 95, 199, 200, 40, 23, RegexUtil.TYPE_FULL_DAY_TO_KR, 1);
    TimestampEntity n2_3_t1_x2 = TimestampEntity.init(ratio, "n2_3_t1_x2", "n2_3", "nanum_barunpen", "a h:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 100, 149, 190, 54, 52, RegexUtil.TYPE_AMPM_TO_KR, 2);
    TimestampEntity n2_3_t2_x2 = TimestampEntity.init(ratio, "n2_3_t2_x2", "n2_3", "nanum_barunpen", "yy년 M월 d일 EEEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 90, 201, 210, 40, 26, RegexUtil.TYPE_FULL_DAY_TO_KR, 2);

    TimestampGroupEntity n2_4 = TimestampGroupEntity("n2_4", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n2_4.png", null, Colors.black.value, 3);
    TimestampEntity n2_4_t1_x0 = TimestampEntity.init(ratio, "n2_4_t1_x0", "n2_4", "ssantokki", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 100, 155, 190, 54, 40, null, 0);
    TimestampEntity n2_4_t2_x0 = TimestampEntity.init(ratio, "n2_4_t2_x0", "n2_4", "ssantokki", "yyyy.MM.dd (E)", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 110, 191, 170, 40, 20, RegexUtil.TYPE_DAY_TO_KR, 0);
    TimestampEntity n2_4_t1_x1 = TimestampEntity.init(ratio, "n2_4_t1_x1", "n2_4", "ssantokki", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 90, 151.5, 210, 54, 50, null, 1);
    TimestampEntity n2_4_t2_x1 = TimestampEntity.init(ratio, "n2_4_t2_x1", "n2_4", "ssantokki", "yyyy.MM.dd (E)", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 105, 194.5, 180, 40, 24, RegexUtil.TYPE_DAY_TO_KR, 1);
    TimestampEntity n2_4_t1_x2 = TimestampEntity.init(ratio, "n2_4_t1_x2", "n2_4", "ssantokki", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 80, 148, 230, 54, 60, null, 2);
    TimestampEntity n2_4_t2_x2 = TimestampEntity.init(ratio, "n2_4_t2_x2", "n2_4", "ssantokki", "yyyy.MM.dd (E)", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 100, 198, 190, 40, 28, RegexUtil.TYPE_DAY_TO_KR, 2);

    TimestampGroupEntity n2_5 = TimestampGroupEntity("n2_5", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n2_5.png", null, Colors.black.value, 6);
    TimestampEntity n2_5_t1_x0 = TimestampEntity.init(ratio, "n2_5_t1_x0", "n2_5", "cafe24_surround_air", "M월 dd일 (E)", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 125, 161, 140, 40, 16, RegexUtil.TYPE_DAY_TO_KR, 0);
    TimestampEntity n2_5_t2_x0 = TimestampEntity.init(ratio, "n2_5_t2_x0", "n2_5", "cafe24_surround_air", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 100, 185, 190, 50, 29, null, 0);
    TimestampEntity n2_5_t1_x1 = TimestampEntity.init(ratio, "n2_5_t1_x1", "n2_5", "cafe24_surround_air", "M월 dd일 (E)", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 120, 157, 150, 40, 20, RegexUtil.TYPE_DAY_TO_KR, 1);
    TimestampEntity n2_5_t2_x1 = TimestampEntity.init(ratio, "n2_5_t2_x1", "n2_5", "cafe24_surround_air", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 95, 188, 200, 50, 36, null, 1);
    TimestampEntity n2_5_t1_x2 = TimestampEntity.init(ratio, "n2_5_t1_x2", "n2_5", "cafe24_surround_air", "M월 dd일 (E)", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 115, 153, 160, 40, 24, RegexUtil.TYPE_DAY_TO_KR, 2);
    TimestampEntity n2_5_t2_x2 = TimestampEntity.init(ratio, "n2_5_t2_x2", "n2_5", "cafe24_surround_air", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 90, 191, 210, 50, 44, null, 2);

    TimestampGroupEntity n3_3 = TimestampGroupEntity("n3_3", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n3_3.png", null, Colors.black.value, 7);
    TimestampEntity n3_3_t1_x0 = TimestampEntity.init(ratio, "n3_3_t1_x0", "n3_3", "tvn_fun_story", "yyyy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 132, 130, 44, 26, null, 0);
    TimestampEntity n3_3_t2_x0 = TimestampEntity.init(ratio, "n3_3_t2_x0", "n3_3", "tvn_fun_story", "EEEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 85, 165, 220, 60, 53, RegexUtil.TYPE_ALL_TO_CAPITAL, 0);
    TimestampEntity n3_3_t3_x0 = TimestampEntity.init(ratio, "n3_3_t3_x0", "n3_3", "tvn_fun_story", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 213, 130, 44, 26, null, 0);
    TimestampEntity n3_3_t1_x1 = TimestampEntity.init(ratio, "n3_3_t1_x1", "n3_3", "tvn_fun_story", "yyyy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 126, 130, 44, 32, null, 1);
    TimestampEntity n3_3_t2_x1 = TimestampEntity.init(ratio, "n3_3_t2_x1", "n3_3", "tvn_fun_story", "EEEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 75, 165, 240, 60, 65, RegexUtil.TYPE_ALL_TO_CAPITAL, 1);
    TimestampEntity n3_3_t3_x1 = TimestampEntity.init(ratio, "n3_3_t3_x1", "n3_3", "tvn_fun_story", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 219, 130, 44, 32, null, 1);
    TimestampEntity n3_3_t1_x2 = TimestampEntity.init(ratio, "n3_3_t1_x2", "n3_3", "tvn_fun_story", "yyyy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 118, 130, 44, 38, null, 2);
    TimestampEntity n3_3_t2_x2 = TimestampEntity.init(ratio, "n3_3_t2_x2", "n3_3", "tvn_fun_story", "EEEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 65, 165, 260, 60, 77, RegexUtil.TYPE_ALL_TO_CAPITAL, 2);
    TimestampEntity n3_3_t3_x2 = TimestampEntity.init(ratio, "n3_3_t3_x2", "n3_3", "tvn_fun_story", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 227, 130, 44, 38, null, 2);


    TimestampGroupEntity n2_1 = TimestampGroupEntity("n2_1", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n2_1.png", null, Colors.black.value, 10);
    TimestampEntity n2_1_t1_x0 = TimestampEntity.init(ratio, "n2_1_t1_x0", "n2_1", "cafe24_one_pretty_night", "yyyy년 MM월 dd일(E)", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 115, 159, 160, 40, 16, RegexUtil.TYPE_DAY_TO_KR, 0);
    TimestampEntity n2_1_t2_x0 = TimestampEntity.init(ratio, "n2_1_t2_x0", "n2_1", "cafe24_one_pretty_night", "a h:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 110, 184, 170, 50, 36, RegexUtil.TYPE_AMPM_TO_KR, 0);
    TimestampEntity n2_1_t1_x1 = TimestampEntity.init(ratio, "n2_1_t1_x1", "n2_1", "cafe24_one_pretty_night", "yyyy년 MM월 dd일(E)", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 105, 155, 180, 40, 20, RegexUtil.TYPE_DAY_TO_KR, 1);
    TimestampEntity n2_1_t2_x1 = TimestampEntity.init(ratio, "n2_1_t2_x1", "n2_1", "cafe24_one_pretty_night", "a h:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 105, 186, 180, 50, 45, RegexUtil.TYPE_AMPM_TO_KR, 1);
    TimestampEntity n2_1_t1_x2 = TimestampEntity.init(ratio, "n2_1_t1_x2", "n2_1", "cafe24_one_pretty_night", "yyyy년 MM월 dd일(E)", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 95, 149, 200, 40, 24, RegexUtil.TYPE_DAY_TO_KR, 2);
    TimestampEntity n2_1_t2_x2 = TimestampEntity.init(ratio, "n2_1_t2_x2", "n2_1", "cafe24_one_pretty_night", "a h:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 100, 188, 190, 50, 54, RegexUtil.TYPE_AMPM_TO_KR, 2);

    TimestampGroupEntity n2_7 = TimestampGroupEntity("n2_7", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n2_7.png", null, Colors.black.value, 11);
    TimestampEntity n2_7_t1_x0 = TimestampEntity.init(ratio, "n2_7_t1_x0", "n2_7", "gmarket_sans", "yyyy.MM.dd (E)", Constants.ALIGN_LEFT, Constants.LOCALE_KR, 10, 310, 140, 40, 16, RegexUtil.TYPE_DAY_TO_KR, 0);
    TimestampEntity n2_7_t2_x0 = TimestampEntity.init(ratio, "n2_7_t2_x0", "n2_7", "gmarket_sans", "a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 10, 335, 160, 50, 28, null, 0);
    TimestampEntity n2_7_t1_x1 = TimestampEntity.init(ratio, "n2_7_t1_x1", "n2_7", "gmarket_sans", "yyyy.MM.dd (E)", Constants.ALIGN_LEFT, Constants.LOCALE_KR, 10, 299, 160, 40, 20, RegexUtil.TYPE_DAY_TO_KR, 1);
    TimestampEntity n2_7_t2_x1 = TimestampEntity.init(ratio, "n2_7_t2_x1", "n2_7", "gmarket_sans", "a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 10, 330, 175, 50, 35, null, 1);
    TimestampEntity n2_7_t1_x2 = TimestampEntity.init(ratio, "n2_7_t1_x2", "n2_7", "gmarket_sans", "yyyy.MM.dd (E)", Constants.ALIGN_LEFT, Constants.LOCALE_KR, 10, 288, 180, 40, 22, RegexUtil.TYPE_DAY_TO_KR, 2);
    TimestampEntity n2_7_t2_x2 = TimestampEntity.init(ratio, "n2_7_t2_x2", "n2_7", "gmarket_sans", "a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 10, 325, 190, 50, 38.5, null, 2);

    TimestampGroupEntity n2_2 = TimestampGroupEntity("n2_2", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n2_2.png", null, Colors.black.value, 14);
    TimestampEntity n2_2_t1_x0 = TimestampEntity.init(ratio, "n2_2_t1_x0", "n2_2", "nanum_amsterdam", "yyyy년 MM월 dd일", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 105, 159, 180, 40, 24, null, 0);
    TimestampEntity n2_2_t2_x0 = TimestampEntity.init(ratio, "n2_2_t2_x0", "n2_2", "nanum_amsterdam", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 123, 185, 145, 50, 32, RegexUtil.TYPE_AMPM_TO_KR, 0);
    TimestampEntity n2_2_t1_x1 = TimestampEntity.init(ratio, "n2_2_t1_x1", "n2_2", "nanum_amsterdam", "yyyy년 MM월 dd일", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 100, 155, 190, 40, 30, null, 1);
    TimestampEntity n2_2_t2_x1 = TimestampEntity.init(ratio, "n2_2_t2_x1", "n2_2", "nanum_amsterdam", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 120.5, 185, 150, 50, 40, RegexUtil.TYPE_AMPM_TO_KR, 1);
    TimestampEntity n2_2_t1_x2 = TimestampEntity.init(ratio, "n2_2_t1_x2", "n2_2", "nanum_amsterdam", "yyyy년 MM월 dd일", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 95, 151, 200, 40, 36, null, 2);
    TimestampEntity n2_2_t2_x2 = TimestampEntity.init(ratio, "n2_2_t2_x2", "n2_2", "nanum_amsterdam", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 118, 187, 155, 50, 48, RegexUtil.TYPE_AMPM_TO_KR, 2);

    TimestampGroupEntity n2_8 = TimestampGroupEntity("n2_8", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n2_8.png", null, Colors.black.value, 15);
    TimestampEntity n2_8_t1_x0 = TimestampEntity.init(ratio, "n2_8_t1_x0", "n2_8", "nanum_yeonji", "a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 315, 100, 40, 28, null, 0);
    TimestampEntity n2_8_t2_x0 = TimestampEntity.init(ratio, "n2_8_t2_x0", "n2_8", "nanum_yeonji", "MMMM dd, yyyy", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 340, 170, 40, 28, null, 0);
    TimestampEntity n2_8_t1_x1 = TimestampEntity.init(ratio, "n2_8_t1_x1", "n2_8", "nanum_yeonji", "a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 305, 120, 40, 34, null, 1);
    TimestampEntity n2_8_t2_x1 = TimestampEntity.init(ratio, "n2_8_t2_x1", "n2_8", "nanum_yeonji", "MMMM dd, yyyy", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 335, 210, 40, 34, null, 1);
    TimestampEntity n2_8_t1_x2 = TimestampEntity.init(ratio, "n2_8_t1_x2", "n2_8", "nanum_yeonji", "a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 292, 140, 40, 40, null, 2);
    TimestampEntity n2_8_t2_x2 = TimestampEntity.init(ratio, "n2_8_t2_x2", "n2_8", "nanum_yeonji", "MMMM dd, yyyy", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 330, 250, 40, 40, null, 2);

    TimestampGroupEntity n2_9 = TimestampGroupEntity("n2_9", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n2_9.png", null, Colors.black.value, 18);
    TimestampEntity n2_9_t1_x0 = TimestampEntity.init(ratio, "n2_9_t1_x0", "n2_9", "nerko_one", "yyyy.MM.dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 10, 110, 40, 24, null, 0);
    TimestampEntity n2_9_t2_x0 = TimestampEntity.init(ratio, "n2_9_t2_x0", "n2_9", "nerko_one", "a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 35, 110, 40, 24, null, 0);
    TimestampEntity n2_9_t1_x1 = TimestampEntity.init(ratio, "n2_9_t1_x1", "n2_9", "nerko_one", "yyyy.MM.dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 12, 145, 40, 32, null, 1);
    TimestampEntity n2_9_t2_x1 = TimestampEntity.init(ratio, "n2_9_t2_x1", "n2_9", "nerko_one", "a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 42, 120, 40, 30, null, 1);
    TimestampEntity n2_9_t1_x2 = TimestampEntity.init(ratio, "n2_9_t1_x2", "n2_9", "nerko_one", "yyyy.MM.dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 14, 180, 40, 40, null, 2);
    TimestampEntity n2_9_t2_x2 = TimestampEntity.init(ratio, "n2_9_t2_x2", "n2_9", "nerko_one", "a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 50, 130, 40, 36, null, 2);

    TimestampGroupEntity n2_10 = TimestampGroupEntity("n2_10", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n2_10.png", null, Colors.black.value, 19);
    TimestampEntity n2_10_t1_x0 = TimestampEntity.init(ratio, "n2_10_t1_x0", "n2_10", "gmarket_sans", "yyyy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 155, 130, 35, 16, null, 0);
    TimestampEntity n2_10_t2_x0 = TimestampEntity.init(ratio, "n2_10_t2_x0", "n2_10", "gmarket_sans", "HH:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 181, 130, 60, 44, null, 0);
    TimestampEntity n2_10_t1_x1 = TimestampEntity.init(ratio, "n2_10_t1_x1", "n2_10", "gmarket_sans", "yyyy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 107.5, 148.5, 175, 35, 20, null, 1);
    TimestampEntity n2_10_t2_x1 = TimestampEntity.init(ratio, "n2_10_t2_x1", "n2_10", "gmarket_sans", "HH:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 107.5, 181.5, 175, 60, 55, null, 1);
    TimestampEntity n2_10_t1_x2 = TimestampEntity.init(ratio, "n2_10_t1_x2", "n2_10", "gmarket_sans", "yyyy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 105, 142, 180, 35, 24, null, 2);
    TimestampEntity n2_10_t2_x2 = TimestampEntity.init(ratio, "n2_10_t2_x2", "n2_10", "gmarket_sans", "HH:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 105, 184, 180, 60, 66, null, 2);

    TimestampGroupEntity n2_11 = TimestampGroupEntity("n2_11", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n2_11.png", null, Colors.black.value, 22);
    TimestampEntity n2_11_t1_x0 = TimestampEntity.init(ratio, "n2_11_t1_x0", "n2_11", "gmarket_sans", "dd", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 78, 301, 70, 65, 38, null, 0);
    TimestampEntity n2_11_t2_x0 = TimestampEntity.initWithFontWeight(ratio, "n2_11_t2_x0", "n2_11", "gmarket_sans_light", "┃", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 143, 304, 30, 60, 30, null, "w100", 0);
    TimestampEntity n2_11_t3_x0 = TimestampEntity.init(ratio, "n2_11_t3_x0", "n2_11", "gmarket_sans", "HH:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 168, 301, 150, 65, 38, null, 0);
    TimestampEntity n2_11_t4_x0 = TimestampEntity.initWithFontWeight(ratio, "n2_11_t4_x0", "n2_11", "gmarket_sans", "MMM", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 95, 351, 50, 30, 12, null, "w100", 0);
    TimestampEntity n2_11_t5_x0 = TimestampEntity.initWithFontWeight(ratio, "n2_11_t5_x0", "n2_11", "gmarket_sans", "yyyy EEEE", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 168, 351, 130, 30, 12, null, "w100", 0);
    TimestampEntity n2_11_t1_x1 = TimestampEntity.init(ratio, "n2_11_t1_x1", "n2_11", "gmarket_sans", "dd", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 78, 295, 70, 65, 47, null, 1);
    TimestampEntity n2_11_t2_x1 = TimestampEntity.initWithFontWeight(ratio, "n2_11_t2_x1", "n2_11", "gmarket_sans_light", "┃", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 143, 298, 30, 60, 37, null, "w100", 1);
    TimestampEntity n2_11_t3_x1 = TimestampEntity.init(ratio, "n2_11_t3_x1", "n2_11", "gmarket_sans", "HH:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 168, 295, 150, 65, 47, null, 1);
    TimestampEntity n2_11_t4_x1 = TimestampEntity.initWithFontWeight(ratio, "n2_11_t4_x1", "n2_11", "gmarket_sans", "MMM", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 95, 349, 50, 30, 15, null, "w100", 1);
    TimestampEntity n2_11_t5_x1 = TimestampEntity.initWithFontWeight(ratio, "n2_11_t5_x1", "n2_11", "gmarket_sans", "yyyy EEEE", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 168, 349, 150, 30, 15, null, "w100", 1);
    TimestampEntity n2_11_t1_x2 = TimestampEntity.init(ratio, "n2_11_t1_x2", "n2_11", "gmarket_sans", "dd", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 78, 287, 70, 65, 56, null, 2);
    TimestampEntity n2_11_t2_x2 = TimestampEntity.initWithFontWeight(ratio, "n2_11_t2_x2", "n2_11", "gmarket_sans_light", "┃", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 143, 290, 30, 60, 44, null, "w100", 2);
    TimestampEntity n2_11_t3_x2 = TimestampEntity.init(ratio, "n2_11_t3_x2", "n2_11", "gmarket_sans", "HH:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 168, 287, 150, 65, 56, null, 2);
    TimestampEntity n2_11_t4_x2 = TimestampEntity.initWithFontWeight(ratio, "n2_11_t4_x2", "n2_11", "gmarket_sans", "MMM", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 95, 347, 50, 30, 18, null, "w100", 2);
    TimestampEntity n2_11_t5_x2 = TimestampEntity.initWithFontWeight(ratio, "n2_11_t5_x2", "n2_11", "gmarket_sans", "yyyy EEEE", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 168, 347, 170, 30, 18, null, "w100", 2);

    TimestampGroupEntity n2_12 = TimestampGroupEntity("n2_12", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n2_12.png", null, Colors.black.value, 23);
    TimestampEntity n2_12_t1_x0 = TimestampEntity.init(ratio, "n2_12_t1_x0", "n2_12", "nerko_one", "MM.dd E", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 125, 155, 140, 40, 26, null, 0);
    TimestampEntity n2_12_t2_x0 = TimestampEntity.init(ratio, "n2_12_t2_x0", "n2_12", "nerko_one", "HH:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 125, 178, 140, 70, 60, null, 0);
    TimestampEntity n2_12_t1_x1 = TimestampEntity.init(ratio, "n2_12_t1_x1", "n2_12", "nerko_one", "MM.dd E", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 112.5, 149, 165, 40, 32, null, 1);
    TimestampEntity n2_12_t2_x1 = TimestampEntity.init(ratio, "n2_12_t2_x1", "n2_12", "nerko_one", "HH:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 112.5, 178.5, 165, 70, 72, null, 1);
    TimestampEntity n2_12_t1_x2 = TimestampEntity.init(ratio, "n2_12_t1_x2", "n2_12", "nerko_one", "MM.dd E", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 100, 141, 190, 40, 38, null, 2);
    TimestampEntity n2_12_t2_x2 = TimestampEntity.init(ratio, "n2_12_t2_x2", "n2_12", "nerko_one", "HH:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 100, 179, 190, 70, 84, null, 2);

    TimestampGroupEntity n3_1 = TimestampGroupEntity("n3_1", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n3_1.png", null, Colors.black.value, 26);
    TimestampEntity n3_1_t1_x0 = TimestampEntity.init(ratio, "n3_1_t1_x0", "n3_1", "nanum_barunpen", "dd MMM, yyyy", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 12, 291, 120, 40, 18, null, 0);
    TimestampEntity n3_1_t2_x0 = TimestampEntity.init(ratio, "n3_1_t2_x0", "n3_1", "nanum_barunpen", "EEEE", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 12, 315, 90, 40, 18, null, 0);
    TimestampEntity n3_1_t3_x0 = TimestampEntity.init(ratio, "n3_1_t3_x0", "n3_1", "nanum_barunpen", "a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 12, 340, 90, 40, 18, null, 0);
    TimestampEntity n3_1_t1_x1 = TimestampEntity.init(ratio, "n3_1_t1_x1", "n3_1", "nanum_barunpen", "dd MMM, yyyy", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 12, 278, 140, 40, 22.5, null, 1);
    TimestampEntity n3_1_t2_x1 = TimestampEntity.init(ratio, "n3_1_t2_x1", "n3_1", "nanum_barunpen", "EEEE", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 12, 306.5, 105, 40, 22.5, null, 1);
    TimestampEntity n3_1_t3_x1 = TimestampEntity.init(ratio, "n3_1_t3_x1", "n3_1", "nanum_barunpen", "a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 12, 338, 105, 40, 22.5, null, 1);
    TimestampEntity n3_1_t1_x2 = TimestampEntity.init(ratio, "n3_1_t1_x2", "n3_1", "nanum_barunpen", "dd MMM, yyyy", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 12, 262, 160, 40, 28, null, 2);
    TimestampEntity n3_1_t2_x2 = TimestampEntity.init(ratio, "n3_1_t2_x2", "n3_1", "nanum_barunpen", "EEEE", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 12, 298, 120, 40, 28, null, 2);
    TimestampEntity n3_1_t3_x2 = TimestampEntity.init(ratio, "n3_1_t3_x2", "n3_1", "nanum_barunpen", "a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 12, 336, 120, 40, 28, null, 2);

    TimestampGroupEntity n3_2 = TimestampGroupEntity("n3_2", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n3_2.png", null, Colors.black.value, 27);
    TimestampEntity n3_2_t1_x0 = TimestampEntity.init(ratio, "n3_2_t1_x0", "n3_2", "cafe24_simplehae", "yyyy", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 10, 80, 40, 24, null, 0);
    TimestampEntity n3_2_t2_x0 = TimestampEntity.init(ratio, "n3_2_t2_x0", "n3_2", "cafe24_simplehae", "MMMM dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 37, 180, 40, 24, null, 0);
    TimestampEntity n3_2_t3_x0 = TimestampEntity.init(ratio, "n3_2_t3_x0", "n3_2", "cafe24_simplehae", "a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 64, 120, 40, 24, null, 0);
    TimestampEntity n3_2_t1_x1 = TimestampEntity.init(ratio, "n3_2_t1_x1", "n3_2", "cafe24_simplehae", "yyyy", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 12, 80, 40, 30, null, 1);
    TimestampEntity n3_2_t2_x1 = TimestampEntity.init(ratio, "n3_2_t2_x1", "n3_2", "cafe24_simplehae", "MMMM dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 45, 180, 40, 30, null, 1);
    TimestampEntity n3_2_t3_x1 = TimestampEntity.init(ratio, "n3_2_t3_x1", "n3_2", "cafe24_simplehae", "a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 78, 140, 40, 30, null, 1);
    TimestampEntity n3_2_t1_x2 = TimestampEntity.init(ratio, "n3_2_t1_x2", "n3_2", "cafe24_simplehae", "yyyy", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 14, 100, 40, 36, null, 2);
    TimestampEntity n3_2_t2_x2 = TimestampEntity.init(ratio, "n3_2_t2_x2", "n3_2", "cafe24_simplehae", "MMMM dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 53, 180, 40, 36, null, 2);
    TimestampEntity n3_2_t3_x2 = TimestampEntity.init(ratio, "n3_2_t3_x2", "n3_2", "cafe24_simplehae", "a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 92, 160, 40, 36, null, 2);

    TimestampGroupEntity n2_6 = TimestampGroupEntity("n2_6", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n2_6.png", null, Colors.black.value, 30);
    TimestampEntity n2_6_t1_x0 = TimestampEntity.init(ratio, "n2_6_t1_x0", "n2_6", "tvn_fun_story", "a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 18, 110, 45, 32, null, 0);
    TimestampEntity n2_6_t2_x0 = TimestampEntity.init(ratio, "n2_6_t2_x0", "n2_6", "tvn_fun_story", "yyyy.MM.dd.E", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 50, 160, 45, 32, null, 0);
    TimestampEntity n2_6_t1_x1 = TimestampEntity.init(ratio, "n2_6_t1_x1", "n2_6", "tvn_fun_story", "a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 19, 125, 45, 40, null, 1);
    TimestampEntity n2_6_t2_x1 = TimestampEntity.init(ratio, "n2_6_t2_x1", "n2_6", "tvn_fun_story", "yyyy.MM.dd.E", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 58, 180, 45, 40, null, 1);
    TimestampEntity n2_6_t1_x2 = TimestampEntity.init(ratio, "n2_6_t1_x2", "n2_6", "tvn_fun_story", "a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 20, 140, 45, 46, null, 2);
    TimestampEntity n2_6_t2_x2 = TimestampEntity.init(ratio, "n2_6_t2_x2", "n2_6", "tvn_fun_story", "yyyy.MM.dd.E", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 15, 65, 200, 45, 46, null, 2);

    TimestampGroupEntity n3_4 = TimestampGroupEntity("n3_4", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n3_4.png", null, Colors.black.value, 31);
    TimestampEntity n3_4_t3_x0 = TimestampEntity.init(ratio, "n3_4_t3_x0", "n3_4", "cafe24_one_pretty_night", "a h시 m분", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 125, 134, 140, 40, 18, RegexUtil.TYPE_AMPM_TO_KR, 0);
    TimestampEntity n3_4_t2_x0 = TimestampEntity.init(ratio, "n3_4_t2_x0", "n3_4", "cafe24_one_pretty_night", "EEEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 125, 163, 140, 64, 48, RegexUtil.TYPE_FULL_DAY_TO_KR, 0);
    TimestampEntity n3_4_t1_x0 = TimestampEntity.init(ratio, "n3_4_t1_x0", "n3_4", "cafe24_one_pretty_night", "yyyy년 M월 d일", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 125, 214, 140, 40, 18, null, 0);
    TimestampEntity n3_4_t3_x1 = TimestampEntity.init(ratio, "n3_4_t3_x1", "n3_4", "cafe24_one_pretty_night", "a h시 m분", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 115, 124, 160, 40, 23, RegexUtil.TYPE_AMPM_TO_KR, 1);
    TimestampEntity n3_4_t2_x1 = TimestampEntity.init(ratio, "n3_4_t2_x1", "n3_4", "cafe24_one_pretty_night", "EEEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 115, 163, 160, 64, 60, RegexUtil.TYPE_FULL_DAY_TO_KR, 1);
    TimestampEntity n3_4_t1_x1 = TimestampEntity.init(ratio, "n3_4_t1_x1", "n3_4", "cafe24_one_pretty_night", "yyyy년 M월 d일", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 115, 224, 160, 40, 23, null, 1);
    TimestampEntity n3_4_t3_x2 = TimestampEntity.init(ratio, "n3_4_t3_x2", "n3_4", "cafe24_one_pretty_night", "a h시 m분", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 105, 114, 180, 40, 28, RegexUtil.TYPE_AMPM_TO_KR, 2);
    TimestampEntity n3_4_t2_x2 = TimestampEntity.init(ratio, "n3_4_t2_x2", "n3_4", "cafe24_one_pretty_night", "EEEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 105, 163, 180, 64, 72, RegexUtil.TYPE_FULL_DAY_TO_KR, 2);
    TimestampEntity n3_4_t1_x2 = TimestampEntity.init(ratio, "n3_4_t1_x2", "n3_4", "cafe24_one_pretty_night", "yyyy년 M월 d일", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 105, 234, 180, 40, 28, null, 2);


    TimestampGroupEntity n2_13 = TimestampGroupEntity("n2_13", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n2_13.png", null, Colors.black.value, 34);
    TimestampEntity n2_13_t1_x0 = TimestampEntity.init(ratio, "n2_13_t1_x0", "n2_13", "dita_sweet", "hh:mm", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 83, 160, 140, 60, 48, null, 0);
    TimestampEntity n2_13_t3_x0 = TimestampEntity.init(ratio, "n2_13_t3_x0", "n2_13", "dita_sweet", "yyyy", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 170, 202, 50, 30, 14, null, 0);
    TimestampEntity n2_13_t2_x0 = TimestampEntity.init(ratio, "n2_13_t2_x0", "n2_13", "dita_sweet", "a", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 225, 182, 50, 30, 20, null, 0);
    TimestampEntity n2_13_t4_x0 = TimestampEntity.init(ratio, "n2_13_t4_x0", "n2_13", "dita_sweet", "MMM dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 225, 202, 60, 30, 14, null, 0);
    TimestampEntity n2_13_t1_x1 = TimestampEntity.init(ratio, "n2_13_t1_x1", "n2_13", "dita_sweet", "hh:mm", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 85, 152, 150, 60, 60, null, 1);
    TimestampEntity n2_13_t3_x1 = TimestampEntity.init(ratio, "n2_13_t3_x1", "n2_13", "dita_sweet", "yyyy", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 180, 202, 50, 30, 17.5, null, 1);
    TimestampEntity n2_13_t2_x1 = TimestampEntity.init(ratio, "n2_13_t2_x1", "n2_13", "dita_sweet", "a", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 238, 177, 50, 30, 25, null, 1);
    TimestampEntity n2_13_t4_x1 = TimestampEntity.init(ratio, "n2_13_t4_x1", "n2_13", "dita_sweet", "MMM dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 238, 202, 60, 30, 17.5, null, 1);
    TimestampEntity n2_13_t1_x2 = TimestampEntity.init(ratio, "n2_13_t1_x2", "n2_13", "dita_sweet", "hh:mm", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 87, 147, 160, 60, 72, null, 2);
    TimestampEntity n2_13_t3_x2 = TimestampEntity.init(ratio, "n2_13_t3_x2", "n2_13", "dita_sweet", "yyyy", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 190, 204, 50, 30, 21, null, 2);
    TimestampEntity n2_13_t2_x2 = TimestampEntity.init(ratio, "n2_13_t2_x2", "n2_13", "dita_sweet", "a", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 250, 172, 50, 30, 30, null, 2);
    TimestampEntity n2_13_t4_x2 = TimestampEntity.init(ratio, "n2_13_t4_x2", "n2_13", "dita_sweet", "MMM dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 250, 204, 60, 30, 21, null, 2);

    TimestampGroupEntity n3_5 = TimestampGroupEntity("n3_5", Constants.TIMESTAMP_CATEGORY_NORMAL, "assets/timestamp/group/n3_5.png", null, Colors.black.value, 35);
    TimestampEntity n3_5_t1_x0 = TimestampEntity.init(ratio, "n3_5_t1_x0", "n3_5", "emilio_20", "EEE", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 10, 245, 100, 54, 32, null, 0);
    TimestampEntity n3_5_t2_x0 = TimestampEntity.init(ratio, "n3_5_t2_x0", "n3_5", "emilio_20", "ahhmm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 10, 285, 170, 54, 32, null, 0);
    TimestampEntity n3_5_t3_x0 = TimestampEntity.init(ratio, "n3_5_t3_x0", "n3_5", "emilio_20", "yyyyMMdd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 10, 325, 210, 54, 32, null, 0);
    TimestampEntity n3_5_t1_x1 = TimestampEntity.init(ratio, "n3_5_t1_x1", "n3_5", "emilio_20", "EEE", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 10, 230, 110, 54, 37, null, 1);
    TimestampEntity n3_5_t2_x1 = TimestampEntity.init(ratio, "n3_5_t2_x1", "n3_5", "emilio_20", "ahhmm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 10, 276.5, 195, 54, 37, null, 1);
    TimestampEntity n3_5_t3_x1 = TimestampEntity.init(ratio, "n3_5_t3_x1", "n3_5", "emilio_20", "yyyyMMdd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 10, 323, 245, 54, 37, null, 1);
    TimestampEntity n3_5_t1_x2 = TimestampEntity.init(ratio, "n3_5_t1_x2", "n3_5", "emilio_20", "EEE", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 10, 215, 120, 54, 42, null, 2);
    TimestampEntity n3_5_t2_x2 = TimestampEntity.init(ratio, "n3_5_t2_x2", "n3_5", "emilio_20", "ahhmm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 10, 268, 220, 54, 42, null, 2);
    TimestampEntity n3_5_t3_x2 = TimestampEntity.init(ratio, "n3_5_t3_x2", "n3_5", "emilio_20", "yyyyMMdd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 10, 321, 280, 54, 42, null, 2);

    timestampGroupBox.put("n1_1", n1_1);
    timestampBox.put("n1_1_t1_x0", n1_1_t1_x0);
    timestampBox.put("n1_1_t1_x1", n1_1_t1_x1);
    timestampBox.put("n1_1_t1_x2", n1_1_t1_x2);

    timestampGroupBox.put("n1_2", n1_2);
    timestampBox.put("n1_2_t1_x0", n1_2_t1_x0);
    timestampBox.put("n1_2_t1_x1", n1_2_t1_x1);
    timestampBox.put("n1_2_t1_x2", n1_2_t1_x2);

    timestampGroupBox.put("n1_3", n1_3);
    timestampBox.put("n1_3_t1_x0", n1_3_t1_x0);
    timestampBox.put("n1_3_t1_x1", n1_3_t1_x1);
    timestampBox.put("n1_3_t1_x2", n1_3_t1_x2);

    timestampGroupBox.put("n1_4", n1_4);
    timestampBox.put("n1_4_t1_x0", n1_4_t1_x0);
    timestampBox.put("n1_4_t1_x1", n1_4_t1_x1);
    timestampBox.put("n1_4_t1_x2", n1_4_t1_x2);

    timestampGroupBox.put("n1_5", n1_5);
    timestampBox.put("n1_5_t1_x0", n1_5_t1_x0);
    timestampBox.put("n1_5_t1_x1", n1_5_t1_x1);
    timestampBox.put("n1_5_t1_x2", n1_5_t1_x2);

    timestampGroupBox.put("n1_6", n1_6);
    timestampBox.put("n1_6_t1_x0", n1_6_t1_x0);
    timestampBox.put("n1_6_t1_x1", n1_6_t1_x1);
    timestampBox.put("n1_6_t1_x2", n1_6_t1_x2);

    timestampGroupBox.put("n1_7", n1_7);
    timestampBox.put("n1_7_t1_x0", n1_7_t1_x0);
    timestampBox.put("n1_7_t2_x0", n1_7_t2_x0);
    timestampBox.put("n1_7_t3_x0", n1_7_t3_x0);
    timestampBox.put("n1_7_t1_x1", n1_7_t1_x1);
    timestampBox.put("n1_7_t2_x1", n1_7_t2_x1);
    timestampBox.put("n1_7_t3_x1", n1_7_t3_x1);
    timestampBox.put("n1_7_t1_x2", n1_7_t1_x2);
    timestampBox.put("n1_7_t2_x2", n1_7_t2_x2);
    timestampBox.put("n1_7_t3_x2", n1_7_t3_x2);

    timestampGroupBox.put("n1_8", n1_8);
    timestampBox.put("n1_8_t1_x0", n1_8_t1_x0);
    timestampBox.put("n1_8_t1_x1", n1_8_t1_x1);
    timestampBox.put("n1_8_t1_x2", n1_8_t1_x2);

    timestampGroupBox.put("n1_9", n1_9);
    timestampBox.put("n1_9_t1_x0", n1_9_t1_x0);
    timestampBox.put("n1_9_t1_x1", n1_9_t1_x1);
    timestampBox.put("n1_9_t1_x2", n1_9_t1_x2);

    timestampGroupBox.put("n1_10", n1_10);
    timestampBox.put("n1_10_t1_x0", n1_10_t1_x0);
    timestampBox.put("n1_10_t2_x0", n1_10_t2_x0);
    timestampBox.put("n1_10_t3_x0", n1_10_t3_x0);
    timestampBox.put("n1_10_t1_x1", n1_10_t1_x1);
    timestampBox.put("n1_10_t2_x1", n1_10_t2_x1);
    timestampBox.put("n1_10_t3_x1", n1_10_t3_x1);
    timestampBox.put("n1_10_t1_x2", n1_10_t1_x2);
    timestampBox.put("n1_10_t2_x2", n1_10_t2_x2);
    timestampBox.put("n1_10_t3_x2", n1_10_t3_x2);

    timestampGroupBox.put("n1_11", n1_11);
    timestampBox.put("n1_11_t1_x0", n1_11_t1_x0);
    timestampBox.put("n1_11_t1_x1", n1_11_t1_x1);
    timestampBox.put("n1_11_t1_x2", n1_11_t1_x2);

    timestampGroupBox.put("n1_12", n1_12);
    timestampBox.put("n1_12_t1_x0", n1_12_t1_x0);
    timestampBox.put("n1_12_t1_x1", n1_12_t1_x1);
    timestampBox.put("n1_12_t1_x2", n1_12_t1_x2);

    timestampGroupBox.put("n1_13", n1_13);
    timestampBox.put("n1_13_t1_x0", n1_13_t1_x0);
    timestampBox.put("n1_13_t2_x0", n1_13_t2_x0);
    timestampBox.put("n1_13_t1_x1", n1_13_t1_x1);
    timestampBox.put("n1_13_t2_x1", n1_13_t2_x1);
    timestampBox.put("n1_13_t1_x2", n1_13_t1_x2);
    timestampBox.put("n1_13_t2_x2", n1_13_t2_x2);

    timestampGroupBox.put("n1_14", n1_14);
    timestampBox.put("n1_14_t1_x0", n1_14_t1_x0);
    timestampBox.put("n1_14_t1_x1", n1_14_t1_x1);
    timestampBox.put("n1_14_t1_x2", n1_14_t1_x2);

    timestampGroupBox.put("n1_15", n1_15);
    timestampBox.put("n1_15_t1_x0", n1_15_t1_x0);
    timestampBox.put("n1_15_t1_x1", n1_15_t1_x1);
    timestampBox.put("n1_15_t1_x2", n1_15_t1_x2);

    timestampGroupBox.put("n1_16", n1_16);
    timestampBox.put("n1_16_t1_x0", n1_16_t1_x0);
    timestampBox.put("n1_16_t2_x0", n1_16_t2_x0);
    timestampBox.put("n1_16_t1_x1", n1_16_t1_x1);
    timestampBox.put("n1_16_t2_x1", n1_16_t2_x1);
    timestampBox.put("n1_16_t1_x2", n1_16_t1_x2);
    timestampBox.put("n1_16_t2_x2", n1_16_t2_x2);

    timestampGroupBox.put("n1_17", n1_17);
    timestampBox.put("n1_17_t1_x0", n1_17_t1_x0);
    timestampBox.put("n1_17_t2_x0", n1_17_t2_x0);
    timestampBox.put("n1_17_t1_x1", n1_17_t1_x1);
    timestampBox.put("n1_17_t2_x1", n1_17_t2_x1);
    timestampBox.put("n1_17_t1_x2", n1_17_t1_x2);
    timestampBox.put("n1_17_t2_x2", n1_17_t2_x2);

    timestampGroupBox.put("n1_18", n1_18);
    timestampBox.put("n1_18_t1_x0", n1_18_t1_x0);
    timestampBox.put("n1_18_t2_x0", n1_18_t2_x0);
    timestampBox.put("n1_18_t3_x0", n1_18_t3_x0);
    timestampBox.put("n1_18_t1_x1", n1_18_t1_x1);
    timestampBox.put("n1_18_t2_x1", n1_18_t2_x1);
    timestampBox.put("n1_18_t3_x1", n1_18_t3_x1);
    timestampBox.put("n1_18_t1_x2", n1_18_t1_x2);
    timestampBox.put("n1_18_t2_x2", n1_18_t2_x2);
    timestampBox.put("n1_18_t3_x2", n1_18_t3_x2);

    timestampGroupBox.put("n2_1", n2_1);
    timestampBox.put("n2_1_t1_x0", n2_1_t1_x0);
    timestampBox.put("n2_1_t2_x0", n2_1_t2_x0);
    timestampBox.put("n2_1_t1_x1", n2_1_t1_x1);
    timestampBox.put("n2_1_t2_x1", n2_1_t2_x1);
    timestampBox.put("n2_1_t1_x2", n2_1_t1_x2);
    timestampBox.put("n2_1_t2_x2", n2_1_t2_x2);

    timestampGroupBox.put("n2_2", n2_2);
    timestampBox.put("n2_2_t1_x0", n2_2_t1_x0);
    timestampBox.put("n2_2_t2_x0", n2_2_t2_x0);
    timestampBox.put("n2_2_t1_x1", n2_2_t1_x1);
    timestampBox.put("n2_2_t2_x1", n2_2_t2_x1);
    timestampBox.put("n2_2_t1_x2", n2_2_t1_x2);
    timestampBox.put("n2_2_t2_x2", n2_2_t2_x2);

    timestampGroupBox.put("n2_3", n2_3);
    timestampBox.put("n2_3_t1_x0", n2_3_t1_x0);
    timestampBox.put("n2_3_t2_x0", n2_3_t2_x0);
    timestampBox.put("n2_3_t1_x1", n2_3_t1_x1);
    timestampBox.put("n2_3_t2_x1", n2_3_t2_x1);
    timestampBox.put("n2_3_t1_x2", n2_3_t1_x2);
    timestampBox.put("n2_3_t2_x2", n2_3_t2_x2);

    timestampGroupBox.put("n2_4", n2_4);
    timestampBox.put("n2_4_t1_x0", n2_4_t1_x0);
    timestampBox.put("n2_4_t2_x0", n2_4_t2_x0);
    timestampBox.put("n2_4_t1_x1", n2_4_t1_x1);
    timestampBox.put("n2_4_t2_x1", n2_4_t2_x1);
    timestampBox.put("n2_4_t1_x2", n2_4_t1_x2);
    timestampBox.put("n2_4_t2_x2", n2_4_t2_x2);

    timestampGroupBox.put("n2_5", n2_5);
    timestampBox.put("n2_5_t1_x0", n2_5_t1_x0);
    timestampBox.put("n2_5_t2_x0", n2_5_t2_x0);
    timestampBox.put("n2_5_t1_x1", n2_5_t1_x1);
    timestampBox.put("n2_5_t2_x1", n2_5_t2_x1);
    timestampBox.put("n2_5_t1_x2", n2_5_t1_x2);
    timestampBox.put("n2_5_t2_x2", n2_5_t2_x2);

    timestampGroupBox.put("n3_3", n3_3);
    timestampBox.put("n3_3_t1_x0", n3_3_t1_x0);
    timestampBox.put("n3_3_t2_x0", n3_3_t2_x0);
    timestampBox.put("n3_3_t3_x0", n3_3_t3_x0);
    timestampBox.put("n3_3_t1_x1", n3_3_t1_x1);
    timestampBox.put("n3_3_t2_x1", n3_3_t2_x1);
    timestampBox.put("n3_3_t3_x1", n3_3_t3_x1);
    timestampBox.put("n3_3_t1_x2", n3_3_t1_x2);
    timestampBox.put("n3_3_t2_x2", n3_3_t2_x2);
    timestampBox.put("n3_3_t3_x2", n3_3_t3_x2);

    timestampGroupBox.put("n2_7", n2_7);
    timestampBox.put("n2_7_t1_x0", n2_7_t1_x0);
    timestampBox.put("n2_7_t2_x0", n2_7_t2_x0);
    timestampBox.put("n2_7_t1_x1", n2_7_t1_x1);
    timestampBox.put("n2_7_t2_x1", n2_7_t2_x1);
    timestampBox.put("n2_7_t1_x2", n2_7_t1_x2);
    timestampBox.put("n2_7_t2_x2", n2_7_t2_x2);

    timestampGroupBox.put("n2_8", n2_8);
    timestampBox.put("n2_8_t1_x0", n2_8_t1_x0);
    timestampBox.put("n2_8_t2_x0", n2_8_t2_x0);
    timestampBox.put("n2_8_t1_x1", n2_8_t1_x1);
    timestampBox.put("n2_8_t2_x1", n2_8_t2_x1);
    timestampBox.put("n2_8_t1_x2", n2_8_t1_x2);
    timestampBox.put("n2_8_t2_x2", n2_8_t2_x2);

    timestampGroupBox.put("n2_9", n2_9);
    timestampBox.put("n2_9_t1_x0", n2_9_t1_x0);
    timestampBox.put("n2_9_t2_x0", n2_9_t2_x0);
    timestampBox.put("n2_9_t1_x1", n2_9_t1_x1);
    timestampBox.put("n2_9_t2_x1", n2_9_t2_x1);
    timestampBox.put("n2_9_t1_x2", n2_9_t1_x2);
    timestampBox.put("n2_9_t2_x2", n2_9_t2_x2);

    timestampGroupBox.put("n2_10", n2_10);
    timestampBox.put("n2_10_t1_x0", n2_10_t1_x0);
    timestampBox.put("n2_10_t2_x0", n2_10_t2_x0);
    timestampBox.put("n2_10_t1_x1", n2_10_t1_x1);
    timestampBox.put("n2_10_t2_x1", n2_10_t2_x1);
    timestampBox.put("n2_10_t1_x2", n2_10_t1_x2);
    timestampBox.put("n2_10_t2_x2", n2_10_t2_x2);

    timestampGroupBox.put("n2_11", n2_11);
    timestampBox.put("n2_11_t1_x0", n2_11_t1_x0);
    timestampBox.put("n2_11_t2_x0", n2_11_t2_x0);
    timestampBox.put("n2_11_t3_x0", n2_11_t3_x0);
    timestampBox.put("n2_11_t4_x0", n2_11_t4_x0);
    timestampBox.put("n2_11_t5_x0", n2_11_t5_x0);
    timestampBox.put("n2_11_t1_x1", n2_11_t1_x1);
    timestampBox.put("n2_11_t2_x1", n2_11_t2_x1);
    timestampBox.put("n2_11_t3_x1", n2_11_t3_x1);
    timestampBox.put("n2_11_t4_x1", n2_11_t4_x1);
    timestampBox.put("n2_11_t5_x1", n2_11_t5_x1);
    timestampBox.put("n2_11_t1_x2", n2_11_t1_x2);
    timestampBox.put("n2_11_t2_x2", n2_11_t2_x2);
    timestampBox.put("n2_11_t3_x2", n2_11_t3_x2);
    timestampBox.put("n2_11_t4_x2", n2_11_t4_x2);
    timestampBox.put("n2_11_t5_x2", n2_11_t5_x2);

    timestampGroupBox.put("n2_12", n2_12);
    timestampBox.put("n2_12_t1_x0", n2_12_t1_x0);
    timestampBox.put("n2_12_t2_x0", n2_12_t2_x0);
    timestampBox.put("n2_12_t1_x1", n2_12_t1_x1);
    timestampBox.put("n2_12_t2_x1", n2_12_t2_x1);
    timestampBox.put("n2_12_t1_x2", n2_12_t1_x2);
    timestampBox.put("n2_12_t2_x2", n2_12_t2_x2);

    timestampGroupBox.put("n3_1", n3_1);
    timestampBox.put("n3_1_t1_x0", n3_1_t1_x0);
    timestampBox.put("n3_1_t2_x0", n3_1_t2_x0);
    timestampBox.put("n3_1_t3_x0", n3_1_t3_x0);
    timestampBox.put("n3_1_t1_x1", n3_1_t1_x1);
    timestampBox.put("n3_1_t2_x1", n3_1_t2_x1);
    timestampBox.put("n3_1_t3_x1", n3_1_t3_x1);
    timestampBox.put("n3_1_t1_x2", n3_1_t1_x2);
    timestampBox.put("n3_1_t2_x2", n3_1_t2_x2);
    timestampBox.put("n3_1_t3_x2", n3_1_t3_x2);

    timestampGroupBox.put("n3_2", n3_2);
    timestampBox.put("n3_2_t1_x0", n3_2_t1_x0);
    timestampBox.put("n3_2_t2_x0", n3_2_t2_x0);
    timestampBox.put("n3_2_t3_x0", n3_2_t3_x0);
    timestampBox.put("n3_2_t1_x1", n3_2_t1_x1);
    timestampBox.put("n3_2_t2_x1", n3_2_t2_x1);
    timestampBox.put("n3_2_t3_x1", n3_2_t3_x1);
    timestampBox.put("n3_2_t1_x2", n3_2_t1_x2);
    timestampBox.put("n3_2_t2_x2", n3_2_t2_x2);
    timestampBox.put("n3_2_t3_x2", n3_2_t3_x2);

    timestampGroupBox.put("n2_6", n2_6);
    timestampBox.put("n2_6_t1_x0", n2_6_t1_x0);
    timestampBox.put("n2_6_t2_x0", n2_6_t2_x0);
    timestampBox.put("n2_6_t1_x1", n2_6_t1_x1);
    timestampBox.put("n2_6_t2_x1", n2_6_t2_x1);
    timestampBox.put("n2_6_t1_x2", n2_6_t1_x2);
    timestampBox.put("n2_6_t2_x2", n2_6_t2_x2);

    timestampGroupBox.put("n3_4", n3_4);
    timestampBox.put("n3_4_t1_x0", n3_4_t1_x0);
    timestampBox.put("n3_4_t2_x0", n3_4_t2_x0);
    timestampBox.put("n3_4_t3_x0", n3_4_t3_x0);
    timestampBox.put("n3_4_t1_x1", n3_4_t1_x1);
    timestampBox.put("n3_4_t2_x1", n3_4_t2_x1);
    timestampBox.put("n3_4_t3_x1", n3_4_t3_x1);
    timestampBox.put("n3_4_t1_x2", n3_4_t1_x2);
    timestampBox.put("n3_4_t2_x2", n3_4_t2_x2);
    timestampBox.put("n3_4_t3_x2", n3_4_t3_x2);

    timestampGroupBox.put("n2_13", n2_13);
    timestampBox.put("n2_13_t1_x0", n2_13_t1_x0);
    timestampBox.put("n2_13_t2_x0", n2_13_t2_x0);
    timestampBox.put("n2_13_t3_x0", n2_13_t3_x0);
    timestampBox.put("n2_13_t4_x0", n2_13_t4_x0);
    timestampBox.put("n2_13_t1_x1", n2_13_t1_x1);
    timestampBox.put("n2_13_t2_x1", n2_13_t2_x1);
    timestampBox.put("n2_13_t3_x1", n2_13_t3_x1);
    timestampBox.put("n2_13_t4_x1", n2_13_t4_x1);
    timestampBox.put("n2_13_t1_x2", n2_13_t1_x2);
    timestampBox.put("n2_13_t2_x2", n2_13_t2_x2);
    timestampBox.put("n2_13_t3_x2", n2_13_t3_x2);
    timestampBox.put("n2_13_t4_x2", n2_13_t4_x2);

    timestampGroupBox.put("n3_5", n3_5);
    timestampBox.put("n3_5_t1_x0", n3_5_t1_x0);
    timestampBox.put("n3_5_t2_x0", n3_5_t2_x0);
    timestampBox.put("n3_5_t3_x0", n3_5_t3_x0);
    timestampBox.put("n3_5_t1_x1", n3_5_t1_x1);
    timestampBox.put("n3_5_t2_x1", n3_5_t2_x1);
    timestampBox.put("n3_5_t3_x1", n3_5_t3_x1);
    timestampBox.put("n3_5_t1_x2", n3_5_t1_x2);
    timestampBox.put("n3_5_t2_x2", n3_5_t2_x2);
    timestampBox.put("n3_5_t3_x2", n3_5_t3_x2);
}

  static void saveTempStamp() {
    // 원본: ratio = logicalWidth / 390. 이 앱에서는 렌더러가 390 기준 스케일을 적용합니다.
    const double ratio = 1.0;

    TimestampGroupEntity s1_1 = TimestampGroupEntity("s1_1", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s1_1.png", null, Colors.black.value, 1);
    TimestampEntity s1_1_t1_x0 = TimestampEntity.init(ratio, "s1_1_t1_x0", "s1_1", "tvn_fun_story", "yyyy.MM.dd.E a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 85, 332, 220, 40, 26, null, 0);
    ImageEntity s1_1_i1_x0 = ImageEntity.init(ratio, "s1_1_i1_x0", "s1_1", "stamp", "assets/timestamp/image/stamp/stamp_1.png", 55, 325, 280, 50, 1, 0);
    TimestampEntity s1_1_t1_x1 = TimestampEntity.init(ratio, "s1_1_t1_x1", "s1_1", "tvn_fun_story", "yyyy.MM.dd.E a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 72.5, 330, 245, 40, 30, null, 1);
    ImageEntity s1_1_i1_x1 = ImageEntity.init(ratio, "s1_1_i1_x1", "s1_1", "stamp", "assets/timestamp/image/stamp/stamp_1.png", 40, 318, 310, 60, 1, 1);
    TimestampEntity s1_1_t1_x2 = TimestampEntity.init(ratio, "s1_1_t1_x2", "s1_1", "tvn_fun_story", "yyyy.MM.dd.E a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 60, 327, 270, 40, 34, null, 2);
    ImageEntity s1_1_i1_x2 = ImageEntity.init(ratio, "s1_1_i1_x2", "s1_1", "stamp", "assets/timestamp/image/stamp/stamp_1.png", 25, 310, 340, 70, 1, 2);


    TimestampGroupEntity s1_2 = TimestampGroupEntity("s1_2", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s1_2.png", null, Colors.black.value, 4);
    TimestampEntity s1_2_t1_x0 = TimestampEntity.init(ratio, "s1_2_t1_x0", "s1_2", "cafe24_shiningstar", "yyyy.MM.dd.E a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 85, 332, 220, 40, 30, null, 0);
    ImageEntity s1_2_i1_x0 = ImageEntity.init(ratio, "s1_2_i1_x0", "s1_2", "stamp", "assets/timestamp/image/stamp/stamp_2.png", 55, 325, 280, 50, 1, 0);
    TimestampEntity s1_2_t1_x1 = TimestampEntity.init(ratio, "s1_2_t1_x1", "s1_2", "cafe24_shiningstar", "yyyy.MM.dd.E a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 70, 330, 250, 40, 35, null, 1);
    ImageEntity s1_2_i1_x1 = ImageEntity.init(ratio, "s1_2_i1_x1", "s1_2", "stamp", "assets/timestamp/image/stamp/stamp_2.png", 40, 318, 310, 60, 1, 1);
    TimestampEntity s1_2_t1_x2 = TimestampEntity.init(ratio, "s1_2_t1_x2", "s1_2", "cafe24_shiningstar", "yyyy.MM.dd.E a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 55, 327, 280, 40, 40, null, 2);
    ImageEntity s1_2_i1_x2 = ImageEntity.init(ratio, "s1_2_i1_x2", "s1_2", "stamp", "assets/timestamp/image/stamp/stamp_2.png", 25, 310, 340, 70, 1, 2);

    TimestampGroupEntity s1_3 = TimestampGroupEntity("s1_3", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s1_3.png", null, Colors.black.value, 5);
    TimestampEntity s1_3_t1_x0 = TimestampEntity.initWithFontWeight(ratio, "s1_3_t1_x0", "s1_3", "tvn_fun_story", "E", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 54, 333, 40, 40, 28, RegexUtil.TYPE_DAY_TO_KR, "w900", 0);
    TimestampEntity s1_3_t2_x0 = TimestampEntity.initWithColor(ratio, "s1_3_t2_x0", "s1_3", "kangwon_all_study", "yyyy년 MM월 dd일 a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 80, 330, 260, 40, 20, RegexUtil.TYPE_AMPM_TO_KR, null, Colors.black.value, 0);
    ImageEntity s1_3_i1_x0 = ImageEntity.init(ratio, "s1_3_i1_x0", "s1_3", "stamp", "assets/timestamp/image/stamp/stamp_3.png", 55, 325, 280, 50, 1, 0);
    TimestampEntity s1_3_t1_x1 = TimestampEntity.initWithFontWeight(ratio, "s1_3_t1_x1", "s1_3", "tvn_fun_story", "E", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 41, 332, 40, 40, 35, RegexUtil.TYPE_DAY_TO_KR, "w900", 1);
    TimestampEntity s1_3_t2_x1 = TimestampEntity.initWithColor(ratio, "s1_3_t2_x1", "s1_3", "kangwon_all_study", "yyyy년 MM월 dd일 a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 81, 328, 260, 40, 22, RegexUtil.TYPE_AMPM_TO_KR, null, Colors.black.value, 1);
    ImageEntity s1_3_i1_x1 = ImageEntity.init(ratio, "s1_3_i1_x1", "s1_3", "stamp", "assets/timestamp/image/stamp/stamp_3.png", 40, 318, 310, 60, 1, 1);
    TimestampEntity s1_3_t1_x2 = TimestampEntity.initWithFontWeight(ratio, "s1_3_t1_x2", "s1_3", "tvn_fun_story", "E", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 28, 329, 40, 40, 39, RegexUtil.TYPE_DAY_TO_KR, "w900", 2);
    TimestampEntity s1_3_t2_x2 = TimestampEntity.initWithColor(ratio, "s1_3_t2_x2", "s1_3", "kangwon_all_study", "yyyy년 MM월 dd일 a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 81, 325, 260, 40, 24, RegexUtil.TYPE_AMPM_TO_KR, null, Colors.black.value, 2);
    ImageEntity s1_3_i1_x2 = ImageEntity.init(ratio, "s1_3_i1_x2", "s1_3", "stamp", "assets/timestamp/image/stamp/stamp_3.png", 25, 310, 340, 70, 1, 2);

    TimestampGroupEntity s1_4 = TimestampGroupEntity("s1_4", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s1_4.png", null, Colors.black.value, 8);
    TimestampEntity s1_4_t1_x0 = TimestampEntity.init(ratio, "s1_4_t1_x0", "s1_4", "cafe24_surround_air", "yyyy.MM.dd.E", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 20, 17, 140, 30, 15, null, 0);
    TimestampEntity s1_4_t2_x0 = TimestampEntity.init(ratio, "s1_4_t2_x0", "s1_4", "cafe24_surround_air", "a hh:mm", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 290, 17, 80, 30, 15, null, 0);
    ImageEntity s1_4_i1_x0 = ImageEntity.init(ratio, "s1_4_i1_x0", "s1_4", "stamp", "assets/timestamp/image/stamp/stamp_4.png", 20, 24, 350, 50, 1, 0);
    TimestampEntity s1_4_t1_x1 = TimestampEntity.init(ratio, "s1_4_t1_x1", "s1_4", "cafe24_surround_air", "yyyy.MM.dd.E", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 20, 19, 160, 30, 18, null, 1);
    TimestampEntity s1_4_t2_x1 = TimestampEntity.init(ratio, "s1_4_t2_x1", "s1_4", "cafe24_surround_air", "a hh:mm", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 280, 19, 90, 30, 18, null, 1);
    ImageEntity s1_4_i1_x1 = ImageEntity.init(ratio, "s1_4_i1_x1", "s1_4", "stamp", "assets/timestamp/image/stamp/stamp_4.png", 20, 28, 350, 50, 1, 1);
    TimestampEntity s1_4_t1_x2 = TimestampEntity.init(ratio, "s1_4_t1_x2", "s1_4", "cafe24_surround_air", "yyyy.MM.dd.E", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 20, 20, 180, 30, 21, null, 2);
    TimestampEntity s1_4_t2_x2 = TimestampEntity.init(ratio, "s1_4_t2_x2", "s1_4", "cafe24_surround_air", "a hh:mm", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 270, 20, 100, 30, 21, null, 2);
    ImageEntity s1_4_i1_x2 = ImageEntity.init(ratio, "s1_4_i1_x2", "s1_4", "stamp", "assets/timestamp/image/stamp/stamp_4.png", 20, 31, 350, 50, 1, 2);


    TimestampGroupEntity s1_5 = TimestampGroupEntity("s1_5", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s1_5.png", null, Colors.black.value, 9);
    TimestampEntity s1_5_t1_x0 = TimestampEntity.init(ratio, "s1_5_t1_x0", "s1_5", "rubber_nipple_factory", "yy.MM.dd a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 90, 329, 210, 40, 20, null, 0);
    ImageEntity s1_5_i1_x0 = ImageEntity.init(ratio, "s1_5_i1_x0", "s1_5", "stamp", "assets/timestamp/image/stamp/stamp_5.png", 55, 325, 280, 45, 1, 0);
    TimestampEntity s1_5_t1_x1 = TimestampEntity.init(ratio, "s1_5_t1_x1", "s1_5", "rubber_nipple_factory", "yy.MM.dd a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 70, 323.5, 250, 40, 23, null, 1);
    ImageEntity s1_5_i1_x1 = ImageEntity.init(ratio, "s1_5_i1_x1", "s1_5", "stamp", "assets/timestamp/image/stamp/stamp_5.png", 45, 315.5, 300, 52.5, 1, 1);
    TimestampEntity s1_5_t1_x2 = TimestampEntity.init(ratio, "s1_5_t1_x2", "s1_5", "rubber_nipple_factory", "yy.MM.dd a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 60, 318, 270, 40, 26, null, 2);
    ImageEntity s1_5_i1_x2 = ImageEntity.init(ratio, "s1_5_i1_x2", "s1_5", "stamp", "assets/timestamp/image/stamp/stamp_5.png", 35, 306, 320, 60, 1, 2);


    TimestampGroupEntity s1_6 = TimestampGroupEntity("s1_6", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s1_6.png", null, Colors.black.value, 12);
    TimestampEntity s1_6_t1_x0 = TimestampEntity.init(ratio, "s1_6_t1_x0", "s1_6", "oxanium", "yyyy.MM.dd HH:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 90, 330, 210, 40, 24, null, 0);
    ImageEntity s1_6_i1_x0 = ImageEntity.init(ratio, "s1_6_i1_x0", "s1_6", "stamp", "assets/timestamp/image/stamp/stamp_15.png", 55, 325, 280, 45, 1, 0);
    TimestampEntity s1_6_t1_x1 = TimestampEntity.init(ratio, "s1_6_t1_x1", "s1_6", "oxanium", "yyyy.MM.dd HH:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 80, 326, 230, 40, 27, null, 1);
    ImageEntity s1_6_i1_x1 = ImageEntity.init(ratio, "s1_6_i1_x1", "s1_6", "stamp", "assets/timestamp/image/stamp/stamp_15.png", 45, 317, 300, 52.5, 1, 1);
    TimestampEntity s1_6_t1_x2 = TimestampEntity.init(ratio, "s1_6_t1_x2", "s1_6", "oxanium", "yyyy.MM.dd HH:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 70, 322, 250, 40, 30, null, 2);
    ImageEntity s1_6_i1_x2 = ImageEntity.init(ratio, "s1_6_i1_x2", "s1_6", "stamp", "assets/timestamp/image/stamp/stamp_15.png", 35, 309, 320, 60, 1, 2);

    TimestampGroupEntity s1_7 = TimestampGroupEntity("s1_7", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s1_7.png", null, Colors.black.value, 13);
    TimestampEntity s1_7_t1_x0 = TimestampEntity.init(ratio, "s1_7_t1_x0", "s1_7", "kotra_hope", "a hh:mm yyyy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 80, 165, 230, 40, 24, null, 0);
    ImageEntity s1_7_i1_x0 = ImageEntity.init(ratio, "s1_7_i1_x0", "s1_7", "stamp", "assets/timestamp/image/stamp/stamp_16.png", 115, 187, 160, 40, 1, 0);
    TimestampEntity s1_7_t1_x1 = TimestampEntity.init(ratio, "s1_7_t1_x1", "s1_7", "kotra_hope", "a hh:mm yyyy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 65, 164, 260, 40, 30, null, 1);
    ImageEntity s1_7_i1_x1 = ImageEntity.init(ratio, "s1_7_i1_x1", "s1_7", "stamp", "assets/timestamp/image/stamp/stamp_16.png", 95, 184, 200, 50, 1, 1);
    TimestampEntity s1_7_t1_x2 = TimestampEntity.init(ratio, "s1_7_t1_x2", "s1_7", "kotra_hope", "a hh:mm yyyy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 50, 162, 290, 40, 36, null, 2);
    ImageEntity s1_7_i1_x2 = ImageEntity.init(ratio, "s1_7_i1_x2", "s1_7", "stamp", "assets/timestamp/image/stamp/stamp_16.png", 75, 180, 240, 60, 1, 2);

    TimestampGroupEntity s1_8 = TimestampGroupEntity("s1_8", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s1_8.png", null, Colors.black.value, 16);
    TimestampEntity s1_8_t1_x0 = TimestampEntity.init(ratio, "s1_8_t1_x0", "s1_8", "nanum_yuni_ddingddang", "yyyy년 MM월 dd일 a hh시 mm분", Constants.ALIGN_LEFT, Constants.LOCALE_KR, 15, 330, 210, 40, 24, RegexUtil.TYPE_AMPM_TO_KR, 0);
    ImageEntity s1_8_i1_x0 = ImageEntity.init(ratio, "s1_8_i1_x0", "s1_8", "stamp", "assets/timestamp/image/stamp/stamp_4_3.png", 15, 342, 360, 60, 1, 0);
    TimestampEntity s1_8_t1_x1 = TimestampEntity.init(ratio, "s1_8_t1_x1", "s1_8", "nanum_yuni_ddingddang", "yyyy년 MM월 dd일 a hh시 mm분", Constants.ALIGN_LEFT, Constants.LOCALE_KR, 15, 327, 255, 40, 28, RegexUtil.TYPE_AMPM_TO_KR, 1);
    ImageEntity s1_8_i1_x1 = ImageEntity.init(ratio, "s1_8_i1_x1", "s1_8", "stamp", "assets/timestamp/image/stamp/stamp_4_3.png", 15, 342, 360, 60, 1, 1);
    TimestampEntity s1_8_t1_x2 = TimestampEntity.init(ratio, "s1_8_t1_x2", "s1_8", "nanum_yuni_ddingddang", "yyyy년 MM월 dd일 a hh시 mm분", Constants.ALIGN_LEFT, Constants.LOCALE_KR, 15, 324, 280, 40, 32, RegexUtil.TYPE_AMPM_TO_KR, 2);
    ImageEntity s1_8_i1_x2 = ImageEntity.init(ratio, "s1_8_i1_x2", "s1_8", "stamp", "assets/timestamp/image/stamp/stamp_4_3.png", 15, 342, 360, 60, 1, 2);

    TimestampGroupEntity s1_9 = TimestampGroupEntity("s1_9", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s1_9.png", null, Colors.black.value, 17);
    TimestampEntity s1_9_t1_x0 = TimestampEntity.initWithColor(ratio, "s1_9_t1_x0", "s1_9", "kangwon_study_saeum", "yyyy년 MM월 dd일 a hh시 mm분", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 75, 330, 240, 40, 23, null, null, Colors.black.value, 0);
    ImageEntity s1_9_i1_x0 = ImageEntity.init(ratio, "s1_9_i1_x0", "s1_9", "stamp", "assets/timestamp/image/stamp/stamp_17.png", 65, 330, 260, 45, 1, 0);
    TimestampEntity s1_9_t1_x1 = TimestampEntity.initWithColor(ratio, "s1_9_t1_x1", "s1_9", "kangwon_study_saeum", "yyyy년 MM월 dd일 a hh시 mm분", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 62.5, 326, 265, 40, 26, null, null, Colors.black.value, 1);
    ImageEntity s1_9_i1_x1 = ImageEntity.init(ratio, "s1_9_i1_x1", "s1_9", "stamp", "assets/timestamp/image/stamp/stamp_17.png", 50, 322, 290, 52.5, 1, 1);
    TimestampEntity s1_9_t1_x2 = TimestampEntity.initWithColor(ratio, "s1_9_t1_x2", "s1_9", "kangwon_study_saeum", "yyyy년 MM월 dd일 a hh시 mm분", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 50, 322, 290, 40, 29, null, null, Colors.black.value, 2);
    ImageEntity s1_9_i1_x2 = ImageEntity.init(ratio, "s1_9_i1_x2", "s1_9", "stamp", "assets/timestamp/image/stamp/stamp_17.png", 35, 314, 320, 60, 1, 2);

    TimestampGroupEntity s1_10 = TimestampGroupEntity("s1_10", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s1_10.png", null, null, 20);
    TimestampEntity s1_10_t1_x0 = TimestampEntity.init(ratio, "s1_10_t1_x0", "s1_10", "lobster", "hh:mm a, MMMM dd, yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 80, 173, 230, 44, 20, null, 0);
    ImageEntity s1_10_i1_x0 = ImageEntity.init(ratio, "s1_10_i1_x0", "s1_10", "stamp", "assets/timestamp/image/stamp/stamp_14.png", 55, 175, 20, 40, 1, 0);
    ImageEntity s1_10_i2_x0 = ImageEntity.initWithFlip(ratio, "s1_10_i2_x0", "s1_10", "stamp", "assets/timestamp/image/stamp/stamp_14.png", 320, 175, 20, 40, 1, true, 0);
    TimestampEntity s1_10_t1_x1 = TimestampEntity.init(ratio, "s1_10_t1_x1", "s1_10", "lobster", "hh:mm a, MMMM dd, yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 67.5, 173, 255, 44, 23, null, 1);
    ImageEntity s1_10_i1_x1 = ImageEntity.init(ratio, "s1_10_i1_x1", "s1_10", "stamp", "assets/timestamp/image/stamp/stamp_14.png", 35, 170, 25, 50, 1, 1);
    ImageEntity s1_10_i2_x1 = ImageEntity.initWithFlip(ratio, "s1_10_i2_x1", "s1_10", "stamp", "assets/timestamp/image/stamp/stamp_14.png", 330, 170, 25, 50, 1, true, 1);
    TimestampEntity s1_10_t1_x2 = TimestampEntity.init(ratio, "s1_10_t1_x2", "s1_10", "lobster", "hh:mm a, MMMM dd, yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 55, 173, 280, 44, 26, null, 2);
    ImageEntity s1_10_i1_x2 = ImageEntity.init(ratio, "s1_10_i1_x2", "s1_10", "stamp", "assets/timestamp/image/stamp/stamp_14.png", 15, 165, 30, 60, 1, 2);
    ImageEntity s1_10_i2_x2 = ImageEntity.initWithFlip(ratio, "s1_10_i2_x2", "s1_10", "stamp", "assets/timestamp/image/stamp/stamp_14.png", 345, 165, 30, 60, 1, true, 2);

    TimestampGroupEntity s1_11 = TimestampGroupEntity("s1_11", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s1_11.png", null, Colors.black.value, 21);
    TimestampEntity s1_11_t1_x0 = TimestampEntity.init(ratio, "s1_11_t1_x0", "s1_11", "cafe24_shiningstar", "a hh:mm yyyy/MM/dd E", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 65, 325, 260, 40, 32, null, 0);
    ImageEntity s1_11_i1_x0 = ImageEntity.init(ratio, "s1_11_i1_x0", "s1_11", "stamp", "assets/timestamp/image/stamp/stamp_20.png", 70, 355, 250, 25, 1, 0);
    TimestampEntity s1_11_t1_x1 = TimestampEntity.init(ratio, "s1_11_t1_x1", "s1_11", "cafe24_shiningstar", "a hh:mm yyyy/MM/dd E", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 50, 322, 290, 40, 37, null, 1);
    ImageEntity s1_11_i1_x1 = ImageEntity.init(ratio, "s1_11_i1_x1", "s1_11", "stamp", "assets/timestamp/image/stamp/stamp_20.png", 50, 350, 290, 35, 1, 1);
    TimestampEntity s1_11_t1_x2 = TimestampEntity.init(ratio, "s1_11_t1_x2", "s1_11", "cafe24_shiningstar", "a hh:mm yyyy/MM/dd E", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 45, 319, 300, 40, 42, null, 2);
    ImageEntity s1_11_i1_x2 = ImageEntity.init(ratio, "s1_11_i1_x2", "s1_11", "stamp", "assets/timestamp/image/stamp/stamp_20.png", 30, 345, 330, 45, 1, 2);

    TimestampGroupEntity s1_12 = TimestampGroupEntity("s1_12", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s1_12.png", null, Colors.black.value, 24);
    TimestampEntity s1_12_t1_x0 = TimestampEntity.initWithColor(ratio, "s1_12_t1", "s1_12", "lee_seoyun", "a hh:mm yyyy/MM/dd E", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 65, 335, 260, 40, 20, null, null, Colors.black.value, 0);
    ImageEntity s1_12_i1_x0 = ImageEntity.init(ratio, "s1_12_i1", "s1_12", "stamp", "assets/timestamp/image/stamp/stamp_21.png", 43, 335, 304, 38, 1, 0);
    TimestampEntity s1_12_t1_x1 = TimestampEntity.initWithColor(ratio, "s1_12_t1", "s1_12", "lee_seoyun", "a hh:mm yyyy/MM/dd E", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 60, 332, 270, 40, 22, null, null, Colors.black.value, 1);
    ImageEntity s1_12_i1_x1 = ImageEntity.init(ratio, "s1_12_i1", "s1_12", "stamp", "assets/timestamp/image/stamp/stamp_21.png", 30, 328, 330, 48, 1, 1);
    TimestampEntity s1_12_t1_x2 = TimestampEntity.initWithColor(ratio, "s1_12_t1", "s1_12", "lee_seoyun", "a hh:mm yyyy/MM/dd E", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 55, 330, 280, 40, 24, null, null, Colors.black.value, 2);
    ImageEntity s1_12_i1_x2 = ImageEntity.init(ratio, "s1_12_i1", "s1_12", "stamp", "assets/timestamp/image/stamp/stamp_21.png", 15, 321, 360, 58, 1, 2);

    TimestampGroupEntity s2_1 = TimestampGroupEntity("s2_1", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s2_1.png", null, Colors.black.value, 2);
    TimestampEntity s2_1_t1_x0 = TimestampEntity.init(ratio, "s2_1_t1_x0", "s2_1", "nanum_barunpen", "yyyy/MM/dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 18, 306, 90, 40, 20, null, 0);
    TimestampEntity s2_1_t2_x0 = TimestampEntity.init(ratio, "s2_1_t2_x0", "s2_1", "nanum_barunpen", "a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 18, 344, 70, 40, 20, null, 0);
    ImageEntity s2_1_i1_x0 = ImageEntity.init(ratio, "s2_1_i1_x0", "s2_1", "stamp", "assets/timestamp/image/stamp/stamp_4_2.png", 17, 328, 90, 34, 1, 0);
    TimestampEntity s2_1_t1_x1 = TimestampEntity.init(ratio, "s2_1_t1_x1", "s2_1", "nanum_barunpen", "yyyy/MM/dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 18, 296, 120, 40, 25, null, 1);
    TimestampEntity s2_1_t2_x1 = TimestampEntity.init(ratio, "s2_1_t2_x1", "s2_1", "nanum_barunpen", "a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 18, 342, 100, 40, 25, null, 1);
    ImageEntity s2_1_i1_x1 = ImageEntity.init(ratio, "s2_1_i1_x1", "s2_1", "stamp", "assets/timestamp/image/stamp/stamp_4_2.png", 17, 317, 112, 44, 1, 1);
    TimestampEntity s2_1_t1_x2 = TimestampEntity.init(ratio, "s2_1_t1_x2", "s2_1", "nanum_barunpen", "yyyy/MM/dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 18, 286, 140, 40, 30, null, 2);
    TimestampEntity s2_1_t2_x2 = TimestampEntity.init(ratio, "s2_1_t2_x2", "s2_1", "nanum_barunpen", "a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 18, 340, 110, 40, 30, null, 2);
    ImageEntity s2_1_i1_x2 = ImageEntity.init(ratio, "s2_1_i1_x2", "s2_1", "stamp", "assets/timestamp/image/stamp/stamp_4_2.png", 17, 305, 134, 54, 1, 2);


    TimestampGroupEntity s2_2 = TimestampGroupEntity("s2_2", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s2_2.png", null, Colors.black.value,  3);
    TimestampEntity s2_2_t1_x0 = TimestampEntity.initWithColor(ratio, "s2_2_t1_x0", "s2_2", "nanum_barunpen", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 13, 310, 90, 44, 20, null, null, Colors.black.value, 0);
    TimestampEntity s2_2_t2_x0 = TimestampEntity.init(ratio, "s2_2_t2_x0", "s2_2", "nanum_barunpen", "yyyy MMM dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 12, 342, 110, 44, 20, null, 0);
    ImageEntity s2_2_i1_x0 = ImageEntity.init(ratio, "s2_2_i1_x0", "s2_2", "stamp", "assets/timestamp/image/stamp/stamp_6.png", 17, 314, 80, 34, 1, 0);
    TimestampEntity s2_2_t1_x1 = TimestampEntity.initWithColor(ratio, "s2_2_t1_x1", "s2_2", "nanum_barunpen", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 18, 302, 100, 44, 25, null, null, Colors.black.value, 1);
    TimestampEntity s2_2_t2_x1 = TimestampEntity.init(ratio, "s2_2_t2_x1", "s2_2", "nanum_barunpen", "yyyy MMM dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 12, 340, 125, 44, 25, null, 1);
    ImageEntity s2_2_i1_x1 = ImageEntity.init(ratio, "s2_2_i1_x1", "s2_2", "stamp", "assets/timestamp/image/stamp/stamp_6.png", 18, 301, 100, 44, 1, 1);
    TimestampEntity s2_2_t1_x2 = TimestampEntity.initWithColor(ratio, "s2_2_t1_x2", "s2_2", "nanum_barunpen", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 24, 293, 110, 44, 30, null, null, Colors.black.value, 2);
    TimestampEntity s2_2_t2_x2 = TimestampEntity.init(ratio, "s2_2_t2_x2", "s2_2", "nanum_barunpen", "yyyy MMM dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 12, 338, 140, 44, 30, null, 2);
    ImageEntity s2_2_i1_x2 = ImageEntity.init(ratio, "s2_2_i1_x2", "s2_2", "stamp", "assets/timestamp/image/stamp/stamp_6.png", 19, 287, 120, 54, 1, 2);

    TimestampGroupEntity s2_3 = TimestampGroupEntity("s2_3", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s2_3.png", null, Colors.black.value, 6);
    TimestampEntity s2_3_t1_x0 = TimestampEntity.init(ratio, "s2_3_t1_x0", "s2_3", "lobster", "yyyy.MM.dd.E", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 115, 160, 160, 40, 20, null, 0);
    TimestampEntity s2_3_t2_x0 = TimestampEntity.init(ratio, "s2_3_t2_x0", "s2_3", "lobster", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 115, 190, 160, 50, 30, null, 0);
    ImageEntity s2_3_i1_x0 = ImageEntity.init(ratio, "s2_3_i1_x0", "s2_3", "stamp", "assets/timestamp/image/stamp/stamp_7.png", 125, 140, 140, 25, 1, 0);
    ImageEntity s2_3_i2_x0 = ImageEntity.init(ratio, "s2_3_i2_x0", "s2_3", "stamp", "assets/timestamp/image/stamp/stamp_7.png", 125, 230, 140, 25, 1, 0);
    TimestampEntity s2_3_t1_x1 = TimestampEntity.init(ratio, "s2_3_t1_x1", "s2_3", "lobster", "yyyy.MM.dd.E", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 110, 154, 170, 40, 25, null, 1);
    TimestampEntity s2_3_t2_x1 = TimestampEntity.init(ratio, "s2_3_t2_x1", "s2_3", "lobster", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 110, 191, 170, 50, 37, null, 1);
    ImageEntity s2_3_i1_x1 = ImageEntity.init(ratio, "s2_3_i1_x1", "s2_3", "stamp", "assets/timestamp/image/stamp/stamp_7.png", 107.5, 123, 175, 31, 1, 1);
    ImageEntity s2_3_i2_x1 = ImageEntity.init(ratio, "s2_3_i2_x1", "s2_3", "stamp", "assets/timestamp/image/stamp/stamp_7.png", 107.5, 237, 175, 31, 1, 1);
    TimestampEntity s2_3_t1_x2 = TimestampEntity.init(ratio, "s2_3_t1_x2", "s2_3", "lobster", "yyyy.MM.dd.E", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 95, 148, 200, 40, 30, null, 2);
    TimestampEntity s2_3_t2_x2 = TimestampEntity.init(ratio, "s2_3_t2_x2", "s2_3", "lobster", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 105, 193, 180, 50, 44, null, 2);
    ImageEntity s2_3_i1_x2 = ImageEntity.init(ratio, "s2_3_i1_x2", "s2_3", "stamp", "assets/timestamp/image/stamp/stamp_7.png", 90, 105, 210, 37, 1, 2);
    ImageEntity s2_3_i2_x2 = ImageEntity.init(ratio, "s2_3_i2_x2", "s2_3", "stamp", "assets/timestamp/image/stamp/stamp_7.png", 90, 245, 210, 37, 1, 2);

    TimestampGroupEntity s2_4 = TimestampGroupEntity("s2_4", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s2_4.png", null, Colors.black.value, 7);
    TimestampEntity s2_4_t1_x0 = TimestampEntity.init(ratio, "s2_4_t1_x0", "s2_4", "cafe24_simplehae", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 110, 143, 170, 55, 33, null, 0);
    TimestampEntity s2_4_t2_x0 = TimestampEntity.init(ratio, "s2_4_t2_x0", "s2_4", "cafe24_simplehae", "yyyy.MM.dd.EEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 115, 195, 160, 40, 20, null, 0);
    ImageEntity s2_4_i1_x0 = ImageEntity.init(ratio, "s2_4_i1_x0", "s2_4", "stamp", "assets/timestamp/image/stamp/stamp_4_3.png", 125, 181, 140, 28, 1, 0);
    TimestampEntity s2_4_t1_x1 = TimestampEntity.init(ratio, "s2_4_t1_x1", "s2_4", "cafe24_simplehae", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 102.5, 136, 185, 55, 41, null, 1);
    TimestampEntity s2_4_t2_x1 = TimestampEntity.init(ratio, "s2_4_t2_x1", "s2_4", "cafe24_simplehae", "yyyy.MM.dd.EEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 100, 200, 190, 40, 25, null, 1);
    ImageEntity s2_4_i1_x1 = ImageEntity.init(ratio, "s2_4_i1_x1", "s2_4", "stamp", "assets/timestamp/image/stamp/stamp_4_3.png", 107.5, 172, 175, 44, 1, 1);
    TimestampEntity s2_4_t1_x2 = TimestampEntity.init(ratio, "s2_4_t1_x2", "s2_4", "cafe24_simplehae", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 95, 130, 200, 55, 49, null, 2);
    TimestampEntity s2_4_t2_x2 = TimestampEntity.init(ratio, "s2_4_t2_x2", "s2_4", "cafe24_simplehae", "yyyy.MM.dd.EEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 85, 205, 220, 40, 30, null, 2);
    ImageEntity s2_4_i1_x2 = ImageEntity.init(ratio, "s2_4_i1_x2", "s2_4", "stamp", "assets/timestamp/image/stamp/stamp_4_3.png", 90, 165, 210, 60, 1, 2);

    TimestampGroupEntity s2_5 = TimestampGroupEntity("s2_5", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s2_5.png", null, Colors.black.value, 10);
    TimestampEntity s2_5_t1_x0 = TimestampEntity.init(ratio, "s2_5_t1_x0", "s2_5", "nerko_one", "EEEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 105, 160, 180, 50, 36, RegexUtil.TYPE_ALL_TO_CAPITAL, 0);
    TimestampEntity s2_5_t2_x0 = TimestampEntity.init(ratio, "s2_5_t2_x0", "s2_5", "nerko_one", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 95, 195, 200, 50, 42, null, 0);
    ImageEntity s2_5_i1_x0 = ImageEntity.init(ratio, "s2_5_i1_x0", "s2_5", "stamp", "assets/timestamp/image/stamp/stamp_8.png", 125, 115, 140, 50, 1, 0);
    TimestampEntity s2_5_t1_x1 = TimestampEntity.init(ratio, "s2_5_t1_x1", "s2_5", "nerko_one", "EEEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 95, 159, 200, 50, 43, RegexUtil.TYPE_ALL_TO_CAPITAL, 1);
    TimestampEntity s2_5_t2_x1 = TimestampEntity.init(ratio, "s2_5_t2_x1", "s2_5", "nerko_one", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 95, 200, 200, 50, 50, null, 1);
    ImageEntity s2_5_i1_x1 = ImageEntity.init(ratio, "s2_5_i1_x1", "s2_5", "stamp", "assets/timestamp/image/stamp/stamp_8.png", 110, 95, 170, 65, 1, 1);
    TimestampEntity s2_5_t1_x2 = TimestampEntity.init(ratio, "s2_5_t1_x2", "s2_5", "nerko_one", "EEEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 95, 158, 200, 50, 50, RegexUtil.TYPE_ALL_TO_CAPITAL, 2);
    TimestampEntity s2_5_t2_x2 = TimestampEntity.init(ratio, "s2_5_t2_x2", "s2_5", "nerko_one", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 95, 205, 200, 50, 58, null, 2);
    ImageEntity s2_5_i1_x2 = ImageEntity.init(ratio, "s2_5_i1_x2", "s2_5", "stamp", "assets/timestamp/image/stamp/stamp_8.png", 95, 75, 200, 80, 1, 2);

    TimestampGroupEntity s2_6 = TimestampGroupEntity("s2_6", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s2_6.png", null, Colors.black.value, 11);
    TimestampEntity s2_6_t1_x0 = TimestampEntity.init(ratio, "s2_6_t1_x0", "s2_6", "pacifico_regular", "EEEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 120, 137, 150, 44, 24, null, 0);
    TimestampEntity s2_6_t2_x0 = TimestampEntity.init(ratio, "s2_6_t2_x0", "s2_6", "nanum_barunpen", "HH:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 125, 179, 140, 50, 40, null, 0);
    ImageEntity s2_6_i1_x0 = ImageEntity.init(ratio, "s2_6_i1_x0", "s2_6", "stamp", "assets/timestamp/image/stamp/stamp_9.png", 115, 115, 160, 160, 1, 0);
    TimestampEntity s2_6_t1_x1 = TimestampEntity.init(ratio, "s2_6_t1_x1", "s2_6", "pacifico_regular", "EEEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 115, 130, 160, 44, 30, null, 1);
    TimestampEntity s2_6_t2_x1 = TimestampEntity.init(ratio, "s2_6_t2_x1", "s2_6", "nanum_barunpen", "HH:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 115, 182, 160, 50, 50, null, 1);
    ImageEntity s2_6_i1_x1 = ImageEntity.init(ratio, "s2_6_i1_x1", "s2_6", "stamp", "assets/timestamp/image/stamp/stamp_9.png", 95, 95, 200, 200, 1, 1);
    TimestampEntity s2_6_t1_x2 = TimestampEntity.init(ratio, "s2_6_t1_x2", "s2_6", "pacifico_regular", "EEEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 105, 122, 180, 44, 36, null, 2);
    TimestampEntity s2_6_t2_x2 = TimestampEntity.init(ratio, "s2_6_t2_x2", "s2_6", "nanum_barunpen", "HH:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 105, 185, 180, 50, 60, null, 2);
    ImageEntity s2_6_i1_x2 = ImageEntity.init(ratio, "s2_6_i1_x2", "s2_6", "stamp", "assets/timestamp/image/stamp/stamp_9.png", 75, 75, 240, 240, 1, 2);

    TimestampGroupEntity s3_1 = TimestampGroupEntity("s3_1", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s3_1.png", null, Colors.black.value, 14);
    TimestampEntity s3_1_t1_x0 = TimestampEntity.init(ratio, "s3_1_t1_x0", "s3_1", "tvn_fun_story", "yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 123, 100, 40, 36, null, 0);
    TimestampEntity s3_1_t2_x0 = TimestampEntity.init(ratio, "s3_1_t2_x0", "s3_1", "tvn_fun_story", "MMMM dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 95, 172, 200, 40, 36, null, 0);
    TimestampEntity s3_1_t3_x0 = TimestampEntity.init(ratio, "s3_1_t3_x0", "s3_1", "tvn_fun_story", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 115, 225, 160, 40, 36, null, 0);
    ImageEntity s3_1_i1_x0 = ImageEntity.init(ratio, "s3_1_i1_x0", "s3_1", "stamp", "assets/timestamp/image/stamp/stamp_10.png", 120, 152, 150, 25, 1, 0);
    ImageEntity s3_1_i2_x0 = ImageEntity.init(ratio, "s3_1_i2_x0", "s3_1", "stamp", "assets/timestamp/image/stamp/stamp_10.png", 120, 207, 150, 25, 1, 0);
    TimestampEntity s3_1_t1_x1 = TimestampEntity.init(ratio, "s3_1_t1_x1", "s3_1", "tvn_fun_story", "yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 114, 100, 40, 45, null, 1);
    TimestampEntity s3_1_t2_x1 = TimestampEntity.init(ratio, "s3_1_t2_x1", "s3_1", "tvn_fun_story", "MMMM dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 95, 173.5, 200, 40, 45, null, 1);
    TimestampEntity s3_1_t3_x1 = TimestampEntity.init(ratio, "s3_1_t3_x1", "s3_1", "tvn_fun_story", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 115, 238.5, 160, 40, 45, null, 1);
    ImageEntity s3_1_i1_x1 = ImageEntity.init(ratio, "s3_1_i1_x1", "s3_1", "stamp", "assets/timestamp/image/stamp/stamp_10.png", 101, 146, 188, 31, 1, 1);
    ImageEntity s3_1_i2_x1 = ImageEntity.init(ratio, "s3_1_i2_x1", "s3_1", "stamp", "assets/timestamp/image/stamp/stamp_10.png", 101, 211, 188, 31, 1, 1);
    TimestampEntity s3_1_t1_x2 = TimestampEntity.init(ratio, "s3_1_t1_x2", "s3_1", "tvn_fun_story", "yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 105, 100, 40, 54, null, 2);
    TimestampEntity s3_1_t2_x2 = TimestampEntity.init(ratio, "s3_1_t2_x2", "s3_1", "tvn_fun_story", "MMMM dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 95, 175, 200, 40, 54, null, 2);
    TimestampEntity s3_1_t3_x2 = TimestampEntity.init(ratio, "s3_1_t3_x2", "s3_1", "tvn_fun_story", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 115, 252, 160, 40, 54, null, 2);
    ImageEntity s3_1_i1_x2 = ImageEntity.init(ratio, "s3_1_i1_x2", "s3_1", "stamp", "assets/timestamp/image/stamp/stamp_10.png", 82, 140, 226, 37, 1, 2);
    ImageEntity s3_1_i2_x2 = ImageEntity.init(ratio, "s3_1_i2_x2", "s3_1", "stamp", "assets/timestamp/image/stamp/stamp_10.png", 82, 215, 226, 37, 1, 2);

    TimestampGroupEntity s3_2 = TimestampGroupEntity("s3_2", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s3_2.png", null, null, 15);
    TimestampEntity s3_2_t1_x0 = TimestampEntity.init(ratio, "s3_2_t1", "s3_2", "tvn_fun_story", "yy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 135, 130, 40, 28, null, 0);
    TimestampEntity s3_2_t2_x0 = TimestampEntity.initWithFontWeight(ratio, "s3_2_t2", "s3_2", "tvn_fun_story", "EEEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 130, 167, 130, 60, 46, RegexUtil.TYPE_FULL_DAY_TO_KR, "w900", 0);
    TimestampEntity s3_2_t3_x0 = TimestampEntity.init(ratio, "s3_2_t3", "s3_2", "tvn_fun_story", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 130, 217, 130, 40, 28, RegexUtil.TYPE_AMPM_TO_KR, 0);
    ImageEntity s3_2_i1_x0 = ImageEntity.init(ratio, "s3_2_i1", "s3_2", "stamp", "assets/timestamp/image/stamp/stamp_11.png", 145, 104, 104, 24, 1, 0);
    ImageEntity s3_2_i2_x0 = ImageEntity.initWithFlip(ratio, "s3_2_i2", "s3_2", "stamp", "assets/timestamp/image/stamp/stamp_11.png", 145, 257, 104, 24, 1, true, 0);
    TimestampEntity s3_2_t1_x1 = TimestampEntity.init(ratio, "s3_2_t1", "s3_2", "tvn_fun_story", "yy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 127, 130, 40, 35, null, 1);
    TimestampEntity s3_2_t2_x1 = TimestampEntity.initWithFontWeight(ratio, "s3_2_t2", "s3_2", "tvn_fun_story", "EEEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 130, 168, 130, 60, 52.5, RegexUtil.TYPE_FULL_DAY_TO_KR, "w900", 1);
    TimestampEntity s3_2_t3_x1 = TimestampEntity.init(ratio, "s3_2_t3", "s3_2", "tvn_fun_story", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 130, 227, 130, 40, 35, RegexUtil.TYPE_AMPM_TO_KR, 1);
    ImageEntity s3_2_i1_x1 = ImageEntity.init(ratio, "s3_2_i1", "s3_2", "stamp", "assets/timestamp/image/stamp/stamp_11.png", 130, 84, 130, 30, 1, 1);
    ImageEntity s3_2_i2_x1 = ImageEntity.initWithFlip(ratio, "s3_2_i2", "s3_2", "stamp", "assets/timestamp/image/stamp/stamp_11.png", 130, 273, 130, 30, 1, true, 1);
    TimestampEntity s3_2_t1_x2 = TimestampEntity.init(ratio, "s3_2_t1_x2", "s3_2", "tvn_fun_story", "yy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 119, 130, 40, 42, null, 2);
    TimestampEntity s3_2_t2_x2 = TimestampEntity.initWithFontWeight(ratio, "s3_2_t2_x2", "s3_2", "tvn_fun_story", "EEEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 130, 169, 130, 60, 59, RegexUtil.TYPE_FULL_DAY_TO_KR, "w900", 2);
    TimestampEntity s3_2_t3_x2 = TimestampEntity.init(ratio, "s3_2_t3_x2", "s3_2", "tvn_fun_story", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 130, 237, 130, 40, 42, RegexUtil.TYPE_AMPM_TO_KR, 2);
    ImageEntity s3_2_i1_x2 = ImageEntity.init(ratio, "s3_2_i1_x2", "s3_2", "stamp", "assets/timestamp/image/stamp/stamp_11.png", 117, 64, 156, 36, 1, 2);
    ImageEntity s3_2_i2_x2 = ImageEntity.initWithFlip(ratio, "s3_2_i2_x2", "s3_2", "stamp", "assets/timestamp/image/stamp/stamp_11.png", 117, 289, 156, 36, 1, true, 2);

    TimestampGroupEntity s3_3 = TimestampGroupEntity("s3_3", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s3_3.png", null, Colors.black.value, 18);
    TimestampEntity s3_3_t1_x0 = TimestampEntity.init(ratio, "s3_3_t1_x0", "s3_3", "rubber_nipple_factory", "MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 123, 100, 40, 21, null, 0);
    TimestampEntity s3_3_t2_x0 = TimestampEntity.initWithFontWeight(ratio, "s3_3_t2_x0", "s3_3", "rubber_nipple_factory", "HH", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 135, 165, 120, 60, 46, null, "w900", 0);
    TimestampEntity s3_3_t3_x0 = TimestampEntity.initWithFontWeight(ratio, "s3_3_t3_x0", "s3_3", "rubber_nipple_factory", "mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 135, 220, 120, 60, 46, null, "w900", 0);
    ImageEntity s3_3_i1_x0 = ImageEntity.init(ratio, "s3_3_i1_x0", "s3_3", "stamp", "assets/timestamp/image/stamp/stamp_12.png", 130, 97, 130, 195, 1, 0);
    TimestampEntity s3_3_t1_x1 = TimestampEntity.init(ratio, "s3_3_t1_x1", "s3_3", "rubber_nipple_factory", "MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 113, 100, 40, 26, null, 1);
    TimestampEntity s3_3_t2_x1 = TimestampEntity.initWithFontWeight(ratio, "s3_3_t2_x1", "s3_3", "rubber_nipple_factory", "HH", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 135, 165, 120, 60, 53, null, "w900", 1);
    TimestampEntity s3_3_t3_x1 = TimestampEntity.initWithFontWeight(ratio, "s3_3_t3_x1", "s3_3", "rubber_nipple_factory", "mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 135, 230, 120, 60, 53, null, "w900", 1);
    ImageEntity s3_3_i1_x1 = ImageEntity.init(ratio, "s3_3_i1_x1", "s3_3", "stamp", "assets/timestamp/image/stamp/stamp_12.png", 114, 73, 162, 243, 1, 1);
    TimestampEntity s3_3_t1_x2 = TimestampEntity.init(ratio, "s3_3_t1_x2", "s3_3", "rubber_nipple_factory", "MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 103, 100, 40, 31, null, 2);
    TimestampEntity s3_3_t2_x2 = TimestampEntity.initWithFontWeight(ratio, "s3_3_t2_x2", "s3_3", "rubber_nipple_factory", "HH", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 135, 165, 120, 60, 60, null, "w900", 2);
    TimestampEntity s3_3_t3_x2 = TimestampEntity.initWithFontWeight(ratio, "s3_3_t3_x2", "s3_3", "rubber_nipple_factory", "mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 135, 240, 120, 60, 60, null, "w900", 2);
    ImageEntity s3_3_i1_x2 = ImageEntity.init(ratio, "s3_3_i1_x2", "s3_3", "stamp", "assets/timestamp/image/stamp/stamp_12.png", 98, 49, 194, 291, 1, 2);

    TimestampGroupEntity s3_4 = TimestampGroupEntity("s3_4", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s3_4.png", null, Colors.black.value, 19);
    TimestampEntity s3_4_t1_x0 = TimestampEntity.init(ratio, "s3_4_t1", "s3_4", "rubber_nipple_factory", "a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 165, 126, 60, 30, 19, null, 0);
    TimestampEntity s3_4_t2_x0 = TimestampEntity.initWithFontWeight(ratio, "s3_4_t2", "s3_4", "rubber_nipple_factory", "hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 110, 165, 170, 60, 46, null, "w900", 0);
    TimestampEntity s3_4_t3_x0 = TimestampEntity.init(ratio, "s3_4_t3", "s3_4", "rubber_nipple_factory", "yy.MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 135, 238, 120, 30, 19, null, 0);
    ImageEntity s3_4_i1_x0 = ImageEntity.init(ratio, "s3_4_i1", "s3_4", "stamp", "assets/timestamp/image/stamp/stamp_13.png", 95, 123, 200, 145, 1, 0);
    TimestampEntity s3_4_t1_x1 = TimestampEntity.init(ratio, "s3_4_t1", "s3_4", "rubber_nipple_factory", "a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 165, 114, 60, 30, 24, null, 1);
    TimestampEntity s3_4_t2_x1 = TimestampEntity.initWithFontWeight(ratio, "s3_4_t2", "s3_4", "rubber_nipple_factory", "hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 95, 165, 200, 60, 58, null, "w900", 1);
    TimestampEntity s3_4_t3_x1 = TimestampEntity.init(ratio, "s3_4_t3", "s3_4", "rubber_nipple_factory", "yy.MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 252, 130, 30, 24, null, 1);
    ImageEntity s3_4_i1_x1 = ImageEntity.init(ratio, "s3_4_i1_x2", "s3_4", "stamp", "assets/timestamp/image/stamp/stamp_13.png", 70, 105, 250, 180, 1, 1);
    TimestampEntity s3_4_t1_x2 = TimestampEntity.init(ratio, "s3_4_t1_x2", "s3_4", "rubber_nipple_factory", "a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 165, 101, 60, 30, 28, null, 2);
    TimestampEntity s3_4_t2_x2 = TimestampEntity.initWithFontWeight(ratio, "s3_4_t2_x2", "s3_4", "rubber_nipple_factory", "hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 80, 165, 230, 60, 70, null, "w900", 2);
    TimestampEntity s3_4_t3_x2 = TimestampEntity.init(ratio, "s3_4_t3_x2", "s3_4", "rubber_nipple_factory", "yy.MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 125, 267, 140, 30, 28, null, 2);
    ImageEntity s3_4_i1_x2 = ImageEntity.init(ratio, "s3_4_i1_x2", "s3_4", "stamp", "assets/timestamp/image/stamp/stamp_13.png", 45, 88, 300, 215, 1, 2);

    TimestampGroupEntity s3_5 = TimestampGroupEntity("s3_5", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s3_5.png", null, Colors.black.value, 22);
    TimestampEntity s3_5_t1_x0 = TimestampEntity.init(ratio, "s3_5_t1_x0", "s3_5", "rubber_nipple_factory", "a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 165, 126, 60, 30, 19, null, 0);
    TimestampEntity s3_5_t2_x0 = TimestampEntity.initWithFontWeight(ratio, "s3_5_t2_x0", "s3_5", "rubber_nipple_factory", "hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 125, 170, 140, 50, 32, null, "w900", 0);
    TimestampEntity s3_5_t3_x0 = TimestampEntity.init(ratio, "s3_5_t3_x0", "s3_5", "rubber_nipple_factory", "MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 245, 100, 30, 21, null, 0);
    ImageEntity s3_5_i1_x0 = ImageEntity.init(ratio, "s3_5_i1_x0", "s3_5", "stamp", "assets/timestamp/image/stamp/stamp_12.png", 130, 97, 130, 195, 1, 0);
    ImageEntity s3_5_i2_x0 = ImageEntity.init(ratio, "s3_5_i2_x0", "s3_5", "stamp", "assets/timestamp/image/stamp/stamp_18.png", 170, 200, 50, 35, 1, 0);
    TimestampEntity s3_5_t1_x1 = TimestampEntity.init(ratio, "s3_5_t1_x1", "s3_5", "rubber_nipple_factory", "a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 165, 116, 60, 30, 24, null, 1);
    TimestampEntity s3_5_t2_x1 = TimestampEntity.initWithFontWeight(ratio, "s3_5_t2_x1", "s3_5", "rubber_nipple_factory", "hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 125, 170, 140, 50, 40, null, "w900", 1);
    TimestampEntity s3_5_t3_x1 = TimestampEntity.init(ratio, "s3_5_t3_x1", "s3_5", "rubber_nipple_factory", "MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 257.5, 100, 30, 26, null, 1);
    ImageEntity s3_5_i1_x1 = ImageEntity.init(ratio, "s3_5_i1_x1", "s3_5", "stamp", "assets/timestamp/image/stamp/stamp_12.png", 115, 73.5, 160, 243, 1, 1);
    ImageEntity s3_5_i2_x1 = ImageEntity.init(ratio, "s3_5_i2_x1", "s3_5", "stamp", "assets/timestamp/image/stamp/stamp_18.png", 162.5, 202.5, 65, 44, 1, 1);
    TimestampEntity s3_5_t1_x2 = TimestampEntity.init(ratio, "s3_5_t1_x2", "s3_5", "rubber_nipple_factory", "a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 165, 106, 60, 30, 29, null, 2);
    TimestampEntity s3_5_t2_x2 = TimestampEntity.initWithFontWeight(ratio, "s3_5_t2_x2", "s3_5", "rubber_nipple_factory", "hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 125, 170, 140, 50, 48, null, "w900", 2);
    TimestampEntity s3_5_t3_x2 = TimestampEntity.init(ratio, "s3_5_t3_x2", "s3_5", "rubber_nipple_factory", "MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 270, 100, 30, 31, null, 2);
    ImageEntity s3_5_i1_x2 = ImageEntity.init(ratio, "s3_5_i1_x2", "s3_5", "stamp", "assets/timestamp/image/stamp/stamp_12.png", 100, 50, 190, 291, 1, 2);
    ImageEntity s3_5_i2_x2 = ImageEntity.init(ratio, "s3_5_i2_x2", "s3_5", "stamp", "assets/timestamp/image/stamp/stamp_18.png", 155, 205, 80, 53, 1, 2);

    TimestampGroupEntity s3_6 = TimestampGroupEntity("s3_6", Constants.TIMESTAMP_CATEGORY_STAMP, "assets/timestamp/group/s3_6.png", null, Colors.black.value, 23);
    TimestampEntity s3_6_t1_x0 = TimestampEntity.init(ratio, "s3_6_t1_x0", "s3_6", "manils", "yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 135, 127, 120, 40, 32, null, 0);
    TimestampEntity s3_6_t2_x0 = TimestampEntity.init(ratio, "s3_6_t2_x0", "s3_6", "manils", "MMMM dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 80, 177, 230, 40, 32, RegexUtil.TYPE_ALL_TO_CAPITAL, 0);
    TimestampEntity s3_6_t3_x0 = TimestampEntity.init(ratio, "s3_6_t3_x0", "s3_6", "manils", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 105, 227, 180, 40, 32, null, 0);
    ImageEntity s3_6_i1_x0 = ImageEntity.init(ratio, "s3_6_i1_x0", "s3_6", "stamp", "assets/timestamp/image/stamp/stamp_4_3.png", 115, 152, 160, 31, 1, 0);
    ImageEntity s3_6_i2_x0 = ImageEntity.init(ratio, "s3_6_i2_x0", "s3_6", "stamp", "assets/timestamp/image/stamp/stamp_4_3.png", 115, 202, 160, 31, 1, 0);
    TimestampEntity s3_6_t1_x1 = TimestampEntity.init(ratio, "s3_6_t1_x1", "s3_6", "manils", "yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 135, 119, 120, 40, 40, null, 1);
    TimestampEntity s3_6_t2_x1 = TimestampEntity.init(ratio, "s3_6_t2_x1", "s3_6", "manils", "MMMM dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 80, 179, 230, 40, 40, RegexUtil.TYPE_ALL_TO_CAPITAL, 1);
    TimestampEntity s3_6_t3_x1 = TimestampEntity.init(ratio, "s3_6_t3_x1", "s3_6", "manils", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 105, 239.5, 180, 40, 40, null, 1);
    ImageEntity s3_6_i1_x1 = ImageEntity.init(ratio, "s3_6_i1_x1", "s3_6", "stamp", "assets/timestamp/image/stamp/stamp_4_3.png", 95, 144, 200, 39, 1, 1);
    ImageEntity s3_6_i2_x1 = ImageEntity.init(ratio, "s3_6_i2_x1", "s3_6", "stamp", "assets/timestamp/image/stamp/stamp_4_3.png", 95, 204, 200, 39, 1, 1);
    TimestampEntity s3_6_t1_x2 = TimestampEntity.init(ratio, "s3_6_t1_x2", "s3_6", "manils", "yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 115, 111, 160, 40, 48, null, 2);
    TimestampEntity s3_6_t2_x2 = TimestampEntity.init(ratio, "s3_6_t2_x2", "s3_6", "manils", "MMMM dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 60, 181, 270, 40, 48, RegexUtil.TYPE_ALL_TO_CAPITAL, 2);
    TimestampEntity s3_6_t3_x2 = TimestampEntity.init(ratio, "s3_6_t3_x2", "s3_6", "manils", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 80, 251, 230, 40, 48, null, 2);
    ImageEntity s3_6_i1_x2 = ImageEntity.init(ratio, "s3_6_i1_x2", "s3_6", "stamp", "assets/timestamp/image/stamp/stamp_4_3.png", 75, 136, 240, 47, 1, 2);
    ImageEntity s3_6_i2_x2 = ImageEntity.init(ratio, "s3_6_i2_x2", "s3_6", "stamp", "assets/timestamp/image/stamp/stamp_4_3.png", 75, 206, 240, 47, 1, 2);

    timestampGroupBox.put("s1_1", s1_1);
    timestampBox.put("s1_1_t1_x0", s1_1_t1_x0);
    timestampImageBox.put("s1_1_i1_x0", s1_1_i1_x0);
    timestampBox.put("s1_1_t1_x1", s1_1_t1_x1);
    timestampImageBox.put("s1_1_i1_x1", s1_1_i1_x1);
    timestampBox.put("s1_1_t1_x2", s1_1_t1_x2);
    timestampImageBox.put("s1_1_i1_x2", s1_1_i1_x2);

    timestampGroupBox.put("s1_2", s1_2);
    timestampBox.put("s1_2_t1_x0", s1_2_t1_x0);
    timestampImageBox.put("s1_2_i1_x0", s1_2_i1_x0);
    timestampBox.put("s1_2_t1_x1", s1_2_t1_x1);
    timestampImageBox.put("s1_2_i1_x1", s1_2_i1_x1);
    timestampBox.put("s1_2_t1_x2", s1_2_t1_x2);
    timestampImageBox.put("s1_2_i1_x2", s1_2_i1_x2);

    timestampGroupBox.put("s1_3", s1_3);
    timestampBox.put("s1_3_t1_x0", s1_3_t1_x0);
    timestampBox.put("s1_3_t2_x0", s1_3_t2_x0);
    timestampImageBox.put("s1_3_i1_x0", s1_3_i1_x0);
    timestampBox.put("s1_3_t1_x1", s1_3_t1_x1);
    timestampBox.put("s1_3_t2_x1", s1_3_t2_x1);
    timestampImageBox.put("s1_3_i1_x1", s1_3_i1_x1);
    timestampBox.put("s1_3_t1_x2", s1_3_t1_x2);
    timestampBox.put("s1_3_t2_x2", s1_3_t2_x2);
    timestampImageBox.put("s1_3_i1_x2", s1_3_i1_x2);

    timestampGroupBox.put("s1_4", s1_4);
    timestampBox.put("s1_4_t1_x0", s1_4_t1_x0);
    timestampBox.put("s1_4_t2_x0", s1_4_t2_x0);
    timestampImageBox.put("s1_4_i1_x0", s1_4_i1_x0);
    timestampBox.put("s1_4_t1_x1", s1_4_t1_x1);
    timestampBox.put("s1_4_t2_x1", s1_4_t2_x1);
    timestampImageBox.put("s1_4_i1_x1", s1_4_i1_x1);
    timestampBox.put("s1_4_t1_x2", s1_4_t1_x2);
    timestampBox.put("s1_4_t2_x2", s1_4_t2_x2);
    timestampImageBox.put("s1_4_i1_x2", s1_4_i1_x2);

    timestampGroupBox.put("s1_5", s1_5);
    timestampBox.put("s1_5_t1_x0", s1_5_t1_x0);
    timestampImageBox.put("s1_5_i1_x0", s1_5_i1_x0);
    timestampBox.put("s1_5_t1_x1", s1_5_t1_x1);
    timestampImageBox.put("s1_5_i1_x1", s1_5_i1_x1);
    timestampBox.put("s1_5_t1_x2", s1_5_t1_x2);
    timestampImageBox.put("s1_5_i1_x2", s1_5_i1_x2);

    timestampGroupBox.put("s1_6", s1_6);
    timestampBox.put("s1_6_t1_x0", s1_6_t1_x0);
    timestampImageBox.put("s1_6_i1_x0", s1_6_i1_x0);
    timestampBox.put("s1_6_t1_x1", s1_6_t1_x1);
    timestampImageBox.put("s1_6_i1_x1", s1_6_i1_x1);
    timestampBox.put("s1_6_t1_x2", s1_6_t1_x2);
    timestampImageBox.put("s1_6_i1_x2", s1_6_i1_x2);

    timestampGroupBox.put("s1_7", s1_7);
    timestampBox.put("s1_7_t1_x0", s1_7_t1_x0);
    timestampImageBox.put("s1_7_i1_x0", s1_7_i1_x0);
    timestampBox.put("s1_7_t1_x1", s1_7_t1_x1);
    timestampImageBox.put("s1_7_i1_x1", s1_7_i1_x1);
    timestampBox.put("s1_7_t1_x2", s1_7_t1_x2);
    timestampImageBox.put("s1_7_i1_x2", s1_7_i1_x2);

    timestampGroupBox.put("s1_8", s1_8);
    timestampBox.put("s1_8_t1_x0", s1_8_t1_x0);
    timestampImageBox.put("s1_8_i1_x0", s1_8_i1_x0);
    timestampBox.put("s1_8_t1_x1", s1_8_t1_x1);
    timestampImageBox.put("s1_8_i1_x1", s1_8_i1_x1);
    timestampBox.put("s1_8_t1_x2", s1_8_t1_x2);
    timestampImageBox.put("s1_8_i1_x2", s1_8_i1_x2);

    timestampGroupBox.put("s1_9", s1_9);
    timestampBox.put("s1_9_t1_x0", s1_9_t1_x0);
    timestampImageBox.put("s1_9_i1_x0", s1_9_i1_x0);
    timestampBox.put("s1_9_t1_x1", s1_9_t1_x1);
    timestampImageBox.put("s1_9_i1_x1", s1_9_i1_x1);
    timestampBox.put("s1_9_t1_x2", s1_9_t1_x2);
    timestampImageBox.put("s1_9_i1_x2", s1_9_i1_x2);

    timestampGroupBox.put("s1_10", s1_10);
    timestampBox.put("s1_10_t1_x0", s1_10_t1_x0);
    timestampImageBox.put("s1_10_i1_x0", s1_10_i1_x0);
    timestampImageBox.put("s1_10_i2_x0", s1_10_i2_x0);
    timestampBox.put("s1_10_t1_x1", s1_10_t1_x1);
    timestampImageBox.put("s1_10_i1_x1", s1_10_i1_x1);
    timestampImageBox.put("s1_10_i2_x1", s1_10_i2_x1);
    timestampBox.put("s1_10_t1_x2", s1_10_t1_x2);
    timestampImageBox.put("s1_10_i1_x2", s1_10_i1_x2);
    timestampImageBox.put("s1_10_i2_x2", s1_10_i2_x2);

    timestampGroupBox.put("s1_11", s1_11);
    timestampBox.put("s1_11_t1_x0", s1_11_t1_x0);
    timestampImageBox.put("s1_11_i1_x0", s1_11_i1_x0);
    timestampBox.put("s1_11_t1_x1", s1_11_t1_x1);
    timestampImageBox.put("s1_11_i1_x1", s1_11_i1_x1);
    timestampBox.put("s1_11_t1_x2", s1_11_t1_x2);
    timestampImageBox.put("s1_11_i1_x2", s1_11_i1_x2);

    timestampGroupBox.put("s1_12", s1_12);
    timestampBox.put("s1_12_t1_x0", s1_12_t1_x0);
    timestampImageBox.put("s1_12_i1_x0", s1_12_i1_x0);
    timestampBox.put("s1_12_t1_x1", s1_12_t1_x1);
    timestampImageBox.put("s1_12_i1_x1", s1_12_i1_x1);
    timestampBox.put("s1_12_t1_x2", s1_12_t1_x2);
    timestampImageBox.put("s1_12_i1_x2", s1_12_i1_x2);

    timestampGroupBox.put("s2_1", s2_1);
    timestampBox.put("s2_1_t1_x0", s2_1_t1_x0);
    timestampBox.put("s2_1_t2_x0", s2_1_t2_x0);
    timestampImageBox.put("s2_1_i1_x0", s2_1_i1_x0);
    timestampBox.put("s2_1_t1_x1", s2_1_t1_x1);
    timestampBox.put("s2_1_t2_x1", s2_1_t2_x1);
    timestampImageBox.put("s2_1_i1_x1", s2_1_i1_x1);
    timestampBox.put("s2_1_t1_x2", s2_1_t1_x2);
    timestampBox.put("s2_1_t2_x2", s2_1_t2_x2);
    timestampImageBox.put("s2_1_i1_x2", s2_1_i1_x2);

    timestampGroupBox.put("s2_2", s2_2);
    timestampBox.put("s2_2_t1_x0", s2_2_t1_x0);
    timestampBox.put("s2_2_t2_x0", s2_2_t2_x0);
    timestampImageBox.put("s2_2_i1_x0", s2_2_i1_x0);
    timestampBox.put("s2_2_t1_x1", s2_2_t1_x1);
    timestampBox.put("s2_2_t2_x1", s2_2_t2_x1);
    timestampImageBox.put("s2_2_i1_x1", s2_2_i1_x1);
    timestampBox.put("s2_2_t1_x2", s2_2_t1_x2);
    timestampBox.put("s2_2_t2_x2", s2_2_t2_x2);
    timestampImageBox.put("s2_2_i1_x2", s2_2_i1_x2);

    timestampGroupBox.put("s2_3", s2_3);
    timestampBox.put("s2_3_t1_x0", s2_3_t1_x0);
    timestampBox.put("s2_3_t2_x0", s2_3_t2_x0);
    timestampImageBox.put("s2_3_i1_x0", s2_3_i1_x0);
    timestampImageBox.put("s2_3_i2_x0", s2_3_i2_x0);
    timestampBox.put("s2_3_t1_x1", s2_3_t1_x1);
    timestampBox.put("s2_3_t2_x1", s2_3_t2_x1);
    timestampImageBox.put("s2_3_i1_x1", s2_3_i1_x1);
    timestampImageBox.put("s2_3_i2_x1", s2_3_i2_x1);
    timestampBox.put("s2_3_t1_x2", s2_3_t1_x2);
    timestampBox.put("s2_3_t2_x2", s2_3_t2_x2);
    timestampImageBox.put("s2_3_i1_x2", s2_3_i1_x2);
    timestampImageBox.put("s2_3_i2_x2", s2_3_i2_x2);

    timestampGroupBox.put("s2_4", s2_4);
    timestampBox.put("s2_4_t1_x0", s2_4_t1_x0);
    timestampBox.put("s2_4_t2_x0", s2_4_t2_x0);
    timestampImageBox.put("s2_4_i1_x0", s2_4_i1_x0);
    timestampBox.put("s2_4_t1_x1", s2_4_t1_x1);
    timestampBox.put("s2_4_t2_x1", s2_4_t2_x1);
    timestampImageBox.put("s2_4_i1_x1", s2_4_i1_x1);
    timestampBox.put("s2_4_t1_x2", s2_4_t1_x2);
    timestampBox.put("s2_4_t2_x2", s2_4_t2_x2);
    timestampImageBox.put("s2_4_i1_x2", s2_4_i1_x2);

    timestampGroupBox.put("s2_5", s2_5);
    timestampBox.put("s2_5_t1_x0", s2_5_t1_x0);
    timestampBox.put("s2_5_t2_x0", s2_5_t2_x0);
    timestampImageBox.put("s2_5_i1_x0", s2_5_i1_x0);
    timestampBox.put("s2_5_t1_x1", s2_5_t1_x1);
    timestampBox.put("s2_5_t2_x1", s2_5_t2_x1);
    timestampImageBox.put("s2_5_i1_x1", s2_5_i1_x1);
    timestampBox.put("s2_5_t1_x2", s2_5_t1_x2);
    timestampBox.put("s2_5_t2_x2", s2_5_t2_x2);
    timestampImageBox.put("s2_5_i1_x2", s2_5_i1_x2);

    timestampGroupBox.put("s2_6", s2_6);
    timestampBox.put("s2_6_t1_x0", s2_6_t1_x0);
    timestampBox.put("s2_6_t2_x0", s2_6_t2_x0);
    timestampImageBox.put("s2_6_i1_x0", s2_6_i1_x0);
    timestampBox.put("s2_6_t1_x1", s2_6_t1_x1);
    timestampBox.put("s2_6_t2_x1", s2_6_t2_x1);
    timestampImageBox.put("s2_6_i1_x1", s2_6_i1_x1);
    timestampBox.put("s2_6_t1_x2", s2_6_t1_x2);
    timestampBox.put("s2_6_t2_x2", s2_6_t2_x2);
    timestampImageBox.put("s2_6_i1_x2", s2_6_i1_x2);

    timestampGroupBox.put("s3_1", s3_1);
    timestampBox.put("s3_1_t1_x0", s3_1_t1_x0);
    timestampBox.put("s3_1_t2_x0", s3_1_t2_x0);
    timestampBox.put("s3_1_t3_x0", s3_1_t3_x0);
    timestampImageBox.put("s3_1_i1_x0", s3_1_i1_x0);
    timestampImageBox.put("s3_1_i2_x0", s3_1_i2_x0);
    timestampBox.put("s3_1_t1_x1", s3_1_t1_x1);
    timestampBox.put("s3_1_t2_x1", s3_1_t2_x1);
    timestampBox.put("s3_1_t3_x1", s3_1_t3_x1);
    timestampImageBox.put("s3_1_i1_x1", s3_1_i1_x1);
    timestampImageBox.put("s3_1_i2_x1", s3_1_i2_x1);
    timestampBox.put("s3_1_t1_x2", s3_1_t1_x2);
    timestampBox.put("s3_1_t2_x2", s3_1_t2_x2);
    timestampBox.put("s3_1_t3_x2", s3_1_t3_x2);
    timestampImageBox.put("s3_1_i1_x2", s3_1_i1_x2);
    timestampImageBox.put("s3_1_i2_x2", s3_1_i2_x2);

    timestampGroupBox.put("s3_2", s3_2);
    timestampBox.put("s3_2_t1_x0", s3_2_t1_x0);
    timestampBox.put("s3_2_t2_x0", s3_2_t2_x0);
    timestampBox.put("s3_2_t3_x0", s3_2_t3_x0);
    timestampImageBox.put("s3_2_i1_x0", s3_2_i1_x0);
    timestampImageBox.put("s3_2_i2_x0", s3_2_i2_x0);
    timestampBox.put("s3_2_t1_x1", s3_2_t1_x1);
    timestampBox.put("s3_2_t2_x1", s3_2_t2_x1);
    timestampBox.put("s3_2_t3_x1", s3_2_t3_x1);
    timestampImageBox.put("s3_2_i1_x1", s3_2_i1_x1);
    timestampImageBox.put("s3_2_i2_x1", s3_2_i2_x1);
    timestampBox.put("s3_2_t1_x2", s3_2_t1_x2);
    timestampBox.put("s3_2_t2_x2", s3_2_t2_x2);
    timestampBox.put("s3_2_t3_x2", s3_2_t3_x2);
    timestampImageBox.put("s3_2_i1_x2", s3_2_i1_x2);
    timestampImageBox.put("s3_2_i2_x2", s3_2_i2_x2);

    timestampGroupBox.put("s3_3", s3_3);
    timestampBox.put("s3_3_t1_x0", s3_3_t1_x0);
    timestampBox.put("s3_3_t2_x0", s3_3_t2_x0);
    timestampBox.put("s3_3_t3_x0", s3_3_t3_x0);
    timestampImageBox.put("s3_3_i1_x0", s3_3_i1_x0);
    timestampBox.put("s3_3_t1_x1", s3_3_t1_x1);
    timestampBox.put("s3_3_t2_x1", s3_3_t2_x1);
    timestampBox.put("s3_3_t3_x1", s3_3_t3_x1);
    timestampImageBox.put("s3_3_i1_x1", s3_3_i1_x1);
    timestampBox.put("s3_3_t1_x2", s3_3_t1_x2);
    timestampBox.put("s3_3_t2_x2", s3_3_t2_x2);
    timestampBox.put("s3_3_t3_x2", s3_3_t3_x2);
    timestampImageBox.put("s3_3_i1_x2", s3_3_i1_x2);

    timestampGroupBox.put("s3_4", s3_4);
    timestampBox.put("s3_4_t1_x0", s3_4_t1_x0);
    timestampBox.put("s3_4_t2_x0", s3_4_t2_x0);
    timestampBox.put("s3_4_t3_x0", s3_4_t3_x0);
    timestampImageBox.put("s3_4_i1_x0", s3_4_i1_x0);
    timestampBox.put("s3_4_t1_x1", s3_4_t1_x1);
    timestampBox.put("s3_4_t2_x1", s3_4_t2_x1);
    timestampBox.put("s3_4_t3_x1", s3_4_t3_x1);
    timestampImageBox.put("s3_4_i1_x1", s3_4_i1_x1);
    timestampBox.put("s3_4_t1_x2", s3_4_t1_x2);
    timestampBox.put("s3_4_t2_x2", s3_4_t2_x2);
    timestampBox.put("s3_4_t3_x2", s3_4_t3_x2);
    timestampImageBox.put("s3_4_i1_x2", s3_4_i1_x2);

    timestampGroupBox.put("s3_5", s3_5);
    timestampBox.put("s3_5_t1_x0", s3_5_t1_x0);
    timestampBox.put("s3_5_t2_x0", s3_5_t2_x0);
    timestampBox.put("s3_5_t3_x0", s3_5_t3_x0);
    timestampImageBox.put("s3_5_i1_x0", s3_5_i1_x0);
    timestampImageBox.put("s3_5_i2_x0", s3_5_i2_x0);
    timestampBox.put("s3_5_t1_x1", s3_5_t1_x1);
    timestampBox.put("s3_5_t2_x1", s3_5_t2_x1);
    timestampBox.put("s3_5_t3_x1", s3_5_t3_x1);
    timestampImageBox.put("s3_5_i1_x1", s3_5_i1_x1);
    timestampImageBox.put("s3_5_i2_x1", s3_5_i2_x1);
    timestampBox.put("s3_5_t1_x2", s3_5_t1_x2);
    timestampBox.put("s3_5_t2_x2", s3_5_t2_x2);
    timestampBox.put("s3_5_t3_x2", s3_5_t3_x2);
    timestampImageBox.put("s3_5_i1_x2", s3_5_i1_x2);
    timestampImageBox.put("s3_5_i2_x2", s3_5_i2_x2);

    timestampGroupBox.put("s3_6", s3_6);
    timestampBox.put("s3_6_t1_x0", s3_6_t1_x0);
    timestampBox.put("s3_6_t2_x0", s3_6_t2_x0);
    timestampBox.put("s3_6_t3_x0", s3_6_t3_x0);
    timestampImageBox.put("s3_6_i1_x0", s3_6_i1_x0);
    timestampImageBox.put("s3_6_i2_x0", s3_6_i2_x0);
    timestampBox.put("s3_6_t1_x1", s3_6_t1_x1);
    timestampBox.put("s3_6_t2_x1", s3_6_t2_x1);
    timestampBox.put("s3_6_t3_x1", s3_6_t3_x1);
    timestampImageBox.put("s3_6_i1_x1", s3_6_i1_x1);
    timestampImageBox.put("s3_6_i2_x1", s3_6_i2_x1);
    timestampBox.put("s3_6_t1_x2", s3_6_t1_x2);
    timestampBox.put("s3_6_t2_x2", s3_6_t2_x2);
    timestampBox.put("s3_6_t3_x2", s3_6_t3_x2);
    timestampImageBox.put("s3_6_i1_x2", s3_6_i1_x2);
    timestampImageBox.put("s3_6_i2_x2", s3_6_i2_x2);
}

  static void saveTempFrame() {
    // 원본: ratio = logicalWidth / 390. 이 앱에서는 렌더러가 390 기준 스케일을 적용합니다.
    const double ratio = 1.0;

    TimestampGroupEntity f1 = TimestampGroupEntity("f1", Constants.TIMESTAMP_CATEGORY_FRAME, "assets/timestamp/group/f1.png",  null, null, 0);
    TimestampEntity f1_t1_x0 = TimestampEntity.init(ratio, "f1_t1_x0", "f1", "nanum_square", "yyyy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 125, 161, 140, 40, 18, null, 0);
    TimestampEntity f1_t2_x0 = TimestampEntity.init(ratio, "f1_t2_x0", "f1", "nanum_square", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 100, 183, 190, 59, 32, null, 0);
    ImageEntity f1_i1_x0 = ImageEntity.init(ratio, "f1_i1_x0", "f1", "frame", "assets/timestamp/image/frame/frame_1.png", 15, 15, 360, 360, 0, 0);
    ImageEntity f1_i2_x0 = ImageEntity.init(ratio, "f1_i2_x0", "f1", "rec", "assets/timestamp/image/rec/rec_1.png", 30, 25, 40, 16, 0, 0);
    TimestampEntity f1_t1_x1 = TimestampEntity.init(ratio, "f1_t1_x1", "f1", "nanum_square", "yyyy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 120, 154.5, 150, 40, 22.5, null, 1);
    TimestampEntity f1_t2_x1 = TimestampEntity.init(ratio, "f1_t2_x1", "f1", "nanum_square", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 95, 182.5, 200, 59, 40, null, 1);
    ImageEntity f1_i1_x1 = ImageEntity.init(ratio, "f1_i1_x1", "f1", "frame", "assets/timestamp/image/frame/frame_1.png", 15, 15, 360, 360, 0, 1);
    ImageEntity f1_i2_x1 = ImageEntity.init(ratio, "f1_i2_x1", "f1", "rec", "assets/timestamp/image/rec/rec_1.png", 30, 25, 40, 16, 0, 1);
    TimestampEntity f1_t1_x2 = TimestampEntity.init(ratio, "f1_t1_x2", "f1", "nanum_square", "yyyy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 115, 148, 160, 40, 27, null, 2);
    TimestampEntity f1_t2_x2 = TimestampEntity.init(ratio, "f1_t2_x2", "f1", "nanum_square", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 90, 182, 210, 59, 48, null, 2);
    ImageEntity f1_i1_x2 = ImageEntity.init(ratio, "f1_i1_x2", "f1", "frame", "assets/timestamp/image/frame/frame_1.png", 15, 15, 360, 360, 0, 2);
    ImageEntity f1_i2_x2 = ImageEntity.init(ratio, "f1_i2_x2", "f1", "rec", "assets/timestamp/image/rec/rec_1.png", 30, 25, 40, 16, 0, 2);

    TimestampGroupEntity f2 = TimestampGroupEntity("f2", Constants.TIMESTAMP_CATEGORY_FRAME, "assets/timestamp/group/f2.png",  null, Colors.black.value, 1);
    TimestampEntity f2_t1_x0 = TimestampEntity.init(ratio, "f2_t1_x0", "f2", "tvn_fun_story", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 125, 155, 140, 45, 32, null, 0);
    TimestampEntity f2_t2_x0 = TimestampEntity.init(ratio, "f2_t2_x0", "f2", "tvn_fun_story", "yyyy.MM.dd.EEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 100, 190, 190, 45, 32, null, 0);
    ImageEntity f2_i1_x0 = ImageEntity.init(ratio, "f2_i1_x0", "f2", "frame", "assets/timestamp/image/frame/frame_2.png", 15, 15, 360, 360, 0, 0);
    TimestampEntity f2_t1_x1 = TimestampEntity.init(ratio, "f2_t1_x1", "f2", "tvn_fun_story", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 120, 151, 150, 45, 40, null, 1);
    TimestampEntity f2_t2_x1 = TimestampEntity.init(ratio, "f2_t2_x1", "f2", "tvn_fun_story", "yyyy.MM.dd.EEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 95, 194, 200, 45, 40, null, 1);
    ImageEntity f2_i1_x1 = ImageEntity.init(ratio, "f2_i1_x1", "f2", "frame", "assets/timestamp/image/frame/frame_2.png", 15, 15, 360, 360, 0, 1);
    TimestampEntity f2_t1_x2 = TimestampEntity.init(ratio, "f2_t1_x2", "f2", "tvn_fun_story", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 115, 147, 160, 45, 48, null, 2);
    TimestampEntity f2_t2_x2 = TimestampEntity.init(ratio, "f2_t2_x2", "f2", "tvn_fun_story", "yyyy.MM.dd.EEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 90, 198, 210, 45, 48, null, 2);
    ImageEntity f2_i1_x2 = ImageEntity.init(ratio, "f2_i1_x2", "f2", "frame", "assets/timestamp/image/frame/frame_2.png", 15, 15, 360, 360, 0, 2);

    TimestampGroupEntity f3 = TimestampGroupEntity("f3", Constants.TIMESTAMP_CATEGORY_FRAME, "assets/timestamp/group/f3.png",  null, Colors.black.value, 2);
    TimestampEntity f3_t1_x0 = TimestampEntity.init(ratio, "f3_t1_x0", "f3", "cafe24_simplehae", "yyyy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 105, 157, 180, 45, 24, null, 0);
    TimestampEntity f3_t2_x0 = TimestampEntity.init(ratio, "f3_t2_x0", "f3", "cafe24_simplehae", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 105, 186, 180, 49, 28, RegexUtil.TYPE_AMPM_TO_KR, 0);
    ImageEntity f3_i1_x0 = ImageEntity.init(ratio, "f3_i1_x0", "f3", "frame", "assets/timestamp/image/frame/frame_3.png", 15, 15, 360, 360, 0, 0);
    TimestampEntity f3_t1_x1 = TimestampEntity.init(ratio, "f3_t1_x1", "f3", "cafe24_simplehae", "yyyy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 100, 153.5, 190, 45, 30, null, 1);
    TimestampEntity f3_t2_x1 = TimestampEntity.init(ratio, "f3_t2_x1", "f3", "cafe24_simplehae", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 100, 189.5, 190, 49, 35, RegexUtil.TYPE_AMPM_TO_KR, 1);
    ImageEntity f3_i1_x1 = ImageEntity.init(ratio, "f3_i1_x1", "f3", "frame", "assets/timestamp/image/frame/frame_3.png", 15, 15, 360, 360, 0, 1);
    TimestampEntity f3_t1_x2 = TimestampEntity.init(ratio, "f3_t1_x2", "f3", "cafe24_simplehae", "yyyy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 95, 150, 200, 45, 36, null, 2);
    TimestampEntity f3_t2_x2 = TimestampEntity.init(ratio, "f3_t2_x2", "f3", "cafe24_simplehae", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 95, 193, 200, 49, 42, RegexUtil.TYPE_AMPM_TO_KR, 2);
    ImageEntity f3_i1_x2 = ImageEntity.init(ratio, "f3_i1_x2", "f3", "frame", "assets/timestamp/image/frame/frame_3.png", 15, 15, 360, 360, 0, 2);

    TimestampGroupEntity f4 = TimestampGroupEntity("f4", Constants.TIMESTAMP_CATEGORY_FRAME, "assets/timestamp/group/f4.png",  null, Colors.black.value, 3);
    TimestampEntity f4_t1_x0 = TimestampEntity.init(ratio, "f4_t1_x0", "f4", "kotra_hope", "yy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 120, 125, 150, 45, 28, null, 0);
    TimestampEntity f4_t2_x0 = TimestampEntity.init(ratio, "f4_t2_x0", "f4", "kotra_hope", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 120, 155, 150, 45, 28, null, 0);
    TextEntity f4_txt1_x0 = TextEntity.init(ratio, "f4_txt1_x0", "f4", "nanum_start_again", Constants.INPUT_TEXT, Colors.black.value, 15, 340, 360, 40, 20, 0);
    ImageEntity f4_i1_x0 = ImageEntity.init(ratio, "f4_i1_x0", "f4", "frame", "assets/timestamp/image/frame/frame_4.png", 0, 0, 390, 390, 0, 0);
    TimestampEntity f4_t1_x1 = TimestampEntity.init(ratio, "f4_t1_x1", "f4", "kotra_hope", "yy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 120, 122, 150, 45, 35, null, 1);
    TimestampEntity f4_t2_x1 = TimestampEntity.init(ratio, "f4_t2_x1", "f4", "kotra_hope", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 120, 158, 150, 45, 35, null, 1);
    TextEntity f4_txt1_x1 = TextEntity.init(ratio, "f4_txt1_x1", "f4", "nanum_start_again", Constants.INPUT_TEXT, Colors.black.value, 15, 340, 360, 40, 20, 1);
    ImageEntity f4_i1_x1 = ImageEntity.init(ratio, "f4_i1_x1", "f4", "frame", "assets/timestamp/image/frame/frame_4.png", 0, 0, 390, 390, 0, 1);
    TimestampEntity f4_t1_x2 = TimestampEntity.init(ratio, "f4_t1_x2", "f4", "kotra_hope", "yy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 120, 119, 150, 45, 42, null, 2);
    TimestampEntity f4_t2_x2 = TimestampEntity.init(ratio, "f4_t2_x2", "f4", "kotra_hope", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 120, 161, 150, 45, 42, null, 2);
    TextEntity f4_txt1_x2 = TextEntity.init(ratio, "f4_txt1_x2", "f4", "nanum_start_again", Constants.INPUT_TEXT, Colors.black.value, 15, 340, 360, 40, 20, 2);
    ImageEntity f4_i1_x2 = ImageEntity.init(ratio, "f4_i1_x2", "f4", "frame", "assets/timestamp/image/frame/frame_4.png", 0, 0, 390, 390, 0, 2);

    TimestampGroupEntity f5 = TimestampGroupEntity("f5", Constants.TIMESTAMP_CATEGORY_FRAME, "assets/timestamp/group/f5.png",  null, Colors.black.value, 4);
    TimestampEntity f5_t1_x0 = TimestampEntity.init(ratio, "f5_t1_x0", "f5", "nanum_middle_school", "a hh시 mm분", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 100, 175, 190, 40, 36, RegexUtil.TYPE_AMPM_TO_KR, 0);
    TimestampEntity f5_t2_x0 = TimestampEntity.init(ratio, "f5_t2_x0", "f5", "nanum_middle_school", "- yyyy년 M월 d일 EEEE -", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 105, 325, 180, 35, 20, RegexUtil.TYPE_FULL_DAY_TO_KR, 0);
    ImageEntity f5_i1_x0 = ImageEntity.init(ratio, "f5_i1_x0", "f5", "frame", "assets/timestamp/image/frame/frame_5.png", 15, 15, 360, 360, 0, 0);
    TimestampEntity f5_t1_x1 = TimestampEntity.init(ratio, "f5_t1_x1", "f5", "nanum_middle_school", "a hh시 mm분", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 100, 175, 190, 40, 45, RegexUtil.TYPE_AMPM_TO_KR, 1);
    TimestampEntity f5_t2_x1 = TimestampEntity.init(ratio, "f5_t2_x1", "f5", "nanum_middle_school", "- yyyy년 M월 d일 EEEE -", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 95, 324, 200, 35, 25, RegexUtil.TYPE_FULL_DAY_TO_KR, 1);
    ImageEntity f5_i1_x1 = ImageEntity.init(ratio, "f5_i1_x1", "f5", "frame", "assets/timestamp/image/frame/frame_5.png", 15, 15, 360, 360, 0, 1);
    TimestampEntity f5_t1_x2 = TimestampEntity.init(ratio, "f5_t1_x2", "f5", "nanum_middle_school", "a hh시 mm분", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 100, 175, 190, 40, 54, RegexUtil.TYPE_AMPM_TO_KR, 2);
    TimestampEntity f5_t2_x2 = TimestampEntity.init(ratio, "f5_t2_x2", "f5", "nanum_middle_school", "- yyyy년 M월 d일 EEEE -", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 75, 323, 240, 35, 30, RegexUtil.TYPE_FULL_DAY_TO_KR, 2);
    ImageEntity f5_i1_x2 = ImageEntity.init(ratio, "f5_i1_x2", "f5", "frame", "assets/timestamp/image/frame/frame_5.png", 15, 15, 360, 360, 0, 2);


    TimestampGroupEntity f6 = TimestampGroupEntity("f6", Constants.TIMESTAMP_CATEGORY_FRAME, "assets/timestamp/group/f6.png",  null, Colors.black.value, 5);
    TimestampEntity f6_t2_x0 = TimestampEntity.init(ratio, "f6_t2_x0", "f6", "cafe24_surround_air", "yyyy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 125, 40, 140, 40, 16, RegexUtil.TYPE_FULL_DAY_TO_KR, 0);
    TimestampEntity f6_t1_x0 = TimestampEntity.init(ratio, "f6_t1_x0", "f6", "cafe24_surround_air", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 90, 170, 210, 50, 32, null, 0);
    ImageEntity f6_i1_x0 = ImageEntity.init(ratio, "f6_i1_x0", "f6", "frame", "assets/timestamp/image/frame/frame_6.png", 15, 15, 360, 360, 0, 0);
    TimestampEntity f6_t2_x1 = TimestampEntity.init(ratio, "f6_t2_x1", "f6", "cafe24_surround_air", "yyyy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 120, 42, 150, 40, 19, RegexUtil.TYPE_FULL_DAY_TO_KR, 1);
    TimestampEntity f6_t1_x1 = TimestampEntity.init(ratio, "f6_t1_x1", "f6", "cafe24_surround_air", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 85, 170, 220, 50, 40, null, 1);
    ImageEntity f6_i1_x1 = ImageEntity.init(ratio, "f6_i1_x1", "f6", "frame", "assets/timestamp/image/frame/frame_6.png", 15, 15, 360, 360, 0, 1);
    TimestampEntity f6_t2_x2 = TimestampEntity.init(ratio, "f6_t2_x2", "f6", "cafe24_surround_air", "yyyy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 115, 44, 160, 40, 22, RegexUtil.TYPE_FULL_DAY_TO_KR, 2);
    TimestampEntity f6_t1_x2 = TimestampEntity.init(ratio, "f6_t1_x2", "f6", "cafe24_surround_air", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 80, 170, 230, 50, 48, null, 2);
    ImageEntity f6_i1_x2 = ImageEntity.init(ratio, "f6_i1_x2", "f6", "frame", "assets/timestamp/image/frame/frame_6.png", 15, 15, 360, 360, 0, 2);

    TimestampGroupEntity f7 = TimestampGroupEntity("f7", Constants.TIMESTAMP_CATEGORY_FRAME, "assets/timestamp/group/f7.png",  null, Colors.black.value, 6);
    TimestampEntity f7_t1_x0 = TimestampEntity.init(ratio, "f7_t1_x0", "f7", "nanum_amsterdam", "a hh:mm yyyy.MM.dd.EEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 55, 170, 280, 50, 32, null, 0);
    ImageEntity f7_i1_x0 = ImageEntity.init(ratio, "f7_i1_x0", "f7", "frame", "assets/timestamp/image/frame/frame_7.png", 15, 15, 360, 360, 0, 0);
    TimestampEntity f7_t1_x1 = TimestampEntity.init(ratio, "f7_t1_x1", "f7", "nanum_amsterdam", "a hh:mm yyyy.MM.dd.EEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 55, 170, 280, 50, 36, null, 1);
    ImageEntity f7_i1_x1 = ImageEntity.init(ratio, "f7_i1_x1", "f7", "frame", "assets/timestamp/image/frame/frame_7.png", 15, 15, 360, 360, 0, 1);
    TimestampEntity f7_t1_x2 = TimestampEntity.init(ratio, "f7_t1_x2", "f7", "nanum_amsterdam", "a hh:mm yyyy.MM.dd.EEE", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 55, 170, 280, 50, 40, null, 2);
    ImageEntity f7_i1_x2 = ImageEntity.init(ratio, "f7_i1_x2", "f7", "frame", "assets/timestamp/image/frame/frame_7.png", 15, 15, 360, 360, 0, 2);

    TimestampGroupEntity f8 = TimestampGroupEntity("f8", Constants.TIMESTAMP_CATEGORY_FRAME, "assets/timestamp/group/f8.png",  null, null, 7);
    TimestampEntity f8_t1_x0 = TimestampEntity.init(ratio, "f8_t1_x0", "f8", "ssantokki", "a hh:mm yyyy.MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 55, 170, 280, 50, 26, null, 0);
    ImageEntity f8_i1_x0 = ImageEntity.init(ratio, "f8_i1_x0", "f8", "frame", "assets/timestamp/image/frame/frame_8.png", 15, 15, 360, 360, 0, 0);
    TimestampEntity f8_t1_x1 = TimestampEntity.init(ratio, "f8_t1_x1", "f8", "ssantokki", "a hh:mm yyyy.MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 55, 170, 280, 50, 29, null, 1);
    ImageEntity f8_i1_x1 = ImageEntity.init(ratio, "f8_i1_x1", "f8", "frame", "assets/timestamp/image/frame/frame_8.png", 15, 15, 360, 360, 0, 1);
    TimestampEntity f8_t1_x2 = TimestampEntity.init(ratio, "f8_t1_x2", "f8", "ssantokki", "a hh:mm yyyy.MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 55, 170, 280, 50, 32, null, 2);
    ImageEntity f8_i1_x2 = ImageEntity.init(ratio, "f8_i_x2", "f8", "frame", "assets/timestamp/image/frame/frame_8.png", 15, 15, 360, 360, 0, 2);

    TimestampGroupEntity f9 = TimestampGroupEntity("f9", Constants.TIMESTAMP_CATEGORY_FRAME, "assets/timestamp/group/f9.png",  null, Colors.grey.value, 8);
    TimestampEntity f9_t1_x0 = TimestampEntity.init(ratio, "f9_t1_x0", "f9", "kotra_hope", "yyyy/MM/dd a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 75, 338, 240, 45, 26, null, 0);
    ImageEntity f9_i1_x0 = ImageEntity.init(ratio, "f9_i1_x0", "f9", "frame", "assets/timestamp/image/frame/frame_9.png", 0, 0, 390, 390, 0, 0);
    TimestampEntity f9_t1_x1 = TimestampEntity.init(ratio, "f9_t1_x1", "f9", "kotra_hope", "yyyy/MM/dd a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 75, 339, 240, 45, 29, null, 1);
    ImageEntity f9_i1_x1 = ImageEntity.init(ratio, "f9_i1_x1", "f9", "frame", "assets/timestamp/image/frame/frame_9.png", 0, 0, 390, 390, 0, 1);
    TimestampEntity f9_t1_x2 = TimestampEntity.init(ratio, "f9_t1_x2", "f9", "kotra_hope", "yyyy/MM/dd a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 75, 340, 240, 45, 32, null, 2);
    ImageEntity f9_i1_x2 = ImageEntity.init(ratio, "f9_i1_x2", "f9", "frame", "assets/timestamp/image/frame/frame_9.png", 0, 0, 390, 390, 0, 2);
    // TimestampGroupEntity f10 = TimestampGroupEntity("f10", Constants.TIMESTAMP_CATEGORY_FRAME, "assets/timestamp/group/f9.png",  null, Colors.grey.value, 9);
    // TimestampEntity f10_t1 = TimestampEntity.init(ratio, "f10_t1", "f10", "kotra_hope", "yyyy년 M월 d일 a h시 m분", Constants.ALIGN_CENTER, Constants.LOCALE_ALL, 65, 170, 260, 50, 26, RegexUtil.TYPE_DAY_TO_KR);
    // ImageEntity f10_i1 = ImageEntity.init(ratio, "f10_i1", "f10", "frame", "assets/timestamp/image/frame/frame_10.png", 0, 0, 390, 390, 0);

    timestampGroupBox.put("f1", f1);
    timestampBox.put("f1_t1_x0", f1_t1_x0);
    timestampBox.put("f1_t2_x0", f1_t2_x0);
    timestampImageBox.put("f1_i1_x0", f1_i1_x0);
    timestampImageBox.put("f1_i2_x0", f1_i2_x0);
    timestampBox.put("f1_t1_x1", f1_t1_x1);
    timestampBox.put("f1_t2_x1", f1_t2_x1);
    timestampImageBox.put("f1_i1_x1", f1_i1_x1);
    timestampImageBox.put("f1_i2_x1", f1_i2_x1);
    timestampBox.put("f1_t1_x2", f1_t1_x2);
    timestampBox.put("f1_t2_x2", f1_t2_x2);
    timestampImageBox.put("f1_i1_x2", f1_i1_x2);
    timestampImageBox.put("f1_i2_x2", f1_i2_x2);

    timestampGroupBox.put("f2", f2);
    timestampBox.put("f2_t1_x0", f2_t1_x0);
    timestampBox.put("f2_t2_x0", f2_t2_x0);
    timestampImageBox.put("f2_i1_x0", f2_i1_x0);
    timestampBox.put("f2_t1_x1", f2_t1_x1);
    timestampBox.put("f2_t2_x1", f2_t2_x1);
    timestampImageBox.put("f2_i1_x1", f2_i1_x1);
    timestampBox.put("f2_t1_x2", f2_t1_x2);
    timestampBox.put("f2_t2_x2", f2_t2_x2);
    timestampImageBox.put("f2_i1_x2", f2_i1_x2);

    timestampGroupBox.put("f3", f3);
    timestampBox.put("f3_t1_x0", f3_t1_x0);
    timestampBox.put("f3_t2_x0", f3_t2_x0);
    timestampImageBox.put("f3_i1_x0", f3_i1_x0);
    timestampBox.put("f3_t1_x1", f3_t1_x1);
    timestampBox.put("f3_t2_x1", f3_t2_x1);
    timestampImageBox.put("f3_i1_x1", f3_i1_x1);
    timestampBox.put("f3_t1_x2", f3_t1_x2);
    timestampBox.put("f3_t2_x2", f3_t2_x2);
    timestampImageBox.put("f3_i1_x2", f3_i1_x2);

    timestampGroupBox.put("f4", f4);
    timestampBox.put("f4_t1_x0", f4_t1_x0);
    timestampBox.put("f4_t2_x0", f4_t2_x0);
    timestampImageBox.put("f4_i1_x0", f4_i1_x0);
    textBox.put("f4_txt1_x0", f4_txt1_x0);
    timestampBox.put("f4_t1_x1", f4_t1_x1);
    timestampBox.put("f4_t2_x1", f4_t2_x1);
    timestampImageBox.put("f4_i1_x1", f4_i1_x1);
    textBox.put("f4_txt1_x1", f4_txt1_x1);
    timestampBox.put("f4_t1_x2", f4_t1_x2);
    timestampBox.put("f4_t2_x2", f4_t2_x2);
    timestampImageBox.put("f4_i1_x2", f4_i1_x2);
    textBox.put("f4_txt1_x2", f4_txt1_x2);

    timestampGroupBox.put("f5", f5);
    timestampBox.put("f5_t1_x0", f5_t1_x0);
    timestampBox.put("f5_t2_x0", f5_t2_x0);
    timestampImageBox.put("f5_i1_x0", f5_i1_x0);
    timestampBox.put("f5_t1_x1", f5_t1_x1);
    timestampBox.put("f5_t2_x1", f5_t2_x1);
    timestampImageBox.put("f5_i1_x1", f5_i1_x1);
    timestampBox.put("f5_t1_x2", f5_t1_x2);
    timestampBox.put("f5_t2_x2", f5_t2_x2);
    timestampImageBox.put("f5_i1_x2", f5_i1_x2);

    timestampGroupBox.put("f6", f6);
    timestampBox.put("f6_t1_x0", f6_t1_x0);
    timestampBox.put("f6_t2_x0", f6_t2_x0);
    timestampImageBox.put("f6_i1_x0", f6_i1_x0);
    timestampBox.put("f6_t1_x1", f6_t1_x1);
    timestampBox.put("f6_t2_x1", f6_t2_x1);
    timestampImageBox.put("f6_i1_x1", f6_i1_x1);
    timestampBox.put("f6_t1_x2", f6_t1_x2);
    timestampBox.put("f6_t2_x2", f6_t2_x2);
    timestampImageBox.put("f6_i1_x2", f6_i1_x2);

    timestampGroupBox.put("f7", f7);
    timestampBox.put("f7_t1_x0", f7_t1_x0);
    timestampImageBox.put("f7_i1_x0", f7_i1_x0);
    timestampBox.put("f7_t1_x1", f7_t1_x1);
    timestampImageBox.put("f7_i1_x1", f7_i1_x1);
    timestampBox.put("f7_t1_x2", f7_t1_x2);
    timestampImageBox.put("f7_i1_x2", f7_i1_x2);

    timestampGroupBox.put("f8", f8);
    timestampBox.put("f8_t1_x0", f8_t1_x0);
    timestampImageBox.put("f8_i1_x0", f8_i1_x0);
    timestampBox.put("f8_t1_x1", f8_t1_x1);
    timestampImageBox.put("f8_i1_x1", f8_i1_x1);
    timestampBox.put("f8_t1_x2", f8_t1_x2);
    timestampImageBox.put("f8_i1_x2", f8_i1_x2);

    timestampGroupBox.put("f9", f9);
    timestampBox.put("f9_t1_x0", f9_t1_x0);
    timestampImageBox.put("f9_i1_x0", f9_i1_x0);
    timestampBox.put("f9_t1_x1", f9_t1_x1);
    timestampImageBox.put("f9_i1_x1", f9_i1_x1);
    timestampBox.put("f9_t1_x2", f9_t1_x2);
    timestampImageBox.put("f9_i1_x2", f9_i1_x2);

    // timestampGroupBox.put("f10", f10);
    // timestampBox.put("f10_t1", f10_t1);
    // timestampImageBox.put("f10_i1", f10_i1);
}

  static void saveTempAnalog() {
    // 원본: ratio = logicalWidth / 390. 이 앱에서는 렌더러가 390 기준 스케일을 적용합니다.
    const double ratio = 1.0;

    TimestampGroupEntity a1 = TimestampGroupEntity("a1", Constants.TIMESTAMP_CATEGORY_ANALOG, "assets/timestamp/group/a1.png",  null, Colors.black.value, 0);
    AnalogTimestampEntity a1_t1_x0 = AnalogTimestampEntity.init(ratio, "a1_t1_x0", "a1", "assets/timestamp/analog/a1/hour.png", "assets/timestamp/analog/a1/minute.png", "assets/timestamp/analog/a1/background.png", 155, 130, 80, 80, 0);
    TimestampEntity a1_t3_x0 = TimestampEntity.init(ratio, "a1_t3_x0", "a1", "nanum_amsterdam", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 145, 215, 100, 30, 20, RegexUtil.TYPE_FULL_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 0);
    TimestampEntity a1_t2_x0 = TimestampEntity.init(ratio, "a1_t2_x0", "a1", "nanum_amsterdam", "yyyy년 M월 d일", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 130, 235, 130, 30, 20, null, 0);
    AnalogTimestampEntity a1_t1_x1 = AnalogTimestampEntity.init(ratio, "a1_t1_x1", "a1", "assets/timestamp/analog/a1/hour.png", "assets/timestamp/analog/a1/minute.png", "assets/timestamp/analog/a1/background.png", 145, 110, 100, 100, 1);
    TimestampEntity a1_t3_x1 = TimestampEntity.init(ratio, "a1_t3_x1", "a1", "nanum_amsterdam", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 145, 217, 100, 30, 25, RegexUtil.TYPE_FULL_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 1);
    TimestampEntity a1_t2_x1 = TimestampEntity.init(ratio, "a1_t2_x1", "a1", "nanum_amsterdam", "yyyy년 M월 d일", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 125, 244, 140, 30, 25, null, 1);
    AnalogTimestampEntity a1_t1_x2 = AnalogTimestampEntity.init(ratio, "a1_t1_x2", "a1", "assets/timestamp/analog/a1/hour.png", "assets/timestamp/analog/a1/minute.png", "assets/timestamp/analog/a1/background.png", 135, 90, 120, 120, 2);
    TimestampEntity a1_t3_x2 = TimestampEntity.init(ratio, "a1_t3_x2", "a1", "nanum_amsterdam", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 145, 221, 100, 30, 30, RegexUtil.TYPE_FULL_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 2);
    TimestampEntity a1_t2_x2 = TimestampEntity.init(ratio, "a1_t2_x2", "a1", "nanum_amsterdam", "yyyy년 M월 d일", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 120, 253, 150, 30, 30, null, 2);

    TimestampGroupEntity a2 = TimestampGroupEntity("a2", Constants.TIMESTAMP_CATEGORY_ANALOG, "assets/timestamp/group/a2.png",  null, Colors.black.value, 1);
    AnalogTimestampEntity a2_t1_x0 = AnalogTimestampEntity.init(ratio, "a2_t1_x0", "a2", "assets/timestamp/analog/a2/hour.png", "assets/timestamp/analog/a2/minute.png", "assets/timestamp/analog/a2/background.png", 155, 130, 80, 80, 0);
    TimestampEntity a2_t3_x0 = TimestampEntity.init(ratio, "a2_t3_x0", "a2", "nanum_amsterdam", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 215, 100, 30, 21, null, 0);
    TimestampEntity a2_t2_x0 = TimestampEntity.init(ratio, "a2_t2_x0", "a2", "nanum_amsterdam", "MMMM dd, yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 235, 130, 30, 21, null, 0);
    AnalogTimestampEntity a2_t1_x1 = AnalogTimestampEntity.init(ratio, "a2_t1_x1", "a2", "assets/timestamp/analog/a2/hour.png", "assets/timestamp/analog/a2/minute.png", "assets/timestamp/analog/a2/background.png", 145, 110, 100, 100, 1);
    TimestampEntity a2_t3_x1 = TimestampEntity.init(ratio, "a2_t3_x1", "a2", "nanum_amsterdam", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 125, 217, 140, 30, 25, null, 1);
    TimestampEntity a2_t2_x1 = TimestampEntity.init(ratio, "a2_t2_x1", "a2", "nanum_amsterdam", "MMMM dd, yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 125, 244, 140, 30, 25, null, 1);
    AnalogTimestampEntity a2_t1_x2 = AnalogTimestampEntity.init(ratio, "a2_t1_x2", "a2", "assets/timestamp/analog/a2/hour.png", "assets/timestamp/analog/a2/minute.png", "assets/timestamp/analog/a2/background.png", 135, 90, 120, 120, 2);
    TimestampEntity a2_t3_x2 = TimestampEntity.init(ratio, "a2_t3_x2", "a2", "nanum_amsterdam", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 120, 221, 150, 30, 30, null, 2);
    TimestampEntity a2_t2_x2 = TimestampEntity.init(ratio, "a2_t2_x2", "a2", "nanum_amsterdam", "MMMM dd, yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 120, 253, 150, 30, 30, null, 2);


    TimestampGroupEntity a3 = TimestampGroupEntity("a3", Constants.TIMESTAMP_CATEGORY_ANALOG, "assets/timestamp/group/a3.png",  null, Colors.black.value, 2);
    AnalogTimestampEntity a3_t1_x0 = AnalogTimestampEntity.init(ratio, "a3_t1_x0", "a3", "assets/timestamp/analog/a3/hour.png", "assets/timestamp/analog/a3/minute.png", "assets/timestamp/analog/a3/background.png", 155, 130, 80, 80, 0);
    TimestampEntity a3_t3_x0 = TimestampEntity.init(ratio, "a3_t3_x0", "a3", "nanum_mago", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 145, 215, 100, 30, 22, RegexUtil.TYPE_FULL_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 0);
    TimestampEntity a3_t2_x0 = TimestampEntity.init(ratio, "a3_t2_x0", "a3", "nanum_mago", "MMM dd, yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 235, 130, 30, 22, null, 0);
    AnalogTimestampEntity a3_t1_x1 = AnalogTimestampEntity.init(ratio, "a3_t1_x1", "a3", "assets/timestamp/analog/a3/hour.png", "assets/timestamp/analog/a3/minute.png", "assets/timestamp/analog/a3/background.png", 145, 110, 100, 100, 1);
    TimestampEntity a3_t3_x1 = TimestampEntity.init(ratio, "a3_t3_x1", "a3", "nanum_mago", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 145, 217, 100, 30, 27, RegexUtil.TYPE_FULL_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 1);
    TimestampEntity a3_t2_x1 = TimestampEntity.init(ratio, "a3_t2_x1", "a3", "nanum_mago", "MMM dd, yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 241, 130, 30, 27, null, 1);
    AnalogTimestampEntity a3_t1_x2 = AnalogTimestampEntity.init(ratio, "a3_t1_x2", "a3", "assets/timestamp/analog/a3/hour.png", "assets/timestamp/analog/a3/minute.png", "assets/timestamp/analog/a3/background.png", 135, 90, 120, 120, 2);
    TimestampEntity a3_t3_x2 = TimestampEntity.init(ratio, "a3_t3_x2", "a3", "nanum_mago", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 145, 219, 100, 30, 32, RegexUtil.TYPE_FULL_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 2);
    TimestampEntity a3_t2_x2 = TimestampEntity.init(ratio, "a3_t2_x2", "a3", "nanum_mago", "MMM dd, yyyy", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 247, 130, 30, 32, null, 2);

    TimestampGroupEntity a4 = TimestampGroupEntity("a4", Constants.TIMESTAMP_CATEGORY_ANALOG, "assets/timestamp/group/a4.png",  null, Colors.black.value, 3);
    AnalogTimestampEntity a4_t1_x0 = AnalogTimestampEntity.init(ratio, "a4_t1_x0", "a4", "assets/timestamp/analog/a4/hour.png", "assets/timestamp/analog/a4/minute.png", "assets/timestamp/analog/a4/background.png", 155, 130, 80, 80, 0);
    TimestampEntity a4_t2_x0 = TimestampEntity.init(ratio, "a4_t2_x0", "a4", "lobster", "yyyy.MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 215, 100, 30, 15, null, 0);
    TimestampEntity a4_t3_x0 = TimestampEntity.init(ratio, "a4_t3_x0", "a4", "lobster", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 235, 130, 30, 15, null, 0);
    AnalogTimestampEntity a4_t1_x1 = AnalogTimestampEntity.init(ratio, "a4_t1_x1", "a4", "assets/timestamp/analog/a4/hour.png", "assets/timestamp/analog/a4/minute.png", "assets/timestamp/analog/a4/background.png", 145, 110, 100, 100, 1);
    TimestampEntity a4_t2_x1 = TimestampEntity.init(ratio, "a4_t2_x1", "a4", "lobster", "yyyy.MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 217, 100, 30, 19, null, 1);
    TimestampEntity a4_t3_x1 = TimestampEntity.init(ratio, "a4_t3_x1", "a4", "lobster", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 242, 130, 30, 19, null, 1);
    AnalogTimestampEntity a4_t1_x2 = AnalogTimestampEntity.init(ratio, "a4_t1_x2", "a4", "assets/timestamp/analog/a4/hour.png", "assets/timestamp/analog/a4/minute.png", "assets/timestamp/analog/a4/background.png", 135, 90, 120, 120, 2);
    TimestampEntity a4_t2_x2 = TimestampEntity.init(ratio, "a4_t2_x2", "a4", "lobster", "yyyy.MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 135, 219, 120, 30, 23, null, 2);
    TimestampEntity a4_t3_x2 = TimestampEntity.init(ratio, "a4_t3_x2", "a4", "lobster", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 120, 249, 150, 30, 23, null, 2);

    TimestampGroupEntity a5 = TimestampGroupEntity("a5", Constants.TIMESTAMP_CATEGORY_ANALOG, "assets/timestamp/group/a5.png",  null, Colors.black.value, 4);
    AnalogTimestampEntity a5_t1_x0 = AnalogTimestampEntity.init(ratio, "a5_t1_x0", "a5", "assets/timestamp/analog/a5/hour.png", "assets/timestamp/analog/a5/minute.png", "assets/timestamp/analog/a5/background.png", 155, 130, 80, 80, 0);
    TimestampEntity a5_t3_x0 = TimestampEntity.init(ratio, "a5_t3_x0", "a5", "nanum_yeonji", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 145, 215, 100, 30, 20, RegexUtil.TYPE_FULL_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 0);
    TimestampEntity a5_t2_x0 = TimestampEntity.init(ratio, "a5_t2_x0", "a5", "nanum_yeonji", "yyyy년 M월 d일", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 130, 235, 130, 30, 20, null, 0);
    AnalogTimestampEntity a5_t1_x1 = AnalogTimestampEntity.init(ratio, "a5_t1_x1", "a5", "assets/timestamp/analog/a5/hour.png", "assets/timestamp/analog/a5/minute.png", "assets/timestamp/analog/a5/background.png", 145, 110, 100, 100, 1);
    TimestampEntity a5_t3_x1 = TimestampEntity.init(ratio, "a5_t3_x1", "a5", "nanum_yeonji", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 140, 217, 110, 30, 25, RegexUtil.TYPE_FULL_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 1);
    TimestampEntity a5_t2_x1 = TimestampEntity.init(ratio, "a5_t2_x1", "a5", "nanum_yeonji", "yyyy년 M월 d일", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 120, 242, 150, 30, 25, null, 1);
    AnalogTimestampEntity a5_t1_x2 = AnalogTimestampEntity.init(ratio, "a5_t1_x2", "a5", "assets/timestamp/analog/a5/hour.png", "assets/timestamp/analog/a5/minute.png", "assets/timestamp/analog/a5/background.png", 135, 90, 120, 120, 2);
    TimestampEntity a5_t3_x2 = TimestampEntity.init(ratio, "a5_t3_x2", "a5", "nanum_yeonji", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 135, 219, 120, 30, 30, RegexUtil.TYPE_FULL_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 2);
    TimestampEntity a5_t2_x2 = TimestampEntity.init(ratio, "a5_t2_x2", "a5", "nanum_yeonji", "yyyy년 M월 d일", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 110, 249, 170, 30, 30, null, 2);

    TimestampGroupEntity a6 = TimestampGroupEntity("a6", Constants.TIMESTAMP_CATEGORY_ANALOG, "assets/timestamp/group/a6.png",  null, Colors.black.value, 5);
    AnalogTimestampEntity a6_t1_x0 = AnalogTimestampEntity.init(ratio, "a6_t1_x0", "a6", "assets/timestamp/analog/a6/hour.png", "assets/timestamp/analog/a6/minute.png", "assets/timestamp/analog/a6/background.png", 155, 130, 80, 80, 0);
    TimestampEntity a6_t3_x0 = TimestampEntity.init(ratio, "a6_t3_x0", "a6", "nanum_ddobak", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 215, 130, 30, 24, null, 0);
    TimestampEntity a6_t2_x0 = TimestampEntity.init(ratio, "a6_t2_x0", "a6", "nanum_ddobak", "yyyy.MMM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 235, 130, 30, 24, null, 0);
    AnalogTimestampEntity a6_t1_x1 = AnalogTimestampEntity.init(ratio, "a6_t1_x1", "a6", "assets/timestamp/analog/a6/hour.png", "assets/timestamp/analog/a6/minute.png", "assets/timestamp/analog/a6/background.png", 145, 110, 100, 100, 1);
    TimestampEntity a6_t3_x1 = TimestampEntity.init(ratio, "a6_t3_x1", "a6", "nanum_ddobak", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 125, 217, 140, 30, 30, null, 1);
    TimestampEntity a6_t2_x1 = TimestampEntity.init(ratio, "a6_t2_x1", "a6", "nanum_ddobak", "yyyy.MMM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 125, 242, 140, 30, 30, null, 1);
    AnalogTimestampEntity a6_t1_x2 = AnalogTimestampEntity.init(ratio, "a6_t1_x2", "a6", "assets/timestamp/analog/a6/hour.png", "assets/timestamp/analog/a6/minute.png", "assets/timestamp/analog/a6/background.png", 135, 90, 120, 120, 2);
    TimestampEntity a6_t3_x2 = TimestampEntity.init(ratio, "a6_t3_x2", "a6", "nanum_ddobak", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 120, 219, 150, 30, 36, null, 2);
    TimestampEntity a6_t2_x2 = TimestampEntity.init(ratio, "a6_t2_x2", "a6", "nanum_ddobak", "yyyy.MMM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 120, 249, 150, 30, 36, null, 2);

    TimestampGroupEntity a7 = TimestampGroupEntity("a7", Constants.TIMESTAMP_CATEGORY_ANALOG, "assets/timestamp/group/a7.png",  null, Colors.black.value, 6);
    AnalogTimestampEntity a7_t1_x0 = AnalogTimestampEntity.init(ratio, "a7_t1_x0", "a7", "assets/timestamp/analog/a7/hour.png", "assets/timestamp/analog/a7/minute.png", "assets/timestamp/analog/a7/background.png", 155, 130, 80, 80, 0);
    TimestampEntity a7_t2_x0 = TimestampEntity.init(ratio, "a7_t2_x0", "a7", "tektur", "yy.MMM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 215, 130, 30, 19, null, 0);
    TimestampEntity a7_t3_x0 = TimestampEntity.init(ratio, "a7_t3_x0", "a7", "tektur", "EEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 238, 100, 30, 19, null, 0);
    AnalogTimestampEntity a7_t1_x1 = AnalogTimestampEntity.init(ratio, "a7_t1_x1", "a7", "assets/timestamp/analog/a7/hour.png", "assets/timestamp/analog/a7/minute.png", "assets/timestamp/analog/a7/background.png", 145, 110, 100, 100, 1);
    TimestampEntity a7_t2_x1 = TimestampEntity.init(ratio, "a7_t2_x1", "a7", "tektur", "yy.MMM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 125, 217, 140, 30, 24, null, 1);
    TimestampEntity a7_t3_x1 = TimestampEntity.init(ratio, "a7_t3_x1", "a7", "tektur", "EEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 140, 245, 110, 30, 24, null, 1);
    AnalogTimestampEntity a7_t1_x2 = AnalogTimestampEntity.init(ratio, "a7_t1_x2", "a7", "assets/timestamp/analog/a7/hour.png", "assets/timestamp/analog/a7/minute.png", "assets/timestamp/analog/a7/background.png", 135, 90, 120, 120, 2);
    TimestampEntity a7_t2_x2 = TimestampEntity.init(ratio, "a7_t2_x2", "a7", "tektur", "yy.MMM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 120, 219, 150, 30, 29, null, 2);
    TimestampEntity a7_t3_x2 = TimestampEntity.init(ratio, "a7_t3_x2", "a7", "tektur", "EEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 135, 252, 120, 30, 29, null, 2);

    TimestampGroupEntity a8 = TimestampGroupEntity("a8", Constants.TIMESTAMP_CATEGORY_ANALOG, "assets/timestamp/group/a8.png",  null, Colors.black.value, 7);
    AnalogTimestampEntity a8_t1_x0 = AnalogTimestampEntity.init(ratio, "a8_t1_x0", "a8", "assets/timestamp/analog/a8/hour.png", "assets/timestamp/analog/a8/minute.png", "assets/timestamp/analog/a8/background.png", 145, 125, 100, 100, 0);
    TimestampEntity a8_t3_x0 = TimestampEntity.init(ratio, "a8_t3_x0", "a8", "nanum_amsterdam", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 145, 215, 100, 30, 20, RegexUtil.TYPE_FULL_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 0);
    TimestampEntity a8_t2_x0 = TimestampEntity.init(ratio, "a8_t2_x0", "a8", "nanum_amsterdam", "yy년 M월 d일", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 130, 235, 130, 30, 20, null, 0);
    AnalogTimestampEntity a8_t1_x1 = AnalogTimestampEntity.init(ratio, "a8_t1_x1", "a8", "assets/timestamp/analog/a8/hour.png", "assets/timestamp/analog/a8/minute.png", "assets/timestamp/analog/a8/background.png", 132.5, 100, 125, 125, 1);
    TimestampEntity a8_t3_x1 = TimestampEntity.init(ratio, "a8_t3_x1", "a8", "nanum_amsterdam", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 145, 217, 100, 30, 25, RegexUtil.TYPE_FULL_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 1);
    TimestampEntity a8_t2_x1 = TimestampEntity.init(ratio, "a8_t2_x1", "a8", "nanum_amsterdam", "yy년 M월 d일", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 130, 242, 130, 30, 25, null, 1);
    AnalogTimestampEntity a8_t1_x2 = AnalogTimestampEntity.init(ratio, "a8_t1_x2", "a8", "assets/timestamp/analog/a8/hour.png", "assets/timestamp/analog/a8/minute.png", "assets/timestamp/analog/a8/background.png", 120, 75, 150, 150, 2);
    TimestampEntity a8_t3_x2 = TimestampEntity.init(ratio, "a8_t3_x2", "a8", "nanum_amsterdam", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 145, 219, 100, 30, 30, RegexUtil.TYPE_FULL_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 2);
    TimestampEntity a8_t2_x2 = TimestampEntity.init(ratio, "a8_t2_x2", "a8", "nanum_amsterdam", "yy년 M월 d일", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 130, 249, 130, 30, 30, null, 2);

    TimestampGroupEntity a9 = TimestampGroupEntity("a9", Constants.TIMESTAMP_CATEGORY_ANALOG, "assets/timestamp/group/a9.png",  null, Colors.black.value, 8);
    AnalogTimestampEntity a9_t1_x0 = AnalogTimestampEntity.init(ratio, "a9_t1_x0", "a9", "assets/timestamp/analog/a9/hour.png", "assets/timestamp/analog/a9/minute.png", "assets/timestamp/analog/a9/background.png", 155, 130, 80, 80, 0);
    TimestampEntity a9_t3_x0 = TimestampEntity.init(ratio, "a9_t2_x0", "a9", "oxanium", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 130, 215, 130, 30, 18, null, 0);
    TimestampEntity a9_t2_x0 = TimestampEntity.init(ratio, "a9_t1_x0", "a9", "oxanium", "yy.M.d", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 235, 100, 30, 18, null, 0);
    AnalogTimestampEntity a9_t1_x1 = AnalogTimestampEntity.init(ratio, "a9_t1_x1", "a9", "assets/timestamp/analog/a9/hour.png", "assets/timestamp/analog/a9/minute.png", "assets/timestamp/analog/a9/background.png", 145, 110, 100, 100, 1);
    TimestampEntity a9_t3_x1 = TimestampEntity.init(ratio, "a9_t2_x1", "a9", "oxanium", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 120, 217, 150, 30, 22.5, null, 1);
    TimestampEntity a9_t2_x1 = TimestampEntity.init(ratio, "a9_t1_x1", "a9", "oxanium", "yy.M.d", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 140, 242, 110, 30, 22.5, null, 1);
    AnalogTimestampEntity a9_t1_x2 = AnalogTimestampEntity.init(ratio, "a9_t1_x2", "a9", "assets/timestamp/analog/a9/hour.png", "assets/timestamp/analog/a9/minute.png", "assets/timestamp/analog/a9/background.png", 135, 90, 120, 120, 2);
    TimestampEntity a9_t3_x2 = TimestampEntity.init(ratio, "a9_t3_x2", "a9", "oxanium", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 110, 219, 170, 30, 27, null, 2);
    TimestampEntity a9_t2_x2 = TimestampEntity.init(ratio, "a9_t2_x2", "a9", "oxanium", "yy.M.d", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 135, 249, 120, 30, 27, null, 2);

    TimestampGroupEntity a10 = TimestampGroupEntity("a10", Constants.TIMESTAMP_CATEGORY_ANALOG, "assets/timestamp/group/a10.png",  null, Colors.black.value, 9);
    AnalogTimestampEntity a10_t1_x0 = AnalogTimestampEntity.init(ratio, "a10_t1_x0", "a10", "assets/timestamp/analog/a10/hour.png", "assets/timestamp/analog/a10/minute.png", "assets/timestamp/analog/a10/background.png", 145, 120, 100, 100, 0);
    TimestampEntity a10_t2_x0 = TimestampEntity.init(ratio, "a10_t2_x0", "a10", "nanum_slowslow", "yyyy.MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 215, 100, 30, 23, null, 0);
    TimestampEntity a10_t3_x0 = TimestampEntity.init(ratio, "a10_t3_x0", "a10", "nanum_slowslow", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 235, 100, 30, 23, RegexUtil.TYPE_FULL_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 0);
    AnalogTimestampEntity a10_t1_x1 = AnalogTimestampEntity.init(ratio, "a10_t1_x1", "a10", "assets/timestamp/analog/a10/hour.png", "assets/timestamp/analog/a10/minute.png", "assets/timestamp/analog/a10/background.png", 132.5, 100, 125, 125, 1);
    TimestampEntity a10_t2_x1 = TimestampEntity.init(ratio, "a10_t2_x1", "a10", "nanum_slowslow", "yyyy.MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 217, 100, 30, 28.75, null, 1);
    TimestampEntity a10_t3_x1 = TimestampEntity.init(ratio, "a10_t3_x1", "a10", "nanum_slowslow", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 242, 100, 30, 28.75, RegexUtil.TYPE_FULL_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 1);
    AnalogTimestampEntity a10_t1_x2 = AnalogTimestampEntity.init(ratio, "a10_t1_x2", "a10", "assets/timestamp/analog/a10/hour.png", "assets/timestamp/analog/a10/minute.png", "assets/timestamp/analog/a10/background.png", 120, 75, 150, 150, 2);
    TimestampEntity a10_t2_x2 = TimestampEntity.init(ratio, "a10_t2_x2", "a10", "nanum_slowslow", "yyyy.MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 219, 100, 30, 34.5, null, 2);
    TimestampEntity a10_t3_x2 = TimestampEntity.init(ratio, "a10_t3_x2", "a10", "nanum_slowslow", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 249, 100, 30, 34.5, RegexUtil.TYPE_FULL_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 2);

    TimestampGroupEntity a11 = TimestampGroupEntity("a11", Constants.TIMESTAMP_CATEGORY_ANALOG, "assets/timestamp/group/a11.png",  null, Colors.black.value, 10);
    AnalogTimestampEntity a11_t1_x0 = AnalogTimestampEntity.init(ratio, "a11_t1_x0", "a11", "assets/timestamp/analog/a11/hour.png", "assets/timestamp/analog/a11/minute.png", "assets/timestamp/analog/a11/background.png", 150, 125, 90, 90, 0);
    TimestampEntity a11_t3_x0 = TimestampEntity.init(ratio, "a11_t3_x0", "a11", "nanum_galmat", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 145, 215, 100, 30, 20, RegexUtil.TYPE_FULL_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 0);
    TimestampEntity a11_t2_x0 = TimestampEntity.init(ratio, "a11_t2_x0", "a11", "nanum_galmat", "yy년 M월 d일", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 130, 235, 130, 30, 20, null, 0);
    AnalogTimestampEntity a11_t1_x1 = AnalogTimestampEntity.init(ratio, "a11_t1_x1", "a11", "assets/timestamp/analog/a11/hour.png", "assets/timestamp/analog/a11/minute.png", "assets/timestamp/analog/a11/background.png", 138.75, 100, 112.5, 112.5, 1);
    TimestampEntity a11_t3_x1 = TimestampEntity.init(ratio, "a11_t3_x1", "a11", "nanum_galmat", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 145, 217, 100, 30, 25, RegexUtil.TYPE_FULL_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 1);
    TimestampEntity a11_t2_x1 = TimestampEntity.init(ratio, "a11_t2_x1", "a11", "nanum_galmat", "yy년 M월 d일", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 130, 242, 130, 30, 25, null, 1);
    AnalogTimestampEntity a11_t1_x2 = AnalogTimestampEntity.init(ratio, "a11_t1_x2", "a11", "assets/timestamp/analog/a11/hour.png", "assets/timestamp/analog/a11/minute.png", "assets/timestamp/analog/a11/background.png", 127.5, 75, 135, 135, 2);
    TimestampEntity a11_t3_x2 = TimestampEntity.init(ratio, "a11_t3_x2", "a11", "nanum_galmat", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 145, 219, 100, 30, 30, RegexUtil.TYPE_FULL_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 2);
    TimestampEntity a11_t2_x2 = TimestampEntity.init(ratio, "a11_t2_x2", "a11", "nanum_galmat", "yy년 M월 d일", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 130, 249, 130, 30, 30, null, 2);

    TimestampGroupEntity a12 = TimestampGroupEntity("a12", Constants.TIMESTAMP_CATEGORY_ANALOG, "assets/timestamp/group/a12.png",  null, Colors.black.value, 11);
    AnalogTimestampEntity a12_t1_x0 = AnalogTimestampEntity.init(ratio, "a12_t1_x0", "a12", "assets/timestamp/analog/a12/hour.png", "assets/timestamp/analog/a12/minute.png", "assets/timestamp/analog/a12/background.png", 145, 120, 100, 100, 0);
    TimestampEntity a12_t3_x0 = TimestampEntity.init(ratio, "a12_t3_x0", "a12", "nanum_amsterdam", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 215, 100, 30, 20, RegexUtil.TYPE_ALL_TO_CAPITAL, 0);
    TimestampEntity a12_t2_x0 = TimestampEntity.init(ratio, "a12_t2_x0", "a12", "nanum_amsterdam", "yyyy.M.d", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 145, 235, 100, 30, 20, null, 0);
    AnalogTimestampEntity a12_t1_x1 = AnalogTimestampEntity.init(ratio, "a12_t1_x1", "a12", "assets/timestamp/analog/a12/hour.png", "assets/timestamp/analog/a12/minute.png", "assets/timestamp/analog/a12/background.png", 132.5, 100, 125, 125, 1);
    TimestampEntity a12_t3_x1 = TimestampEntity.init(ratio, "a12_t3_x1", "a12", "nanum_amsterdam", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 135, 217, 120, 30, 25, RegexUtil.TYPE_ALL_TO_CAPITAL, 1);
    TimestampEntity a12_t2_x1 = TimestampEntity.init(ratio, "a12_t2_x1", "a12", "nanum_amsterdam", "yyyy.M.d", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 140, 242, 110, 30, 25, null, 1);
    AnalogTimestampEntity a12_t1_x2 = AnalogTimestampEntity.init(ratio, "a12_t2_x2", "a12", "assets/timestamp/analog/a12/hour.png", "assets/timestamp/analog/a12/minute.png", "assets/timestamp/analog/a12/background.png", 120, 75, 150, 150, 2);
    TimestampEntity a12_t3_x2 = TimestampEntity.init(ratio, "a12_t3_x2", "a12", "nanum_amsterdam", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 125, 219, 140, 30, 30, RegexUtil.TYPE_ALL_TO_CAPITAL, 2);
    TimestampEntity a12_t2_x2 = TimestampEntity.init(ratio, "a12_t2_x2", "a12", "nanum_amsterdam", "yyyy.M.d", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 135, 249, 120, 30, 30, null, 2);

    TimestampGroupEntity a13 = TimestampGroupEntity("a13", Constants.TIMESTAMP_CATEGORY_ANALOG, "assets/timestamp/group/a13.png",  null, Colors.black.value, 12);
    AnalogTimestampEntity a13_t1_x0 = AnalogTimestampEntity.init(ratio, "a13_t1_x0", "a13", "assets/timestamp/analog/a13/hour.png", "assets/timestamp/analog/a13/minute.png", "assets/timestamp/analog/a13/background.png", 145, 120, 100, 100, 0);
    TimestampEntity a13_t3_x0 = TimestampEntity.init(ratio, "a13_t3_x0", "a13", "nanum_amsterdam", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 145, 215, 100, 30, 20, RegexUtil.TYPE_FULL_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 0);
    TimestampEntity a13_t2_x0 = TimestampEntity.init(ratio, "a13_t2_x0", "a13", "nanum_amsterdam", "yy년 M월 d일", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 145, 235, 100, 30, 20, null, 0);
    AnalogTimestampEntity a13_t1_x1 = AnalogTimestampEntity.init(ratio, "a13_t1_x1", "a13", "assets/timestamp/analog/a13/hour.png", "assets/timestamp/analog/a13/minute.png", "assets/timestamp/analog/a13/background.png", 132.5, 100, 125, 125, 1);
    TimestampEntity a13_t3_x1 = TimestampEntity.init(ratio, "a13_t3_x1", "a13", "nanum_amsterdam", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 140, 217, 110, 30, 25, RegexUtil.TYPE_FULL_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 1);
    TimestampEntity a13_t2_x1 = TimestampEntity.init(ratio, "a13_t2_x1", "a13", "nanum_amsterdam", "yy년 M월 d일", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 135, 242, 120, 30, 25, null, 1);
    AnalogTimestampEntity a13_t1_x2 = AnalogTimestampEntity.init(ratio, "a13_t1_x2", "a13", "assets/timestamp/analog/a13/hour.png", "assets/timestamp/analog/a13/minute.png", "assets/timestamp/analog/a13/background.png", 120, 75, 150, 150, 2);
    TimestampEntity a13_t3_x2 = TimestampEntity.init(ratio, "a13_t3_x2", "a13", "nanum_amsterdam", "EEEE a", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 135, 219, 120, 30, 30, RegexUtil.TYPE_FULL_DAY_TO_KR+","+RegexUtil.TYPE_AMPM_TO_KR, 2);
    TimestampEntity a13_t2_x2 = TimestampEntity.init(ratio, "a13_t2_x2", "a13", "nanum_amsterdam", "yy년 M월 d일", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 125, 249, 140, 30, 30, null, 2);

    timestampGroupBox.put("a1", a1);
    analogTimestampBox.put("a1_t1_x0", a1_t1_x0);
    timestampBox.put("a1_t2_x0", a1_t2_x0);
    timestampBox.put("a1_t3_x0", a1_t3_x0);
    analogTimestampBox.put("a1_t1_x1", a1_t1_x1);
    timestampBox.put("a1_t2_x1", a1_t2_x1);
    timestampBox.put("a1_t3_x1", a1_t3_x1);
    analogTimestampBox.put("a1_t1_x2", a1_t1_x2);
    timestampBox.put("a1_t2_x2", a1_t2_x2);
    timestampBox.put("a1_t3_x2", a1_t3_x2);

    timestampGroupBox.put("a2", a2);
    analogTimestampBox.put("a2_t1_x0", a2_t1_x0);
    timestampBox.put("a2_t2_x0", a2_t2_x0);
    timestampBox.put("a2_t3_x0", a2_t3_x0);
    analogTimestampBox.put("a2_t1v", a2_t1_x1);
    timestampBox.put("a2_t2_x1", a2_t2_x1);
    timestampBox.put("a2_t3_x1", a2_t3_x1);
    analogTimestampBox.put("a2_t1_x2", a2_t1_x2);
    timestampBox.put("a2_t2_x2", a2_t2_x2);
    timestampBox.put("a2_t3_x2", a2_t3_x2);

    timestampGroupBox.put("a3", a3);
    analogTimestampBox.put("a3_t1_x0", a3_t1_x0);
    timestampBox.put("a3_t2_x0", a3_t2_x0);
    timestampBox.put("a3_t3_x0", a3_t3_x0);
    analogTimestampBox.put("a3_t1_x1", a3_t1_x1);
    timestampBox.put("a3_t2_x1", a3_t2_x1);
    timestampBox.put("a3_t3_x1", a3_t3_x1);
    analogTimestampBox.put("a3_t1_x2", a3_t1_x2);
    timestampBox.put("a3_t2_x2", a3_t2_x2);
    timestampBox.put("a3_t3_x2", a3_t3_x2);

    timestampGroupBox.put("a4", a4);
    analogTimestampBox.put("a4_t1_x0", a4_t1_x0);
    timestampBox.put("a4_t2_x0", a4_t2_x0);
    timestampBox.put("a4_t3_x0", a4_t3_x0);
    analogTimestampBox.put("a4_t1_x1", a4_t1_x1);
    timestampBox.put("a4_t2_x1", a4_t2_x1);
    timestampBox.put("a4_t3_x1", a4_t3_x1);
    analogTimestampBox.put("a4_t1_x2", a4_t1_x2);
    timestampBox.put("a4_t2_x2", a4_t2_x2);
    timestampBox.put("a4_t3_x2", a4_t3_x2);

    timestampGroupBox.put("a5", a5);
    analogTimestampBox.put("a5_t1_x0", a5_t1_x0);
    timestampBox.put("a5_t2_x0", a5_t2_x0);
    timestampBox.put("a5_t3_x0", a5_t3_x0);
    analogTimestampBox.put("a5_t1_x1", a5_t1_x1);
    timestampBox.put("a5_t2_x1", a5_t2_x1);
    timestampBox.put("a5_t3_x1", a5_t3_x1);
    analogTimestampBox.put("a5_t1_x2", a5_t1_x2);
    timestampBox.put("a5_t2_x2", a5_t2_x2);
    timestampBox.put("a5_t3_x2", a5_t3_x2);

    timestampGroupBox.put("a6", a6);
    analogTimestampBox.put("a6_t1_x0", a6_t1_x0);
    timestampBox.put("a6_t2_x0", a6_t2_x0);
    timestampBox.put("a6_t3_x0", a6_t3_x0);
    analogTimestampBox.put("a6_t1_x1", a6_t1_x1);
    timestampBox.put("a6_t2_x1", a6_t2_x1);
    timestampBox.put("a6_t3_x1", a6_t3_x1);
    analogTimestampBox.put("a6_t1_x2", a6_t1_x2);
    timestampBox.put("a6_t2_x2", a6_t2_x2);
    timestampBox.put("a6_t3_x2", a6_t3_x2);

    timestampGroupBox.put("a7", a7);
    analogTimestampBox.put("a7_t1_x0", a7_t1_x0);
    timestampBox.put("a7_t2_x0", a7_t2_x0);
    timestampBox.put("a7_t3_x0", a7_t3_x0);
    analogTimestampBox.put("a7_t1_x1", a7_t1_x1);
    timestampBox.put("a7_t2_x1", a7_t2_x1);
    timestampBox.put("a7_t3_x1", a7_t3_x1);
    analogTimestampBox.put("a7_t1_x2", a7_t1_x2);
    timestampBox.put("a7_t2_x2", a7_t2_x2);
    timestampBox.put("a7_t3_x2", a7_t3_x2);

    timestampGroupBox.put("a8", a8);
    analogTimestampBox.put("a8_t1_x0", a8_t1_x0);
    timestampBox.put("a8_t2_x0", a8_t2_x0);
    timestampBox.put("a8_t3_x0", a8_t3_x0);
    analogTimestampBox.put("a8_t1_x1", a8_t1_x1);
    timestampBox.put("a8_t2_x1", a8_t2_x1);
    timestampBox.put("a8_t3_x1", a8_t3_x1);
    analogTimestampBox.put("a8_t1_x2", a8_t1_x2);
    timestampBox.put("a8_t2_x2", a8_t2_x2);
    timestampBox.put("a8_t3_x2", a8_t3_x2);

    timestampGroupBox.put("a9", a9);
    analogTimestampBox.put("a9_t1_x0", a9_t1_x0);
    timestampBox.put("a9_t2_x0", a9_t2_x0);
    timestampBox.put("a9_t3_x0", a9_t3_x0);
    analogTimestampBox.put("a9_t1_x1", a9_t1_x1);
    timestampBox.put("a9_t2_x1", a9_t2_x1);
    timestampBox.put("a9_t3_x1", a9_t3_x1);
    analogTimestampBox.put("a9_t1_x2", a9_t1_x2);
    timestampBox.put("a9_t2_x2", a9_t2_x2);
    timestampBox.put("a9_t3_x2", a9_t3_x2);

    timestampGroupBox.put("a10", a10);
    analogTimestampBox.put("a10_t1_x0", a10_t1_x0);
    timestampBox.put("a10_t2_x0", a10_t2_x0);
    timestampBox.put("a10_t3_x0", a10_t3_x0);
    analogTimestampBox.put("a10_t1_x1", a10_t1_x1);
    timestampBox.put("a10_t2_x1", a10_t2_x1);
    timestampBox.put("a10_t3_x1", a10_t3_x1);
    analogTimestampBox.put("a10_t1_x2", a10_t1_x2);
    timestampBox.put("a10_t2_x2", a10_t2_x2);
    timestampBox.put("a10_t3_x2", a10_t3_x2);

    timestampGroupBox.put("a11", a11);
    analogTimestampBox.put("a11_t1_x0", a11_t1_x0);
    timestampBox.put("a11_t2_x0", a11_t2_x0);
    timestampBox.put("a11_t3_x0", a11_t3_x0);
    analogTimestampBox.put("a11_t1_x1", a11_t1_x1);
    timestampBox.put("a11_t2_x1", a11_t2_x1);
    timestampBox.put("a11_t3_x1", a11_t3_x1);
    analogTimestampBox.put("a11_t1_x2", a11_t1_x2);
    timestampBox.put("a11_t2_x2", a11_t2_x2);
    timestampBox.put("a11_t3_x2", a11_t3_x2);

    timestampGroupBox.put("a12", a12);
    analogTimestampBox.put("a12_t1_x0", a12_t1_x0);
    timestampBox.put("a12_t2_x0", a12_t2_x0);
    timestampBox.put("a12_t3_x0", a12_t3_x0);
    analogTimestampBox.put("a12_t1_x1", a12_t1_x1);
    timestampBox.put("a12_t2_x1", a12_t2_x1);
    timestampBox.put("a12_t3_x1", a12_t3_x1);
    analogTimestampBox.put("a12_t1_x2", a12_t1_x2);
    timestampBox.put("a12_t2_x2", a12_t2_x2);
    timestampBox.put("a12_t3_x2", a12_t3_x2);

    timestampGroupBox.put("a13", a13);
    analogTimestampBox.put("a13_t1_x0", a13_t1_x0);
    timestampBox.put("a13_t2_x0", a13_t2_x0);
    timestampBox.put("a13_t3_x0", a13_t3_x0);
    analogTimestampBox.put("a13_t1_x1", a13_t1_x1);
    timestampBox.put("a13_t2_x1", a13_t2_x1);
    timestampBox.put("a13_t3_x1", a13_t3_x1);
    analogTimestampBox.put("a13_t1_x2", a13_t1_x2);
    timestampBox.put("a13_t2_x2", a13_t2_x2);
    timestampBox.put("a13_t3_x2", a13_t3_x2);
}

  static void saveTempDday() {
    // 원본: ratio = logicalWidth / 390. 이 앱에서는 렌더러가 390 기준 스케일을 적용합니다.
    const double ratio = 1.0;

    TimestampGroupEntity d1 = TimestampGroupEntity("d1", Constants.TIMESTAMP_CATEGORY_DDAY, "assets/timestamp/group/d1.png",  null, Colors.black.value, 0);
    DdayTimestampEntity d1_t1 = DdayTimestampEntity.init(ratio, "d1_t1", "d1", "kangwon_all_study", Constants.ALIGN_CENTER, 85, 155, 220, 90, 82);
    TimestampEntity d1_t2 = TimestampEntity.init(ratio, "d1_t2", "d1", "kangwon_all_study", "yyyy/MM/dd (E)", Constants.ALIGN_CENTER, Constants.LOCALE_KR, 120, 135, 150, 40, 18, RegexUtil.TYPE_DAY_TO_KR, 0);

    TimestampGroupEntity d2 = TimestampGroupEntity("d2", Constants.TIMESTAMP_CATEGORY_DDAY, "assets/timestamp/group/d2.png",  null, Colors.black.value, 1);
    DdayTimestampEntity d2_t1 = DdayTimestampEntity.init(ratio, "d2_t1", "d2", "tvn_fun_story", Constants.ALIGN_CENTER, 85, 160, 220, 90, 82);
    TimestampEntity d2_t2 = TimestampEntity.init(ratio, "d2_t2", "d2", "tvn_fun_story", "yyyy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 120, 135, 150, 40, 26, null, 0);

    TimestampGroupEntity d3 = TimestampGroupEntity("d3", Constants.TIMESTAMP_CATEGORY_DDAY, "assets/timestamp/group/d3.png",  null, Colors.black.value, 2);
    DdayTimestampEntity d3_t1 = DdayTimestampEntity.init(ratio, "d3_t1", "d3", "cafe24_dangdanghae", Constants.ALIGN_CENTER, 75, 135, 240, 80, 60);
    TimestampEntity d3_t2 = TimestampEntity.init(ratio, "d3_t2", "d3", "cafe24_dangdanghae", "a hh:mm dd/MMM", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 105, 195, 180, 40, 18, RegexUtil.TYPE_ALL_TO_CAPITAL, 0);

    TimestampGroupEntity d4 = TimestampGroupEntity("d4", Constants.TIMESTAMP_CATEGORY_DDAY, "assets/timestamp/group/d4.png",  null, Colors.black.value, 3);
    DdayTimestampEntity d4_t1 = DdayTimestampEntity.init(ratio, "d4_t1", "d4", "gmarket_sans", Constants.ALIGN_LEFT, 160, 314, 180, 70, 50);
    TimestampEntity d4_t2 = TimestampEntity.init(ratio, "d4_t2", "d4", "gmarket_sans", "EEEE", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 50, 315, 90, 40, 16, null, 0);
    TimestampEntity d4_t3 = TimestampEntity.init(ratio, "d4_t3", "d4", "gmarket_sans", "dd. MMM yyyy", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 20, 340, 120, 40, 16, RegexUtil.TYPE_ALL_TO_CAPITAL, 0);
    ImageEntity d4_i1 = ImageEntity.init(ratio, "d4_i1", "d4", "stamp", "assets/timestamp/image/stamp/stamp_19.png", 140, 330, 20, 40, 1, 0);

    TimestampGroupEntity d5 = TimestampGroupEntity("d5", Constants.TIMESTAMP_CATEGORY_DDAY, "assets/timestamp/group/d5.png",  null, Colors.black.value, 4);
    DdayTimestampEntity d5_t1 = DdayTimestampEntity.init(ratio, "d5_t1", "d5", "magnolia_script", Constants.ALIGN_LEFT, 120, 315, 160, 70, 50);
    TimestampEntity d5_t2 = TimestampEntity.init(ratio, "d5_t2", "d5", "magnolia_script", "MM/dd", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 10, 316, 60, 40, 16, null, 0);
    TimestampEntity d5_t3 = TimestampEntity.init(ratio, "d5_t3", "d5", "magnolia_script", "yyyy", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 10, 344, 60, 40, 16, null, 0);
    ImageEntity d5_i1 = ImageEntity.init(ratio, "d5_i1", "d5", "stamp", "assets/timestamp/image/stamp/stamp_4_2.png", 10, 330, 100, 35, 1, 0);

    TimestampGroupEntity d6 = TimestampGroupEntity("d6", Constants.TIMESTAMP_CATEGORY_DDAY, "assets/timestamp/group/d6.png",  null, Colors.black.value, 5);
    DdayTimestampEntity d6_t1 = DdayTimestampEntity.init(ratio, "d6_t1", "d6", "cafe24_dangdanghae", Constants.ALIGN_CENTER, 80, 160, 230, 90, 70);
    TimestampEntity d6_t2 = TimestampEntity.init(ratio, "d6_t3", "d6", "cafe24_dangdanghae", "a hh:mm", Constants.ALIGN_RIGHT, Constants.LOCALE_KR_EN, 112, 135, 80, 40, 16, null, 0);
    TimestampEntity d6_t3 = TimestampEntity.init(ratio, "d6_t4", "d6", "cafe24_dangdanghae", "MM/dd yy", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 205, 135, 80, 40, 16, null, 0);
    ImageEntity d6_i1 = ImageEntity.init(ratio, "d6_i1", "d6", "stamp", "assets/timestamp/image/stamp/stamp_19_2.png", 195, 146, 8, 16, 1, 0);

    TimestampGroupEntity d7 = TimestampGroupEntity("d7", Constants.TIMESTAMP_CATEGORY_DDAY, "assets/timestamp/group/d7.png",  null, Colors.black.value, 6);
    DdayTimestampEntity d7_t1 = DdayTimestampEntity.init(ratio, "d7_t1", "d7", "peace_sans", Constants.ALIGN_LEFT, 40, 300, 210, 80, 65);
    TimestampEntity d7_t2 = TimestampEntity.initWithRotate(ratio, "d7_t2", "d7", "gmarket_sans", "yy/MM/dd", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, -30, 305, 120, 40, 16, null, -pi/2, 0);
    TimestampEntity d7_t3 = TimestampEntity.init(ratio, "d7_t3", "d7", "gmarket_sans", "HH:mm", Constants.ALIGN_LEFT, Constants.LOCALE_KR_EN, 40, 275, 60, 40, 16, null, 0);

    TimestampGroupEntity d8 = TimestampGroupEntity("d8", Constants.TIMESTAMP_CATEGORY_DDAY, "assets/timestamp/group/d8.png",  null, Colors.black.value, 7);
    DdayTimestampEntity d8_t1 = DdayTimestampEntity.init(ratio, "d8_t1", "d8", "kangwon_study_tenten", Constants.ALIGN_CENTER, 80, 155, 230, 80, 70);
    TimestampEntity d8_t2 = TimestampEntity.init(ratio, "d8_t2", "d8", "gmarket_sans", "yyyy/MM/dd a h:m", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 75, 345, 240, 40, 16, null, 0);

    timestampGroupBox.put("d1", d1);
    ddayTimestampBox.put("d1_t1", d1_t1);
    timestampBox.put("d1_t2", d1_t2);
    timestampGroupBox.put("d2", d2);
    ddayTimestampBox.put("d2_t1", d2_t1);
    timestampBox.put("d2_t2", d2_t2);
    timestampGroupBox.put("d3", d3);
    ddayTimestampBox.put("d3_t1", d3_t1);
    timestampBox.put("d3_t2", d3_t2);
    timestampGroupBox.put("d4", d4);
    ddayTimestampBox.put("d4_t1", d4_t1);
    timestampBox.put("d4_t2", d4_t2);
    timestampBox.put("d4_t3", d4_t3);
    timestampImageBox.put("d4_i1", d4_i1);
    timestampGroupBox.put("d5", d5);
    ddayTimestampBox.put("d5_t1", d5_t1);
    timestampBox.put("d5_t2", d5_t2);
    timestampBox.put("d5_t3", d5_t3);
    timestampImageBox.put("d5_i1", d5_i1);
    timestampGroupBox.put("d6", d6);
    ddayTimestampBox.put("d6_t1", d6_t1);
    timestampBox.put("d6_t2", d6_t2);
    timestampBox.put("d6_t3", d6_t3);
    timestampImageBox.put("d6_i1", d6_i1);
    timestampGroupBox.put("d7", d7);
    ddayTimestampBox.put("d7_t1", d7_t1);
    timestampBox.put("d7_t2", d7_t2);
    timestampBox.put("d7_t3", d7_t3);
    timestampGroupBox.put("d8", d8);
    ddayTimestampBox.put("d8_t1", d8_t1);
    timestampBox.put("d8_t2", d8_t2);
}

  static void saveTempStyle() {
    // 원본: ratio = logicalWidth / 390. 이 앱에서는 렌더러가 390 기준 스케일을 적용합니다.
    const double ratio = 1.0;

    TimestampGroupEntity style3 = TimestampGroupEntity("style3", Constants.TIMESTAMP_CATEGORY_STYLISH, "assets/timestamp/group/kr/style3.png", null, null, 1);
    TimestampEntity style3_t1 = TimestampEntity.initWithFontWeight(ratio, "style3_t1", "style3", "nanum_square", "yyyy.MM.dd a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_KR_EN, 95, 195, 200, 40, 16, null, "w500", 0);
    TextEntity style3_txt1 = TextEntity.initWithFontWeight(ratio, "style3_txt1", "style3", "nanum_square_bold", getEatTime(), Colors.white.value, 35, 130, 320, 80, 58, 0, "w900");
    TextEntity style3_txt2 = TextEntity.initWithBackgroundColor(ratio, "style3_txt2", "style3", "nanum_square", I18n.get(I18n.locale, "today_dish_record"), Colors.black.value, 122, 338, 146, 32, 16, 0, "w500", Colors.white.value);

    TimestampGroupEntity style2 = TimestampGroupEntity("style2", Constants.TIMESTAMP_CATEGORY_STYLISH, "assets/timestamp/group/kr/style2.png", null, null, 2);
    TimestampEntity style2_t1 = TimestampEntity.init(ratio, "style2_t1", "style2", "bailleul_roman_italic", "yy/MM/dd", Constants.ALIGN_LEFT, Constants.LOCALE_EN, 10, 345, 130, 40, 22, null, 0);
    TimestampEntity style2_t2 = TimestampEntity.init(ratio, "style2_t2", "style2", "bailleul_roman_italic", "a hh:mm", Constants.ALIGN_RIGHT, Constants.LOCALE_EN, 250, 345, 130, 40, 22, null, 0);
    ImageEntity style2_i1 = ImageEntity.init(ratio, "style2_i1", "style2", "style", "assets/timestamp/image/style/style_1.png", 115, 20, 160, 48, 0, 0);
    TextEntity style2_txt1 = TextEntity.init(ratio, "style2_txt1", "style2", "cafe24_dangdanghae", "On the table", Colors.white.value, 95, 20, 200, 40, 28, 0);

    TimestampGroupEntity style11 = TimestampGroupEntity("style11", Constants.TIMESTAMP_CATEGORY_STYLISH, "assets/timestamp/group/kr/style11.png", null, null, 3);
    TimestampEntity style11_t1 = TimestampEntity.init(ratio, "style11_t1", "style11", "lee_seoyun", "yyyy.MM.dd a hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_EN, 12, 345, 200, 40, 20, null, 0);
    ImageEntity style11_i1 = ImageEntity.init(ratio, "style11_i1", "style11", "style", "assets/timestamp/image/style/style_4.png", 75, 31, 240, 44, 0, 0);
    ImageEntity style11_i2 = ImageEntity.init(ratio, "style11_i2", "style11", "style", "assets/timestamp/image/style/style_5.png", -25, 15, 83, 83, 0, 0);
    TextEntity style11_txt1 = TextEntity.init(ratio, "style11_txt1", "style11", "nanum_hana_hand_write", I18n.get(I18n.locale, "today_brunch"), Colors.black.value, 95, 23, 200, 55, 42, 0);
    TextEntity style11_txt2 = TextEntity.init(ratio, "style11_txt2", "style11", "nanum_hana_hand_write", I18n.get(I18n.locale, "shrimp"), Colors.white.value, 75, 140, 80, 40, 30, 0);
    TextEntity style11_txt3 = TextEntity.init(ratio, "style11_txt3", "style11", "nanum_hana_hand_write", I18n.get(I18n.locale, "rucola"), Colors.white.value, 230, 215, 100, 40, 30, 0);
    TextEntity style11_txt4 = TextEntity.init(ratio, "style11_txt4", "style11", "nanum_hana_hand_write", I18n.get(I18n.locale, "egg"), Colors.white.value, 105, 220, 70, 40, 30, 0);
    TextEntity style11_txt5 = TextEntity.init(ratio, "style11_txt5", "style11", "nanum_hana_hand_write", I18n.get(I18n.locale, "cherry_tomato"), Colors.white.value, 160, 120, 120, 40, 30, 0);


    TimestampGroupEntity style1 = TimestampGroupEntity("style1", Constants.TIMESTAMP_CATEGORY_STYLISH, "assets/timestamp/group/kr/style1.png", null, null, 4);
    TimestampEntity style1_t1 = TimestampEntity.init(ratio, "style1_t1", "style1", "rondal_bold", "EEEE", Constants.ALIGN_CENTER, Constants.LOCALE_EN, 85, 160, 220, 70, 56, null, 0);
    TimestampEntity style1_t2 = TimestampEntity.initWithFontWeight(ratio, "style1_t2", "style1", "lobster", "MM", Constants.ALIGN_RIGHT, Constants.LOCALE_EN, 30, 175, 40, 40, 18, null, "w100", 0);
    TimestampEntity style1_t3 = TimestampEntity.initWithFontWeight(ratio, "style1_t3", "style1", "lobster", "dd", Constants.ALIGN_LEFT, Constants.LOCALE_EN, 320, 175, 40, 40, 18, null, "w100", 0);
    RoundTextEntity style1_rtxt1 = RoundTextEntity.init(ratio, "style1_rtxt1", "style1", "rondal", "Many a little makes a miracle", Colors.white.value, 45, 90, 300, 60, 16, 280, 0);
    ImageEntity style1_i1 = ImageEntity.init(ratio, "style1_i1", "style1", "circle", "assets/timestamp/image/circle/circle_1.png", 142.5, 245, 105, 46, 0, 0);
    TimestampEntity style1_t4 = TimestampEntity.init(ratio, "style1_t4", "style1", "rondal", "a hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_EN, 135, 250, 120, 40, 18, null, 0);


    TimestampGroupEntity style4 = TimestampGroupEntity("style4", Constants.TIMESTAMP_CATEGORY_STYLISH, "assets/timestamp/group/kr/style4.png", null, null, 5);
    TimestampEntity style4_t1 = TimestampEntity.init(ratio, "style4_t1", "style4", "unna_bold", "hh:mm", Constants.ALIGN_LEFT, Constants.LOCALE_EN, 28, 150, 80, 40, 32, null, 0);
    TimestampEntity style4_t2 = TimestampEntity.init(ratio, "style4_t2", "style4", "unna_bold", "a", Constants.ALIGN_LEFT, Constants.LOCALE_EN, 107, 147, 50, 30, 16, RegexUtil.TYPE_ALL_TO_LOWERCASE, 0);
    TextEntity style4_txt1 = TextEntity.init(ratio, "style4_txt1", "style4", "unna_bold", "Good", Colors.white.value, 10, 15, 140, 60, 50, 0);
    TextEntity style4_txt2 = TextEntity.init(ratio, "style4_txt2", "style4", "unna_bold", "Morning.", Colors.white.value, 10, 60, 230, 60, 50, 0);
    TextEntity style4_txt3 = TextEntity.init(ratio, "style4_txt3", "style4", "unna_italic", "Recorded in", Colors.yellow.value, 85, 340, 110, 44, 18, 0);
    TimestampEntity style4_t3 = TimestampEntity.initWithColor(ratio, "style4_t3", "style4", "unna_italic", "MMMM dd, yyyy", Constants.ALIGN_LEFT, Constants.LOCALE_EN, 185, 344, 140, 40, 18, null, null, Colors.yellow.value, 0);

    TimestampGroupEntity style5 = TimestampGroupEntity("style5", Constants.TIMESTAMP_CATEGORY_STYLISH, "assets/timestamp/group/kr/style5.png", null, null, 6);
    TimestampEntity style5_t1 = TimestampEntity.init(ratio, "style5_t1", "style5", "bailleul_roman", "a hh:mm yyyy.MM.dd EEEE", Constants.ALIGN_CENTER, Constants.LOCALE_EN, 45, 210, 300, 40, 18, null, 0);
    TextEntity style5_txt1 = TextEntity.init(ratio, "style5_txt1", "style5", "nyghtserif", "Morning Vibes.", Colors.yellow.value, 20, 150, 350, 60, 40, 0);
    RoundTextEntity style5_rtxt1 = RoundTextEntity.init(ratio, "style5_rtxt1", "style5", "unna_regular", "⦁ Life is full of possibilities ⦁", Colors.white.value, 45, 90, 300, 60, 18, 250, 0);

    TimestampGroupEntity style6 = TimestampGroupEntity("style6", Constants.TIMESTAMP_CATEGORY_STYLISH, "assets/timestamp/group/kr/style6.png", null, null, 7);
    TimestampEntity style6_t1 = TimestampEntity.initWithRotateColor(ratio, "style6_t1", "style6", "curvilingus", "yyyy.MM.dd EEEE", Constants.ALIGN_LEFT, Constants.LOCALE_EN, -85, 100, 200, 40, 22, RegexUtil.TYPE_ALL_TO_CAPITAL, pi/2, Colors.black.value, 0);
    TimestampEntity style6_t2 = TimestampEntity.init(ratio, "style6_t2", "style6", "curvilingus", "hh:mm a", Constants.ALIGN_RIGHT, Constants.LOCALE_EN, 255, 345, 120, 40, 26, RegexUtil.TYPE_ALL_TO_LOWERCASE, 0);
    ImageEntity style6_i1 = ImageEntity.init(ratio, "style6_i1", "style6", "style", "assets/timestamp/image/style/style_2.png", -1, 0, 46, 390, 0, 0);

    TimestampGroupEntity style7 = TimestampGroupEntity("style7", Constants.TIMESTAMP_CATEGORY_STYLISH, "assets/timestamp/group/kr/style7.png", null, null, 8);
    TimestampEntity style7_t1 = TimestampEntity.initWithFontWeight(ratio, "style6_t1", "style7", "nanum_square", "yy.MM.dd", Constants.ALIGN_CENTER, Constants.LOCALE_EN, 10, 5, 60, 30, 11, null, "w600", 0);
    TimestampEntity style7_t2 = TimestampEntity.initWithFontWeight(ratio, "style6_t2", "style7", "nanum_square", "hh", Constants.ALIGN_CENTER, Constants.LOCALE_EN, 10, 30, 60, 50, 42, null, "w900", 0);
    TimestampEntity style7_t3 = TimestampEntity.initWithFontWeight(ratio, "style6_t3", "style7", "nanum_square", "mm", Constants.ALIGN_CENTER, Constants.LOCALE_EN, 10, 76, 60, 50, 42, null, "w900", 0);
    TimestampEntity style7_t4 = TimestampEntity.initWithColor(ratio, "style6_t4", "style7", "nanum_square", "a", Constants.ALIGN_CENTER, Constants.LOCALE_EN, 10, 106, 60, 50, 11, null, "w600", Colors.black.value, 0);
    ImageEntity style7_i1 = ImageEntity.init(ratio, "style7_i1", "style7", "style", "assets/timestamp/image/style/style_3.png", 15, 123, 50, 15, 0, 0);
    TextEntity style7_txt1 = TextEntity.initWithFontWeight(ratio, "style7_txt1", "style7", "nanum_myeongjo", I18n.get(I18n.locale, "style7_default_text1"), Colors.white.value, 70, 160, 250, 40, 20, 0,"w400");
    TextEntity style7_txt2 = TextEntity.initWithFontWeight(ratio, "style7_txt2", "style7", "nanum_myeongjo", I18n.get(I18n.locale, "style7_default_text2"), Colors.white.value, 30, 185, 330, 40, 20, 0,"w400");
    TextEntity style7_txt3 = TextEntity.init(ratio, "style7_txt3", "style7", "bailleul_roman_italic", "Today's reading", Colors.white.value, 75, 345, 240, 40, 16, 0);


    TimestampGroupEntity style8 = TimestampGroupEntity("style8", Constants.TIMESTAMP_CATEGORY_STYLISH, "assets/timestamp/group/kr/style8.png", null, null, 9);
    TextEntity style8_txt1 = TextEntity.init(ratio, "style8_txt1", "style8", "cafe24_dangdanghae", "Today", Colors.yellow.value, 3, 10, 140, 60, 40, 0);
    TextEntity style8_txt2 = TextEntity.init(ratio, "style8_txt2", "style8", "cafe24_dangdanghae", "Activity.", Colors.yellow.value, 10, 60, 160, 60, 40, 0);
    RoundTextEntity style8_rtxt1 = RoundTextEntity.initWithRotate(ratio, "style8_rtxt1", "style8", "unna_regular", "Today's activity record", Colors.white.value, 255, 35, 90, 60, 10, 35, -pi/2, 0);
    TimestampEntity style8_t1 = TimestampEntity.initWithColor(ratio, "style8_t1", "style8", "oooh_baby", "a", Constants.ALIGN_CENTER, Constants.LOCALE_EN, 310, 10, 80, 40, 24, null, null, Colors.yellow.value, 0);
    TimestampEntity style8_t2 = TimestampEntity.init(ratio, "style8_t2", "style8", "unna_regular", "hh", Constants.ALIGN_CENTER, Constants.LOCALE_EN, 320, 35, 60, 40, 40, null, 0);
    TimestampEntity style8_t3 = TimestampEntity.init(ratio, "style8_t3", "style8", "unna_regular", "mm", Constants.ALIGN_CENTER, Constants.LOCALE_EN, 320, 70, 60, 40, 40, null, 0);


    TimestampGroupEntity style9 = TimestampGroupEntity("style9", Constants.TIMESTAMP_CATEGORY_STYLISH, "assets/timestamp/group/kr/style9.png", null, null, 10);
    TimestampEntity style9_t1 = TimestampEntity.init(ratio, "style9_t1", "style9", "clarity_city_bold_italic", "EEEE", Constants.ALIGN_CENTER, Constants.LOCALE_EN, 115, 63, 160, 40, 26, null, 0);
    TimestampEntity style9_t2 = TimestampEntity.init(ratio, "style9_t2", "style9", "clarity_city_bold_italic", "yyyy / MM / dd", Constants.ALIGN_CENTER, Constants.LOCALE_EN, 115, 93, 160, 40, 22, null, 0);
    TimestampEntity style9_t3 = TimestampEntity.init(ratio, "style9_t3", "style9", "clarity_city_bold_italic", "HH:mm", Constants.ALIGN_CENTER, Constants.LOCALE_EN, 50, 175, 290, 40, 60, null, 0);
    ImageEntity style9_i1 = ImageEntity.init(ratio, "style9_i1", "style9", "circle", "assets/timestamp/image/circle/circle_2.png", 57.5, 150, 275, 90, 0, 0);

    TimestampGroupEntity style10 = TimestampGroupEntity("style10", Constants.TIMESTAMP_CATEGORY_STYLISH, "assets/timestamp/group/kr/style10.png", null, null, 11);
    StyleTimestampEntity style10_t1 = StyleTimestampEntity.init(ratio, "style10_t1", "style10", Constants.STYLE_TYPE_DAY_ROLLER ,"nanum_barunpen", "dd", Constants.ALIGN_CENTER, Constants.LOCALE_EN, 95, 70, 200, 40, 16, null, "w600", 0);
    TimestampEntity style10_t2 = TimestampEntity.init(ratio, "style10_t2", "style10", "nyghtserif", "MMMM", Constants.ALIGN_CENTER, Constants.LOCALE_EN, 125, 25, 140, 40, 35, null, 0);
    TimestampEntity style10_t3 = TimestampEntity.initWithFontWeight(ratio, "style10_t3", "style10", "gmarket_sans", "a", Constants.ALIGN_RIGHT, Constants.LOCALE_EN, 70, 167, 50, 36, 14, null, "w600", 0);
    TimestampEntity style10_t4 = TimestampEntity.initWithFontWeight(ratio, "style10_t4", "style10", "gmarket_sans", "hh:mm", Constants.ALIGN_CENTER, Constants.LOCALE_EN, 105, 172, 180, 60, 50, null, "w900", 0);


    timestampGroupBox.delete("style1");
    timestampGroupBox.put("style1", style1);
    timestampBox.put("style1_t1", style1_t1);
    timestampBox.put("style1_t2", style1_t2);
    timestampBox.put("style1_t3", style1_t3);
    timestampBox.put("style1_t4", style1_t4);
    timestampImageBox.put("style1_i1", style1_i1);
    roundTextBox.put("style1_rtxt1", style1_rtxt1);

    timestampGroupBox.delete("style2");
    timestampGroupBox.put("style2", style2);
    timestampBox.put("style2_t1", style2_t1);
    timestampBox.put("style2_t2", style2_t2);
    timestampImageBox.put("style2_i1", style2_i1);
    textBox.put("style2_txt1", style2_txt1);

    timestampGroupBox.delete("style3");
    textBox.delete("style3_txt2");
    timestampGroupBox.put("style3", style3);
    timestampBox.put("style3_t1", style3_t1);
    textBox.put("style3_txt1", style3_txt1);
    textBox.put("style3_txt2", style3_txt2);

    timestampGroupBox.delete("style4");
    timestampGroupBox.put("style4", style4);
    timestampBox.put("style4_t1", style4_t1);
    timestampBox.put("style4_t2", style4_t2);
    timestampBox.put("style4_t3", style4_t3);
    textBox.put("style4_txt1", style4_txt1);
    textBox.put("style4_txt2", style4_txt2);
    textBox.put("style4_txt3", style4_txt3);

    timestampGroupBox.delete("style5");
    timestampGroupBox.put("style5", style5);
    timestampBox.put("style5_t1", style5_t1);
    textBox.put("style5_txt1", style5_txt1);
    roundTextBox.put("style5_rtxt1", style5_rtxt1);

    timestampGroupBox.delete("style6");
    timestampImageBox.delete("style6_i1");
    timestampImageBox.delete("style6_i2");
    timestampImageBox.delete("style6_i3");
    timestampGroupBox.put("style6", style6);
    timestampBox.put("style6_t1", style6_t1);
    timestampBox.put("style6_t2", style6_t2);
    timestampImageBox.put("style6_i1", style6_i1);

    timestampGroupBox.delete("style7");
    timestampGroupBox.put("style7", style7);
    timestampBox.put("style7_t1", style7_t1);
    timestampBox.put("style7_t2", style7_t2);
    timestampBox.put("style7_t3", style7_t3);
    timestampBox.put("style7_t4", style7_t4);
    timestampImageBox.put("style7_i1", style7_i1);
    textBox.put("style7_txt1", style7_txt1);
    textBox.put("style7_txt2", style7_txt2);
    textBox.put("style7_txt3", style7_txt3);

    timestampGroupBox.delete("style8");
    timestampGroupBox.put("style8", style8);
    textBox.put("style8_txt1", style8_txt1);
    textBox.put("style8_txt2", style8_txt2);
    roundTextBox.put("style8_rtxt1", style8_rtxt1);
    timestampBox.put("style8_t1", style8_t1);
    timestampBox.put("style8_t2", style8_t2);
    timestampBox.put("style8_t3", style8_t3);

    timestampGroupBox.delete("style9");
    timestampGroupBox.put("style9", style9);
    timestampBox.put("style9_t1", style9_t1);
    timestampBox.put("style9_t2", style9_t2);
    timestampBox.put("style9_t3", style9_t3);
    timestampImageBox.put("style9_i1", style9_i1);

    timestampGroupBox.delete("style10");
    timestampGroupBox.put("style10", style10);
    styleTimestampBox.put("style10_t1", style10_t1);
    timestampBox.put("style10_t2", style10_t2);
    timestampBox.put("style10_t3", style10_t3);
    timestampBox.put("style10_t4", style10_t4);

    timestampGroupBox.delete("style11");
    timestampGroupBox.put("style11", style11);
    timestampBox.put("style11_t1", style11_t1);
    timestampImageBox.put("style11_i1", style11_i1);
    timestampImageBox.put("style11_i2", style11_i2);
    textBox.put("style11_txt1", style11_txt1);
    textBox.put("style11_txt2", style11_txt2);
    textBox.put("style11_txt3", style11_txt3);
    textBox.put("style11_txt4", style11_txt4);
    textBox.put("style11_txt5", style11_txt5);
}

  static String getEatTime() {
    String eatTime = "LUNCH";
    DateTime currentTime = DateTime.now();
    if(currentTime.hour >= 5 && currentTime.hour <= 10) {
      eatTime = "BREAKFAST";
    }
    if(currentTime.hour > 10 && currentTime.hour <= 15) {
      eatTime = "LUNCH";
    }
    if(currentTime.hour >= 16 && currentTime.hour <= 22) {
      eatTime = "DINNER";
    }
    return eatTime;
}
}

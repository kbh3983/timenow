"""
샘플 앱 TimestampRepository.dart 의 데이터 정의 코드를 이 앱으로 그대로 이식하는 생성기.

- saveTemp* 메서드 본문을 그대로 복사 (한국어 로케일 기준)
- `if(I18n.LOCALE_EN_US == I18n.locale) { ... }` 영어 분기는 제거
- window.devicePixelRatio 기반 ratio 계산은 `const double ratio = 1.0;` 로 치환
  (실제 화면 스케일은 렌더러에서 390 기준으로 적용)
- 이미지 에셋 원본 픽셀 크기 표 생성 (BoxFit.scaleDown 재현용)
"""
import os, re, struct, sys, io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

SAMPLE = r'C:\Project\timenow\timestamp_sample\now'
APP = r'C:\Project\timenow'
SRC_FILE = os.path.join(SAMPLE, r'lib\repo\TimestampRepository.dart')
OUT_DATA = os.path.join(APP, r'lib\stamps\sample_stamp_data.dart')
OUT_ASSETS = os.path.join(APP, r'lib\stamps\sample_stamp_assets.dart')

src = open(SRC_FILE, encoding='utf-8').read().replace('\r\n', '\n')

METHODS = ['saveTempNormal', 'saveTempStamp', 'saveTempFrame', 'saveTempAnalog',
           'saveTempDday', 'saveTempStyle', 'getEatTime']


def extract_method(name):
    m = re.search(r'static (void|String) ' + name + r'\(\) \{', src)
    assert m, name
    i = m.end()
    depth = 1
    in_str = False
    while depth > 0:
        c = src[i]
        if in_str:
            if c == '\\':
                i += 1
            elif c == '"':
                in_str = False
        else:
            if c == '"':
                in_str = True
            elif c == '{':
                depth += 1
            elif c == '}':
                depth -= 1
        i += 1
    header = src[m.start():m.end()]
    body = src[m.end():i - 1]
    return header, body


RATIO_LINES = [
    'var pixelRatio = window.devicePixelRatio;',
    'var logicalScreenSize = window.physicalSize / pixelRatio;',
    'var logicalWidth = logicalScreenSize.width;',
    'double baseDeviceWidth = 390;',
]


def transform_body(body):
    out = []
    lines = body.split('\n')
    skip_depth = 0
    removed_en = 0
    for line in lines:
        s = line.strip()
        if skip_depth > 0:
            skip_depth += line.count('{') - line.count('}')
            continue
        if re.match(r'^if\s*\(\s*I18n\.LOCALE_EN_US\s*==\s*I18n\.locale\s*\)\s*\{\s*$', s):
            skip_depth = 1
            removed_en += 1
            continue
        if s in RATIO_LINES:
            continue
        if s == 'double ratio = logicalWidth / baseDeviceWidth;':
            indent = line[:len(line) - len(line.lstrip())]
            out.append(indent + '// 원본: ratio = logicalWidth / 390. 이 앱에서는 렌더러가 390 기준 스케일을 적용합니다.')
            out.append(indent + 'const double ratio = 1.0;')
            continue
        out.append(line.rstrip())
    return '\n'.join(out), removed_en


parts = []
total_en = 0
for name in METHODS:
    header, body = extract_method(name)
    tbody, n = transform_body(body)
    total_en += n
    parts.append('  ' + header + tbody + '}\n')

data = '''// GENERATED FILE - DO NOT EDIT BY HAND.
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

''' + '\n'.join(parts) + '}\n'

os.makedirs(os.path.dirname(OUT_DATA), exist_ok=True)
with open(OUT_DATA, 'w', encoding='utf-8', newline='\n') as f:
    f.write(data)
print('data written', OUT_DATA, 'EN blocks removed:', total_en)

# ---- asset pixel sizes ----
paths = sorted(set(re.findall(r'"(assets/timestamp/(?:image|analog)/[^"]+)"', src)))


def png_size(p):
    with open(p, 'rb') as fh:
        h = fh.read(24)
    return struct.unpack('>II', h[16:24])


rows = []
for p in paths:
    w, h = png_size(os.path.join(SAMPLE, p.replace('/', os.sep)))
    rows.append("  '%s': Size(%d, %d)," % (p, w, h))

assets = '''// GENERATED FILE - DO NOT EDIT BY HAND. (tool/gen_sample_stamps.py)
// 샘플 스탬프 이미지 에셋의 원본 픽셀 크기.
// 샘플의 Image.asset(width, height) 기본 동작(BoxFit.scaleDown) 을 동일하게 재현하기 위해 사용합니다.
import 'dart:ui' show Size;

const Map<String, Size> sampleStampImageSizes = <String, Size>{
''' + '\n'.join(rows) + '\n};\n'
with open(OUT_ASSETS, 'w', encoding='utf-8', newline='\n') as f:
    f.write(assets)
print('assets written', OUT_ASSETS, len(rows))


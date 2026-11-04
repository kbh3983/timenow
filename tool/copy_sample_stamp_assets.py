"""샘플 스탬프용 이미지/폰트 에셋을 앱으로 복사하고 pubspec 에 넣을 항목을 출력합니다."""
import os, re, shutil, sys, io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
SAMPLE = r'C:\Project\timenow\timestamp_sample\now'
APP = r'C:\Project\timenow'

# 1) 이미지 에셋: 샘플과 동일한 경로(assets/timestamp/...)로 복사 → 데이터 경로를 그대로 사용
src_root = os.path.join(SAMPLE, 'assets', 'timestamp')
dst_root = os.path.join(APP, 'assets', 'timestamp')
asset_dirs = []
for sub in ['analog', 'image']:
    for dirpath, _, files in os.walk(os.path.join(src_root, sub)):
        rel = os.path.relpath(dirpath, src_root)
        out_dir = os.path.join(dst_root, rel)
        pngs = [f for f in files if f.lower().endswith('.png')]
        if not pngs:
            continue
        os.makedirs(out_dir, exist_ok=True)
        for f in pngs:
            shutil.copy2(os.path.join(dirpath, f), os.path.join(out_dir, f))
        asset_dirs.append('assets/timestamp/' + rel.replace(os.sep, '/') + '/')
asset_dirs.sort(key=lambda s: [int(t) if t.isdigit() else t for t in re.split(r'(\d+)', s)])

# 2) 폰트: 앱에서 제공하는 스탬프(기존 13종·D-day 제외)가 쓰는 폰트 중 앱에 없는 것만 assets/font/stamp/ 로 복사
#    (gen_sample_stamps.py 로 생성된 한국어 데이터 기준)
data = open(os.path.join(APP, r'lib\stamps\sample_stamp_data.dart'), encoding='utf-8').read()
EXCLUDED = {'n1_1', 'n1_2', 'n2_1', 'n2_2', 'n3_1', 'n3_2', 's1_1', 's1_2', 's2_1', 's2_2',
            's3_1', 's3_2', 'style1', 'd1', 'd2', 'd3', 'd4', 'd5', 'd6', 'd7', 'd8'}
fams = sorted(set(fam for group, fam in re.findall(
    r'^\s*\w+ \w+ = (?:TimestampEntity|TextEntity|RoundTextEntity|StyleTimestampEntity)\.init\w*\(ratio,\s*"[^"]+",\s*"([^"]+)",\s*(?:Constants\.\w+\s*,\s*)?"([^"]+)"',
    data, re.M) if group not in EXCLUDED))

# 앱에 이미 등록된 폰트(동일 파일) → 기존 패밀리 재사용
existing = {
    'rubber_nipple_factory', 'nixie_one', 'cafe24_one_pretty_night', 'nanum_amsterdam',
    'nanum_barunpen', 'cafe24_simplehae', 'tvn_fun_story', 'cafe24_shiningstar',
    'rondal', 'rondal_bold', 'lobster', 'lee_seoyun',
}
font_files = {}
for sub in ['en', 'kr']:
    d = os.path.join(SAMPLE, 'assets', 'font', sub)
    for f in os.listdir(d):
        base, ext = os.path.splitext(f)
        if ext.lower() in ('.ttf', '.otf'):
            font_files.setdefault(base, os.path.join(d, f))

out_font_dir = os.path.join(APP, 'assets', 'font', 'stamp')
os.makedirs(out_font_dir, exist_ok=True)
pub_fonts = []
total = 0
for fam in fams:
    if fam in existing:
        continue
    src = font_files[fam]
    fname = os.path.basename(src)
    shutil.copy2(src, os.path.join(out_font_dir, fname))
    total += os.path.getsize(src)
    pub_fonts.append('    - family: %s\n      fonts:\n        - asset: assets/font/stamp/%s' % (fam, fname))

print('# ASSET DIRS')
for a in asset_dirs:
    print('    - ' + a)
print('# FONTS (%d, %.1f MB)' % (len(pub_fonts), total / 1024 / 1024))
print('\n'.join(pub_fonts))


"""pubspec.yaml 에 샘플 스탬프 에셋 디렉터리와 폰트 패밀리를 추가합니다 (중복 실행 안전)."""
import os, re, sys, io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
APP = r'C:\Project\timenow'
PUB = os.path.join(APP, 'pubspec.yaml')
text = open(PUB, encoding='utf-8').read()
nl = '\r\n' if '\r\n' in text else '\n'
text = text.replace('\r\n', '\n')

MARK_A = '    # --- 샘플 스탬프 에셋 (tool/copy_sample_stamp_assets.py) ---'
MARK_F = '    # --- 샘플 스탬프 폰트 (tool/copy_sample_stamp_assets.py) ---'
if MARK_A in text:
    print('already applied')
    sys.exit(0)

# asset dirs
dirs = []
root = os.path.join(APP, 'assets', 'timestamp')
for dirpath, _, files in os.walk(root):
    if any(f.lower().endswith('.png') for f in files):
        rel = os.path.relpath(dirpath, APP).replace(os.sep, '/') + '/'
        dirs.append(rel)
dirs.sort(key=lambda s: [int(t) if t.isdigit() else t for t in re.split(r'(\d+)', s)])
asset_block = MARK_A + '\n' + '\n'.join('    - ' + d for d in dirs) + '\n'

# fonts
font_dir = os.path.join(APP, 'assets', 'font', 'stamp')
fonts = sorted(os.listdir(font_dir))
font_block = MARK_F + '\n' + '\n'.join(
    '    - family: %s\n      fonts:\n        - asset: assets/font/stamp/%s' % (os.path.splitext(f)[0], f)
    for f in fonts) + '\n'

anchor_assets = '    - assets/font/\n'
assert anchor_assets in text
text = text.replace(anchor_assets, anchor_assets + asset_block, 1)

anchor_fonts = '    - family: Lobster\n      fonts:\n        - asset: assets/font/lobster.otf\n'
assert anchor_fonts in text
text = text.replace(anchor_fonts, anchor_fonts + font_block, 1)

open(PUB, 'w', encoding='utf-8', newline='').write(text.replace('\n', nl))
print('applied: %d asset dirs, %d fonts' % (len(dirs), len(fonts)))


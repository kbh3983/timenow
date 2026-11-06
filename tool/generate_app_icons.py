import os
from PIL import Image, ImageDraw

def main():
    src_path = r'C:/Users/bbong/.gemini/antigravity/brain/053d37fe-8a1e-46ed-846c-5570977c3c4e/.user_uploaded/media_1793978109794_26bddcb6.png'
    img = Image.open(src_path).convert('RGBA')

    # 1. Project asset paths
    os.makedirs('assets/icons', exist_ok=True)
    os.makedirs('assets/images', exist_ok=True)
    img.save('assets/icons/app_logo.png', 'PNG')
    img.save('assets/images/app_logo.png', 'PNG')
    print('Saved assets/icons/app_logo.png & assets/images/app_logo.png')

    # 2. iOS AppIcon sizes
    ios_dir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    os.makedirs(ios_dir, exist_ok=True)
    ios_sizes = {
        'Icon-App-20x20@1x.png': (20, 20),
        'Icon-App-20x20@2x.png': (40, 40),
        'Icon-App-20x20@3x.png': (60, 60),
        'Icon-App-29x29@1x.png': (29, 29),
        'Icon-App-29x29@2x.png': (58, 58),
        'Icon-App-29x29@3x.png': (87, 87),
        'Icon-App-40x40@1x.png': (40, 40),
        'Icon-App-40x40@2x.png': (80, 80),
        'Icon-App-40x40@3x.png': (120, 120),
        'Icon-App-60x60@2x.png': (120, 120),
        'Icon-App-60x60@3x.png': (180, 180),
        'Icon-App-76x76@1x.png': (76, 76),
        'Icon-App-76x76@2x.png': (152, 152),
        'Icon-App-83.5x83.5@2x.png': (167, 167),
        'Icon-App-1024x1024@1x.png': (1024, 1024),
    }

    # iOS requires no alpha channel in AppIcon
    img_rgb = img.convert('RGB')
    for filename, (w, h) in ios_sizes.items():
        out_path = os.path.join(ios_dir, filename)
        resized = img_rgb.resize((w, h), Image.Resampling.LANCZOS)
        resized.save(out_path, 'PNG')
        print(f'Saved {out_path} ({w}x{h})')

    # 3. Android mipmap legacy icons
    android_res = 'android/app/src/main/res'
    mipmap_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }

    for folder, size in mipmap_sizes.items():
        folder_path = os.path.join(android_res, folder)
        os.makedirs(folder_path, exist_ok=True)
        # ic_launcher.png (square / squircle)
        out_path = os.path.join(folder_path, 'ic_launcher.png')
        resized = img.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(out_path, 'PNG')

        # ic_launcher_round.png (Circular mask for devices requesting round icon)
        round_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        mask = Image.new('L', (size, size), 0)
        draw = ImageDraw.Draw(mask)
        draw.ellipse((0, 0, size - 1, size - 1), fill=255)
        round_img.paste(resized, (0, 0), mask=mask)
        round_path = os.path.join(folder_path, 'ic_launcher_round.png')
        round_img.save(round_path, 'PNG')
        print(f'Saved {out_path} and {round_path}')

    # 4. Android adaptive icon foregrounds
    adaptive_sizes = {
        'mipmap-mdpi': 108,
        'mipmap-hdpi': 162,
        'mipmap-xhdpi': 216,
        'mipmap-xxhdpi': 324,
        'mipmap-xxxhdpi': 432,
    }

    # The text width is 327 / 512 = 63.8% of the icon.
    # In adaptive 108dp canvas, safe zone diameter is 72dp (66.7%).
    # Placing it scaled to ~75% fits perfectly centered inside the safe circle/squircle.
    scale_factor = 0.75
    for folder, size in adaptive_sizes.items():
        folder_path = os.path.join(android_res, folder)
        os.makedirs(folder_path, exist_ok=True)
        # Foreground canvas with neon lime background
        fg_canvas = Image.new('RGBA', (size, size), (198, 255, 0, 255))

        content_size = int(size * scale_factor)
        offset = (size - content_size) // 2

        scaled_content = img.resize((content_size, content_size), Image.Resampling.LANCZOS)
        fg_canvas.paste(scaled_content, (offset, offset))

        fg_path = os.path.join(folder_path, 'ic_launcher_foreground.png')
        fg_canvas.save(fg_path, 'PNG')
        print(f'Saved {fg_path} ({size}x{size})')

    # 5. Android adaptive icon xml files
    anydpi_dir = os.path.join(android_res, 'mipmap-anydpi-v26')
    os.makedirs(anydpi_dir, exist_ok=True)

    ic_launcher_xml = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
'''
    with open(os.path.join(anydpi_dir, 'ic_launcher.xml'), 'w', encoding='utf-8') as f:
        f.write(ic_launcher_xml)

    with open(os.path.join(anydpi_dir, 'ic_launcher_round.xml'), 'w', encoding='utf-8') as f:
        f.write(ic_launcher_xml)
    print('Saved mipmap-anydpi-v26/ic_launcher.xml & ic_launcher_round.xml')

    # 6. Android background color: #C6FF00 (Neon Lime)
    values_dir = os.path.join(android_res, 'values')
    os.makedirs(values_dir, exist_ok=True)
    colors_xml_path = os.path.join(values_dir, 'colors.xml')

    colors_xml = '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#C6FF00</color>
</resources>
'''
    with open(colors_xml_path, 'w', encoding='utf-8') as f:
        f.write(colors_xml)
    print('Updated colors.xml with ic_launcher_background: #C6FF00')

if __name__ == '__main__':
    main()

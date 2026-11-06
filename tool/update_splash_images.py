import os
from PIL import Image

def main():
    # 1. Load pristine assets/images/splash_logo.png
    splash_logo_path = 'assets/images/splash_logo.png'
    orig_splash = Image.open(splash_logo_path).convert('RGBA')
    w, h = orig_splash.size

    # 20% upscale for splash_logo.png (756x261 -> 907x313)
    new_w = int(w * 1.20)
    new_h = int(h * 1.20)
    upscaled_splash = orig_splash.resize((new_w, new_h), Image.Resampling.LANCZOS)
    upscaled_splash.save(splash_logo_path, 'PNG')
    print(f'Updated {splash_logo_path}: {w}x{h} -> {new_w}x{new_h}')

    # 2. Android 12 splash screen (1152x1152 canvas)
    # The circular splash window on Android 12 has diameter 768px (radius 384px).
    # Original content was 516x162. 20% upscale is 619x194.
    # At 619x194, max distance from center is 314.4px, leaving ~70px safe margin inside the 384px circle!
    android12_path = 'assets/images/splash_logo_android12.png'
    orig_a12 = Image.open(android12_path).convert('RGBA')
    bbox = orig_a12.getbbox()
    content = orig_a12.crop(bbox)

    target_cw = int(content.width * 1.20)  # 516 * 1.20 = 619
    target_ch = int(content.height * 1.20) # 162 * 1.20 = 194
    content_scaled = content.resize((target_cw, target_ch), Image.Resampling.LANCZOS)

    canvas12 = Image.new('RGBA', (1152, 1152), (0, 0, 0, 0))
    offset_x = (1152 - target_cw) // 2
    offset_y = (1152 - target_ch) // 2
    canvas12.paste(content_scaled, (offset_x, offset_y), mask=content_scaled)
    canvas12.save(android12_path, 'PNG')
    print(f'Updated {android12_path}: content {target_cw}x{target_ch} centered at ({offset_x}, {offset_y})')

    # 3. Android drawable-*/splash.png (scaled by 1.20)
    density_splash_sizes = {
        'drawable-mdpi': (int(189 * 1.20), int(65 * 1.20)),
        'drawable-hdpi': (int(283 * 1.20), int(97 * 1.20)),
        'drawable-xhdpi': (int(378 * 1.20), int(130 * 1.20)),
        'drawable-xxhdpi': (int(567 * 1.20), int(195 * 1.20)),
        'drawable-xxxhdpi': (int(756 * 1.20), int(261 * 1.20)),
    }

    android_res = 'android/app/src/main/res'
    for folder, (sw, sh) in density_splash_sizes.items():
        folder_path = os.path.join(android_res, folder)
        os.makedirs(folder_path, exist_ok=True)
        out_path = os.path.join(folder_path, 'splash.png')
        resized = orig_splash.resize((sw, sh), Image.Resampling.LANCZOS)
        resized.save(out_path, 'PNG')
        print(f'Saved {out_path} ({sw}x{sh})')

    # 4. Android drawable-*/android12splash.png and drawable-night-*/android12splash.png
    android12_density_sizes = {
        'drawable-mdpi': 288,
        'drawable-hdpi': 432,
        'drawable-xhdpi': 576,
        'drawable-xxhdpi': 864,
        'drawable-xxxhdpi': 1152,
        'drawable-night-mdpi': 288,
        'drawable-night-hdpi': 432,
        'drawable-night-xhdpi': 576,
        'drawable-night-xxhdpi': 864,
        'drawable-night-xxxhdpi': 1152,
    }

    for folder, size in android12_density_sizes.items():
        folder_path = os.path.join(android_res, folder)
        os.makedirs(folder_path, exist_ok=True)
        out_path = os.path.join(folder_path, 'android12splash.png')
        resized = canvas12.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(out_path, 'PNG')
        print(f'Saved {out_path} ({size}x{size})')

    # 5. iOS LaunchImage sizes
    ios_launch_dir = 'ios/Runner/Assets.xcassets/LaunchImage.imageset'
    os.makedirs(ios_launch_dir, exist_ok=True)
    ios_launch_sizes = {
        'LaunchImage.png': (int(189 * 1.20), int(65 * 1.20)),
        'LaunchImage@2x.png': (int(378 * 1.20), int(130 * 1.20)),
        'LaunchImage@3x.png': (int(567 * 1.20), int(195 * 1.20)),
    }
    for filename, (sw, sh) in ios_launch_sizes.items():
        out_path = os.path.join(ios_launch_dir, filename)
        resized = orig_splash.resize((sw, sh), Image.Resampling.LANCZOS)
        resized.save(out_path, 'PNG')
        print(f'Saved {out_path} ({sw}x{sh})')

if __name__ == '__main__':
    main()

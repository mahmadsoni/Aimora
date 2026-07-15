"""
Generates the AIMORA brand logo (master PNG) and all Android mipmap
launcher icon densities. Run once with `python3 tools_gen_logo.py`.
Requires Pillow (already available in the build environment).
"""
from PIL import Image, ImageDraw
import math
import os

ROOT = os.path.dirname(os.path.abspath(__file__))

# ---- Brand palette -----------------------------------------------------
BG_TOP = (11, 15, 26)        # #0B0F1A deep space navy
BG_BOTTOM = (20, 27, 51)     # #141B33
CYAN = (0, 229, 255)         # #00E5FF electric cyan (primary)
VIOLET = (124, 77, 255)      # #7C4DFF deep violet (secondary)
WHITE = (245, 248, 255)

SIZE = 1024


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def make_master_logo():
    img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Diagonal gradient rounded-square background
    for y in range(SIZE):
        t = y / SIZE
        color = lerp(BG_TOP, BG_BOTTOM, t)
        draw.line([(0, y), (SIZE, y)], fill=color + (255,))

    # Round the corners (superellipse-style mask)
    mask = Image.new('L', (SIZE, SIZE), 0)
    mdraw = ImageDraw.Draw(mask)
    radius = int(SIZE * 0.22)
    mdraw.rounded_rectangle([0, 0, SIZE, SIZE], radius=radius, fill=255)
    bg = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    bg.paste(img, (0, 0), mask)
    img = bg
    draw = ImageDraw.Draw(img)

    cx, cy = SIZE // 2, SIZE // 2

    # Outer glow ring (violet)
    ring_r = int(SIZE * 0.34)
    for w, alpha in [(26, 40), (18, 70), (10, 140)]:
        draw.ellipse(
            [cx - ring_r, cy - ring_r, cx + ring_r, cy + ring_r],
            outline=VIOLET + (alpha,), width=w
        )

    # Main crosshair ring (cyan)
    main_r = int(SIZE * 0.26)
    draw.ellipse(
        [cx - main_r, cy - main_r, cx + main_r, cy + main_r],
        outline=CYAN + (255,), width=int(SIZE * 0.028)
    )

    # Center dot
    dot_r = int(SIZE * 0.035)
    draw.ellipse([cx - dot_r, cy - dot_r, cx + dot_r, cy + dot_r], fill=WHITE + (255,))

    # Four crosshair ticks (gap between ring and tick, like a real reticle)
    gap = int(SIZE * 0.06)
    tick_len = int(SIZE * 0.14)
    tick_w = int(SIZE * 0.028)
    positions = [
        (0, -1),  # top
        (0, 1),   # bottom
        (-1, 0),  # left
        (1, 0),   # right
    ]
    for dx, dy in positions:
        x0 = cx + dx * (main_r + gap)
        y0 = cy + dy * (main_r + gap)
        x1 = cx + dx * (main_r + gap + tick_len)
        y1 = cy + dy * (main_r + gap + tick_len)
        if dx == 0:
            draw.line([(x0 - tick_w // 2, y0), (x1 - tick_w // 2, y1)], fill=CYAN + (255,), width=tick_w)
        else:
            draw.line([(x0, y0 - tick_w // 2), (x1, y1 - tick_w // 2)], fill=CYAN + (255,), width=tick_w)

    img.save(os.path.join(ROOT, 'assets', 'icons', 'logo.png'))
    return img


def make_launcher_icons(master: Image.Image):
    densities = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }
    res_dir = os.path.join(ROOT, 'android', 'app', 'src', 'main', 'res')
    # flatten onto opaque background for legacy launcher icon (no alpha halo)
    flat = Image.new('RGB', master.size, BG_TOP)
    flat.paste(master, (0, 0), master)
    for folder, px in densities.items():
        d = os.path.join(res_dir, folder)
        os.makedirs(d, exist_ok=True)
        resized = flat.resize((px, px), Image.LANCZOS)
        resized.save(os.path.join(d, 'ic_launcher.png'))

    # Play Store icon (512x512, high quality)
    store = flat.resize((512, 512), Image.LANCZOS)
    store.save(os.path.join(ROOT, 'assets', 'icons', 'play_store_icon.png'))


def make_splash_asset(master: Image.Image):
    # Simple 512 transparent version for splash screen widget usage
    small = master.resize((512, 512), Image.LANCZOS)
    small.save(os.path.join(ROOT, 'assets', 'icons', 'logo_transparent.png'))


if __name__ == '__main__':
    m = make_master_logo()
    make_launcher_icons(m)
    make_splash_asset(m)
    print('Logo and launcher icons generated.')

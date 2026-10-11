#!/usr/bin/env python3
"""Generate the Asan Bill Viewer launcher icon.

Brand green tile with a white receipt-and-tick mark.
Outputs (committed under tools/android/res/, installed by patch_android.sh):
  - mipmap-{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}/ic_launcher.png        (legacy)
  - mipmap-*/ic_launcher_foreground.png                            (adaptive)
  - mipmap-anydpi-v26/ic_launcher.xml + ic_launcher_round.xml     (adaptive)
  - values/ic_launcher_background.xml
Run: python3 tools/make_icon.py
"""
import math
import os

from PIL import Image, ImageDraw

GREEN = (14, 122, 79, 255)
WHITE = (255, 255, 255, 255)

HERE = os.path.dirname(os.path.abspath(__file__))
RES = os.path.join(HERE, "android", "res")

DENSITIES = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}
# Adaptive foreground is drawn on a 108dp canvas.
FG_DP = {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432}


def draw_receipt(draw: ImageDraw.ImageDraw, s: float, cx: float, cy: float,
                 scale: float = 1.0):
    """White receipt with zigzag bottom, bill lines and a green tick."""
    w = 0.42 * s * scale
    top = cy - 0.235 * s * scale
    bottom = cy + 0.235 * s * scale
    teeth_top = bottom - 0.045 * s * scale
    x0, x1 = cx - w / 2, cx + w / 2
    r = 0.035 * s * scale

    # Body: rounded top, zigzag bottom.
    pts = [(x0 + r, top)]
    pts.append((x1 - r, top))
    # top-right corner arc
    for a in range(-90, 1, 15):
        pts.append((x1 - r + r * math.cos(math.radians(a)),
                    top + r + r * math.sin(math.radians(a))))
    pts.append((x1, teeth_top))
    # zigzag teeth
    teeth = 7
    tw = (x1 - x0) / teeth
    for i in range(teeth):
        pts.append((x0 + tw * (i + 0.5), bottom))
        pts.append((x0 + tw * (i + 1), teeth_top))
    pts.append((x0, teeth_top))
    # top-left corner arc
    for a in range(90, 181, 15):
        pts.append((x0 + r + r * math.cos(math.radians(a)),
                    top + r + r * math.sin(math.radians(a))))
    draw.polygon(pts, fill=WHITE)

    # Bill lines (brand green).
    lw = 0.055 * s * scale
    for j, frac in enumerate((0.30, 0.44)):
        y = top + frac * (bottom - top)
        ww = (0.30 if j == 0 else 0.20) * s * scale
        draw.rounded_rectangle([cx - ww / 2, y - lw / 2,
                                cx + ww / 2, y + lw / 2],
                               radius=lw / 2, fill=GREEN)

    # Green tick badge.
    cr = 0.068 * s * scale
    ccy = top + 0.66 * (bottom - top)
    draw.ellipse([cx - cr, ccy - cr, cx + cr, ccy + cr], fill=GREEN)
    sw = 0.030 * s * scale
    draw.line([(cx - 0.032 * s * scale, ccy),
               (cx - 0.008 * s * scale, ccy + 0.026 * s * scale),
               (cx + 0.038 * s * scale, ccy - 0.030 * s * scale)],
              fill=WHITE, width=int(sw), joint="curve")


def legacy_icon(px: int) -> Image.Image:
    s = 1024
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([0, 0, s, s], radius=int(0.225 * s), fill=GREEN)
    draw_receipt(d, s, s / 2, s / 2)
    return img.resize((px, px), Image.LANCZOS)


def foreground(px: int) -> Image.Image:
    s = 1024
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Adaptive safe zone: keep artwork inside the central ~66%.
    draw_receipt(d, s, s / 2, s / 2, scale=0.62)
    return img.resize((px, px), Image.LANCZOS)


def main() -> None:
    for name, px in DENSITIES.items():
        d = os.path.join(RES, f"mipmap-{name}")
        os.makedirs(d, exist_ok=True)
        legacy_icon(px).save(os.path.join(d, "ic_launcher.png"))
        foreground(FG_DP[name]).save(
            os.path.join(d, "ic_launcher_foreground.png"))

    anydpi = os.path.join(RES, "mipmap-anydpi-v26")
    os.makedirs(anydpi, exist_ok=True)
    adaptive = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
    <monochrome android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
"""
    for fname in ("ic_launcher.xml", "ic_launcher_round.xml"):
        with open(os.path.join(anydpi, fname), "w") as f:
            f.write(adaptive)

    values = os.path.join(RES, "values")
    os.makedirs(values, exist_ok=True)
    with open(os.path.join(values, "ic_launcher_background.xml"), "w") as f:
        f.write("""<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#0E7A4F</color>
</resources>
""")
    print("icon resources written to", RES)


if __name__ == "__main__":
    main()

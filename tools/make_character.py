"""Ubah gambar karakter pixel art badan penuh jadi sprite siap pakai di game.

Yang dikerjakan:
1. Membuang latar belakang polos dan bayangan abu-abu di bawah kaki.
2. Mencari ukuran kotak pixel asli gambar.
3. Mengecilkan gambar tepat mengikuti grid pixel itu (1 kotak = 1 pixel),
   sehingga hasilnya tajam dan berlatar transparan.

Pakai:
    pip3 install pillow numpy scipy
    python3 tools/make_character.py gambar_programmer.jpg assets/photos/member1.png

Kalau gambarmu foto asli (bukan pixel art), pakai tools/pixelate.py dulu.
"""
import sys

import numpy as np
from PIL import Image
from scipy import ndimage


def foreground_mask(a: np.ndarray) -> np.ndarray:
    edges = np.concatenate([a[:20].reshape(-1, 3), a[-20:].reshape(-1, 3),
                            a[:, :20].reshape(-1, 3), a[:, -20:].reshape(-1, 3)])
    bg = np.median(edges, 0)
    dist = np.sqrt(((a - bg) ** 2).sum(2))
    sat = a.max(2) - a.min(2)
    bglike = (dist < 28) | ((sat < 18) & (a.mean(2) > 170))  # latar + bayangan
    lab, _ = ndimage.label(bglike)
    border = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
    fg = ~np.isin(lab, list(border))
    fg = ndimage.binary_opening(fg, iterations=2)
    lab2, n2 = ndimage.label(fg)
    sizes = ndimage.sum(fg, lab2, range(1, n2 + 1))
    fg = lab2 == (np.argmax(sizes) + 1)
    return ndimage.binary_fill_holes(fg)


def block_size(a: np.ndarray, fg: np.ndarray) -> float:
    """Ukuran kotak pixel: periode berulang dari garis-garis tepi warna."""
    h = a.shape[0]
    best = []
    for axis in (0, 1):
        d = np.abs(np.diff(a, axis=axis)).sum(2) > 60
        prof = d.sum(1 - axis).astype(float)
        prof -= prof.mean()
        ac = np.correlate(prof, prof, "full")[len(prof) - 1:]
        lo, hi = int(h / 60), int(h / 22)
        lags = np.arange(lo, hi)
        vals = ac[lo:hi]
        peaks = [k for k in range(1, len(vals) - 1) if vals[k] >= vals[k - 1] and vals[k] >= vals[k + 1]]
        if not peaks:
            continue
        top = max(vals[k] for k in peaks)
        k = min(k for k in peaks if vals[k] >= 0.6 * top)
        # haluskan ke pecahan dengan parabola di sekitar puncak
        y0, y1, y2 = vals[k - 1], vals[k], vals[k + 1]
        off = 0.5 * (y0 - y2) / (y0 - 2 * y1 + y2) if (y0 - 2 * y1 + y2) != 0 else 0.0
        best.append(lags[k] + off)
    return float(np.mean(best)) if best else h / 40.0


def make_character(src: str, dst: str) -> None:
    a = np.asarray(Image.open(src).convert("RGB")).astype(float)
    fg = foreground_mask(a)
    ys, xs = np.where(fg)
    y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    sub = a[y0:y1, x0:x1]
    b = block_size(sub, fg[y0:y1, x0:x1])
    nh, nw = round((y1 - y0) / b), round((x1 - x0) / b)
    out = np.zeros((nh, nw, 4), np.uint8)
    for j in range(nh):
        for i in range(nw):
            yy0, yy1 = int(y0 + j * b + b * 0.25), int(y0 + j * b + b * 0.75)
            xx0, xx1 = int(x0 + i * b + b * 0.25), int(x0 + i * b + b * 0.75)
            m = fg[yy0:yy1, xx0:xx1]
            if m.size and m.mean() > 0.5:
                out[j, i, :3] = np.median(a[yy0:yy1, xx0:xx1][m], 0)
                out[j, i, 3] = 255
    Image.fromarray(out, "RGBA").save(dst)
    print(f"OK -> {dst}  ({nw}x{nh} pixel, kotak asli {b:.2f}px)")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    make_character(sys.argv[1], sys.argv[2])

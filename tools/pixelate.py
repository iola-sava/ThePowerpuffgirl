"""Pixelate foto wajah anggota sebelum dimasukkan ke game.

Pakai:
    pip install pillow
    python tools/pixelate.py foto_asli.jpg assets/photos/member1.png

Hasilnya PNG 64x64 dengan wajah ter-pixelate (16x16 blok), jadi foto asli
tidak perlu ikut di-commit ke GitHub.
"""
import sys
from PIL import Image, ImageOps


def pixelate(src: str, dst: str, blocks: int = 16, out_size: int = 64) -> None:
    img = Image.open(src).convert("RGB")
    img = ImageOps.exif_transpose(img)
    s = min(img.size)
    left, top = (img.width - s) // 2, (img.height - s) // 2
    img = img.crop((left, top, left + s, top + s))
    small = img.resize((blocks, blocks), Image.LANCZOS)
    small = ImageOps.posterize(small, 3)
    small.resize((out_size, out_size), Image.NEAREST).save(dst)
    print(f"OK -> {dst}")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    pixelate(sys.argv[1], sys.argv[2])

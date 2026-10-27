class_name PhotoUtil
extends RefCounted
## Memuat gambar karakter anggota (pixel art badan penuh, latar transparan)
## dan membuat potongan wajahnya untuk papan anggota & HUD.
## Gambar karakter dibuat dengan tools/make_character.py.


## Gambar badan penuh apa adanya.
static func load_photo(path: String, fallback: Color) -> Texture2D:
	if path != "":
		if ResourceLoader.exists(path):
			var tex := load(path) as Texture2D
			if tex:
				return tex
		elif FileAccess.file_exists(path):
			var img := Image.load_from_file(path)
			if img:
				return ImageTexture.create_from_image(img)
	return _placeholder(fallback)


## Potongan persegi bagian kepala (bagian atas gambar badan penuh).
static func face(tex: Texture2D) -> Texture2D:
	if tex == null:
		return null
	var img := tex.get_image()
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	var s := mini(img.get_width(), img.get_height())
	var out := Image.create(s, s, false, Image.FORMAT_RGBA8)
	out.fill(Color("#fff8f0"))
	out.blend_rect(img, Rect2i((img.get_width() - s) / 2, 0, s, s), Vector2i.ZERO)
	return ImageTexture.create_from_image(out)


## Gambar persegi dijadikan lingkaran (untuk papan anggota & HUD).
## `diameter` dalam pixel tekstur (sprite dipakai dengan scale 0.5).
static func circle(tex: Texture2D, diameter: int) -> Texture2D:
	if tex == null:
		return null
	var img := tex.get_image()
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	img.resize(diameter, diameter, Image.INTERPOLATE_NEAREST)
	var c := Vector2(diameter, diameter) / 2.0
	var r := diameter / 2.0
	for y in diameter:
		for x in diameter:
			var d := Vector2(x + 0.5, y + 0.5).distance_to(c)
			var col := img.get_pixel(x, y)
			col.a *= clampf(r - d, 0.0, 1.0)
			img.set_pixel(x, y, col)
	return ImageTexture.create_from_image(img)


static func _placeholder(col: Color) -> Texture2D:
	var img := Image.create(12, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	img.fill_rect(Rect2i(3, 1, 6, 6), Color("#ffd9c2"))
	img.fill_rect(Rect2i(2, 8, 8, 12), col)
	img.fill_rect(Rect2i(3, 20, 6, 12), col.darkened(0.4))
	return ImageTexture.create_from_image(img)

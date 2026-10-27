class_name PhotoUtil
extends RefCounted
## Memuat foto anggota lalu mem-pixelate-nya (crop persegi -> resize kecil -> posterize).


static func load_pixelated(path: String, pixels: int, fallback: Color) -> Texture2D:
	var img: Image = null
	if path != "":
		if ResourceLoader.exists(path):
			var tex := load(path) as Texture2D
			if tex:
				img = tex.get_image()
		elif FileAccess.file_exists(path):
			img = Image.load_from_file(path)

	if img == null or img.is_empty():
		return _placeholder(pixels, fallback)

	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)

	# crop tengah jadi persegi
	var s := mini(img.get_width(), img.get_height())
	img = img.get_region(Rect2i((img.get_width() - s) / 2, (img.get_height() - s) / 2, s, s))

	# kecilkan -> efek pixel
	img.resize(pixels, pixels, Image.INTERPOLATE_LANCZOS)

	# posterize biar warnanya retro
	for y in pixels:
		for x in pixels:
			var c := img.get_pixel(x, y)
			c.r = snappedf(c.r, 1.0 / 7.0)
			c.g = snappedf(c.g, 1.0 / 7.0)
			c.b = snappedf(c.b, 1.0 / 7.0)
			img.set_pixel(x, y, c)

	return ImageTexture.create_from_image(img)


static func _placeholder(pixels: int, col: Color) -> Texture2D:
	var img := Image.create(pixels, pixels, false, Image.FORMAT_RGBA8)
	img.fill(col.darkened(0.5))
	var c := Vector2(pixels / 2.0, pixels / 2.0)
	for y in pixels:
		for x in pixels:
			var p := Vector2(x + 0.5, y + 0.5)
			if p.distance_to(c + Vector2(0, -pixels * 0.12)) < pixels * 0.2:
				img.set_pixel(x, y, col)
			elif p.y > pixels * 0.62 and absf(p.x - c.x) < pixels * 0.32:
				img.set_pixel(x, y, col)
	return ImageTexture.create_from_image(img)

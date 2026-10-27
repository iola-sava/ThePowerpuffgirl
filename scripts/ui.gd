@tool
class_name UI
extends RefCounted
## Palet warna, font, dan fungsi gambar bersama (gaya pastel lucu).

const BODY := preload("res://assets/fonts/Poppins-Medium.ttf")
const BOLD := preload("res://assets/fonts/Poppins-Bold.ttf")

const INK := Color("#5b4a6e")
const MUTED := Color("#9a8aae")
const CREAM := Color("#fff8f0")
const PINK := Color("#ff8fc1")
const MINT := Color("#7fdca0")
const SUN := Color("#ffd84d")


static func box(bg: Color, radius: int, border := Color.TRANSPARENT, bw := 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	s.anti_aliasing = true
	if bw > 0:
		s.border_color = border
		s.set_border_width_all(bw)
	return s


## Foto berbentuk lingkaran dengan cincin warna.
static func circle_photo(ci: CanvasItem, tex: Texture2D, c: Vector2, r: float, ring: Color, ring_w := 2.0) -> void:
	ci.draw_circle(c, r + ring_w + 1.0, Color.WHITE)
	ci.draw_circle(c, r + ring_w, ring)
	var pts := PackedVector2Array()
	var uvs := PackedVector2Array()
	for i in 32:
		var a := TAU * i / 32.0
		var d := Vector2(cos(a), sin(a))
		pts.append(c + d * r)
		uvs.append(Vector2(0.5, 0.5) + d * 0.5)
	if tex:
		ci.draw_colored_polygon(pts, Color.WHITE, uvs, tex)
	else:
		ci.draw_colored_polygon(pts, Color("#ffd9c2"))


static func star_points(c: Vector2, r_out: float, r_in: float, rot := -PI / 2.0) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 10:
		var r := r_out if i % 2 == 0 else r_in
		var a := rot + PI * i / 5.0
		pts.append(c + Vector2(cos(a), sin(a)) * r)
	return pts


static func heart(ci: CanvasItem, c: Vector2, s: float, col: Color) -> void:
	ci.draw_circle(c + Vector2(-s * 0.5, -s * 0.2), s * 0.55, col)
	ci.draw_circle(c + Vector2(s * 0.5, -s * 0.2), s * 0.55, col)
	ci.draw_colored_polygon(PackedVector2Array([
		c + Vector2(-s * 1.02, 0), c + Vector2(s * 1.02, 0), c + Vector2(0, s * 1.1)
	]), col)


static func sparkle(ci: CanvasItem, c: Vector2, s: float, col: Color) -> void:
	ci.draw_colored_polygon(PackedVector2Array([
		c + Vector2(0, -s), c + Vector2(s * 0.25, -s * 0.25), c + Vector2(s, 0),
		c + Vector2(s * 0.25, s * 0.25), c + Vector2(0, s), c + Vector2(-s * 0.25, s * 0.25),
		c + Vector2(-s, 0), c + Vector2(-s * 0.25, -s * 0.25)
	]), col)

extends Node2D
## Latar pastel: langit gradasi, pelangi, awan imut, kilau, bukit (parallax).

const RAINBOW := ["#ffb3c7", "#ffd3a8", "#fff1a8", "#c7f5c9", "#bfe3ff", "#d9c7ff"]

var _cam_x := 0.0
var _t := 0.0


func _process(delta: float) -> void:
	_t += delta
	var cam := get_viewport().get_camera_2d()
	if cam:
		_cam_x = cam.get_screen_center_position().x
	queue_redraw()


func _draw() -> void:
	var size := get_viewport_rect().size
	var top := Color("#b9e3ff")
	var bottom := Color("#ffe1f0")
	var bands := 24
	for i in bands:
		draw_rect(Rect2(0, size.y * i / bands, size.x, size.y / bands + 1),
			top.lerp(bottom, float(i) / (bands - 1)))

	# pelangi
	var rc := Vector2(fposmod(470.0 - _cam_x * 0.04, size.x + 400.0) - 200.0, 300.0)
	for i in RAINBOW.size():
		draw_arc(rc, 150.0 - i * 6.0, PI, TAU, 64, Color(RAINBOW[i], 0.6), 6.0, true)

	# kilau
	for i in 14:
		var x := fposmod(i * 97.0 - _cam_x * 0.15, size.x)
		var y := 20.0 + fmod(i * 53.0, 170.0)
		var a := 0.3 + 0.5 * absf(sin(_t * 2.0 + i))
		UI.sparkle(self, Vector2(x, y), 2.5 + (i % 3), Color(1, 1, 1, a))

	# awan
	for i in 5:
		var x := fposmod(i * 190.0 - _cam_x * 0.1, size.x + 140.0) - 70.0
		var y := 50.0 + (i % 3) * 30.0 + sin(_t + i) * 2.0
		_cloud(Vector2(x, y), i % 2 == 0)

	_hills(size, 0.2, 262.0, 26.0, 0.012, Color("#c8f2dc"))
	_hills(size, 0.45, 292.0, 18.0, 0.02, Color("#a5e8c0"))


func _cloud(c: Vector2, face: bool) -> void:
	for d in [Vector2(-14, 4), Vector2(0, -2), Vector2(14, 4)]:
		draw_circle(c + d + Vector2(0, 3), 12.0, Color("#ffd6ea"))
	for d in [Vector2(-14, 4), Vector2(0, -2), Vector2(14, 4)]:
		draw_circle(c + d, 12.0, Color.WHITE)
	draw_rect(Rect2(c + Vector2(-14, 4), Vector2(28, 12)), Color.WHITE)
	if face:
		draw_circle(c + Vector2(-5, 3), 1.4, UI.INK)
		draw_circle(c + Vector2(5, 3), 1.4, UI.INK)
		draw_circle(c + Vector2(-9, 7), 2.2, Color(1, 0.6, 0.75, 0.6))
		draw_circle(c + Vector2(9, 7), 2.2, Color(1, 0.6, 0.75, 0.6))
		draw_arc(c + Vector2(0, 5), 2.0, 0.2, PI - 0.2, 8, UI.INK, 1.0)


func _hills(size: Vector2, factor: float, base: float, amp: float, freq: float, col: Color) -> void:
	var pts := PackedVector2Array([Vector2(0, size.y)])
	var sx := 0.0
	while sx <= size.x + 8.0:
		var wx := sx + _cam_x * factor
		pts.append(Vector2(sx, base - (sin(wx * freq) * 0.6 + sin(wx * freq * 2.3) * 0.4) * amp))
		sx += 8.0
	pts.append(Vector2(size.x, size.y))
	draw_colored_polygon(pts, col)

extends Node2D
## Latar langit + bukit + awan dengan efek parallax mengikuti kamera.

var _cam_x := 0.0


func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam:
		_cam_x = cam.get_screen_center_position().x
	queue_redraw()


func _draw() -> void:
	var size := get_viewport_rect().size
	# langit gradasi
	var top := Color("#5ec8f2")
	var bottom := Color("#c9f0ff")
	var bands := 12
	for i in bands:
		var t := float(i) / (bands - 1)
		draw_rect(Rect2(0, size.y * i / bands, size.x, size.y / bands + 1), top.lerp(bottom, t))
	# awan
	for i in 6:
		var x := fposmod(i * 170.0 - _cam_x * 0.1, size.x + 120.0) - 60.0
		var y := 40.0 + (i % 3) * 28.0
		for c in [Vector2(0, 0), Vector2(14, -6), Vector2(28, 0), Vector2(14, 4)]:
			draw_circle(Vector2(x, y) + c, 12.0, Color(1, 1, 1, 0.9))
	_hills(size, 0.2, 250.0, 30.0, 0.012, Color("#8ecf9a"))
	_hills(size, 0.45, 285.0, 22.0, 0.02, Color("#6bb87a"))


func _hills(size: Vector2, factor: float, base: float, amp: float, freq: float, col: Color) -> void:
	var pts := PackedVector2Array([Vector2(0, size.y)])
	var sx := 0.0
	while sx <= size.x + 8.0:
		var wx := sx + _cam_x * factor
		pts.append(Vector2(sx, base - (sin(wx * freq) * 0.6 + sin(wx * freq * 2.3) * 0.4) * amp))
		sx += 8.0
	pts.append(Vector2(size.x, size.y))
	draw_colored_polygon(pts, col)

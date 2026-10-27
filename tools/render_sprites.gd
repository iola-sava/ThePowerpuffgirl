extends SceneTree
## Generator gambar sprite (PNG) untuk semua objek game.
## Semua gambar dibuat 2x lebih besar, lalu di scene dipakai dengan scale 0.5.
##
## Jalankan dari folder project (butuh Godot 4.3+):
##   godot --path . -s tools/render_sprites.gd
## Hasil: assets/sprites/*.png

const OUT := "res://assets/sprites/"
const INK := Color("#5b4a6e")
const SKIN := Color("#ffd9c2")


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))

	# --- player: kaki + tangan (tidak diwarnai) ---
	await _render("player_idle", Vector2(20, 18), Vector2(10, 16), _limbs.bind(0.0, true, false))
	for i in 4:
		await _render("player_walk_%d" % i, Vector2(20, 18), Vector2(10, 16), _limbs.bind(i * PI / 2.0, true, false))
	await _render("player_jump", Vector2(20, 18), Vector2(10, 16), _limbs.bind(0.0, false, true))
	# --- player: baju (putih, diwarnai lewat modulate) ---
	await _render("player_shirt", Vector2(14, 12), Vector2(7, 12), _shirt)
	await _render("shadow", Vector2(16, 6), Vector2(8, 3), _shadow)
	# --- cincin foto & placeholder wajah ---
	await _render("ring_white", Vector2(26, 26), Vector2(13, 13), _circle.bind(11.6, Color.WHITE))
	await _render("ring_color", Vector2(24, 24), Vector2(12, 12), _circle.bind(10.6, Color.WHITE))
	await _render("face_placeholder", Vector2(20, 20), Vector2(10, 10), _face)
	# --- musuh ---
	for i in 4:
		await _render("enemy_%d" % i, Vector2(18, 18), Vector2(9, 15), _enemy.bind(1.0 + sin(i * PI / 2.0) * 0.08))
	await _render("enemy_dead", Vector2(18, 18), Vector2(9, 15), _enemy_dead)
	# --- bintang, hati, centang ---
	await _render("star", Vector2(18, 18), Vector2(9, 9), _star)
	await _render("heart", Vector2(12, 12), Vector2(6, 6), _heart)
	await _render("check", Vector2(12, 12), Vector2(6, 6), _check)
	# --- papan anggota ---
	await _render("sign_pole", Vector2(4, 36), Vector2(2, 36), _pole)
	await _render("sign_board_back", Vector2(30, 30), Vector2(15, 15), _rounded.bind(Vector2(28, 28), 8))
	await _render("sign_board_front", Vector2(26, 26), Vector2(13, 13), _rounded.bind(Vector2(24, 24), 6))
	# --- bendera finish ---
	for i in 4:
		await _render("flag_%d" % i, Vector2(40, 98), Vector2(6, 92), _flag.bind(i * PI / 12.0))
	print("Selesai: sprite tersimpan di ", OUT)
	quit()


func _render(name: String, size: Vector2, origin: Vector2, fn: Callable) -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(size * 2.0)
	vp.transparent_bg = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var painter := Node2D.new()
	painter.scale = Vector2(2, 2)
	painter.position = origin * 2.0
	painter.draw.connect(func() -> void: fn.call(painter))
	vp.add_child(painter)
	root.add_child(vp)
	for i in 3:
		await process_frame
	var img := vp.get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path(OUT + name + ".png"))
	vp.queue_free()


# ------------------------------------------------------------------ gambar
func _limbs(ci: Node2D, walk: float, on_floor: bool, rising: bool) -> void:
	var s := sin(walk) * 2.5
	var fy := -2.0 if on_floor else -4.0
	for lx in [-2.5 + s * 0.5, 2.5 - s * 0.5]:
		ci.draw_set_transform(Vector2(lx, fy), 0.0, Vector2(1.0, 0.7))
		ci.draw_circle(Vector2.ZERO, 2.4, INK)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var arm_y := -12.0 if rising else -7.0 - sin(walk) * 1.0
	ci.draw_circle(Vector2(-6.5, arm_y), 1.9, SKIN)
	ci.draw_circle(Vector2(6.5, arm_y), 1.9, SKIN)


func _shirt(ci: Node2D) -> void:
	var body := Rect2(-5.5, -11, 11, 9)
	ci.draw_style_box(UI.box(Color(0.75, 0.75, 0.75), 4), Rect2(body.position + Vector2(0, 1), body.size))
	ci.draw_style_box(UI.box(Color(0.88, 0.88, 0.88), 4), body)
	ci.draw_circle(Vector2(0, -6), 2.2, Color.WHITE)


func _shadow(ci: Node2D) -> void:
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.35))
	ci.draw_circle(Vector2.ZERO, 7.0, Color(0.35, 0.25, 0.45, 0.25))


func _circle(ci: Node2D, r: float, col: Color) -> void:
	ci.draw_circle(Vector2.ZERO, r, col)


func _face(ci: Node2D) -> void:
	ci.draw_circle(Vector2.ZERO, 9.0, SKIN)
	ci.draw_circle(Vector2(-3, -1), 1.1, INK)
	ci.draw_circle(Vector2(3, -1), 1.1, INK)
	ci.draw_circle(Vector2(-5, 2), 1.6, Color(1, 0.6, 0.75, 0.6))
	ci.draw_circle(Vector2(5, 2), 1.6, Color(1, 0.6, 0.75, 0.6))
	ci.draw_arc(Vector2(0, 1.5), 1.6, 0.3, PI - 0.3, 8, INK, 0.8)


func _enemy(ci: Node2D, sq: float) -> void:
	var body := Color("#c3a6ff")
	ci.draw_set_transform(Vector2(0, -6), 0.0, Vector2(1.0 / sq, sq))
	ci.draw_circle(Vector2(0, 1), 7.0, body.darkened(0.15))
	ci.draw_circle(Vector2.ZERO, 7.0, body)
	ci.draw_circle(Vector2(-2.5, -3), 2.2, Color(1, 1, 1, 0.6))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var d := -1.0
	ci.draw_circle(Vector2(-2.5 + d, -7), 1.3, INK)
	ci.draw_circle(Vector2(2.5 + d, -7), 1.3, INK)
	ci.draw_circle(Vector2(-4.5 + d, -4.5), 1.5, Color(1, 0.55, 0.75, 0.7))
	ci.draw_circle(Vector2(4.5 + d, -4.5), 1.5, Color(1, 0.55, 0.75, 0.7))
	ci.draw_arc(Vector2(d, -5.5), 1.4, 0.3, PI - 0.3, 8, INK, 0.8)


func _enemy_dead(ci: Node2D) -> void:
	ci.draw_set_transform(Vector2(0, -1.5), 0.0, Vector2(1.6, 0.35))
	ci.draw_circle(Vector2.ZERO, 6.0, Color("#c3a6ff"))


func _star(ci: Node2D) -> void:
	ci.draw_colored_polygon(UI.star_points(Vector2(0, 1), 7.0, 3.4), Color("#f2a93b"))
	ci.draw_colored_polygon(UI.star_points(Vector2.ZERO, 6.5, 3.0), UI.SUN)
	ci.draw_circle(Vector2(-1.5, -1.5), 1.2, Color(1, 1, 1, 0.8))


func _heart(ci: Node2D) -> void:
	UI.heart(ci, Vector2(0, 0), 3.6, Color(1, 1, 1, 0.95))
	UI.heart(ci, Vector2(0, -1), 3.0, UI.PINK)


func _check(ci: Node2D) -> void:
	ci.draw_circle(Vector2.ZERO, 5.0, Color.WHITE)
	ci.draw_circle(Vector2.ZERO, 4.0, UI.MINT)
	ci.draw_polyline(PackedVector2Array([Vector2(-2, 0), Vector2(-0.5, 1.5), Vector2(2, -1.5)]),
		Color.WHITE, 1.3, true)


func _pole(ci: Node2D) -> void:
	ci.draw_style_box(UI.box(Color("#d9a877"), 1), Rect2(-1.5, -34, 3, 34))


func _rounded(ci: Node2D, size: Vector2, radius: int) -> void:
	ci.draw_style_box(UI.box(Color.WHITE, radius), Rect2(-size / 2.0, size))


func _flag(ci: Node2D, t: float) -> void:
	ci.draw_style_box(UI.box(Color.WHITE, 2), Rect2(-1.5, -80, 3, 80))
	ci.draw_colored_polygon(UI.star_points(Vector2(0, -84), 6.0, 2.8), UI.SUN)
	var pts := PackedVector2Array()
	for i in 8:
		pts.append(Vector2(2.0 + i * 4.0, -78 + sin(t * 6.0 - i * 0.7) * 1.5))
	for i in range(7, -1, -1):
		pts.append(Vector2(2.0 + i * 4.0, -60 + sin(t * 6.0 - i * 0.7) * 1.5))
	ci.draw_colored_polygon(pts, UI.PINK)
	UI.heart(ci, Vector2(16, -70 + sin(t * 6.0 - 3.5) * 1.5), 3.2, Color.WHITE)
	ci.draw_style_box(UI.box(Color("#ff9fc9"), 3), Rect2(-7, -5, 15, 5))

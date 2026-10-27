extends Node2D
## Micro game "Team Intro": temui semua anggota tim untuk membuka gerbang keluar.
## Data anggota dibaca dari res://data/team.json

const ROOM := Rect2(32, 56, 576, 272)
const WALL := 8.0
const GATE_W := 48.0
const DATA_PATH := "res://data/team.json"
const PHOTO_PIXELS := 16

enum State { TITLE, PLAY, POPUP, END }

var state := State.TITLE
var team_name := "Tim Kami"
var members: Array = []
var stands: Array[MemberStand] = []
var player: Player
var popup: InfoPopup
var top_label: Label
var hint_label: Label
var gate: StaticBody2D
var gate_open := false
var _wall_rects: Array[Rect2] = []
var _gate_rect: Rect2
var _time := 0.0


func _ready() -> void:
	y_sort_enabled = true
	_load_data()
	_build_walls()
	_spawn_stands()

	player = Player.new()
	player.position = Vector2(ROOM.get_center().x, ROOM.end.y - 32)
	player.frozen = true
	add_child(player)

	_build_hud()
	popup = InfoPopup.new()
	add_child(popup)
	popup.show_message(team_name.to_upper(),
		"Micro game perkenalan tim.\nTemui setiap anggota di podiumnya untuk membuka gerbang keluar!",
		Color("#4361ee"), "Tekan E untuk mulai")
	_update_hud()


# ---------- data ----------
func _load_data() -> void:
	var f := FileAccess.open(DATA_PATH, FileAccess.READ)
	if f == null:
		push_error("Tidak bisa membuka " + DATA_PATH)
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		team_name = str(parsed.get("team_name", team_name))
		members = parsed.get("members", [])


# ---------- level ----------
func _build_walls() -> void:
	var top := ROOM.position.y - WALL
	var left := ROOM.position.x - WALL
	var full_w := ROOM.size.x + WALL * 2.0
	var half := ROOM.size.x / 2.0 - GATE_W / 2.0 + WALL
	_add_wall(Rect2(left, top, WALL, ROOM.size.y + WALL * 2.0))           # kiri
	_add_wall(Rect2(ROOM.end.x, top, WALL, ROOM.size.y + WALL * 2.0))     # kanan
	_add_wall(Rect2(left, ROOM.end.y, full_w, WALL))                      # bawah
	_add_wall(Rect2(left, top, half, WALL))                               # atas kiri
	_add_wall(Rect2(ROOM.get_center().x + GATE_W / 2.0, top, half, WALL)) # atas kanan
	_gate_rect = Rect2(ROOM.get_center().x - GATE_W / 2.0, top, GATE_W, WALL)
	gate = _make_body(_gate_rect)


func _add_wall(r: Rect2) -> void:
	_wall_rects.append(r)
	_make_body(r)


func _make_body(r: Rect2) -> StaticBody2D:
	var body := StaticBody2D.new()
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = r.size
	cs.shape = shape
	cs.position = r.get_center()
	body.add_child(cs)
	add_child(body)
	return body


func _spawn_stands() -> void:
	var n := members.size()
	for i in n:
		var m: Dictionary = members[i]
		var col := Color.html(str(m.get("color", "#e9c46a")))
		var tex := PhotoUtil.load_pixelated(str(m.get("photo", "")), PHOTO_PIXELS, col)
		var s := MemberStand.new()
		s.setup(m, i, col, tex)
		s.position = Vector2(ROOM.position.x + ROOM.size.x * (i + 1) / (n + 1), ROOM.position.y + 104)
		add_child(s)
		stands.append(s)


# ---------- HUD ----------
func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	top_label = _hud_label(Vector2(0, 14), 13, Color.WHITE)
	hint_label = _hud_label(Vector2(0, 338), 10, Color("#b8b3d6"))
	layer.add_child(top_label)
	layer.add_child(hint_label)


func _hud_label(pos: Vector2, font_size: int, col: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.size = Vector2(640, 20)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", col)
	return l


func _visited_count() -> int:
	var c := 0
	for s in stands:
		if s.visited:
			c += 1
	return c


func _update_hud() -> void:
	top_label.text = "%s   •   Anggota ditemui: %d/%d" % [team_name, _visited_count(), stands.size()]
	if gate_open:
		hint_label.text = "Gerbang terbuka!  Keluar lewat pintu atas  ↑"
	else:
		hint_label.text = "WASD / Panah: jalan    •    E: bicara dengan anggota"


# ---------- input & loop ----------
func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var k: int = event.physical_keycode
	var interact := k in [KEY_E, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]

	match state:
		State.TITLE:
			if interact:
				_resume()
		State.POPUP:
			if interact or k == KEY_ESCAPE:
				_resume()
				_check_all_visited()
		State.PLAY:
			if interact:
				for s in stands:
					if s.player_inside:
						_open_member(s)
						break
		State.END:
			if k == KEY_R:
				get_tree().reload_current_scene()


func _resume() -> void:
	popup.hide_popup()
	state = State.PLAY
	player.frozen = false


func _open_member(s: MemberStand) -> void:
	state = State.POPUP
	player.frozen = true
	s.visited = true
	popup.show_member(s.data, s.photo, s.color, s.index + 1, stands.size())
	_update_hud()


func _check_all_visited() -> void:
	if gate_open or stands.is_empty() or _visited_count() < stands.size():
		return
	gate_open = true
	gate.queue_free()
	_update_hud()


func _process(delta: float) -> void:
	_time += delta
	if state == State.PLAY and gate_open and player.position.y < ROOM.position.y - WALL - 4:
		_finish()
	queue_redraw()


func _finish() -> void:
	state = State.END
	player.frozen = true
	var lines := ""
	for m in members:
		lines += "• %s (%s)\n" % [str(m.get("name", "")), str(m.get("role", ""))]
	popup.show_message("TIM LENGKAP!",
		"Kamu sudah kenalan dengan:\n" + lines + "\nSiap berkolaborasi di proyek akhir!",
		Color("#e9c46a"), "Tekan R untuk main lagi")


# ---------- render ----------
func _draw() -> void:
	draw_rect(get_viewport_rect(), Color("#1d1b2e"))

	# lantai kotak-kotak
	var tile := 16
	for x in range(int(ROOM.position.x), int(ROOM.end.x), tile):
		for y in range(int(ROOM.position.y), int(ROOM.end.y), tile):
			var even := ((x + y) / tile) % 2 == 0
			draw_rect(Rect2(x, y, tile, tile), Color("#3d3a5c") if even else Color("#36334f"))

	# karpet di depan podium
	draw_rect(Rect2(ROOM.position.x + 48, ROOM.position.y + 136, ROOM.size.x - 96, 8), Color("#4a3f6b"))

	# dinding
	for r in _wall_rects:
		draw_rect(r, Color("#5b4b8a"))
		draw_rect(Rect2(r.position, Vector2(r.size.x, 2)), Color("#7a68b3"))

	# gerbang
	if gate_open:
		var a := 0.35 + 0.25 * sin(_time * 4.0)
		draw_rect(Rect2(_gate_rect.position.x, 0, GATE_W, _gate_rect.end.y), Color(0.91, 0.77, 0.42, a))
	else:
		draw_rect(_gate_rect, Color("#2b2540"))
		for i in 5:
			var bx := _gate_rect.position.x + 4 + i * 10
			draw_rect(Rect2(bx, _gate_rect.position.y, 3, WALL), Color("#e9c46a"))

extends Node2D
## Micro game "Team Intro" versi platformer.
## Pilih karakter (kepalanya foto anggota) -> lari & lompat -> temui papan tiap
## anggota (checkpoint) -> kumpulkan koin -> sentuh bendera finish.
##
## Data anggota : res://data/team.json
## Peta level   : res://data/level1.txt  (lihat legenda di README)

const TILE := 16
const DATA_PATH := "res://data/team.json"
const LEVEL_PATH := "res://data/level1.txt"
const PHOTO_PIXELS := 20

enum State { SELECT, PLAY, POPUP, END }

var state := State.SELECT
var team_name := "Tim Kami"
var members: Array = []
var photos: Array = []
var colors: Array = []

var world: Node2D
var player: Player
var popup: InfoPopup
var select_screen: SelectScreen
var hud: Control

var member_posts: Array[Pickup] = []
var coins := 0
var total_coins := 0
var respawn_point := Vector2.ZERO
var level_size := Vector2i.ZERO
var chosen_index := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_data()

	var sky_layer := CanvasLayer.new()
	sky_layer.layer = -10
	var sky := Node2D.new()
	sky.set_script(load("res://scripts/sky.gd"))
	sky_layer.add_child(sky)
	add_child(sky_layer)

	world = Node2D.new()
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(world)
	_build_level()
	_spawn_player()
	_build_hud()

	popup = InfoPopup.new()
	add_child(popup)

	select_screen = SelectScreen.new()
	select_screen.team_name = team_name
	select_screen.members = members
	select_screen.photos = photos
	select_screen.colors = colors
	select_screen.chosen.connect(_on_character_chosen)
	add_child(select_screen)

	get_tree().paused = true
	_update_hud()


# ---------------- data ----------------
func _load_data() -> void:
	var f := FileAccess.open(DATA_PATH, FileAccess.READ)
	if f:
		var parsed: Variant = JSON.parse_string(f.get_as_text())
		if parsed is Dictionary:
			team_name = str(parsed.get("team_name", team_name))
			members = parsed.get("members", [])
	else:
		push_error("Tidak bisa membuka " + DATA_PATH)
	if members.is_empty():
		members = [{"name": "Pemain", "nim": "-", "role": "-", "color": "#4361ee"}]
	for m in members:
		var col := Color.html(str(m.get("color", "#4361ee")))
		colors.append(col)
		photos.append(PhotoUtil.load_pixelated(str(m.get("photo", "")), PHOTO_PIXELS, col))


# ---------------- level ----------------
func _build_level() -> void:
	var text := FileAccess.get_file_as_string(LEVEL_PATH)
	var rows := text.split("\n")
	while rows.size() > 0 and rows[rows.size() - 1].strip_edges() == "":
		rows.remove_at(rows.size() - 1)

	var tiles := {}
	var w := 0
	for y in rows.size():
		var row: String = rows[y].trim_suffix("\r")
		w = maxi(w, row.length())
		for x in row.length():
			var ch := row[x]
			var cell := Vector2i(x, y)
			var foot := Vector2(x * TILE + TILE / 2.0, (y + 1) * TILE)
			match ch:
				"#", "B", "-":
					tiles[cell] = ch
				"o":
					_spawn_pickup(Pickup.Kind.COIN, foot)
					total_coins += 1
				"1", "2", "3", "4", "5", "6", "7", "8", "9":
					var idx := int(ch) - 1
					if idx < members.size():
						var p := _spawn_pickup(Pickup.Kind.MEMBER, foot)
						p.index = idx
						p.data = members[idx]
						p.color = colors[idx]
						p.photo = photos[idx]
						member_posts.append(p)
				"e":
					var e := Enemy.new()
					e.position = foot
					world.add_child(e)
				"P":
					respawn_point = foot
				"F":
					var fl := _spawn_pickup(Pickup.Kind.FINISH, foot)
					fl.color = Color("#e76f51")
	level_size = Vector2i(w, rows.size())

	var art := LevelArt.new()
	art.tiles = tiles
	world.add_child(art)
	world.move_child(art, 0)

	# collider: gabungkan tile berurutan dalam satu baris
	for y in level_size.y:
		var x := 0
		while x < w:
			var ch: String = tiles.get(Vector2i(x, y), "")
			if ch == "":
				x += 1
				continue
			var one_way := ch == "-"
			var sx := x
			while x < w and (tiles.get(Vector2i(x, y), "") == "-") == one_way \
					and tiles.has(Vector2i(x, y)):
				x += 1
			var h := 6.0 if one_way else float(TILE)
			_add_block(Rect2(sx * TILE, y * TILE, (x - sx) * TILE, h), one_way)

	# dinding tak terlihat di kiri & kanan level
	var lh := level_size.y * TILE
	_add_block(Rect2(-TILE, -lh, TILE, lh * 2), false)
	_add_block(Rect2(w * TILE, -lh, TILE, lh * 2), false)


func _add_block(r: Rect2, one_way: bool) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = r.size
	cs.shape = shape
	cs.position = r.get_center()
	cs.one_way_collision = one_way
	body.add_child(cs)
	world.add_child(body)


func _spawn_pickup(kind: Pickup.Kind, pos: Vector2) -> Pickup:
	var p := Pickup.new()
	p.kind = kind
	p.position = pos
	p.touched.connect(_on_pickup_touched)
	world.add_child(p)
	return p


func _spawn_player() -> void:
	player = Player.new()
	player.position = respawn_point
	player.photo = photos[0]
	player.color = colors[0]
	player.fall_limit = level_size.y * TILE + 48
	player.died.connect(_on_player_died)
	world.add_child(player)

	var cam := Camera2D.new()
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = level_size.x * TILE
	cam.limit_bottom = level_size.y * TILE
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 8.0
	cam.offset = Vector2(0, -24)
	player.add_child(cam)


# ---------------- HUD ----------------
func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	hud = Control.new()
	hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.draw.connect(_draw_hud)
	layer.add_child(hud)


func _met_count() -> int:
	var c := 0
	for p in member_posts:
		if p.visited:
			c += 1
	return c


func _update_hud() -> void:
	if hud:
		hud.queue_redraw()


func _pill(x: float, text: String, icon: int) -> float:
	var w := UI.BOLD.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x + 34.0
	var r := Rect2(x, 10, w, 24)
	hud.draw_style_box(UI.box(Color(0.36, 0.29, 0.43, 0.18), 12), Rect2(r.position + Vector2(0, 2), r.size))
	hud.draw_style_box(UI.box(UI.CREAM, 12, Color.WHITE, 2), r)
	var ic := r.position + Vector2(14, 12)
	match icon:
		0:
			hud.draw_colored_polygon(UI.star_points(ic, 7.0, 3.2), UI.SUN)
		1:
			UI.heart(hud, ic + Vector2(0, -1), 3.4, UI.PINK)
		2:
			UI.circle_photo(hud, photos[chosen_index], ic, 6.5, colors[chosen_index], 1.0)
	hud.draw_string(UI.BOLD, r.position + Vector2(24, 17), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, UI.INK)
	return x + w + 8.0


func _draw_hud() -> void:
	var x := 12.0
	x = _pill(x, str(members[chosen_index].get("name", "")), 2)
	x = _pill(x, "%d / %d" % [coins, total_coins], 0)
	x = _pill(x, "%d / %d" % [_met_count(), member_posts.size()], 1)
	if state == State.PLAY:
		hud.draw_string_outline(UI.BODY, Vector2(12, 52), "A/D jalan  •  Spasi lompat  •  injak musuh dari atas",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 10, 4, Color(1, 1, 1, 0.8))
		hud.draw_string(UI.BODY, Vector2(12, 52), "A/D jalan  •  Spasi lompat  •  injak musuh dari atas",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 10, UI.INK)


# ---------------- events ----------------
func _on_character_chosen(i: int) -> void:
	chosen_index = i
	player.photo = photos[i]
	player.color = colors[i]
	player.queue_redraw()
	state = State.PLAY
	get_tree().paused = false
	_update_hud()


func _on_pickup_touched(p: Pickup) -> void:
	if state != State.PLAY:
		return
	match p.kind:
		Pickup.Kind.COIN:
			coins += 1
			p.collect()
		Pickup.Kind.MEMBER:
			respawn_point = p.global_position
			if not p.visited:
				p.visited = true
				_open_popup.call_deferred(p)
		Pickup.Kind.FINISH:
			if _met_count() < member_posts.size():
				_pause_with_message("Belum lengkap!",
					"Temui dulu semua anggota tim sebelum finish.", Color("#e76f51"),
					"Tekan E untuk lanjut")
			else:
				_finish.call_deferred()
	_update_hud()


func _open_popup(p: Pickup) -> void:
	state = State.POPUP
	get_tree().paused = true
	popup.show_member(p.data, p.photo, p.color, _met_count(), member_posts.size())
	Fx.burst(self, p.global_position + Vector2(0, -44), UI.PINK, 10, 70.0, Fx.Shape.HEART, 2.2)


func _pause_with_message(title: String, body: String, col: Color, hint: String) -> void:
	state = State.POPUP
	get_tree().paused = true
	popup.show_message(title, body, col, hint)
	player.position.x -= 24


func _on_player_died() -> void:
	player.respawn(respawn_point)


func _finish() -> void:
	state = State.END
	_update_hud()
	get_tree().paused = true
	var lines := ""
	for m in members:
		lines += "• %s  —  %s\n" % [str(m.get("name", "")), str(m.get("role", ""))]
	popup.show_message("LEVEL SELESAI!",
		"%s\n%s\nKoin terkumpul: %d/%d\nSiap berkolaborasi di proyek akhir!" % [
			team_name, lines, coins, total_coins],
		Color("#ffd23f"), "Tekan R untuk main lagi")


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var k: int = event.physical_keycode
	match state:
		State.POPUP:
			if k in [KEY_E, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_ESCAPE]:
				popup.hide_popup()
				state = State.PLAY
				get_tree().paused = false
				_update_hud()
				get_viewport().set_input_as_handled()
		State.END:
			if k == KEY_R:
				get_tree().paused = false
				get_tree().reload_current_scene()

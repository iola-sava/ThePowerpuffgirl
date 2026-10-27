@tool
class_name LevelArt
extends Node2D
## Menggambar tile level (sekali saja, karena levelnya statis).
## '#' tanah kue berumput • 'B' balok permen • '-' platform awan (bisa dilompati dari bawah)
## Di editor, level dari data/level1.txt ikut ditampilkan sebagai pratinjau,
## lengkap dengan penanda posisi bintang, musuh, papan anggota, start, dan finish.

const TILE := 16
const FLOWER_COLS := [Color("#ff8fc1"), Color("#ffffff"), Color("#c3a6ff"), Color("#ffd84d")]

var tiles: Dictionary = {}  # Vector2i -> karakter tile
var _markers: Dictionary = {}  # khusus pratinjau editor


func _ready() -> void:
	if Engine.is_editor_hint():
		_load_preview()


func _load_preview() -> void:
	var rows := FileAccess.get_file_as_string("res://data/level1.txt").split("\n")
	for y in rows.size():
		var row: String = rows[y].trim_suffix("\r")
		for x in row.length():
			var ch := row[x]
			if ch in ["#", "B", "-"]:
				tiles[Vector2i(x, y)] = ch
			elif ch != " ":
				_markers[Vector2i(x, y)] = ch
	queue_redraw()


func _draw() -> void:
	if Engine.is_editor_hint():
		var lw := 0
		var lh := 0
		for pos: Vector2i in tiles:
			lw = maxi(lw, pos.x + 1)
			lh = maxi(lh, pos.y + 1)
		draw_rect(Rect2(0, 0, lw * TILE, lh * TILE), Color("#cfeaff"))
	# urutan: tanah dulu, lalu rumput (supaya lengkungan rumput di atas tanah), lalu lainnya
	for pos: Vector2i in tiles:
		if tiles[pos] == "#":
			_draw_soil(_rect(pos), pos)
	for pos: Vector2i in tiles:
		if tiles[pos] == "#" and tiles.get(pos + Vector2i.UP, "") != "#":
			_draw_grass(_rect(pos), pos)
	for pos: Vector2i in tiles:
		match tiles[pos]:
			"B":
				_draw_candy(_rect(pos))
			"-":
				_draw_cloud(_rect(pos), pos)
	if Engine.is_editor_hint():
		_draw_markers()


func _rect(pos: Vector2i) -> Rect2:
	return Rect2(pos.x * TILE, pos.y * TILE, TILE, TILE)


func _hash(pos: Vector2i) -> int:
	return absi((pos.x * 73856093) ^ (pos.y * 19349663))


func _draw_soil(r: Rect2, pos: Vector2i) -> void:
	draw_rect(r, Color("#f6c896"))
	var h := _hash(pos)
	for i in 2:
		var d := Vector2(3 + (h >> (i * 4)) % 10, 4 + (h >> (i * 5 + 3)) % 9)
		draw_circle(r.position + d, 1.4, Color("#e5a56b"))
	if not tiles.has(pos + Vector2i.LEFT):
		draw_rect(Rect2(r.position, Vector2(2, TILE)), Color("#e5a56b"))
	if not tiles.has(pos + Vector2i.RIGHT):
		draw_rect(Rect2(r.position + Vector2(TILE - 2, 0), Vector2(2, TILE)), Color("#e5a56b"))


func _draw_grass(r: Rect2, pos: Vector2i) -> void:
	var p := r.position
	draw_rect(Rect2(p, Vector2(TILE, 5)), UI.MINT)
	for i in 4:
		draw_circle(p + Vector2(2 + i * 4, 5), 2.4, UI.MINT)
	draw_rect(Rect2(p + Vector2(0, 0), Vector2(TILE, 2)), Color("#b8f5cc"))
	var h := _hash(pos)
	if h % 3 == 0:
		var fc: Color = FLOWER_COLS[(h >> 3) % FLOWER_COLS.size()]
		var c := p + Vector2(4 + (h >> 5) % 8, -2)
		draw_rect(Rect2(c + Vector2(-0.5, 0), Vector2(1, 3)), Color("#4fbf7a"))
		for a in 5:
			var d := Vector2(cos(a * TAU / 5.0), sin(a * TAU / 5.0)) * 1.6
			draw_circle(c + d, 1.2, fc)
		draw_circle(c, 0.9, UI.SUN)


func _draw_candy(r: Rect2) -> void:
	var inner := r.grow(-0.5)
	draw_style_box(UI.box(Color("#e57aa8"), 4), inner)
	draw_style_box(UI.box(Color("#ff9fc9"), 4), Rect2(inner.position, inner.size - Vector2(0, 2.5)))
	draw_style_box(UI.box(Color(1, 1, 1, 0.55), 2), Rect2(inner.position + Vector2(2.5, 2), Vector2(5, 2)))
	draw_circle(inner.position + Vector2(10.5, 3), 0.9, Color(1, 1, 1, 0.7))


func _draw_cloud(r: Rect2, pos: Vector2i) -> void:
	var p := r.position
	var left: bool = tiles.get(pos + Vector2i.LEFT, "") != "-"
	var right: bool = tiles.get(pos + Vector2i.RIGHT, "") != "-"
	var body := Rect2(p + Vector2(2 if left else 0, 2), Vector2(TILE - (2 if left else 0) - (2 if right else 0), 6))
	draw_style_box(UI.box(Color("#d6e6ff"), 3), Rect2(body.position + Vector2(0, 1.5), body.size))
	draw_style_box(UI.box(Color.WHITE, 3), body)
	draw_circle(p + Vector2(5, 2.5), 3.2, Color.WHITE)
	draw_circle(p + Vector2(11, 2), 3.6, Color.WHITE)


func _draw_markers() -> void:
	var cols := {"o": UI.SUN, "e": Color("#c3a6ff"), "P": Color("#7fdca0"), "F": UI.PINK}
	for pos: Vector2i in _markers:
		var ch: String = _markers[pos]
		var c := Vector2(pos.x * TILE + TILE / 2.0, pos.y * TILE + TILE / 2.0)
		var col: Color = cols.get(ch, Color("#ff9f6b"))
		draw_circle(c, 6.0, Color(col, 0.85))
		draw_string(UI.BOLD, c + Vector2(-8, 3.5), ch, HORIZONTAL_ALIGNMENT_CENTER, 16, 9, UI.INK)

class_name LevelArt
extends Node2D
## Menggambar tile level (sekali saja, karena levelnya statis).
## '#' tanah berumput • 'B' balok batu • '-' papan kayu (bisa dilompati dari bawah)

const TILE := 16

var tiles: Dictionary = {}  # Vector2i -> karakter tile


func _draw() -> void:
	for pos: Vector2i in tiles:
		var ch: String = tiles[pos]
		var r := Rect2(pos.x * TILE, pos.y * TILE, TILE, TILE)
		match ch:
			"#":
				_draw_ground(r, pos)
			"B":
				_draw_stone(r)
			"-":
				_draw_plank(r)


func _draw_ground(r: Rect2, pos: Vector2i) -> void:
	draw_rect(r, Color("#8b5a2b"))
	var hsh := (pos.x * 73856093) ^ (pos.y * 19349663)
	for i in 3:
		var sx := posmod(hsh >> (i * 4), 13) + 1
		var sy := posmod(hsh >> (i * 5 + 2), 13) + 1
		draw_rect(Rect2(r.position.x + sx, r.position.y + sy, 2, 2), Color("#6e4520"))
	if tiles.get(pos + Vector2i.UP, "") != "#":
		draw_rect(Rect2(r.position, Vector2(TILE, 5)), Color("#5cb85c"))
		draw_rect(Rect2(r.position, Vector2(TILE, 2)), Color("#8fdc6c"))
		for i in 3:
			draw_rect(Rect2(r.position.x + 2 + i * 5, r.position.y + 5, 2, 2), Color("#5cb85c"))


func _draw_stone(r: Rect2) -> void:
	draw_rect(r, Color("#6c7a89"))
	draw_rect(Rect2(r.position, Vector2(TILE, 2)), Color("#95a5b5"))
	draw_rect(Rect2(r.position, Vector2(2, TILE)), Color("#95a5b5"))
	draw_rect(Rect2(r.position + Vector2(0, TILE - 2), Vector2(TILE, 2)), Color("#4a5663"))
	draw_rect(Rect2(r.position + Vector2(TILE - 2, 0), Vector2(2, TILE)), Color("#4a5663"))
	draw_rect(Rect2(r.position + Vector2(5, 5), Vector2(6, 6)), Color("#5d6a78"))


func _draw_plank(r: Rect2) -> void:
	draw_rect(Rect2(r.position, Vector2(TILE, 6)), Color("#c8915a"))
	draw_rect(Rect2(r.position, Vector2(TILE, 2)), Color("#e3b17d"))
	draw_rect(Rect2(r.position + Vector2(0, 5), Vector2(TILE, 1)), Color("#8a5a2f"))
	draw_rect(Rect2(r.position + Vector2(TILE - 1, 0), Vector2(1, 6)), Color("#8a5a2f"))

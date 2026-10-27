class_name MemberStand
extends Area2D
## Podium anggota: menampilkan foto pixel melayang, prompt [E] saat pemain dekat.

var data: Dictionary = {}
var index := 0
var color := Color.WHITE
var photo: Texture2D
var player_inside := false
var visited := false
var _t := 0.0


func setup(d: Dictionary, i: int, c: Color, p: Texture2D) -> void:
	data = d
	index = i
	color = c
	photo = p


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1

	# zona interaksi
	var zone := CollisionShape2D.new()
	var zr := RectangleShape2D.new()
	zr.size = Vector2(60, 64)
	zone.shape = zr
	zone.position = Vector2(0, 16)
	add_child(zone)

	# podium padat
	var body := StaticBody2D.new()
	var bs := CollisionShape2D.new()
	var br := RectangleShape2D.new()
	br.size = Vector2(28, 12)
	bs.shape = br
	bs.position = Vector2(0, 6)
	body.add_child(bs)
	add_child(body)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(b: Node2D) -> void:
	if b is Player:
		player_inside = true


func _on_body_exited(b: Node2D) -> void:
	if b is Player:
		player_inside = false


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var font := ThemeDB.fallback_font

	# bayangan + podium
	draw_rect(Rect2(-16, 10, 32, 4), Color(0, 0, 0, 0.25))
	draw_rect(Rect2(-14, 0, 28, 12), color.darkened(0.35))
	draw_rect(Rect2(-14, 0, 28, 3), color)

	# foto pixel melayang
	var y := -22.0 + sin(_t * 2.0 + index) * 2.0
	draw_rect(Rect2(-15, y - 15, 30, 30), color)
	draw_rect(Rect2(-13, y - 13, 26, 26), Color("#14121f"))
	if photo:
		draw_texture_rect(photo, Rect2(-12, y - 12, 24, 24), false)

	# label peran
	draw_string(font, Vector2(-50, 26), str(data.get("role", "")),
		HORIZONTAL_ALIGNMENT_CENTER, 100, 8, Color(1, 1, 1, 0.85))

	if visited:
		draw_circle(Vector2(14, y - 14), 5.0, Color("#2a9d8f"))
		draw_polyline(PackedVector2Array([
			Vector2(11.5, y - 14), Vector2(13.5, y - 12), Vector2(16.5, y - 16.5)
		]), Color.WHITE, 1.5)

	if player_inside:
		var py := y - 30 + sin(_t * 6.0)
		draw_rect(Rect2(-7, py - 7, 14, 14), Color.WHITE)
		draw_string(font, Vector2(-7, py + 4), "E",
			HORIZONTAL_ALIGNMENT_CENTER, 14, 10, Color("#14121f"))
	elif not visited:
		var a := 0.5 + 0.5 * sin(_t * 4.0)
		draw_string(font, Vector2(-5, y - 20), "!",
			HORIZONTAL_ALIGNMENT_CENTER, 10, 12, Color(color, a))

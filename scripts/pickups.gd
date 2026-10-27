class_name Pickup
extends Area2D
## Objek yang bisa disentuh pemain: koin, papan anggota (checkpoint), atau bendera finish.

signal touched(p: Pickup)

enum Kind { COIN, MEMBER, FINISH }

var kind := Kind.COIN
var data: Dictionary = {}
var index := 0
var color := Color("#e9c46a")
var photo: Texture2D
var visited := false
var _t := 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	match kind:
		Kind.COIN:
			r.size = Vector2(10, 10)
			cs.position = Vector2(0, -8)
		Kind.MEMBER:
			r.size = Vector2(20, 48)
			cs.position = Vector2(0, -24)
		Kind.FINISH:
			r.size = Vector2(16, 80)
			cs.position = Vector2(0, -40)
	cs.shape = r
	add_child(cs)
	body_entered.connect(_on_body_entered)
	_t = randf() * 3.0


func _on_body_entered(b: Node2D) -> void:
	if b is Player:
		touched.emit(self)


func collect() -> void:
	set_deferred("monitoring", false)
	var tw := create_tween()
	tw.tween_property(self, "position:y", position.y - 16, 0.25)
	tw.parallel().tween_property(self, "modulate:a", 0.0, 0.25)
	tw.tween_callback(queue_free)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	match kind:
		Kind.COIN:
			var w := absf(cos(_t * 4.0)) * 5.0 + 1.0
			draw_set_transform(Vector2(0, -8), 0.0, Vector2(w / 6.0, 1.0))
			draw_circle(Vector2.ZERO, 6.0, Color("#c9971c"))
			draw_circle(Vector2.ZERO, 4.5, Color("#ffd23f"))
			draw_rect(Rect2(-1, -3, 2, 6), Color("#fff3b0"))
		Kind.MEMBER:
			_draw_member()
		Kind.FINISH:
			_draw_finish()


func _draw_member() -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(-1, -30, 3, 30), Color("#5c4a3d"))
	var y := -48.0 + sin(_t * 2.0) * 1.5
	draw_rect(Rect2(-11, y - 1, 22, 22), Color("#1d1b2e"))
	draw_rect(Rect2(-10, y, 20, 20), color)
	if photo:
		draw_texture_rect(photo, Rect2(-8, y + 2, 16, 16), false)
	draw_string(font, Vector2(-40, y - 4), str(data.get("role", "")),
		HORIZONTAL_ALIGNMENT_CENTER, 80, 8, Color.WHITE)
	if visited:
		draw_circle(Vector2(10, y), 4.0, Color("#2a9d8f"))
		draw_polyline(PackedVector2Array([
			Vector2(8, y), Vector2(9.5, y + 1.5), Vector2(12, y - 1.5)
		]), Color.WHITE, 1.2)
	else:
		var a := 0.5 + 0.5 * sin(_t * 5.0)
		draw_string(font, Vector2(-5, y - 14), "!", HORIZONTAL_ALIGNMENT_CENTER, 10, 12,
			Color(1, 0.9, 0.3, a))


func _draw_finish() -> void:
	draw_rect(Rect2(-1, -80, 3, 80), Color("#dfe6e9"))
	draw_circle(Vector2(0.5, -82), 3.0, Color("#ffd23f"))
	var pts := PackedVector2Array()
	for i in 7:
		var x := 2.0 + i * 4.0
		pts.append(Vector2(x, -78 + sin(_t * 6.0 - i * 0.7) * 1.5))
	for i in range(6, -1, -1):
		var x := 2.0 + i * 4.0
		pts.append(Vector2(x, -64 + sin(_t * 6.0 - i * 0.7) * 1.5))
	draw_colored_polygon(pts, color)
	draw_rect(Rect2(-6, -4, 14, 4), Color("#6c7a89"))

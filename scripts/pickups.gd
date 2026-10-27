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
	Fx.burst(get_parent(), global_position + Vector2(0, -8), UI.SUN, 7, 55.0, Fx.Shape.SPARKLE, 2.0)
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
			_draw_star()
		Kind.MEMBER:
			_draw_member()
		Kind.FINISH:
			_draw_finish()


func _draw_star() -> void:
	var c := Vector2(0, -8 + sin(_t * 3.0) * 1.5)
	var rot := -PI / 2.0 + sin(_t * 2.0) * 0.25
	draw_colored_polygon(UI.star_points(c + Vector2(0, 1), 7.0, 3.4, rot), Color("#f2a93b"))
	draw_colored_polygon(UI.star_points(c, 6.5, 3.0, rot), UI.SUN)
	draw_circle(c + Vector2(-1.5, -1.5), 1.2, Color(1, 1, 1, 0.8))


func _draw_member() -> void:
	var y := -44.0 + sin(_t * 2.0) * 1.5
	# tiang
	draw_style_box(UI.box(Color("#d9a877"), 1), Rect2(-1.5, y + 10, 3, -y - 10))
	# papan + foto bulat
	draw_style_box(UI.box(Color("#ffffff"), 8, color, 2), Rect2(-14, y - 12, 28, 28))
	UI.circle_photo(self, photo, Vector2(0, y + 2), 10.0, color, 1.2)
	# pita peran
	var role := str(data.get("role", ""))
	var font: Font = UI.BOLD
	var fs := 7
	var w := font.get_string_size(role, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + 10.0
	draw_style_box(UI.box(color, 5), Rect2(-w / 2.0, y - 24, w, 10))
	draw_string(font, Vector2(-w / 2.0, y - 16.5), role, HORIZONTAL_ALIGNMENT_CENTER, w, fs, Color.WHITE)
	if visited:
		draw_circle(Vector2(13, y - 10), 5.0, Color.WHITE)
		draw_circle(Vector2(13, y - 10), 4.0, UI.MINT)
		draw_polyline(PackedVector2Array([
			Vector2(11, y - 10), Vector2(12.5, y - 8.5), Vector2(15, y - 11.5)
		]), Color.WHITE, 1.3, true)
	else:
		var hy := y - 34.0 + sin(_t * 4.0) * 2.0
		UI.heart(self, Vector2(0, hy + 1), 3.6, Color(1, 1, 1, 0.9))
		UI.heart(self, Vector2(0, hy), 3.0, UI.PINK)


func _draw_finish() -> void:
	draw_style_box(UI.box(Color.WHITE, 2), Rect2(-1.5, -80, 3, 80))
	draw_colored_polygon(UI.star_points(Vector2(0, -84), 6.0, 2.8), UI.SUN)
	var pts := PackedVector2Array()
	for i in 8:
		pts.append(Vector2(2.0 + i * 4.0, -78 + sin(_t * 6.0 - i * 0.7) * 1.5))
	for i in range(7, -1, -1):
		pts.append(Vector2(2.0 + i * 4.0, -60 + sin(_t * 6.0 - i * 0.7) * 1.5))
	draw_colored_polygon(pts, UI.PINK)
	UI.heart(self, Vector2(16, -70 + sin(_t * 6.0 - 3.5) * 1.5), 3.2, Color.WHITE)
	draw_style_box(UI.box(Color("#ff9fc9"), 3), Rect2(-7, -5, 15, 5))

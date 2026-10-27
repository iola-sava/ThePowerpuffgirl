class_name Player
extends CharacterBody2D
## Karakter pemain top-down. Gerak: WASD / tombol panah.

const SPEED := 110.0

var frozen := false
var facing := Vector2.DOWN
var _walk_t := 0.0


func _ready() -> void:
	collision_layer = 1
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 6.0
	shape.shape = circle
	shape.position = Vector2(0, 4)
	add_child(shape)


func _physics_process(delta: float) -> void:
	var dir := Vector2.ZERO
	if not frozen:
		dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if dir == Vector2.ZERO:
			dir = Vector2(
				float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
				float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
			).normalized()

	velocity = dir * SPEED
	move_and_slide()

	if dir != Vector2.ZERO:
		facing = dir
		_walk_t += delta * 12.0
	else:
		_walk_t = 0.0
	queue_redraw()


func _draw() -> void:
	var bob := absf(sin(_walk_t)) * -2.0
	# bayangan
	draw_set_transform(Vector2(0, 10), 0.0, Vector2(1.0, 0.4))
	draw_circle(Vector2.ZERO, 7.0, Color(0, 0, 0, 0.3))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# kaki
	var step := sin(_walk_t) * 2.0
	draw_rect(Rect2(-4, 6 + bob + step * 0.5, 3, 4), Color("#264653"))
	draw_rect(Rect2(1, 6 + bob - step * 0.5, 3, 4), Color("#264653"))
	# badan
	draw_rect(Rect2(-5, -2 + bob, 10, 9), Color("#4361ee"))
	draw_rect(Rect2(-5, -2 + bob, 10, 2), Color("#6c84ff"))
	# kepala
	draw_circle(Vector2(0, -7 + bob), 5.5, Color("#f4c095"))
	draw_rect(Rect2(-5.5, -13 + bob, 11, 4), Color("#3d2c29"))
	# mata (tidak terlihat saat menghadap ke atas)
	if facing.y > -0.6:
		var ox := facing.x * 1.5
		draw_rect(Rect2(-3 + ox, -8 + bob, 1.5, 2), Color("#1d1b2e"))
		draw_rect(Rect2(1.5 + ox, -8 + bob, 1.5, 2), Color("#1d1b2e"))

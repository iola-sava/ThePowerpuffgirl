class_name Player
extends CharacterBody2D
## Karakter platformer. Kepalanya = foto pixel anggota yang dipilih.
## Gerak: A/D atau panah • Lompat: Spasi / W / panah atas

signal died

const SPEED := 130.0
const ACCEL := 900.0
const JUMP_V := -360.0
const GRAVITY := 900.0
const MAX_FALL := 480.0
const JUMP_KEYS := [KEY_SPACE, KEY_W, KEY_UP, KEY_K]

var photo: Texture2D
var color := Color("#4361ee")
var facing := 1.0
var invuln := 0.0
var fall_limit := 100000.0

var _coyote := 0.0
var _buffer := 0.0
var _walk := 0.0
var _squash := Vector2.ONE


func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 4.0
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(10, 20)
	cs.shape = r
	cs.position = Vector2(0, -10)
	add_child(cs)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo \
			and event.physical_keycode in JUMP_KEYS:
		_buffer = 0.12


func _jump_held() -> bool:
	for k in JUMP_KEYS:
		if Input.is_physical_key_pressed(k):
			return true
	return false


func _physics_process(delta: float) -> void:
	var dir := Input.get_axis("ui_left", "ui_right")
	if dir == 0.0:
		dir = float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A))
	velocity.x = move_toward(velocity.x, dir * SPEED, ACCEL * delta)
	if dir != 0.0:
		facing = signf(dir)

	_coyote = 0.1 if is_on_floor() else _coyote - delta
	_buffer -= delta
	velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)

	if _buffer > 0.0 and _coyote > 0.0:
		velocity.y = JUMP_V
		_buffer = 0.0
		_coyote = 0.0
		_squash = Vector2(0.75, 1.3)
	elif velocity.y < 0.0 and not _jump_held():
		velocity.y += GRAVITY * delta * 1.5  # lompat pendek kalau tombol dilepas

	var was_air := not is_on_floor()
	move_and_slide()
	if was_air and is_on_floor():
		_squash = Vector2(1.3, 0.75)
	_squash = _squash.lerp(Vector2.ONE, 12.0 * delta)

	_walk = _walk + delta * 14.0 if absf(velocity.x) > 10.0 and is_on_floor() else 0.0
	if invuln > 0.0:
		invuln -= delta
	if global_position.y > fall_limit:
		died.emit()
	queue_redraw()


func bounce() -> void:
	velocity.y = JUMP_V * 0.7


func hit() -> void:
	if invuln <= 0.0:
		died.emit()


func respawn(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	invuln = 1.2


func _draw() -> void:
	if invuln > 0.0 and int(invuln * 16.0) % 2 == 0:
		return
	draw_set_transform(Vector2.ZERO, 0.0, _squash)
	var dark := Color("#1d1b2e")
	# kaki
	if is_on_floor():
		var s := sin(_walk) * 2.0
		draw_rect(Rect2(-4 + s * 0.5, -4, 3, 4), dark)
		draw_rect(Rect2(1 - s * 0.5, -4, 3, 4), dark)
	else:
		draw_rect(Rect2(-4, -5, 3, 3), dark)
		draw_rect(Rect2(1, -5, 3, 3), dark)
	# badan + tangan
	draw_rect(Rect2(-5, -10, 10, 7), color)
	draw_rect(Rect2(-5, -10, 10, 2), color.lightened(0.3))
	var arm := -9.0 if velocity.y < 0.0 else -8.0
	draw_rect(Rect2(-7, arm, 2, 4), Color("#f4c095"))
	draw_rect(Rect2(5, arm, 2, 4), Color("#f4c095"))
	# kepala = foto
	draw_rect(Rect2(-8, -25, 16, 16), dark)
	if photo:
		draw_texture_rect(photo, Rect2(-7, -24, 14, 14), false)
	else:
		draw_rect(Rect2(-7, -24, 14, 14), Color("#f4c095"))

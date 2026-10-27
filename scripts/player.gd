@tool
class_name Player
extends CharacterBody2D
## Scene: res://scenes/player.tscn
## Karakter platformer. Kepalanya = foto pixel anggota yang dipilih.
## Gerak: A/D atau panah • Lompat: Spasi / W / panah atas
## Angka gerak bisa diubah di Inspector (klik node Player).

signal died

@export var speed := 130.0
@export var jump_velocity := -360.0
@export var gravity := 900.0
@export var acceleration := 900.0
@export var max_fall := 480.0

const JUMP_KEYS := [KEY_SPACE, KEY_W, KEY_UP, KEY_K]

var photo: Texture2D
var color := Color("#ff8fc1")
var facing := 1.0
var invuln := 0.0
var fall_limit := 100000.0

var _coyote := 0.0
var _buffer := 0.0
var _walk := 0.0
var _idle := 0.0
var _squash := Vector2.ONE


@onready var camera: Camera2D = $Camera2D


func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventKey and event.pressed and not event.echo \
			and event.physical_keycode in JUMP_KEYS:
		_buffer = 0.12


func _jump_held() -> bool:
	for k in JUMP_KEYS:
		if Input.is_physical_key_pressed(k):
			return true
	return false


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var dir := Input.get_axis("ui_left", "ui_right")
	if dir == 0.0:
		dir = float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A))
	velocity.x = move_toward(velocity.x, dir * speed, acceleration * delta)
	if dir != 0.0:
		facing = signf(dir)

	_coyote = 0.1 if is_on_floor() else _coyote - delta
	_buffer -= delta
	velocity.y = minf(velocity.y + gravity * delta, max_fall)

	if _buffer > 0.0 and _coyote > 0.0:
		velocity.y = jump_velocity
		_buffer = 0.0
		_coyote = 0.0
		_squash = Vector2(0.75, 1.3)
		Fx.burst(get_parent(), global_position, Color.WHITE, 5, 40.0)
	elif velocity.y < 0.0 and not _jump_held():
		velocity.y += gravity * delta * 1.5  # lompat pendek kalau tombol dilepas

	var was_air := not is_on_floor()
	move_and_slide()
	if was_air and is_on_floor():
		_squash = Vector2(1.3, 0.75)
		Fx.burst(get_parent(), global_position, Color.WHITE, 6, 45.0)
	_squash = _squash.lerp(Vector2.ONE, 12.0 * delta)

	_idle += delta
	_walk = _walk + delta * 14.0 if absf(velocity.x) > 10.0 and is_on_floor() else 0.0
	if invuln > 0.0:
		invuln -= delta
	if global_position.y > fall_limit:
		died.emit()
	queue_redraw()


func bounce() -> void:
	velocity.y = jump_velocity * 0.7


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
	var on_floor := is_on_floor()
	# bayangan
	if on_floor:
		draw_set_transform(Vector2(0, 0), 0.0, Vector2(1.0, 0.35))
		draw_circle(Vector2.ZERO, 7.0, Color(0.35, 0.25, 0.45, 0.25))
	draw_set_transform(Vector2.ZERO, 0.0, _squash)
	var breathe := sin(_idle * 3.0) * 0.6 if _walk == 0.0 else absf(sin(_walk)) * -1.5
	var ink := UI.INK
	# kaki
	var s := sin(_walk) * 2.5
	var fy := -2.0 if on_floor else -4.0
	draw_set_transform(Vector2(-2.5 + s * 0.5, fy), 0.0, _squash * Vector2(1.0, 0.7))
	draw_circle(Vector2.ZERO, 2.4, ink)
	draw_set_transform(Vector2(2.5 - s * 0.5, fy), 0.0, _squash * Vector2(1.0, 0.7))
	draw_circle(Vector2.ZERO, 2.4, ink)
	draw_set_transform(Vector2.ZERO, 0.0, _squash)
	# badan
	var body := Rect2(-5.5, -11 + breathe, 11, 9)
	draw_style_box(UI.box(color.darkened(0.15), 4), Rect2(body.position + Vector2(0, 1), body.size))
	draw_style_box(UI.box(color, 4), body)
	draw_circle(Vector2(0, -6 + breathe), 2.2, color.lightened(0.35))
	# tangan
	var arm_y := -12.0 if velocity.y < 0.0 else -7.0 - sin(_walk) * 1.0
	draw_circle(Vector2(-6.5, arm_y + breathe), 1.9, Color("#ffd9c2"))
	draw_circle(Vector2(6.5, arm_y + breathe), 1.9, Color("#ffd9c2"))
	# kepala = foto bulat
	UI.circle_photo(self, photo, Vector2(0, -20 + breathe), 9.0, color, 1.6)

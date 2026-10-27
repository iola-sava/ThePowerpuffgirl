class_name Player
extends CharacterBody2D
## Scene dasar: res://scenes/player.tscn
## Scene tiap anggota (mewarisi scene dasar, hanya beda gambar):
##   res://scenes/player_1.tscn  – Programmer
##   res://scenes/player_2.tscn  – Artist
##   res://scenes/player_3.tscn  – Project + Level
##
## Gerak: A/D atau panah • Lompat: Spasi / W / panah atas
## Angka gerak bisa diubah di Inspector (klik node Player di player.tscn,
## perubahan otomatis berlaku untuk ketiga karakter).
##
## Node gambar: Visual/Shadow (bayangan) dan Visual/Body (gambar badan penuh).

signal died

@export var speed := 130.0
@export var jump_velocity := -360.0
@export var gravity := 900.0
@export var acceleration := 900.0
@export var max_fall := 480.0

const JUMP_KEYS := [KEY_SPACE, KEY_W, KEY_UP, KEY_K]

## Gambar badan penuh (opsional; kalau kosong pakai gambar di node Body).
var photo: Texture2D:
	set(value):
		photo = value
		if is_node_ready() and value:
			_set_body(value)
var color := Color("#ff8fc1")
var facing := 1.0
var invuln := 0.0
var fall_limit := 100000.0

var _coyote := 0.0
var _buffer := 0.0
var _t := 0.0
var _squash := Vector2.ONE

@onready var camera: Camera2D = $Camera2D
@onready var _visual: Node2D = $Visual
@onready var _shadow: Sprite2D = $Visual/Shadow
@onready var _body: Sprite2D = $Visual/Body


func _ready() -> void:
	_set_body(photo if photo else _body.texture)


func _set_body(tex: Texture2D) -> void:
	if tex == null:
		return
	_body.texture = tex
	_body.offset = Vector2(0, -tex.get_height() / 2.0)  # kaki tepat di titik (0, 0)


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
		_squash = Vector2(0.8, 1.2)
		Fx.burst(get_parent(), global_position, Color.WHITE, 5, 40.0)
	elif velocity.y < 0.0 and not _jump_held():
		velocity.y += gravity * delta * 1.5  # lompat pendek kalau tombol dilepas

	var was_air := not is_on_floor()
	move_and_slide()
	if was_air and is_on_floor():
		_squash = Vector2(1.2, 0.8)
		Fx.burst(get_parent(), global_position, Color.WHITE, 6, 45.0)
	_squash = _squash.lerp(Vector2.ONE, 12.0 * delta)

	if invuln > 0.0:
		invuln -= delta
	if global_position.y > fall_limit:
		died.emit()
	_update_visual(delta)


func _update_visual(delta: float) -> void:
	_t += delta
	var on_floor := is_on_floor()
	var walking := on_floor and absf(velocity.x) > 10.0
	var breathe := 1.0
	if walking:
		_body.position.y = -roundf(absf(sin(_t * 12.0)) * 2.0)  # langkah melompat-lompat kecil
		_body.rotation = sin(_t * 12.0) * 0.06
	else:
		_body.position.y = 0.0
		_body.rotation = 0.0
		breathe = 1.0 + sin(_t * 3.0) * 0.02
	_body.flip_h = facing < 0.0
	_shadow.visible = on_floor
	_visual.scale = _squash * Vector2(1.0, breathe)
	_visual.visible = invuln <= 0.0 or int(invuln * 16.0) % 2 == 1


func bounce() -> void:
	velocity.y = jump_velocity * 0.7


func hit() -> void:
	if invuln <= 0.0:
		died.emit()


func respawn(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	invuln = 1.2

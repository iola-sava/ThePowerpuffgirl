class_name Player
extends CharacterBody2D
## Scene: res://scenes/player.tscn
## Karakter platformer. Kepalanya = foto pixel anggota yang dipilih.
## Gerak: A/D atau panah • Lompat: Spasi / W / panah atas
## Angka gerak bisa diubah di Inspector (klik node Player).
##
## Node gambar (semua bisa dilihat & diklik di editor):
##   Visual/Shadow  – bayangan
##   Visual/Limbs   – kaki & tangan (AnimatedSprite2D: idle, walk, jump)
##   Visual/Shirt   – baju (warnanya diatur lewat modulate)
##   Visual/Head    – cincin + foto wajah

signal died

@export var speed := 130.0
@export var jump_velocity := -360.0
@export var gravity := 900.0
@export var acceleration := 900.0
@export var max_fall := 480.0

const JUMP_KEYS := [KEY_SPACE, KEY_W, KEY_UP, KEY_K]

var photo: Texture2D:
	set(value):
		photo = value
		if is_node_ready() and value:
			_photo_sprite.texture = PhotoUtil.circle(value, 36)
var color := Color("#ff8fc1"):
	set(value):
		color = value
		if is_node_ready():
			_apply_color()
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
@onready var _limbs: AnimatedSprite2D = $Visual/Limbs
@onready var _shirt: Sprite2D = $Visual/Shirt
@onready var _head: Node2D = $Visual/Head
@onready var _ring_color: Sprite2D = $Visual/Head/RingColor
@onready var _photo_sprite: Sprite2D = $Visual/Head/Photo


func _ready() -> void:
	_apply_color()
	if photo:
		_photo_sprite.texture = PhotoUtil.circle(photo, 36)


func _apply_color() -> void:
	_shirt.modulate = color
	_ring_color.modulate = color


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

	if invuln > 0.0:
		invuln -= delta
	if global_position.y > fall_limit:
		died.emit()
	_update_visual(delta)


func _update_visual(delta: float) -> void:
	_t += delta
	var on_floor := is_on_floor()
	var walking := on_floor and absf(velocity.x) > 10.0
	if not on_floor:
		_limbs.play("jump")
	elif walking:
		_limbs.play("walk")
	else:
		_limbs.play("idle")
	# badan & kepala naik-turun (napas / langkah)
	var bob := absf(sin(_t * 12.0)) * -1.5 if walking else sin(_t * 3.0) * 0.6
	_shirt.position.y = -6.0 + bob
	_head.position.y = -20.0 + bob
	_shadow.visible = on_floor
	_visual.scale = _squash
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

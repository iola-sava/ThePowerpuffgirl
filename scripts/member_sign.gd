class_name MemberSign
extends Area2D
## Scene: res://scenes/member_sign.tscn
## Papan anggota: foto bulat + pita peran. Saat disentuh, kartu perkenalan muncul
## dan papan ini menjadi checkpoint.
##
## Node gambar: Pole (tiang), Board/Back (bingkai berwarna), Board/Front,
## Board/RingColor + Board/Photo (foto bulat), Board/RoleLabel (pita peran),
## Board/Heart (belum ditemui), Board/Check (sudah ditemui).

signal reached(post: MemberSign)

var data: Dictionary = {}
var index := 0
var color := Color("#ff8fc1")
var photo: Texture2D
var visited := false:
	set(value):
		visited = value
		if is_node_ready():
			_check.visible = value
			_heart.visible = not value

var _t := 0.0

@onready var _board: Node2D = $Board
@onready var _back: Sprite2D = $Board/Back
@onready var _ring: Sprite2D = $Board/RingColor
@onready var _photo: Sprite2D = $Board/Photo
@onready var _label: Label = $Board/RoleLabel
@onready var _heart: Sprite2D = $Board/Heart
@onready var _check: Sprite2D = $Board/Check


func _ready() -> void:
	_t = index * 1.3
	_back.modulate = color
	_ring.modulate = color
	if photo:
		_photo.texture = PhotoUtil.circle(photo, 40)
		_photo.scale = Vector2(0.5, 0.5)
	if data.has("role"):
		_label.text = str(data["role"])
	_label.add_theme_stylebox_override("normal", _pill_style())
	_label.reset_size()
	_label.position = Vector2(-_label.size.x / 2.0, -24.0)
	visited = visited
	body_entered.connect(_on_body_entered)


func _pill_style() -> StyleBoxFlat:
	var s := UI.box(color, 5)
	s.content_margin_left = 5
	s.content_margin_right = 5
	return s


func _process(delta: float) -> void:
	_t += delta
	_board.position.y = -44.0 + sin(_t * 2.0) * 1.5
	_heart.position.y = -34.0 + sin(_t * 4.0) * 2.0


func _on_body_entered(b: Node2D) -> void:
	if b is Player:
		reached.emit(self)

@tool
class_name MemberSign
extends Area2D
## Scene: res://scenes/member_sign.tscn
## Papan anggota: foto bulat + pita peran. Saat disentuh, kartu perkenalan muncul
## dan papan ini menjadi checkpoint.

signal reached(post: MemberSign)

var data: Dictionary = {}
var index := 0
var color := Color("#ff8fc1")
var photo: Texture2D
var visited := false
var _t := 0.0


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)


func _on_body_entered(b: Node2D) -> void:
	if b is Player:
		reached.emit(self)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var y := -44.0 + sin(_t * 2.0) * 1.5
	# tiang
	draw_style_box(UI.box(Color("#d9a877"), 1), Rect2(-1.5, y + 10, 3, -y - 10))
	# papan + foto bulat
	draw_style_box(UI.box(Color.WHITE, 8, color, 2), Rect2(-14, y - 12, 28, 28))
	UI.circle_photo(self, photo, Vector2(0, y + 2), 10.0, color, 1.2)
	# pita peran
	var role := str(data.get("role", "Peran"))
	var fs := 7
	var w := UI.BOLD.get_string_size(role, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + 10.0
	draw_style_box(UI.box(color, 5), Rect2(-w / 2.0, y - 24, w, 10))
	draw_string(UI.BOLD, Vector2(-w / 2.0, y - 16.5), role, HORIZONTAL_ALIGNMENT_CENTER, w, fs, Color.WHITE)
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

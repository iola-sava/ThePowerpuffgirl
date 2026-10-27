@tool
class_name FinishFlag
extends Area2D
## Scene: res://scenes/finish_flag.tscn
## Bendera finish. Hanya bisa diselesaikan setelah semua anggota ditemui.

signal reached(flag: FinishFlag)

@export var color := Color("#ff8fc1")

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
	draw_style_box(UI.box(Color.WHITE, 2), Rect2(-1.5, -80, 3, 80))
	draw_colored_polygon(UI.star_points(Vector2(0, -84), 6.0, 2.8), UI.SUN)
	var pts := PackedVector2Array()
	for i in 8:
		pts.append(Vector2(2.0 + i * 4.0, -78 + sin(_t * 6.0 - i * 0.7) * 1.5))
	for i in range(7, -1, -1):
		pts.append(Vector2(2.0 + i * 4.0, -60 + sin(_t * 6.0 - i * 0.7) * 1.5))
	draw_colored_polygon(pts, color)
	UI.heart(self, Vector2(16, -70 + sin(_t * 6.0 - 3.5) * 1.5), 3.2, Color.WHITE)
	draw_style_box(UI.box(Color("#ff9fc9"), 3), Rect2(-7, -5, 15, 5))

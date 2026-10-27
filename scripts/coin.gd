@tool
class_name Coin
extends Area2D
## Scene: res://scenes/coin.tscn
## Bintang yang bisa dikumpulkan pemain.

signal collected(coin: Coin)

var _t := 0.0
var _taken := false


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_t = randf() * 3.0
	body_entered.connect(_on_body_entered)


func _on_body_entered(b: Node2D) -> void:
	if _taken or not (b is Player):
		return
	_taken = true
	collected.emit(self)
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
	var c := Vector2(0, -8 + sin(_t * 3.0) * 1.5)
	var rot := -PI / 2.0 + sin(_t * 2.0) * 0.25
	draw_colored_polygon(UI.star_points(c + Vector2(0, 1), 7.0, 3.4, rot), Color("#f2a93b"))
	draw_colored_polygon(UI.star_points(c, 6.5, 3.0, rot), UI.SUN)
	draw_circle(c + Vector2(-1.5, -1.5), 1.2, Color(1, 1, 1, 0.8))

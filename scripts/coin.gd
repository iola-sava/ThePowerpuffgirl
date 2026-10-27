class_name Coin
extends Area2D
## Scene: res://scenes/coin.tscn
## Bintang yang bisa dikumpulkan pemain. Gambar: node Sprite (star.png).

signal collected(coin: Coin)

var _t := 0.0
var _taken := false

@onready var _sprite: Sprite2D = $Sprite


func _ready() -> void:
	_t = randf() * 3.0
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_t += delta
	_sprite.position.y = -8.0 + sin(_t * 3.0) * 1.5
	_sprite.rotation = sin(_t * 2.0) * 0.25


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

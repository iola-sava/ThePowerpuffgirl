class_name Enemy
extends CharacterBody2D
## Scene: res://scenes/enemy.tscn
## Musuh blob yang mondar-mandir. Injak dari atas untuk mengalahkannya.
## Kalau tersentuh dari samping, pemain kembali ke checkpoint.
## Gambar: node Sprite (AnimatedSprite2D: wobble, dead).

@export var speed := 35.0
@export var gravity := 900.0

var dir := -1.0
var dead := false

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _ray: RayCast2D = $EdgeRay
@onready var _hitbox: Area2D = $Hitbox


func _ready() -> void:
	_hitbox.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if dead:
		return
	velocity.y = minf(velocity.y + gravity * delta, 480.0)
	velocity.x = dir * speed
	_ray.position = Vector2(dir * 7.0, -2)
	move_and_slide()
	if is_on_wall() or (is_on_floor() and not _ray.is_colliding()):
		dir *= -1.0
	_sprite.flip_h = dir > 0.0


func _on_body_entered(b: Node2D) -> void:
	if dead or not (b is Player):
		return
	var p := b as Player
	if p.velocity.y > 0.0 and p.global_position.y < global_position.y - 4.0:
		dead = true
		p.bounce()
		_sprite.play("dead")
		Fx.burst(get_parent(), global_position + Vector2(0, -5), Color("#c3a6ff"), 10, 70.0, Fx.Shape.SPARKLE, 2.0)
		set_deferred("collision_layer", 0)
		_hitbox.set_deferred("monitoring", false)
		var tw := create_tween()
		tw.tween_interval(0.4)
		tw.tween_callback(queue_free)
	else:
		p.hit()

class_name Enemy
extends CharacterBody2D
## Musuh blob yang mondar-mandir. Injak dari atas untuk mengalahkannya.

const SPEED := 35.0
const GRAVITY := 900.0

var dir := -1.0
var dead := false
var _t := 0.0
var _ray: RayCast2D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(12, 10)
	cs.shape = r
	cs.position = Vector2(0, -5)
	add_child(cs)

	_ray = RayCast2D.new()
	_ray.target_position = Vector2(0, 10)
	_ray.collision_mask = 1
	add_child(_ray)

	var hitbox := Area2D.new()
	hitbox.collision_layer = 0
	hitbox.collision_mask = 2
	var hs := CollisionShape2D.new()
	var hr := RectangleShape2D.new()
	hr.size = Vector2(14, 12)
	hs.shape = hr
	hs.position = Vector2(0, -6)
	hitbox.add_child(hs)
	add_child(hitbox)
	hitbox.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_t += delta
	queue_redraw()
	if dead:
		return
	velocity.y = minf(velocity.y + GRAVITY * delta, 480.0)
	velocity.x = dir * SPEED
	_ray.position = Vector2(dir * 7.0, -2)
	move_and_slide()
	if is_on_wall() or (is_on_floor() and not _ray.is_colliding()):
		dir *= -1.0


func _on_body_entered(b: Node2D) -> void:
	if dead or not (b is Player):
		return
	var p := b as Player
	if p.velocity.y > 0.0 and p.global_position.y < global_position.y - 4.0:
		dead = true
		p.bounce()
		set_deferred("collision_layer", 0)
		var tw := create_tween()
		tw.tween_interval(0.4)
		tw.tween_callback(queue_free)
	else:
		p.hit()


func _draw() -> void:
	var body := Color("#9b5de5")
	if dead:
		draw_rect(Rect2(-7, -3, 14, 3), body)
		return
	var sq := 1.0 + sin(_t * 8.0) * 0.08
	draw_set_transform(Vector2(0, -5), 0.0, Vector2(1.0 / sq, sq))
	draw_circle(Vector2.ZERO, 6.5, body)
	draw_circle(Vector2(-2, -3), 2.0, body.lightened(0.3))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for ex in [-2.5, 2.5]:
		draw_circle(Vector2(ex + dir, -7), 2.0, Color.WHITE)
		draw_rect(Rect2(ex + dir * 2.0 - 0.75, -7.5, 1.5, 2), Color("#1d1b2e"))

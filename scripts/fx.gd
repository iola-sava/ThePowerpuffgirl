class_name Fx
extends Node2D
## Efek partikel kecil: debu saat mendarat, kilau saat ambil bintang, dll.

enum Shape { DOT, SPARKLE, HEART }

var _parts: Array = []
var _shape := Shape.DOT


static func burst(parent: Node, pos: Vector2, col: Color, count := 8, speed := 60.0,
		shape := Shape.DOT, size := 2.5) -> void:
	var fx := Fx.new()
	fx.position = pos
	fx._shape = shape
	for i in count:
		var a := randf() * TAU if shape != Shape.DOT else PI + randf() * PI
		fx._parts.append({
			"p": Vector2.ZERO,
			"v": Vector2(cos(a), sin(a)) * speed * randf_range(0.5, 1.0),
			"life": 1.0,
			"size": size * randf_range(0.7, 1.2),
			"col": col,
		})
	parent.add_child(fx)


func _process(delta: float) -> void:
	var alive := false
	for p in _parts:
		p.p += p.v * delta
		p.v *= 0.9
		p.life -= delta * 2.2
		if p.life > 0.0:
			alive = true
	if not alive:
		queue_free()
	queue_redraw()


func _draw() -> void:
	for p in _parts:
		if p.life <= 0.0:
			continue
		var col: Color = p.col
		col.a = p.life
		var s: float = p.size * (0.5 + p.life * 0.5)
		match _shape:
			Shape.DOT:
				draw_circle(p.p, s, col)
			Shape.SPARKLE:
				UI.sparkle(self, p.p, s * 1.6, col)
			Shape.HEART:
				UI.heart(self, p.p, s, col)

class_name SelectScreen
extends CanvasLayer
## Layar pilih karakter: tampilkan semua anggota, pilih dengan kiri/kanan.

signal chosen(index: int)

var team_name := ""
var members: Array = []
var photos: Array = []
var colors: Array = []
var sel := 0
var _t := 0.0
var _canvas: Control


func _init() -> void:
	layer = 20


func _ready() -> void:
	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.draw.connect(_on_draw)
	add_child(_canvas)


func _process(delta: float) -> void:
	_t += delta
	_canvas.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not (event is InputEventKey and event.pressed and not event.echo):
		return
	var k: int = event.physical_keycode
	var n := maxi(members.size(), 1)
	if k in [KEY_LEFT, KEY_A]:
		sel = posmod(sel - 1, n)
	elif k in [KEY_RIGHT, KEY_D]:
		sel = posmod(sel + 1, n)
	elif k in [KEY_E, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
		visible = false
		chosen.emit(sel)
	get_viewport().set_input_as_handled()


func _on_draw() -> void:
	var c := _canvas
	var font := ThemeDB.fallback_font
	var vp := c.get_viewport_rect().size
	c.draw_rect(Rect2(Vector2.ZERO, vp), Color(0.07, 0.06, 0.12, 0.88))
	c.draw_string(font, Vector2(0, 58), "PILIH KARAKTER", HORIZONTAL_ALIGNMENT_CENTER, vp.x, 24, Color.WHITE)
	c.draw_string(font, Vector2(0, 82), team_name, HORIZONTAL_ALIGNMENT_CENTER, vp.x, 12, Color("#ffd23f"))

	var n := members.size()
	var cw := 150.0
	var gap := 20.0
	var x0 := (vp.x - (n * cw + (n - 1) * gap)) / 2.0
	for i in n:
		var m: Dictionary = members[i]
		var col: Color = colors[i]
		var is_sel := i == sel
		var y := 104.0 - (4.0 + sin(_t * 5.0) * 2.0 if is_sel else 0.0)
		var r := Rect2(x0 + i * (cw + gap), y, cw, 186)
		c.draw_rect(r, Color("#1d1b2e"))
		c.draw_rect(r, col if is_sel else Color("#4a4566"), false, 3.0 if is_sel else 1.0)
		c.draw_rect(Rect2(r.position + Vector2(33, 16), Vector2(84, 84)), col)
		c.draw_texture_rect(photos[i], Rect2(r.position + Vector2(35, 18), Vector2(80, 80)), false)
		c.draw_string(font, r.position + Vector2(6, 124), str(m.get("name", "")),
			HORIZONTAL_ALIGNMENT_CENTER, cw - 12, 12, Color.WHITE)
		c.draw_string(font, r.position + Vector2(6, 142), "NIM " + str(m.get("nim", "")),
			HORIZONTAL_ALIGNMENT_CENTER, cw - 12, 9, Color("#b8b3d6"))
		c.draw_string(font, r.position + Vector2(6, 164), str(m.get("role", "")),
			HORIZONTAL_ALIGNMENT_CENTER, cw - 12, 11, col)
		if is_sel:
			var tx := r.position.x + cw / 2.0
			var ty := r.end.y + 8.0
			c.draw_colored_polygon(PackedVector2Array([Vector2(tx, ty), Vector2(tx - 6, ty + 8), Vector2(tx + 6, ty + 8)]), col)

	c.draw_string(font, Vector2(0, 340), "A / D  atau  Kiri / Kanan: pilih      •      E / Spasi: mulai",
		HORIZONTAL_ALIGNMENT_CENTER, vp.x, 11, Color("#b8b3d6"))

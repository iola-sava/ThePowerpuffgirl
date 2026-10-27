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
	var vp := c.get_viewport_rect().size
	c.draw_rect(Rect2(Vector2.ZERO, vp), Color(1.0, 0.88, 0.94, 0.82))
	for i in 10:
		var p := Vector2(fposmod(i * 71.0 + _t * 12.0, vp.x), fmod(i * 41.0, 90.0) + 10.0)
		UI.sparkle(c, p, 3.0 + i % 3, Color(1, 1, 1, 0.5 + 0.5 * sin(_t * 3.0 + i)))

	c.draw_string_outline(UI.BOLD, Vector2(0, 56), "PILIH KARAKTER", HORIZONTAL_ALIGNMENT_CENTER, vp.x, 26, 8, Color.WHITE)
	c.draw_string(UI.BOLD, Vector2(0, 56), "PILIH KARAKTER", HORIZONTAL_ALIGNMENT_CENTER, vp.x, 26, UI.INK)
	c.draw_string(UI.BOLD, Vector2(0, 80), team_name, HORIZONTAL_ALIGNMENT_CENTER, vp.x, 13, UI.PINK)

	var n := members.size()
	var cw := 150.0
	var gap := 22.0
	var x0 := (vp.x - (n * cw + (n - 1) * gap)) / 2.0
	for i in n:
		var m: Dictionary = members[i]
		var col: Color = colors[i]
		var is_sel := i == sel
		var lift := (6.0 + sin(_t * 5.0) * 2.0) if is_sel else 0.0
		var r := Rect2(x0 + i * (cw + gap), 100.0 - lift, cw, 196)
		c.draw_style_box(UI.box(Color(0.36, 0.29, 0.43, 0.15), 18), Rect2(r.position + Vector2(0, 5 + lift), r.size))
		c.draw_style_box(UI.box(UI.CREAM, 18, col if is_sel else Color.WHITE, 4 if is_sel else 2), r)
		# gambar badan penuh, berdiri di atas lingkaran warna anggota
		c.draw_circle(r.position + Vector2(cw / 2.0, 66), 42.0, Color(col, 0.22))
		var tex: Texture2D = photos[i]
		var sz := tex.get_size() * 2.0
		var feet := r.position + Vector2(cw / 2.0, 108)
		c.draw_set_transform(feet + Vector2(0, 1), 0.0, Vector2(1.0, 0.3))
		c.draw_circle(Vector2.ZERO, 12.0, Color(0.36, 0.29, 0.43, 0.25))
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		var bob := -absf(sin(_t * 8.0)) * 3.0 if is_sel else 0.0
		c.draw_texture_rect(tex, Rect2(feet + Vector2(-sz.x / 2.0, -sz.y + bob), sz), false)
		c.draw_string(UI.BOLD, r.position + Vector2(6, 128), str(m.get("name", "")),
			HORIZONTAL_ALIGNMENT_CENTER, cw - 12, 13, UI.INK)
		c.draw_string(UI.BODY, r.position + Vector2(6, 146), "NIM " + str(m.get("nim", "")),
			HORIZONTAL_ALIGNMENT_CENTER, cw - 12, 9, UI.MUTED)
		var role := str(m.get("role", ""))
		var w := UI.BOLD.get_string_size(role, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x + 18.0
		var pill := Rect2(r.position + Vector2((cw - w) / 2.0, 158), Vector2(w, 20))
		c.draw_style_box(UI.box(col, 10), pill)
		c.draw_string(UI.BOLD, pill.position + Vector2(0, 14), role, HORIZONTAL_ALIGNMENT_CENTER, w, 10, Color.WHITE)
		if is_sel:
			UI.heart(c, Vector2(r.position.x + cw / 2.0, r.end.y + 14 + lift), 6.0, col)

	c.draw_string(UI.BODY, Vector2(0, 346), "A / D  atau  Kiri / Kanan: pilih      •      E / Spasi: mulai",
		HORIZONTAL_ALIGNMENT_CENTER, vp.x, 11, UI.INK)

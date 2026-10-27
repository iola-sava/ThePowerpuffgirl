class_name InfoPopup
extends CanvasLayer
## Popup kartu anggota / pesan judul & ending.

var _root: Control
var _panel: PanelContainer
var _style: StyleBoxFlat
var _photo: TextureRect
var _photo_frame: PanelContainer
var _photo_style: StyleBoxFlat
var _title: Label
var _sub: Label
var _body: Label
var _hint: Label


func _init() -> void:
	layer = 10


func _ready() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	var dim := ColorRect.new()
	dim.color = Color(0.36, 0.29, 0.43, 0.45)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(dim)

	_panel = PanelContainer.new()
	_style = UI.box(UI.CREAM, 16, UI.PINK, 4)
	_style.set_content_margin_all(16)
	_style.shadow_color = Color(0.36, 0.29, 0.43, 0.3)
	_style.shadow_size = 8
	_style.shadow_offset = Vector2(0, 4)
	_panel.add_theme_stylebox_override("panel", _style)
	_root.add_child(_panel)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)
	_panel.add_child(hbox)

	_photo_frame = PanelContainer.new()
	_photo_style = UI.box(Color.WHITE, 12, UI.PINK, 3)
	_photo_style.set_content_margin_all(4)
	_photo_frame.add_theme_stylebox_override("panel", _photo_style)
	_photo_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(_photo_frame)
	_photo = TextureRect.new()
	_photo.custom_minimum_size = Vector2(112, 112)
	_photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_photo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_photo_frame.add_child(_photo)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)

	_title = _make_label(18, UI.INK, UI.BOLD)
	_sub = _make_label(12, UI.PINK, UI.BOLD)
	_body = _make_label(11, UI.INK)
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.custom_minimum_size = Vector2(260, 0)
	_hint = _make_label(10, UI.MUTED)
	for l in [_title, _sub, _body, _hint]:
		vbox.add_child(l)

	visible = false


func _make_label(font_size: int, col: Color, font: Font = UI.BODY) -> Label:
	var l := Label.new()
	l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", col)
	return l


func show_member(d: Dictionary, photo: Texture2D, col: Color, num: int, total: int) -> void:
	_style.border_color = col
	_photo_style.border_color = col
	_photo_frame.visible = true
	_photo.texture = photo
	_title.text = str(d.get("name", ""))
	_sub.visible = true
	_sub.text = "NIM %s   •   %s" % [str(d.get("nim", "")), str(d.get("role", ""))]
	_sub.add_theme_color_override("font_color", col)
	_body.text = str(d.get("fact", ""))
	_hint.text = "Anggota %d/%d   —   tekan E untuk lanjut" % [num, total]
	_open()


func show_message(title: String, body: String, col: Color, hint: String) -> void:
	_style.border_color = col
	_photo_frame.visible = false
	_title.text = title
	_sub.visible = false
	_body.text = body
	_hint.text = hint
	_open()


func hide_popup() -> void:
	visible = false


func _open() -> void:
	visible = true
	_center.call_deferred()


func _center() -> void:
	_panel.reset_size()
	var vp := get_viewport().get_visible_rect().size
	_panel.position = ((vp - _panel.size) / 2.0).round()
	_panel.pivot_offset = _panel.size / 2.0
	_panel.scale = Vector2(0.85, 0.85)
	create_tween().tween_property(_panel, "scale", Vector2.ONE, 0.18) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

extends Control

## Giao diện nhỏ xem 5 kỹ năng câu cá tu đạo và điểm mở khóa theo cảnh giới.
## Presentation thuần: đọc qua FishingAPI.get_skills_info() và nghe EventBus BREAKTHROUGH_SUCCESS.

const CultivationEventsContract: Script = preload("res://core/contracts/cultivation_events.gd")

var _fishing_api: RefCounted
var _is_open: bool = false
var _toggle_btn: Button
var _panel: PanelContainer
var _summary_label: Label
var _list_vbox: VBoxContainer


func _ready() -> void:
	_setup_ui()
	_connect_events()
	_update_view()


func setup(fishing_api: RefCounted) -> void:
	_fishing_api = fishing_api
	_update_view()


func toggle_open() -> void:
	set_open(not _is_open)


func set_open(open: bool) -> void:
	if open == _is_open:
		return
	_is_open = open
	if _panel != null:
		_panel.visible = _is_open
	if _toggle_btn != null:
		_toggle_btn.text = "Đóng Kỹ Năng" if _is_open else "Kỹ Năng"
	if _is_open:
		_update_view()


func _setup_ui() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_toggle_btn = Button.new()
	_toggle_btn.name = "BtnToggleSkills"
	_toggle_btn.text = "Kỹ Năng"
	_toggle_btn.custom_minimum_size = Vector2(96.0, 34.0)
	_toggle_btn.anchor_left = 0.0
	_toggle_btn.anchor_top = 0.0
	_toggle_btn.offset_left = 16.0
	_toggle_btn.offset_top = 96.0
	_toggle_btn.pressed.connect(toggle_open)
	add_child(_toggle_btn)

	_panel = PanelContainer.new()
	_panel.name = "SkillPanel"
	_panel.visible = false
	_panel.anchor_left = 0.5
	_panel.anchor_top = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_bottom = 0.5
	_panel.offset_left = -220.0
	_panel.offset_top = -130.0
	_panel.offset_right = 220.0
	_panel.offset_bottom = 130.0

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.11, 0.16, 0.95)
	style.border_color = Color(0.45, 0.78, 0.95, 0.85)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(10.0)
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	_panel.add_child(vbox)

	var header := HBoxContainer.new()
	vbox.add_child(header)
	var title := Label.new()
	title.text = "KỸ NĂNG CÂU CÁ TU ĐẠO"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 14)
	header.add_child(title)

	var close_btn := Button.new()
	close_btn.text = " X "
	close_btn.pressed.connect(func() -> void: set_open(false))
	header.add_child(close_btn)

	_summary_label = Label.new()
	_summary_label.add_theme_font_size_override("font_size", 12)
	_summary_label.add_theme_color_override("font_color", Color(0.95, 0.88, 0.55))
	vbox.add_child(_summary_label)

	_list_vbox = VBoxContainer.new()
	_list_vbox.add_theme_constant_override("separation", 5)
	vbox.add_child(_list_vbox)


func _connect_events() -> void:
	var eb: Node = get_node_or_null("/root/EventBus")
	if eb != null and eb.has_method("subscribe"):
		eb.call("subscribe", CultivationEventsContract.BREAKTHROUGH_SUCCESS, func(_p: Dictionary) -> void: _update_view())


func _update_view() -> void:
	if _list_vbox == null or _fishing_api == null:
		return
	for c in _list_vbox.get_children():
		c.queue_free()

	var info: Dictionary = _fishing_api.call("get_skills_info") as Dictionary
	var realm: int = int(info.get("realm", 0))
	var skills: Array = info.get("skills", []) as Array
	var unlocked_count: int = 0
	for s in skills:
		if bool((s as Dictionary).get("unlocked", false)):
			unlocked_count += 1
	_summary_label.text = "Điểm mở khóa (Cảnh giới %d): %d / %d kỹ năng" % [realm, unlocked_count, skills.size()]

	for s in skills:
		var d: Dictionary = s as Dictionary
		var ok: bool = bool(d.get("unlocked", false))
		var lbl := Label.new()
		var status: String = "[Đã mở]" if ok else "[Khóa - CG %d]" % int(d.get("req_realm", 0))
		lbl.text = "%s %s: %s" % [status, str(d.get("name", "")), str(d.get("effect", ""))]
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color(0.45, 0.95, 0.65) if ok else Color(0.65, 0.68, 0.72))
		_list_vbox.add_child(lbl)

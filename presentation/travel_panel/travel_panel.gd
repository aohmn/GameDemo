## TravelPanel: bang chon diem den khi Player buoc vao cong.
## Chi lang nghe GATE_ENTERED / GATE_EXITED; chi phat DESTINATION_CHOSEN va INPUT_LOCK_REQUESTED.
## KHONG chua logic chuyen map (Bootstrap xu ly).
extends Control
class_name TravelPanel

## Mau nen bang
const BG_COLOR := Color(0.08, 0.10, 0.14, 0.92)
const BTN_COLOR := Color(0.18, 0.42, 0.78, 1.0)
const BTN_LOCKED_COLOR := Color(0.35, 0.35, 0.40, 1.0)
const BTN_CANCEL_COLOR := Color(0.52, 0.18, 0.18, 1.0)
const TEXT_COLOR := Color(1.0, 0.97, 0.90, 1.0)
const TITLE_COLOR := Color(1.0, 0.92, 0.45, 1.0)

## Chieu cao toi thieu nut cam ung (AGENTS §9)
const BTN_HEIGHT: float = 56.0
const BTN_MIN_WIDTH: float = 180.0
const PANEL_WIDTH: float = 320.0
const PADDING: float = 16.0
const ROW_GAP: float = 10.0

var _current_gate_id: String = ""
var _visible_once: bool = false

var _panel: PanelContainer
var _vbox: VBoxContainer
var _title: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	hide()
	EventBus.subscribe(DestinationEvents.GATE_ENTERED, _on_gate_entered)
	EventBus.subscribe(DestinationEvents.GATE_EXITED, _on_gate_exited)


func _exit_tree() -> void:
	if EventBus != null:
		EventBus.unsubscribe(DestinationEvents.GATE_ENTERED, _on_gate_entered)
		EventBus.unsubscribe(DestinationEvents.GATE_EXITED, _on_gate_exited)


func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	var style := StyleBoxFlat.new()
	style.bg_color = BG_COLOR
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.content_margin_left = PADDING
	style.content_margin_right = PADDING
	style.content_margin_top = PADDING
	style.content_margin_bottom = PADDING
	_panel.add_theme_stylebox_override("panel", style)
	_panel.position = Vector2(0.0, 0.0)
	add_child(_panel)

	_vbox = VBoxContainer.new()
	_vbox.add_theme_constant_override("separation", int(ROW_GAP))
	_panel.add_child(_vbox)

	_title = Label.new()
	_title.text = "Chon diem den"
	_title.add_theme_color_override("font_color", TITLE_COLOR)
	_title.add_theme_font_size_override("font_size", 22)
	_vbox.add_child(_title)


func _on_gate_entered(payload: Dictionary) -> void:
	var gate_id: String = str(payload.get("gate_id", ""))
	var destinations: Array = payload.get("destinations", [])
	if _visible_once and gate_id == _current_gate_id:
		return
	_current_gate_id = gate_id
	_visible_once = true
	_populate(destinations)
	_lock_input(true)
	show()


func _on_gate_exited(payload: Dictionary) -> void:
	var gate_id: String = str(payload.get("gate_id", ""))
	if gate_id != _current_gate_id:
		return
	_hide_panel()


func _populate(destinations: Array) -> void:
	# Xoa hang cu (giu lai _title)
	for child: Node in _vbox.get_children():
		if child != _title:
			child.queue_free()

	for dest_val: Variant in destinations:
		if not (dest_val is Dictionary):
			continue
		var dest: Dictionary = dest_val as Dictionary
		var unlocked: bool = bool(dest.get("unlocked", true))
		var display_name: String = str(dest.get("display_name", "???"))

		var row := HBoxContainer.new()
		_vbox.add_child(row)

		var name_lbl := Label.new()
		name_lbl.text = display_name
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_color_override("font_color", TEXT_COLOR)
		name_lbl.add_theme_font_size_override("font_size", 18)
		row.add_child(name_lbl)

		var btn := Button.new()
		btn.text = "Di" if unlocked else "Chua mo"
		btn.custom_minimum_size = Vector2(BTN_MIN_WIDTH, BTN_HEIGHT)
		var btn_style := StyleBoxFlat.new()
		btn_style.bg_color = BTN_COLOR if unlocked else BTN_LOCKED_COLOR
		btn_style.corner_radius_top_left = 8
		btn_style.corner_radius_top_right = 8
		btn_style.corner_radius_bottom_left = 8
		btn_style.corner_radius_bottom_right = 8
		btn.add_theme_stylebox_override("normal", btn_style)
		btn.add_theme_color_override("font_color", TEXT_COLOR)
		btn.add_theme_font_size_override("font_size", 18)
		btn.disabled = not unlocked
		if unlocked:
			var dest_id: String = str(dest.get("id", ""))
			var scene_path: String = str(dest.get("scene_path", ""))
			var spawn_id: String = str(dest.get("spawn_id", ""))
			btn.pressed.connect(_on_destination_chosen.bind(_current_gate_id, dest_id, scene_path, spawn_id))
		row.add_child(btn)

	# Nut "O lai"
	var separator := HSeparator.new()
	_vbox.add_child(separator)

	var cancel_btn := Button.new()
	cancel_btn.text = "O lai"
	cancel_btn.custom_minimum_size = Vector2(BTN_MIN_WIDTH, BTN_HEIGHT)
	var cancel_style := StyleBoxFlat.new()
	cancel_style.bg_color = BTN_CANCEL_COLOR
	cancel_style.corner_radius_top_left = 8
	cancel_style.corner_radius_top_right = 8
	cancel_style.corner_radius_bottom_left = 8
	cancel_style.corner_radius_bottom_right = 8
	cancel_btn.add_theme_stylebox_override("normal", cancel_style)
	cancel_btn.add_theme_color_override("font_color", TEXT_COLOR)
	cancel_btn.add_theme_font_size_override("font_size", 18)
	cancel_btn.pressed.connect(_hide_panel)
	_vbox.add_child(cancel_btn)

	# Can chinh bang vao giua man hinh
	await get_tree().process_frame
	_center_panel()


func _center_panel() -> void:
	var vp_size: Vector2 = get_viewport_rect().size
	_panel.size = Vector2(PANEL_WIDTH, _vbox.size.y + PADDING * 2.0 + 10.0)
	_panel.position = (vp_size - _panel.size) * 0.5


func _on_destination_chosen(gate_id: String, dest_id: String,
		scene_path: String, spawn_id: String) -> void:
	_hide_panel()
	EventBus.emit_event(DestinationEvents.DESTINATION_CHOSEN, {
		"gate_id": gate_id,
		"destination_id": dest_id,
		"scene_path": scene_path,
		"spawn_id": spawn_id,
	})


func _hide_panel() -> void:
	_visible_once = false
	_lock_input(false)
	hide()


func _lock_input(locked: bool) -> void:
	EventBus.emit_event(DestinationEvents.INPUT_LOCK_REQUESTED, {"locked": locked})

extends Control

## Equipment UI (Pháp Bảo & Trang Bị).
## Hiển thị 5 vị trí trang bị, chỉ số tổng hợp và danh sách pháp bảo khả dụng.
## Presentation thuần: chỉ nghe EventBus và phát tín hiệu cho Bootstrap / Coordinator.

const EquipmentEventsContract: Script = preload("res://core/contracts/equipment_events.gd")

signal equip_requested(slot: String, item_id: String)
signal unequip_requested(slot: String)

const SLOT_NAMES: Dictionary = {
	"rod": "Cần Câu",
	"line": "Dây Cước",
	"bait": "Mồi Câu",
	"relic_1": "Bảo Vật 1",
	"relic_2": "Bảo Vật 2"
}

const ITEM_NAMES: Dictionary = {
	"rod_truc_nhiem": "Cần Thanh Trúc",
	"rod_carbon_bien_sau": "Cần Huyền Thiết",
	"line_cuoc_bach_lien": "Cước Bạch Liên",
	"bait_linh_trung": "Mồi Linh Trùng",
	"relic_dinh_hai_chau": "Định Hải Châu"
}

const CANDIDATES: Dictionary = {
	"rod": ["rod_truc_nhiem", "rod_carbon_bien_sau"],
	"line": ["line_cuoc_bach_lien"],
	"bait": ["bait_linh_trung"],
	"relic_1": ["relic_dinh_hai_chau"],
	"relic_2": ["relic_dinh_hai_chau"]
}

var _equipment_api: RefCounted
var _is_open: bool = false
var _selected_slot: String = "rod"

var _panel: PanelContainer
var _toggle_btn: Button
var _slots_vbox: VBoxContainer
var _items_vbox: VBoxContainer
var _stats_label: Label


func _ready() -> void:
	_setup_ui()
	_connect_events()
	_update_view()


func setup(api: RefCounted) -> void:
	_equipment_api = api
	_update_view()


func toggle_open() -> void:
	_is_open = not _is_open
	if _panel != null:
		_panel.visible = _is_open
	if _toggle_btn != null:
		_toggle_btn.text = "Đóng Trang Bị" if _is_open else "Trang Bị"
	if _is_open:
		_update_view()


func _setup_ui() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_toggle_btn = Button.new()
	_toggle_btn.name = "BtnToggleEquipment"
	_toggle_btn.text = "Trang Bị"
	_toggle_btn.custom_minimum_size = Vector2(90.0, 36.0)
	_toggle_btn.anchor_left = 1.0
	_toggle_btn.anchor_top = 0.0
	_toggle_btn.anchor_right = 1.0
	_toggle_btn.anchor_bottom = 0.0
	_toggle_btn.offset_left = -110.0
	_toggle_btn.offset_top = 58.0
	_toggle_btn.offset_right = -20.0
	_toggle_btn.offset_bottom = 94.0
	_toggle_btn.pressed.connect(toggle_open)
	add_child(_toggle_btn)

	_panel = PanelContainer.new()
	_panel.visible = false
	_panel.anchor_left = 0.5
	_panel.anchor_top = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_bottom = 0.5
	_panel.offset_left = -250.0
	_panel.offset_top = -140.0
	_panel.offset_right = 250.0
	_panel.offset_bottom = 140.0

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.11, 0.15, 0.95)
	style.border_color = Color(0.75, 0.65, 0.35, 0.8)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(10.0)
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 6)
	_panel.add_child(main_vbox)

	var header := HBoxContainer.new()
	main_vbox.add_child(header)

	var title := Label.new()
	title.text = "PHÁP BẢO & TRANG BỊ"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 15)
	header.add_child(title)

	var close_btn := Button.new()
	close_btn.text = " X "
	close_btn.pressed.connect(func(): toggle_open())
	header.add_child(close_btn)

	_stats_label = Label.new()
	_stats_label.add_theme_font_size_override("font_size", 12)
	_stats_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.6))
	main_vbox.add_child(_stats_label)

	var content_hbox := HBoxContainer.new()
	content_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_theme_constant_override("separation", 10)
	main_vbox.add_child(content_hbox)

	var left_scroll := ScrollContainer.new()
	left_scroll.custom_minimum_size = Vector2(170.0, 140.0)
	content_hbox.add_child(left_scroll)

	_slots_vbox = VBoxContainer.new()
	_slots_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_slots_vbox.add_theme_constant_override("separation", 4)
	left_scroll.add_child(_slots_vbox)

	var right_scroll := ScrollContainer.new()
	right_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_scroll.custom_minimum_size = Vector2(280.0, 140.0)
	content_hbox.add_child(right_scroll)

	_items_vbox = VBoxContainer.new()
	_items_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_items_vbox.add_theme_constant_override("separation", 4)
	right_scroll.add_child(_items_vbox)


func _connect_events() -> void:
	var eb: Node = get_node_or_null("/root/EventBus")
	if eb != null and eb.has_method("subscribe"):
		eb.call("subscribe", EquipmentEventsContract.ITEM_EQUIPPED, func(_p): _update_view())
		eb.call("subscribe", EquipmentEventsContract.ITEM_UNEQUIPPED, func(_p): _update_view())
		eb.call("subscribe", EquipmentEventsContract.STATS_UPDATED, func(_p): _update_view())


func _update_view() -> void:
	if _slots_vbox == null or _items_vbox == null:
		return
	for c in _slots_vbox.get_children():
		c.queue_free()
	for c in _items_vbox.get_children():
		c.queue_free()

	var equipped: Dictionary = {}
	var stats: Dictionary = {}
	if _equipment_api != null:
		if _equipment_api.has_method("get_all_equipped"):
			equipped = _equipment_api.call("get_all_equipped") as Dictionary
		if _equipment_api.has_method("calculate_total_stats"):
			stats = _equipment_api.call("calculate_total_stats") as Dictionary

	var t_pull: float = float(stats.get("total_pull_force_bonus", 0.0))
	var t_tens: float = float(stats.get("total_max_tension_bonus", 0.0))
	var t_ctrl: float = float(stats.get("total_control_power_bonus", 0.0))
	var t_qi: float = float(stats.get("total_qi_absorption_bonus", 0.0))
	_stats_label.text = "Lực kéo: +%0.1f | Tải dây: +%0.1f | Khống chế: +%0.2f | Hấp thu tu vi: +%0.0f%%" % [t_pull, t_tens, t_ctrl, t_qi]

	for s_key in SLOT_NAMES.keys():
		var s_name: String = str(SLOT_NAMES[s_key])
		var cur_id: String = str(equipped.get(s_key, ""))
		var cur_name: String = str(ITEM_NAMES.get(cur_id, "(Trống)")) if not cur_id.is_empty() else "(Trống)"
		var btn := Button.new()
		btn.text = "%s: %s" % [s_name, cur_name]
		btn.add_theme_font_size_override("font_size", 12)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if s_key == _selected_slot:
			btn.modulate = Color(0.7, 1.0, 0.8)
		btn.pressed.connect(func():
			_selected_slot = s_key
			_update_view()
		)
		_slots_vbox.add_child(btn)

	var cur_equipped_item: String = str(equipped.get(_selected_slot, ""))
	var candidate_list: Array = CANDIDATES.get(_selected_slot, []) as Array

	var slot_title := Label.new()
	slot_title.text = "Vị trí [%s] — %s" % [str(SLOT_NAMES.get(_selected_slot, "")), "Đang dùng: " + str(ITEM_NAMES.get(cur_equipped_item, "Chưa có"))]
	slot_title.add_theme_font_size_override("font_size", 13)
	_items_vbox.add_child(slot_title)

	for item_id in candidate_list:
		var row := HBoxContainer.new()
		_items_vbox.add_child(row)

		var name_lbl := Label.new()
		name_lbl.text = str(ITEM_NAMES.get(item_id, item_id))
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_font_size_override("font_size", 12)
		row.add_child(name_lbl)

		var act_btn := Button.new()
		act_btn.custom_minimum_size = Vector2(75.0, 28.0)
		act_btn.add_theme_font_size_override("font_size", 11)

		if cur_equipped_item == item_id:
			act_btn.text = "Tháo Ra"
			act_btn.pressed.connect(func(): unequip_requested.emit(_selected_slot))
		else:
			act_btn.text = "Trang Bị"
			act_btn.pressed.connect(func(): equip_requested.emit(_selected_slot, str(item_id)))
		row.add_child(act_btn)

extends Control
## Màn hình đấu cá riêng (Presentation thuần: nghe EventBus và gọi FishingAPI).

const FishingEventsContract: Script = preload("res://core/contracts/fishing_events.gd")
const ArenaViewScript: Script = preload("res://presentation/fishing_battle_ui/battle_arena_view.gd")

var _fishing_api: RefCounted
var _arena: Control
var _hp_bar: ProgressBar
var _stamina_bar: ProgressBar
var _qi_bar: ProgressBar
var _tension_bar: ProgressBar
var _drag_slider: HSlider
var _drag_label: Label
var _dir_label: Label
var _steer_val: float = 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_build_ui()
	_subscribe_events()


func set_fishing_api(api: RefCounted) -> void:
	_fishing_api = api


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.07, 0.12, 0.82)
	add_child(bg)

	var root_vbox := VBoxContainer.new()
	root_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_vbox.add_theme_constant_override("separation", 10)
	add_child(root_vbox)

	# HUD cá: HP, Sức, Nội năng
	var hud_row := HBoxContainer.new()
	hud_row.add_theme_constant_override("separation", 12)
	root_vbox.add_child(hud_row)
	_hp_bar = _make_bar(hud_row, "HP Cá", Color(0.9, 0.25, 0.25))
	_stamina_bar = _make_bar(hud_row, "Sức", Color(0.95, 0.72, 0.2))
	_qi_bar = _make_bar(hud_row, "Nội Năng", Color(0.3, 0.78, 0.95))

	_dir_label = Label.new()
	_dir_label.text = "Hướng cá: Đứng yên"
	_dir_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root_vbox.add_child(_dir_label)

	# Vùng nước mô phỏng cá, cần, dây
	_arena = ArenaViewScript.new()
	_arena.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(_arena)

	# Thanh lực căng + Drag máy câu
	var mech_row := HBoxContainer.new()
	mech_row.add_theme_constant_override("separation", 16)
	root_vbox.add_child(mech_row)
	_tension_bar = _make_bar(mech_row, "Lực Căng Dây", Color(0.95, 0.45, 0.2))

	var drag_box := VBoxContainer.new()
	drag_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mech_row.add_child(drag_box)
	_drag_label = Label.new()
	_drag_label.text = "Lực cản máy câu (Drag): 50%"
	drag_box.add_child(_drag_label)
	_drag_slider = HSlider.new()
	_drag_slider.min_value = 0.0
	_drag_slider.max_value = 100.0
	_drag_slider.value = 50.0
	_drag_slider.value_changed.connect(_on_drag_changed)
	drag_box.add_child(_drag_slider)

	# Điều khiển cảm ứng: Trái / Phải + Giữ Thu Dây
	var ctrl_row := HBoxContainer.new()
	ctrl_row.add_theme_constant_override("separation", 16)
	ctrl_row.custom_minimum_size = Vector2(0.0, 76.0)
	root_vbox.add_child(ctrl_row)

	var left_btn := _make_touch_btn(ctrl_row, "◀ Nghiêng Trái")
	left_btn.button_down.connect(func() -> void: _set_steer(-1.0))
	left_btn.button_up.connect(func() -> void: _set_steer(0.0))

	var reel_btn := _make_touch_btn(ctrl_row, "GIỮ THU DÂY")
	reel_btn.button_down.connect(func() -> void: _set_reel(true))
	reel_btn.button_up.connect(func() -> void: _set_reel(false))

	var right_btn := _make_touch_btn(ctrl_row, "Nghiêng Phải ▶")
	right_btn.button_down.connect(func() -> void: _set_steer(1.0))
	right_btn.button_up.connect(func() -> void: _set_steer(0.0))


func _make_bar(parent: Control, title: String, col: Color) -> ProgressBar:
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(box)
	var lbl := Label.new()
	lbl.text = title
	box.add_child(lbl)
	var bar := ProgressBar.new()
	bar.max_value = 100.0
	bar.value = 100.0
	bar.modulate = col
	box.add_child(bar)
	return bar


func _make_touch_btn(parent: Control, text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(btn)
	return btn


func _set_steer(val: float) -> void:
	_steer_val = val
	if _arena != null:
		_arena.set("rod_steer", val)
		_arena.queue_redraw()
	if _fishing_api != null and _fishing_api.has_method("set_rod_steer"):
		_fishing_api.call("set_rod_steer", val)


func _set_reel(held: bool) -> void:
	if _fishing_api != null and _fishing_api.has_method("reel"):
		_fishing_api.call("reel", held)


func _on_drag_changed(val: float) -> void:
	_drag_label.text = "Lực cản máy câu (Drag): %d%%" % int(roundf(val))
	if _fishing_api != null and _fishing_api.has_method("set_drag"):
		_fishing_api.call("set_drag", val / 100.0)


func _subscribe_events() -> void:
	var eb: Node = get_node_or_null("/root/EventBus")
	if eb == null or not eb.has_method("subscribe"):
		return
	eb.call("subscribe", FishingEventsContract.STATE_CHANGED, Callable(self, "_on_state_changed"))
	eb.call("subscribe", FishingEventsContract.FIGHT_UPDATE, Callable(self, "_on_fight_update"))
	eb.call("subscribe", FishingEventsContract.FISH_CAUGHT, Callable(self, "_on_battle_ended"))
	eb.call("subscribe", FishingEventsContract.FISH_ESCAPED, Callable(self, "_on_battle_ended"))


func _on_state_changed(payload: Dictionary) -> void:
	var to_state: String = str(payload.get("to_state", ""))
	if to_state == "FIGHT":
		visible = true
	elif to_state in ["IDLE", "CAUGHT", "FAILED", "ESCAPED"]:
		visible = false


func _on_battle_ended(_payload: Dictionary) -> void:
	visible = false


func _on_fight_update(payload: Dictionary) -> void:
	var max_stam: float = maxf(1.0, float(payload.get("fish_max_stamina", 100.0)))
	var cur_stam: float = float(payload.get("fish_strength", max_stam))
	var max_hp: float = maxf(1.0, float(payload.get("fish_max_hp", max_stam)))
	var cur_hp: float = float(payload.get("fish_hp", cur_stam))
	var max_qi: float = maxf(1.0, float(payload.get("fish_max_qi", 100.0)))
	var cur_qi: float = float(payload.get("fish_qi", 0.0))

	_hp_bar.max_value = max_hp
	_hp_bar.value = cur_hp
	_stamina_bar.max_value = max_stam
	_stamina_bar.value = cur_stam
	_qi_bar.max_value = max_qi
	_qi_bar.value = cur_qi

	var max_t: float = maxf(1.0, float(payload.get("max_tension", 100.0)))
	var cur_t: float = float(payload.get("line_tension", 0.0))
	_tension_bar.max_value = max_t
	_tension_bar.value = cur_t

	var swim_dir: int = int(payload.get("fish_swim_dir", 1))
	_dir_label.text = "Hướng cá: %s" % ("◀ Bơi Trái" if swim_dir < 0 else ("Bơi Phải ▶" if swim_dir > 0 else "Đứng yên"))
	if _arena != null:
		_arena.set("fish_swim_dir", swim_dir)
		_arena.set("fish_pos_norm", float(payload.get("fish_pos_norm", 0.5)))
		_arena.set("tension_ratio", clampf(cur_t / max_t, 0.0, 1.0))
		_arena.queue_redraw()

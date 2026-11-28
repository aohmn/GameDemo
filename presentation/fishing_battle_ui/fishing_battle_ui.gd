extends Control
## Màn hình đấu cá (Presentation thuần: nghe EventBus và gọi FishingAPI).

const FishingEventsContract: Script = preload("res://core/contracts/fishing_events.gd")
const ArenaViewScript: Script = preload("res://presentation/fishing_battle_ui/battle_arena_view.gd")

var _fishing_api: RefCounted
var _arena: Control
var _hp_bar: ProgressBar
var _stamina_bar: ProgressBar
var _qi_bar: ProgressBar
var _tension_bar: ProgressBar
var _durability_bar: ProgressBar
var _drag_slider: HSlider
var _drag_label: Label
var _dir_label: Label
var _skill_container: HBoxContainer
var _fish_skill_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_build_ui()
	_subscribe_events()


func set_fishing_api(api: RefCounted) -> void:
	_fishing_api = api


func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_top = 88.0
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_theme_constant_override("separation", 6)
	add_child(root)

	_build_fish_hud(root)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(spacer)
	_build_mech_hud(root)
	_build_controls(root)


func _build_fish_hud(parent: Control) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	_hp_bar = _bar(row, "HP", Color(0.90, 0.22, 0.22))
	_stamina_bar = _bar(row, "Sức", Color(0.95, 0.72, 0.18))
	_qi_bar = _bar(row, "Nội Năng", Color(0.25, 0.75, 0.95))

	_fish_skill_label = Label.new()
	_fish_skill_label.text = ""
	_fish_skill_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_fish_skill_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.2))
	parent.add_child(_fish_skill_label)

	_dir_label = Label.new()
	_dir_label.text = "Hướng cá: Đứng yên"
	_dir_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(_dir_label)


func _build_arena(parent: Control) -> void:
	_arena = ArenaViewScript.new()
	_arena.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(_arena)


func _build_mech_hud(parent: Control) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)
	_tension_bar = _bar(row, "Lực Căng", Color(0.95, 0.42, 0.18))
	_durability_bar = _bar(row, "Độ Bền Dây", Color(0.55, 0.80, 0.55))

	var drag_box := VBoxContainer.new()
	drag_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(drag_box)
	_drag_label = Label.new()
	_drag_label.text = "Drag: 50%"
	drag_box.add_child(_drag_label)
	_drag_slider = HSlider.new()
	_drag_slider.min_value = 0.0
	_drag_slider.max_value = 100.0
	_drag_slider.value = 50.0
	_drag_slider.value_changed.connect(_on_drag_changed)
	drag_box.add_child(_drag_slider)

	# Nút kỹ năng người chơi
	_skill_container = HBoxContainer.new()
	_skill_container.add_theme_constant_override("separation", 8)
	parent.add_child(_skill_container)
	_add_skill_button("res://modules/fishing/data/skills/skill_toa_ngu.tres", "Tỏa Ngư")
	_add_skill_button("res://modules/fishing/data/skills/skill_giam_chan.tres", "Giảm Chấn")


func _add_skill_button(spec_path: String, fallback_name: String) -> void:
	var btn := Button.new()
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var spec: Resource = load(spec_path) if ResourceLoader.exists(spec_path) else null
	btn.text = str(spec.get("display_name")) if spec != null and "display_name" in spec else fallback_name
	btn.pressed.connect(func() -> void:
		if _fishing_api != null and _fishing_api.has_method("use_battle_skill") and spec != null:
			_fishing_api.call("use_battle_skill", spec)
	)
	_skill_container.add_child(btn)


func _build_controls(_parent: Control) -> void:
	# Điều hướng cần và giật cần đã chuyển sang presentation/fishing_joystick/ (không có nút thu dây).
	pass


func _bar(p: Control, title: String, col: Color) -> ProgressBar:
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.add_child(box)
	var lbl := Label.new()
	lbl.text = title
	box.add_child(lbl)
	var bar := ProgressBar.new()
	bar.max_value = 100.0
	bar.value = 100.0
	bar.show_percentage = false
	bar.modulate = col
	box.add_child(bar)
	return bar


func _touch_btn(p: Control, text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	p.add_child(btn)
	return btn


func _set_steer(val: float) -> void:
	if _arena != null:
		_arena.set("rod_steer", val)
		_arena.queue_redraw()
	if _fishing_api != null and _fishing_api.has_method("set_rod_steer"):
		_fishing_api.call("set_rod_steer", val)


func _set_reel(held: bool) -> void:
	if _fishing_api != null and _fishing_api.has_method("reel"):
		_fishing_api.call("reel", held)


func _on_drag_changed(val: float) -> void:
	_drag_label.text = "Drag: %d%%" % int(roundf(val))
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
	var to: String = str(payload.get("to_state", ""))
	if to == "FIGHT":
		visible = true
	elif to in ["IDLE", "CAUGHT", "FAILED", "ESCAPED"]:
		visible = false


func _on_battle_ended(_payload: Dictionary) -> void:
	visible = false


func _on_fight_update(p: Dictionary) -> void:
	var mhp: float = maxf(1.0, float(p.get("fish_max_hp", 100.0)))
	_hp_bar.max_value = mhp
	_hp_bar.value = float(p.get("fish_hp", mhp))
	var ms: float = maxf(1.0, float(p.get("fish_max_stamina", 100.0)))
	_stamina_bar.max_value = ms
	_stamina_bar.value = float(p.get("fish_strength", ms))
	var mq: float = maxf(1.0, float(p.get("fish_max_qi", 100.0)))
	_qi_bar.max_value = mq
	_qi_bar.value = float(p.get("fish_qi", 0.0))

	var mt: float = maxf(1.0, float(p.get("max_tension", 100.0)))
	var ct: float = float(p.get("line_tension", 0.0))
	_tension_bar.max_value = mt
	_tension_bar.value = ct
	_durability_bar.value = float(p.get("line_durability", 100.0))

	var sd: int = int(p.get("fish_swim_dir", 0))
	_dir_label.text = "◀ Bơi Trái" if sd < 0 else ("Bơi Phải ▶" if sd > 0 else "Đứng yên")

	var tele: bool = bool(p.get("fish_telegraphing", false))
	_fish_skill_label.text = "⚠ Cá đang thi triển kỹ năng!" if tele else ""

	if _arena != null:
		_arena.set("fish_swim_dir", sd)
		_arena.set("fish_pos_norm", float(p.get("fish_pos_norm", 0.5)))
		_arena.set("fish_depth_norm", float(p.get("fish_depth_norm", 0.45)))
		_arena.set("rod_bend", float(p.get("rod_bend", 0.0)))
		_arena.set("tension_ratio", clampf(ct / mt, 0.0, 1.0))
		_arena.set("fish_telegraphing", tele)
		_arena.queue_redraw()

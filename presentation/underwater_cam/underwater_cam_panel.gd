extends Control
## Cửa sổ camera phụ dưới nước hiển thị đồng thời khi đang giằng co (FIGHT).

const FISHING_EVENTS: Script = preload("res://core/contracts/fishing_events.gd")
const ENV_SCRIPT: Script = preload("res://presentation/underwater_cam/underwater_environment.gd")
const FISH_SCRIPT: Script = preload("res://presentation/underwater_cam/underwater_fish_scene.gd")
const LINE_SCRIPT: Script = preload("res://presentation/underwater_cam/underwater_line.gd")
const VFX_SCRIPT: Script = preload("res://presentation/underwater_cam/underwater_vfx.gd")

var _panel: PanelContainer
var _viewport: SubViewport
var _camera: Camera3D
var _fish_node: Node3D
var _line_node: Node3D
var _vfx_node: Node3D

var _fish_pos_norm: float = 0.0
var _fish_depth_norm: float = 0.5
var _fish_swim_dir: int = 1
var _tension_ratio: float = 0.3
var _rod_bend: float = 0.0
var _is_telegraphing: bool = false
var _standalone_mode: bool = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	_build_underwater_world()
	_subscribe_events()
	visible = _standalone_mode


func set_standalone_mode(enabled: bool) -> void:
	_standalone_mode = enabled
	visible = enabled


func apply_fight_update(payload: Dictionary) -> void:
	_fish_pos_norm = float(payload.get("fish_pos_norm", _fish_pos_norm))
	_fish_depth_norm = float(payload.get("fish_depth_norm", _fish_depth_norm))
	_fish_swim_dir = int(payload.get("fish_swim_dir", _fish_swim_dir))
	_rod_bend = float(payload.get("rod_bend", _rod_bend))
	_is_telegraphing = bool(payload.get("fish_telegraphing", false))
	if payload.has("fish_tier") and _fish_node != null and _fish_node.has_method("set_fish_tier"):
		_fish_node.call("set_fish_tier", int(payload.get("fish_tier", 1)))

	var tension: float = float(payload.get("line_tension", 0.0))
	var max_tension: float = maxf(float(payload.get("max_tension", 100.0)), 1.0)
	_tension_ratio = clampf(tension / max_tension, 0.0, 1.0)


func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.anchor_left = 0.62
	_panel.anchor_top = 0.14
	_panel.anchor_right = 0.98
	_panel.anchor_bottom = 0.48
	_panel.offset_left = 0.0
	_panel.offset_top = 0.0
	_panel.offset_right = 0.0
	_panel.offset_bottom = 0.0

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.12, 0.20, 0.88)
	style.border_color = Color(0.28, 0.72, 0.88, 0.9)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(4)
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_theme_constant_override("separation", 2)
	_panel.add_child(vbox)

	var title := Label.new()
	title.text = "Camera Dưới Nước"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", Color(0.75, 0.94, 1.0))
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(title)

	var container := SubViewportContainer.new()
	container.stretch = true
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(container)

	_viewport = SubViewport.new()
	_viewport.own_world_3d = true
	_viewport.transparent_bg = false
	_viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	container.add_child(_viewport)


func _build_underwater_world() -> void:
	var env_node := ENV_SCRIPT.new() as Node3D
	_viewport.add_child(env_node)

	_fish_node = FISH_SCRIPT.new() as Node3D
	_viewport.add_child(_fish_node)

	_line_node = LINE_SCRIPT.new() as Node3D
	_viewport.add_child(_line_node)

	_vfx_node = VFX_SCRIPT.new() as Node3D
	_viewport.add_child(_vfx_node)

	_camera = Camera3D.new()
	_camera.position = Vector3(0.0, -1.2, 3.6)
	_camera.fov = 52.0
	_viewport.add_child(_camera)


func _process(delta: float) -> void:
	if not visible:
		return
	if _fish_node != null and _fish_node.has_method("update_fish"):
		_fish_node.call(
			"update_fish",
			_fish_pos_norm,
			_fish_depth_norm,
			_fish_swim_dir,
			_tension_ratio,
			_is_telegraphing,
			delta
		)
		var mouth_pos: Vector3 = _fish_node.call("get_mouth_world_position")
		if _line_node != null and _line_node.has_method("update_line"):
			_line_node.call("update_line", mouth_pos, _tension_ratio, _rod_bend)
		if _vfx_node != null and _vfx_node.has_method("update_vfx"):
			_vfx_node.call("update_vfx", _fish_node.position, _is_telegraphing, delta)

		# Camera bám cá mượt, có giới hạn, không rung giật
		if _camera != null:
			var target_cam_x: float = clampf(_fish_node.position.x * 0.55, -1.4, 1.4)
			var target_cam_y: float = clampf(_fish_node.position.y + 0.15, -1.85, -0.45)
			var target_cam := Vector3(target_cam_x, target_cam_y, 3.6)
			_camera.position = _camera.position.lerp(target_cam, clampf(delta * 4.5, 0.0, 1.0))
			_camera.look_at(_fish_node.position, Vector3.UP)


func _subscribe_events() -> void:
	var bus: Node = get_node_or_null("/root/EventBus")
	if bus == null:
		return
	bus.call("subscribe", FISHING_EVENTS.STATE_CHANGED, Callable(self, "_on_state_changed"))
	bus.call("subscribe", FISHING_EVENTS.FIGHT_UPDATE, Callable(self, "_on_fight_update"))
	bus.call("subscribe", FISHING_EVENTS.FISH_CAUGHT, Callable(self, "_on_fight_ended"))
	bus.call("subscribe", FISHING_EVENTS.FISH_ESCAPED, Callable(self, "_on_fight_ended"))


func _on_state_changed(payload: Dictionary) -> void:
	if _standalone_mode:
		return
	var to_state: String = str(payload.get("to_state", ""))
	visible = (to_state == "FIGHT")


func _on_fight_update(payload: Dictionary) -> void:
	apply_fight_update(payload)


func _on_fight_ended(_payload: Dictionary) -> void:
	if not _standalone_mode:
		visible = false

extends Control
## Joystick cảm ứng riêng bên phải màn hình cho pha giằng co (FIGHT).
## Hỗ trợ kéo trái/phải điều hướng cần câu và nhấp-nhả để giật nhẹ (twitch).

signal steer_changed(steer_x: float)
signal twitch_triggered()

const FISHING_EVENTS: Script = preload("res://core/contracts/fishing_events.gd")

const DEADZONE: float = 0.14
const PAD_RADIUS: float = 72.0
const KNOB_RADIUS: float = 28.0
const TAP_MAX_TIME_MS: int = 220
const TAP_MAX_DIST_PX: float = 18.0
const TWITCH_DURATION_SEC: float = 0.12

var _fishing_api: RefCounted
var _standalone_mode: bool = false
var _active_touch_index: int = -1
var _mouse_active: bool = false

var _knob_offset: Vector2 = Vector2.ZERO
var _steer_x: float = 0.0
var _press_start_ms: int = 0
var _press_start_pos: Vector2 = Vector2.ZERO
var _max_drag_dist: float = 0.0
var _twitch_timer: float = 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_subscribe_events()
	visible = _standalone_mode
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func set_fishing_api(api: RefCounted) -> void:
	_fishing_api = api


func set_standalone_mode(enabled: bool) -> void:
	_standalone_mode = enabled
	visible = enabled
	queue_redraw()


func get_steer_x() -> float:
	return _steer_x


func _process(delta: float) -> void:
	if _twitch_timer > 0.0:
		_twitch_timer -= delta
		if _twitch_timer <= 0.0:
			_twitch_timer = 0.0
			if _active_touch_index == -1 and not _mouse_active:
				_apply_steer(0.0)
			queue_redraw()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			if _active_touch_index == -1 and _is_near_pad(touch.position):
				_active_touch_index = touch.index
				_begin_press(touch.position)
				get_viewport().set_input_as_handled()
		elif touch.index == _active_touch_index:
			_active_touch_index = -1
			_end_press()
			get_viewport().set_input_as_handled()

	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == _active_touch_index:
			_update_drag(drag.position)
			get_viewport().set_input_as_handled()

	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				if not _mouse_active and _is_near_pad(mb.position):
					_mouse_active = true
					_begin_press(mb.position)
			elif _mouse_active:
				_mouse_active = false
				_end_press()

	elif event is InputEventMouseMotion and _mouse_active:
		var mm := event as InputEventMouseMotion
		_update_drag(mm.position)


func _begin_press(pos: Vector2) -> void:
	_press_start_ms = Time.get_ticks_msec()
	_press_start_pos = pos
	_max_drag_dist = 0.0
	_update_drag(pos)


func _update_drag(pos: Vector2) -> void:
	var center: Vector2 = _get_pad_center()
	var delta_vec: Vector2 = pos - center
	_max_drag_dist = maxf(_max_drag_dist, pos.distance_to(_press_start_pos))

	if delta_vec.length() > PAD_RADIUS:
		delta_vec = delta_vec.normalized() * PAD_RADIUS
	_knob_offset = delta_vec

	var raw_x: float = clampf(delta_vec.x / PAD_RADIUS, -1.0, 1.0)
	var steer: float = 0.0
	if absf(raw_x) > DEADZONE:
		var sign_val: float = 1.0 if raw_x > 0.0 else -1.0
		steer = sign_val * ((absf(raw_x) - DEADZONE) / (1.0 - DEADZONE))
	_apply_steer(clampf(steer, -1.0, 1.0))
	queue_redraw()


func _end_press() -> void:
	var elapsed_ms: int = Time.get_ticks_msec() - _press_start_ms
	var is_tap: bool = elapsed_ms <= TAP_MAX_TIME_MS and _max_drag_dist <= TAP_MAX_DIST_PX
	_knob_offset = Vector2.ZERO

	if is_tap:
		_twitch_timer = TWITCH_DURATION_SEC
		_apply_steer(1.0)
		if _fishing_api != null and _fishing_api.has_method("trigger_twitch"):
			_fishing_api.call("trigger_twitch")
		twitch_triggered.emit()
	else:
		_apply_steer(0.0)
	queue_redraw()


func _apply_steer(val: float) -> void:
	if not is_equal_approx(_steer_x, val):
		_steer_x = val
		steer_changed.emit(_steer_x)
	if _fishing_api != null and _fishing_api.has_method("set_rod_steer"):
		_fishing_api.call("set_rod_steer", _steer_x)


func _get_pad_center() -> Vector2:
	var vp_size: Vector2 = get_viewport_rect().size
	var safe: Rect2i = DisplayServer.get_display_safe_area()
	var right_margin: float = 112.0
	var bottom_margin: float = 128.0
	if safe.size.x > 0 and vp_size.x > 0.0:
		var inset_right: float = maxf(0.0, vp_size.x - float(safe.position.x + safe.size.x))
		right_margin = maxf(right_margin, inset_right + PAD_RADIUS + 24.0)
	return Vector2(vp_size.x - right_margin, vp_size.y - bottom_margin)


func _is_near_pad(pos: Vector2) -> bool:
	return pos.distance_to(_get_pad_center()) <= PAD_RADIUS * 1.45


func _draw() -> void:
	if not visible:
		return
	var center: Vector2 = _get_pad_center()
	draw_circle(center, PAD_RADIUS, Color(0.08, 0.16, 0.24, 0.45))
	draw_arc(center, PAD_RADIUS, 0.0, TAU, 40, Color(0.42, 0.78, 0.94, 0.8), 2.0)
	draw_arc(center, PAD_RADIUS * DEADZONE, 0.0, TAU, 24, Color(0.42, 0.78, 0.94, 0.35), 1.5)
	draw_line(center + Vector2(-PAD_RADIUS * 0.7, 0.0), center + Vector2(PAD_RADIUS * 0.7, 0.0), Color(0.7, 0.9, 1.0, 0.25), 1.5)

	var knob_col := Color(0.45, 0.86, 0.98, 0.85)
	if _twitch_timer > 0.0:
		knob_col = Color(1.0, 0.82, 0.3, 0.95)
	draw_circle(center + _knob_offset, KNOB_RADIUS, knob_col)


func _subscribe_events() -> void:
	var bus: Node = get_node_or_null("/root/EventBus")
	if bus == null:
		return
	bus.call("subscribe", FISHING_EVENTS.STATE_CHANGED, Callable(self, "_on_state_changed"))


func _on_state_changed(payload: Dictionary) -> void:
	if _standalone_mode:
		return
	var to_state: String = str(payload.get("to_state", ""))
	var active: bool = (to_state == "FIGHT")
	visible = active
	if not active:
		_active_touch_index = -1
		_mouse_active = false
		_knob_offset = Vector2.ZERO
		_twitch_timer = 0.0
		_apply_steer(0.0)
		queue_redraw()

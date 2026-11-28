extends Control

signal direction_changed(direction: Vector2)

const DEADZONE: float = 0.12
const PAD_RADIUS: float = 76.0
const KNOB_RADIUS: float = 27.0
const PAD_MARGIN: float = 112.0

var _direction: Vector2 = Vector2.ZERO
var _active_touch_index: int = -1
var _mouse_active: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bus: Node = get_node_or_null("/root/EventBus")
	if bus != null:
		var ev: Script = load("res://core/contracts/fishing_events.gd") as Script
		if ev != null:
			bus.call("subscribe", ev.STATE_CHANGED, Callable(self, "_on_fishing_state_changed"))
	queue_redraw()


func _on_fishing_state_changed(payload: Dictionary) -> void:
	var to_state: String = str(payload.get("to_state", ""))
	var in_fight: bool = (to_state == "FIGHT")
	visible = not in_fight
	if in_fight:
		_active_touch_index = -1
		_mouse_active = false
		_reset_direction()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func get_direction() -> Vector2:
	return _direction


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch

		if touch.pressed:
			if _active_touch_index == -1 and _is_near_pad(touch.position):
				_active_touch_index = touch.index
				_update_direction(touch.position)
				get_viewport().set_input_as_handled()
		elif touch.index == _active_touch_index:
			_active_touch_index = -1
			_reset_direction()
			get_viewport().set_input_as_handled()

	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag

		if drag.index == _active_touch_index:
			_update_direction(drag.position)
			get_viewport().set_input_as_handled()

	elif event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton

		if mouse_button.button_index == MOUSE_BUTTON_LEFT:
			if mouse_button.pressed:
				if not _mouse_active and _is_near_pad(mouse_button.position):
					_mouse_active = true
					_update_direction(mouse_button.position)
			elif _mouse_active:
				_mouse_active = false
				_reset_direction()

	elif event is InputEventMouseMotion:
		var mouse_motion := event as InputEventMouseMotion

		if _mouse_active and (mouse_motion.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			_update_direction(mouse_motion.position)


func _pad_center() -> Vector2:
	var viewport_size: Vector2 = get_viewport_rect().size
	return Vector2(PAD_MARGIN, viewport_size.y - PAD_MARGIN)


func _to_local_position(viewport_position: Vector2) -> Vector2:
	var inverse_transform: Transform2D = get_global_transform_with_canvas().affine_inverse()
	return inverse_transform * viewport_position


func _is_near_pad(viewport_position: Vector2) -> bool:
	var local_position: Vector2 = _to_local_position(viewport_position)
	return local_position.distance_to(_pad_center()) <= PAD_RADIUS * 1.5


func _update_direction(viewport_position: Vector2) -> void:
	var local_position: Vector2 = _to_local_position(viewport_position)
	var delta: Vector2 = local_position - _pad_center()

	if delta.length() > PAD_RADIUS:
		delta = delta.normalized() * PAD_RADIUS

	var next_direction := Vector2(delta.x, -delta.y) / PAD_RADIUS

	if next_direction.length() < DEADZONE:
		next_direction = Vector2.ZERO

	if not next_direction.is_equal_approx(_direction):
		_direction = next_direction
		direction_changed.emit(_direction)

	queue_redraw()


func _reset_direction() -> void:
	if _direction != Vector2.ZERO:
		_direction = Vector2.ZERO
		direction_changed.emit(_direction)

	queue_redraw()


func _draw() -> void:
	var center: Vector2 = _pad_center()
	var knob_offset := Vector2(_direction.x, -_direction.y) * PAD_RADIUS

	draw_circle(center, PAD_RADIUS, Color(0.08, 0.08, 0.08, 0.32))
	draw_arc(
		center,
		PAD_RADIUS,
		0.0,
		PI * 2.0,
		48,
		Color(0.85, 0.85, 0.85, 0.65),
		3.0,
		true
	)
	draw_circle(center + knob_offset, KNOB_RADIUS, Color(0.9, 0.9, 0.9, 0.72))
	draw_arc(
		center + knob_offset,
		KNOB_RADIUS,
		0.0,
		PI * 2.0,
		32,
		Color(1.0, 1.0, 1.0, 0.8),
		2.0,
		true
	)

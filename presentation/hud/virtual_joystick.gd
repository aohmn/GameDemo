extends Control

var _direction := Vector2.ZERO
var _touch_index := -1
var _last_emitted_direction := Vector2.ZERO
var _locked := false


func _ready() -> void:
	set_process_input(true)
	queue_redraw()
	EventBus.subscribe(DestinationEvents.INPUT_LOCK_REQUESTED, _on_input_lock_requested)

func _exit_tree() -> void:
	if EventBus != null:
		EventBus.unsubscribe(DestinationEvents.INPUT_LOCK_REQUESTED, _on_input_lock_requested)

func _on_input_lock_requested(payload: Dictionary) -> void:
	_locked = bool(payload.get("locked", false))
	if _locked:
		_touch_index = -1
		_direction = Vector2.ZERO
		_emit_direction()
		queue_redraw()


func get_direction() -> Vector2:
	return _direction


func is_active() -> bool:
	return _touch_index != -1


func _screen_to_local(screen_position: Vector2) -> Vector2:
	var inverse := get_global_transform_with_canvas().affine_inverse()
	return inverse * screen_position


func _input(event: InputEvent) -> void:
	if _locked:
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch

		if touch.pressed:
			if _touch_index == -1:
				var local_pos := _screen_to_local(touch.position)
				var touch_area := Rect2(Vector2.ZERO, size)

				if touch_area.has_point(local_pos):
					_touch_index = touch.index
					_update_direction(local_pos)
					get_viewport().set_input_as_handled()
		else:
			if touch.index == _touch_index:
				_touch_index = -1
				_direction = Vector2.ZERO
				_emit_direction()
				queue_redraw()
				get_viewport().set_input_as_handled()

	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag

		if drag.index == _touch_index:
			var local_pos := _screen_to_local(drag.position)
			_update_direction(local_pos)
			get_viewport().set_input_as_handled()


func _update_direction(local_position: Vector2) -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.42
	var offset := local_position - center

	if radius > 0.0:
		_direction = offset.limit_length(radius) / radius
	else:
		_direction = Vector2.ZERO

	_emit_direction()
	queue_redraw()


## Phát hướng điều khiển cho Player qua EventBus; không giữ tham chiếu Player.
func _emit_direction() -> void:
	if _direction.is_equal_approx(_last_emitted_direction):
		return
	_last_emitted_direction = _direction
	EventBus.emit_event(PlayerEvents.MOVE_INPUT_CHANGED, {
		"direction": _direction
	})


func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.42

	draw_circle(
		center,
		radius,
		Color(0.04, 0.06, 0.07, 0.45)
	)

	draw_arc(
		center,
		radius,
		0.0,
		TAU,
		48,
		Color(0.85, 0.88, 0.84, 0.75),
		3.0,
		true
	)

	draw_circle(
		center + _direction * radius * 0.58,
		radius * 0.30,
		Color(0.88, 0.90, 0.86, 0.85)
	)

extends Control
class_name WorldMinimap

const MINI_RADIUS := 30.0
const MINI_SIZE := 144.0
const MAP_ZOOM_MIN := 1.0
const MAP_ZOOM_MAX := 4.0

var _world_map_open := false
var _waypoint := Vector3.ZERO
var _has_waypoint := false
var _route: PackedVector3Array = PackedVector3Array()

var _player_position := Vector3.ZERO
var _has_player_position := false
var _npc_positions: Array[Dictionary] = []
var _route_request_serial: int = 0
var _pending_route_request: int = 0

var _map_zoom := 1.0
var _map_pan := Vector2.ZERO

var _touch_positions: Dictionary = {}
var _opening_touch_index := -1
var _gesture_moved := false

var _mouse_down := false
var _mouse_moved := false
var _mouse_last_position := Vector2.ZERO
var _redraw_accumulator: float = 0.0

var _mini_anchors := Vector4.ZERO
var _mini_offsets := Vector4.ZERO

# Map bounds from MapArea (replaces WORLD_HALF_SIZE)
var _map_bounds: Rect2
var _map_bounds_dirty := true


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	process_mode = Node.PROCESS_MODE_INHERIT

	EventBus.subscribe(WorldEvents.PLAYER_POSITION_CHANGED, _on_player_position_changed)
	EventBus.subscribe(WorldEvents.NPC_POSITIONS_CHANGED, _on_npc_positions_changed)
	EventBus.subscribe(WorldEvents.ROUTE_READY, _on_route_ready)

	# Save layout minimap để khôi phục sau khi đóng bản đồ lớn.
	_mini_anchors = Vector4(
		anchor_left,
		anchor_top,
		anchor_right,
		anchor_bottom
	)
	_mini_offsets = Vector4(
		offset_left,
		offset_top,
		offset_right,
		offset_bottom
	)

	# Request map bounds from MapArea
	_request_map_bounds()


func _request_map_bounds() -> void:
	# Try to get map bounds from the MapArea instance in the world
	var map_area: Node = get_tree().get_first_node_in_group("MapArea")
	if is_instance_valid(map_area) and map_area is MapArea:
		var ma: MapArea = map_area as MapArea
		if ma.map_bounds.size.x > 0:
			_map_bounds = ma.map_bounds
		_map_bounds_dirty = false
	else:
		# Fallback: use default bounds based on MINI_RADIUS
		_map_bounds = Rect2(-MINI_RADIUS, -MINI_RADIUS, MINI_RADIUS * 2.0, MINI_RADIUS * 2.0)
		_map_bounds_dirty = false


func _map_bounds_changed(bounds: Rect2) -> void:
	_map_bounds = bounds
	_map_bounds_dirty = false


func _exit_tree() -> void:
	if EventBus != null:
		EventBus.unsubscribe(WorldEvents.PLAYER_POSITION_CHANGED, _on_player_position_changed)
		EventBus.unsubscribe(WorldEvents.NPC_POSITIONS_CHANGED, _on_npc_positions_changed)
		EventBus.unsubscribe(WorldEvents.ROUTE_READY, _on_route_ready)


func _set_world_map_open(is_open: bool) -> void:
	_world_map_open = is_open
	if not is_open:
		_touch_positions.clear()
		_opening_touch_index = -1
		_mouse_down = false
	if is_open:
		_map_zoom = 1.0
		_map_pan = Vector2.ZERO
		_route.clear()
		_pending_route_request = 0
		# Cập nhật map bounds khi mở bản đồ
		_request_map_bounds()

	if is_open:
		# Mở rộng Control phủ toàn thể viewport.
		anchor_left = 0.0
		anchor_top = 0.0
		anchor_right = 1.0
		anchor_bottom = 1.0

		offset_left = 0.0
		offset_top = 0.0
		offset_right = 0.0
		offset_bottom = 0.0
	else:
		# Khôi phục đúng vị trí và kích thước minimap.
		anchor_left = _mini_anchors.x
		anchor_top = _mini_anchors.y
		anchor_right = _mini_anchors.z
		anchor_bottom = _mini_anchors.w

		offset_left = _mini_offsets.x
		offset_top = _mini_offsets.y
		offset_right = _mini_offsets.z
		offset_bottom = _mini_offsets.w

	queue_redraw()


func _process(delta: float) -> void:
	_redraw_accumulator += delta
	# Chỉ queue_redraw tối đa 10 lần/giây (mỗi 0.1s)
	if _redraw_accumulator >= 0.1:
		_redraw_accumulator = 0.0
		queue_redraw()


func _gui_input(event: InputEvent) -> void:
	# Yêu cầu B1: Bỏ qua InputEventMouse có device == InputEvent.DEVICE_ID_EMULATION
	if event is InputEventMouse and event.device == InputEvent.DEVICE_ID_EMULATION:
		return

	if event is InputEventScreenTouch:
		_handle_screen_touch(event)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event)
	elif event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)


func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	var local_position: Vector2 = _screen_to_local(event.position)
	if event.pressed:
		if not _world_map_open:
			_set_world_map_open(true)
			_opening_touch_index = event.index
			accept_event()
			queue_redraw()
			return

		_touch_positions[event.index] = local_position

		if _touch_positions.size() == 1:
			_gesture_moved = false
		else:
			_gesture_moved = true

		accept_event()
		return

	if event.index == _opening_touch_index:
		_opening_touch_index = -1
		accept_event()
		return

	if not _touch_positions.has(event.index):
		return

	if _world_map_open and not _gesture_moved and _touch_positions.size() == 1:
		_handle_full_map_tap(local_position)

	_touch_positions.erase(event.index)

	if _touch_positions.is_empty():
		_gesture_moved = false

	accept_event()
	queue_redraw()


func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	var local_position: Vector2 = _screen_to_local(event.position)

	if not _world_map_open:
		return

	if not _touch_positions.has(event.index):
		return

	var previous_position: Vector2 = _touch_positions[event.index]

	if _touch_positions.size() >= 2:
		# Multi-touch zoom (giữ nguyên như hiện tại)
		var touch_ids: Array = _touch_positions.keys()
		var other_id: int = touch_ids[0]

		if other_id == event.index:
			other_id = touch_ids[1]

		var other_position: Vector2 = _touch_positions[other_id]
		var old_center := (previous_position + other_position) * 0.5
		var new_center := (local_position + other_position) * 0.5
		var old_distance := previous_position.distance_to(other_position)
		var new_distance := local_position.distance_to(other_position)

		_map_pan += new_center - old_center
		_clamp_map_pan()

		if old_distance > 1.0 and new_distance > 1.0:
			_zoom_at(new_distance / old_distance, new_center)

		_touch_positions[event.index] = local_position
		_gesture_moved = true
	else:
		# Yêu cầu B2: Ngưỡng kéo > 12 px (hiện tại 1 px nên ngón rung mất cú chạm)
		_touch_positions[event.index] = local_position
		var movement := local_position - previous_position

		if movement.length() > 12.0:
			_map_pan += movement
			_clamp_map_pan()
			_gesture_moved = true

	accept_event()
	queue_redraw()


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	var local_position: Vector2 = _screen_to_local(event.position)

	# Yêu cầu B1: Bỏ qua InputEventMouse có device == InputEvent.DEVICE_ID_EMULATION
	if event.device == InputEvent.DEVICE_ID_EMULATION:
		return

	if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
		if _world_map_open:
			_zoom_at(1.2, local_position)
			accept_event()
			queue_redraw()
		return

	if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
		if _world_map_open:
			_zoom_at(0.83, local_position)
			accept_event()
			queue_redraw()
		return

	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	if event.pressed:
		if not _world_map_open:
			_set_world_map_open(true)
			accept_event()
			queue_redraw()
			return

		_mouse_down = true
		_mouse_moved = false
		_mouse_last_position = local_position
		accept_event()
	else:
		if not _mouse_down:
			return

		_mouse_down = false

		if not _mouse_moved:
			_handle_full_map_tap(local_position)

		accept_event()
		queue_redraw()


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	# Yêu cầu B1: Bỏ qua InputEventMouse có device == InputEvent.DEVICE_ID_EMULATION
	if event.device == InputEvent.DEVICE_ID_EMULATION:
		return

	var local_position: Vector2 = _screen_to_local(event.position)
	if not _world_map_open or not _mouse_down:
		return

	var movement := local_position - _mouse_last_position
	_mouse_last_position = local_position

	# Yêu cầu B2: Ngưỡng kéo > 12 px
	if movement.length() > 12.0:
		_map_pan += movement
		_clamp_map_pan()
		_mouse_moved = true

	accept_event()
	queue_redraw()


func _handle_full_map_tap(position: Vector2) -> void:
	# Yêu cầu B3: Nút -, +, ĐÓNG có vùng chạm tối thiểu 48x48
	# Sử dụng chung một Rect2 cho vẽ và bắt chạm
	var button_size := Vector2(48.0, 48.0)

	# Close button - area: size.x - 66 wide, 48 high from top-right
	var close_rect := Rect2(
		size.x - 66.0,
		0.0,
		button_size.x,
		button_size.y
	)
	if close_rect.has_point(position):
		_set_world_map_open(false)
		return

	# Zoom out (-) button
	var zoom_out_rect := Rect2(
		size.x - 155.0,
		0.0,
		button_size.x,
		button_size.y
	)
	if zoom_out_rect.has_point(position) and _world_map_open:
		_zoom_at(0.8, _full_map_rect().get_center())
		return

	# Zoom in (+) button
	var zoom_in_rect := Rect2(
		size.x - 112.0,
		0.0,
		button_size.x,
		button_size.y
	)
	if zoom_in_rect.has_point(position) and _world_map_open:
		_zoom_at(1.25, _full_map_rect().get_center())
		return

	# Tap trên bản đồ để đặt waypoint
	var map_rect := _full_map_rect()

	if not map_rect.has_point(position):
		return

	var world_position := _map_to_world(position)
	_waypoint = Vector3(world_position.x, 0.0, world_position.y)
	_has_waypoint = true
	_route.clear()
	_route_request_serial += 1
	_pending_route_request = _route_request_serial

	if _has_player_position:
		EventBus.emit_event(WorldEvents.ROUTE_REQUESTED, {
			"request_id": _pending_route_request,
			"start": _player_position,
			"destination": _waypoint
		})
	else:
		_pending_route_request = 0
	queue_redraw()


func _on_player_position_changed(payload: Dictionary) -> void:
	var position_value: Variant = payload.get("position")
	if position_value is Vector3:
		_player_position = position_value
		_has_player_position = true
		# Yêu cầu cập nhật map bounds khi player di chuyển > 0.5 m
		_request_map_bounds()


func _on_npc_positions_changed(payload: Dictionary) -> void:
	var entries_value: Variant = payload.get("npcs")
	if not (entries_value is Array):
		return
	var entries: Array[Dictionary] = []
	for entry: Variant in entries_value:
		if not (entry is Dictionary):
			continue
		var position_value: Variant = (entry as Dictionary).get("position")
		if position_value is Vector3:
			entries.append({
				"id": str((entry as Dictionary).get("id", "")),
				"position": position_value
			})
	_npc_positions = entries
	# Chỉ redraw nếu NPC thay đổi vị trí > 0.5 m
	var total_move := 0.0
	for entry: Dictionary in entries:
		var pos: Vector3 = entry.get("position") as Vector3
		total_move += abs(pos.distance_to(_player_position))
	if total_move > 0.5:
		queue_redraw()


func _on_route_ready(payload: Dictionary) -> void:
	var request_id_value: Variant = payload.get("request_id", 0)
	if typeof(request_id_value) != TYPE_INT and typeof(request_id_value) != TYPE_FLOAT:
		return
	if int(request_id_value) != _pending_route_request or _pending_route_request == 0:
		return
	_pending_route_request = 0
	var route_value: Variant = payload.get("route")
	if route_value is PackedVector3Array:
		_route = route_value
	elif route_value is Array:
		var converted := PackedVector3Array()
		for point: Variant in route_value:
			if point is Vector3:
				converted.append(point)
		_route = converted
	else:
		_route.clear()
	queue_redraw()


func _zoom_at(factor: float, focal_point: Vector2) -> void:
	var map_center := _full_map_rect().get_center()
	var world_offset := (focal_point - map_center - _map_pan) / _map_zoom

	_map_zoom = clampf(
		_map_zoom * factor,
		MAP_ZOOM_MIN,
		MAP_ZOOM_MAX
	)

	_map_pan = focal_point - map_center - world_offset * _map_zoom
	_clamp_map_pan()
	queue_redraw()


func _clamp_map_pan() -> void:
	var map_rect := _full_map_rect()
	var max_pan := map_rect.size * 0.5 * (_map_zoom - 1.0)

	_map_pan.x = clampf(_map_pan.x, -max_pan.x, max_pan.x)
	_map_pan.y = clampf(_map_pan.y, -max_pan.y, max_pan.y)


func _full_map_rect() -> Rect2:
	return Rect2(
		Vector2(16.0, 54.0),
		Vector2(maxf(1.0, size.x - 32.0), maxf(1.0, size.y - 76.0))
	)


func _draw() -> void:
	if _world_map_open:
		_draw_full_map()
	else:
		_draw_minimap()


func _draw_minimap() -> void:
	var minimap_rect := Rect2(
		Vector2(size.x * 0.5 - MINI_SIZE * 0.5, size.y * 0.57 - MINI_SIZE * 0.5),
		Vector2(MINI_SIZE, MINI_SIZE)
	)

	# Vẽ nền bản đồ minimap (đã clip theo rect)
	draw_rect(minimap_rect, Color(0.025, 0.04, 0.055, 0.90), true)
	draw_rect(minimap_rect, Color(0.72, 0.78, 0.78, 0.95), false, 1.5)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(10.0, 17.0),
		"THẾ GIỚI",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		11,
		Color(0.95, 0.95, 0.88)
	)

	# Vẽ khu vực hiển thị ~30 m quanh Player
	# Scale: 30m radius → full minimap diameter (MINI_SIZE)
	var scale_factor := MINI_SIZE / (2.0 * MINI_RADIUS)

	var center := Vector2(size.x * 0.5, size.y * 0.57)

	# Vẽ đường theo tọa độ thế giới tương đối với Player
	var world_points: Array[Vector2] = WorldNavigation.get_road_points()
	for i in range(world_points.size() - 1):
		_draw_minimap_world_line_clipped(
			world_points[i],
			world_points[i + 1],
			Color(0.24, 0.25, 0.25),
			3.0,
			minimap_rect,
			scale_factor
		)

	if _has_player_position:
		draw_circle(center, 5.0, Color.WHITE)
		draw_circle(center, 3.2, Color(1.0, 0.35, 0.08))

	for npc_entry: Dictionary in _npc_positions:
		var npc_position_value: Variant = npc_entry.get("position")
		if not (npc_position_value is Vector3):
			continue
		var npc_position: Vector3 = npc_position_value as Vector3
		var npc_point := _world_to_minimap(
			npc_position.x,
			npc_position.z
		)
		if minimap_rect.has_point(npc_point):
			draw_circle(npc_point, 4.5, Color(0.15, 0.9, 1.0))
			draw_circle(npc_point, 2.0, Color(0.02, 0.12, 0.2))

	if _has_waypoint:
		var target := _world_to_minimap(_waypoint.x, _waypoint.z)
		draw_circle(target, 4.0, Color(1.0, 0.82, 0.12))

	draw_string(
		ThemeDB.fallback_font,
		Vector2(size.x - 18.0, 17.0),
		"N",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		10,
		Color.WHITE
	)


func _draw_minimap_world_line_clipped(
	start_world: Vector2,
	end_world: Vector2,
	color: Color,
	line_width: float,
	clip_rect: Rect2,
	scale_factor: float
) -> void:
	# Chuyển đổi world points to minimap points
	var start_point := _world_to_minimap(start_world.x, start_world.y)
	var end_point := _world_to_minimap(end_world.x, end_world.y)

	# Kiểm tra xem cả hai điểm có nằm trong clip_rect không
	var start_in := clip_rect.has_point(start_point)
	var end_in := clip_rect.has_point(end_point)

	if start_in and end_in:
		# Cả Ambos trong rect -> vẽ luôn
		draw_line(start_point, end_point, color, line_width, true)
	elif start_in or end_in:
		# Một bên trong, một bên ngoài -> cắt line tại biên rect
		var intersect: Variant = _clip_line_to_rect_2d(start_point, end_point, clip_rect)
		if intersect != null:
			var clipped: Dictionary = intersect as Dictionary
			draw_line(clipped["start"] as Vector2, clipped["end"] as Vector2, color, line_width, true)
	# (cho minimap: các road point gần Player nên thường trong rect)


func _clip_line_to_rect_2d(p1: Vector2, p2: Vector2, rect: Rect2) -> Variant:
	# Thuật toán đơn giản: tìm điểm giao của đoạn line với 4 bên rect
	var dx := p2.x - p1.x
	var dy := p2.y - p1.y

	var t_enter := 0.0
	var t_exit := 1.0

	# X direção
	if abs(dx) > 0.001:
		var t1 := (rect.position.x - p1.x) / dx
		var t2 := (rect.position.x + rect.size.x - p1.x) / dx
		if t1 > t2:
			var tmp := t1
			t1 = t2
			t2 = tmp
		t_enter = max(t_enter, t1)
		t_exit = min(t_exit, t2)
		if t_enter > t_exit: return null

	# Y dirección
	if abs(dy) > 0.001:
		var t3 := (rect.position.y - p1.y) / dy
		var t4 := (rect.position.y + rect.size.y - p1.y) / dy
		if t3 > t4:
			var tmp2 := t3
			t3 = t4
			t4 = tmp2
		t_enter = max(t_enter, t3)
		t_exit = min(t_exit, t4)
		if t_enter > t_exit: return null

	# Kiểm tra xem có giao intersection không
	if t_enter < 0 and t_exit < 0: return null
	if t_enter > 1 and t_exit > 1: return null

	var t_use := max(0.0, min(1.0, t_enter))
	var intersect_start := Vector2(p1.x + dx * t_use, p1.y + dy * t_use)
	t_use = min(1.0, max(0.0, t_exit))
	var intersect_end := Vector2(p1.x + dx * t_use, p1.y + dy * t_use)

	return {"start": intersect_start, "end": intersect_end}


func _world_to_minimap(world_x: float, world_z: float) -> Vector2:
	var center := Vector2(size.x * 0.5, size.y * 0.57)
	if not _has_player_position:
		return center

	var relative := Vector2(
		world_x - _player_position.x,
		world_z - _player_position.z
	)

	# Show ~30m radius around Player
	# Scale: 30m maps to MINI_SIZE/2 (radius in pixels)
	var scale_factor := MINI_SIZE / (2.0 * MINI_RADIUS)

	return center + relative * scale_factor


func _draw_full_map() -> void:
	draw_rect(
		Rect2(Vector2.ZERO, size),
		Color(0.025, 0.035, 0.045, 0.97),
		true
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(20.0, 36.0),
		"BẢN ĐỒ THẾ GIỚI",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		20,
		Color(0.96, 0.94, 0.84)
	)

	# Yêu cầu B3: Nút -, +, ĐÓNG có vùng chạm tối thiểu 48x48
	# Sử dụng chung một Rect2 cho vẽ và bắt chạm
	var button_size := Vector2(48.0, 48.0)

	# Close button
	var close_rect := Rect2(
		size.x - 66.0,
		0.0,
		button_size.x,
		button_size.y
	)
	draw_rect(close_rect, Color(0.8, 0.2, 0.2, 0.9), true)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(size.x - 60.0, 36.0),
		"ĐÓNG",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		14,
		Color.WHITE
	)

	# Zoom out (-) button
	var zoom_out_rect := Rect2(
		size.x - 155.0,
		0.0,
		button_size.x,
		button_size.y
	)
	draw_rect(zoom_out_rect, Color(0.6, 0.6, 0.6, 0.9), true)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(size.x - 150.0, 36.0),
		"−",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		24,
		Color.WHITE
	)

	# Zoom in (+) button
	var zoom_in_rect := Rect2(
		size.x - 112.0,
		0.0,
		button_size.x,
		button_size.y
	)
	draw_rect(zoom_in_rect, Color(0.6, 0.6, 0.6, 0.9), true)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(size.x - 106.0, 36.0),
		"+",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		24,
		Color.WHITE
	)

	var map_rect := _full_map_rect()
	draw_rect(map_rect, Color(0.20, 0.35, 0.22), true)

	# Sử dụng MINI_RADIUS thay vì WORLD_HALF_SIZE
	var scale_x := map_rect.size.x / (MINI_RADIUS * 2.0)
	var scale_y := map_rect.size.y / (MINI_RADIUS * 2.0)

	var world_points: Array[Vector2] = WorldNavigation.get_road_points()
	for i in range(world_points.size() - 1):
		_draw_map_line(
			map_rect,
			scale_x,
			scale_y,
			world_points[i],
			world_points[i + 1],
			Color(0.25, 0.26, 0.26),
			maxf(2.0, scale_x * 3.0)
		)

	if _route.size() >= 2:
		for route_index in range(_route.size() - 1):
			var route_start: Vector3 = _route[route_index]
			var route_end: Vector3 = _route[route_index + 1]
			_draw_map_line(map_rect, scale_x, scale_y, Vector2(route_start.x, route_start.z), Vector2(route_end.x, route_end.z), Color(1.0, 0.78, 0.20), maxf(2.5, scale_x * 2.5))

	if _has_player_position:
		var player_point := _world_to_full_map(
			map_rect,
			scale_x,
			scale_y,
			_player_position.x,
			_player_position.z
		)
		draw_circle(player_point, 7.0, Color.WHITE)
		draw_circle(player_point, 4.5, Color(1.0, 0.35, 0.08))

	for npc_entry: Dictionary in _npc_positions:
		var npc_position_value: Variant = npc_entry.get("position")
		if not (npc_position_value is Vector3):
			continue
		var npc_position: Vector3 = npc_position_value as Vector3
		var npc_point := _world_to_full_map(
			map_rect,
			scale_x,
			scale_y,
			npc_position.x,
			npc_position.z
		)
		if map_rect.has_point(npc_point):
			draw_circle(
				npc_point,
				clampf(5.0 * _map_zoom, 3.0, 8.0),
				Color(0.15, 0.9, 1.0)
			)
			draw_circle(npc_point, 2.0, Color(0.02, 0.12, 0.2))

	if _has_waypoint:
		var target := _world_to_full_map(
			map_rect,
			scale_x,
			scale_y,
			_waypoint.x,
			_waypoint.z
		)
		draw_circle(target, 7.0, Color(1.0, 0.82, 0.12))
		draw_circle(target, 3.0, Color(0.25, 0.18, 0.05))

	var zoom_label := "Zoom: " + str(snappedf(_map_zoom, 0.1)) + "x"

	draw_string(
		ThemeDB.fallback_font,
		Vector2(20.0, size.y - 10.0),
		zoom_label + "  |  Kéo để di chuyển, chụm/xòe để zoom",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		12,
		Color(0.86, 0.88, 0.82)
	)


func _draw_map_line(
	map_rect: Rect2,
	scale_x: float,
	scale_y: float,
	start_world: Vector2,
	end_world: Vector2,
	color: Color,
	width: float
) -> void:
	var start_point := _world_to_full_map(
		map_rect, scale_x, scale_y, start_world.x, start_world.y
	)
	var end_point := _world_to_full_map(
		map_rect, scale_x, scale_y, end_world.x, end_world.y
	)

	draw_line(
		start_point,
		end_point,
		color,
		width * _map_zoom,
		true
	)


func _world_to_full_map(
	map_rect: Rect2,
	scale_x: float,
	scale_y: float,
	world_x: float,
	world_z: float
) -> Vector2:
	var base_point := Vector2(
		map_rect.position.x + (world_x + MINI_RADIUS) * scale_x,
		map_rect.position.y + (world_z + MINI_RADIUS) * scale_y
	)

	return (
		map_rect.get_center()
		+ _map_pan
		+ (base_point - map_rect.get_center()) * _map_zoom
	)


func _map_to_world(position: Vector2) -> Vector2:
	var map_rect := _full_map_rect()
	var base_position := (
		map_rect.get_center()
		+ (position - map_rect.get_center() - _map_pan) / _map_zoom
	)

	var scale_x := map_rect.size.x / (MINI_RADIUS * 2.0)
	var scale_y := map_rect.size.y / (MINI_RADIUS * 2.0)

	return Vector2(
		(base_position.x - map_rect.position.x) / scale_x - MINI_RADIUS,
		(base_position.y - map_rect.position.y) / scale_y - MINI_RADIUS
	)


func _screen_to_local(screen_position: Vector2) -> Vector2:
	return get_global_transform_with_canvas().affine_inverse() * screen_position
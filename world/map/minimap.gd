extends Control
class_name WorldMinimap

var player: Node3D
var map_type: String = "open_world"

const WORLD_HALF_SIZE := 150.0
const MINI_SIZE := 144.0
const MINI_ORIGIN := Vector2(8.0, 24.0)

var _world_map_open := false
var _waypoint := Vector3.ZERO
var _has_waypoint := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_INHERIT


func _process(_delta: float) -> void:
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_handle_map_tap(event.position)
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_map_tap(event.position)


func _handle_map_tap(position: Vector2) -> void:
	if not _world_map_open:
		_world_map_open = true
		_has_waypoint = false
		accept_event()
		queue_redraw()
		return

	if position.y < 64.0 and position.x > size.x - 100.0:
		_world_map_open = false
		accept_event()
		queue_redraw()
		return

	var world_position := _map_to_world(position)
	_waypoint = Vector3(world_position.x, 0.0, world_position.y)
	_has_waypoint = true
	_world_map_open = false

	accept_event()
	queue_redraw()


func _draw() -> void:
	if _world_map_open:
		_draw_full_map()
	else:
		_draw_minimap()


func _draw_minimap() -> void:
	var rect := Rect2(Vector2.ZERO, size)

	draw_rect(rect, Color(0.025, 0.04, 0.055, 0.90), true)
	draw_rect(rect, Color(0.72, 0.78, 0.78, 0.95), false, 1.5)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(10.0, 17.0),
		"THẾ GIỚI",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		11,
		Color(0.95, 0.95, 0.88)
	)

	var center := Vector2(size.x * 0.5, size.y * 0.57)
	var map_rect := Rect2(
		center - Vector2(MINI_SIZE, MINI_SIZE) * 0.5,
		Vector2(MINI_SIZE, MINI_SIZE)
	)

	draw_rect(map_rect, Color(0.20, 0.34, 0.22), true)

	# Duong chinh.
	draw_line(
		Vector2(center.x, map_rect.position.y),
		Vector2(center.x, map_rect.end.y),
		Color(0.24, 0.25, 0.25),
		8.0
	)
	draw_line(
		Vector2(map_rect.position.x, center.y),
		Vector2(map_rect.end.x, center.y),
		Color(0.24, 0.25, 0.25),
		6.0
	)

	# Kenh nuoc.
	draw_line(
		Vector2(center.x + 13.0, map_rect.position.y),
		Vector2(center.x + 13.0, map_rect.end.y),
		Color(0.07, 0.35, 0.52),
		5.0
	)

	# Cac truc duong khu dan cu.
	for offset in [-31.0, 31.0]:
		draw_line(
			Vector2(center.x + offset, map_rect.position.y),
			Vector2(center.x + offset, map_rect.end.y),
			Color(0.28, 0.29, 0.27),
			3.0
		)

	if is_instance_valid(player):
		draw_circle(center, 5.0, Color.WHITE)
		draw_circle(center, 3.2, Color(1.0, 0.35, 0.08))

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


func _draw_full_map() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.025, 0.035, 0.045, 0.97), true)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(20.0, 36.0),
		"BẢN ĐỒ THẾ GIỚI",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		20,
		Color(0.96, 0.94, 0.84)
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(size.x - 86.0, 36.0),
		"ĐÓNG  X",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		14,
		Color(1.0, 0.85, 0.55)
	)

	var map_rect := Rect2(
		Vector2(16.0, 54.0),
		Vector2(size.x - 32.0, size.y - 76.0)
	)

	draw_rect(map_rect, Color(0.20, 0.35, 0.22), true)

	var scale_x := map_rect.size.x / (WORLD_HALF_SIZE * 2.0)
	var scale_y := map_rect.size.y / (WORLD_HALF_SIZE * 2.0)

	# Kenh nuoc doc.
	var canal_x := map_rect.position.x + (175.0 * scale_x)
	draw_line(
		Vector2(canal_x, map_rect.position.y),
		Vector2(canal_x, map_rect.end.y),
		Color(0.06, 0.34, 0.52),
		maxf(4.0, scale_x * 5.2)
	)

	# Duong chinh doc va ngang.
	for x_position in [-65.0, 0.0, 65.0]:
		var px: float = map_rect.position.x + (float(x_position) + WORLD_HALF_SIZE) * scale_x
		draw_line(
			Vector2(px, map_rect.position.y),
			Vector2(px, map_rect.end.y),
			Color(0.25, 0.26, 0.26),
			maxf(2.0, scale_x * 7.0)
		)

	for z_position in [-90.0, -12.0, 70.0]:
		var py: float = map_rect.position.y + (float(z_position) + WORLD_HALF_SIZE) * scale_y
		draw_line(
			Vector2(map_rect.position.x, py),
			Vector2(map_rect.end.x, py),
			Color(0.25, 0.26, 0.26),
			maxf(2.0, scale_y * 7.0)
		)

	# Cum nha o trung tam.
	for row in range(6):
		var z_position := -34.0 + float(row) * 13.0
		_draw_full_map_building(map_rect, scale_x, scale_y, -13.0, z_position)
		_draw_full_map_building(map_rect, scale_x, scale_y, 13.0, z_position)

	# Cac cum nha o ngoai vi.
	for row in range(4):
		var z_position := -125.0 + float(row) * 22.0
		_draw_full_map_building(map_rect, scale_x, scale_y, -85.0, z_position)
		_draw_full_map_building(map_rect, scale_x, scale_y, 85.0, z_position)

	for row in range(3):
		var z_position := 88.0 + float(row) * 20.0
		_draw_full_map_building(map_rect, scale_x, scale_y, -85.0, z_position)
		_draw_full_map_building(map_rect, scale_x, scale_y, 85.0, z_position)

	# Vi tri nguoi choi.
	if is_instance_valid(player):
		var player_point := _world_to_full_map(
			map_rect,
			scale_x,
			scale_y,
			player.global_position.x,
			player.global_position.z
		)
		draw_circle(player_point, 7.0, Color.WHITE)
		draw_circle(player_point, 4.5, Color(1.0, 0.35, 0.08))

	# Diem den.
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

	draw_string(
		ThemeDB.fallback_font,
		Vector2(20.0, size.y - 10.0),
		"Chạm vào bản đồ để đặt điểm đến",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		12,
		Color(0.86, 0.88, 0.82)
	)


func _draw_full_map_building(
	map_rect: Rect2,
	scale_x: float,
	scale_y: float,
	world_x: float,
	world_z: float
) -> void:
	var point := _world_to_full_map(
		map_rect,
		scale_x,
		scale_y,
		world_x,
		world_z
	)
	var building_size := Vector2(
		maxf(3.0, 5.0 * scale_x),
		maxf(3.0, 6.0 * scale_y)
	)
	draw_rect(
		Rect2(point - building_size * 0.5, building_size),
		Color(0.76, 0.61, 0.43),
		true
	)


func _world_to_full_map(
	map_rect: Rect2,
	scale_x: float,
	scale_y: float,
	world_x: float,
	world_z: float
) -> Vector2:
	return Vector2(
		map_rect.position.x + (world_x + WORLD_HALF_SIZE) * scale_x,
		map_rect.position.y + (world_z + WORLD_HALF_SIZE) * scale_y
	)


func _map_to_world(position: Vector2) -> Vector2:
	var map_rect := Rect2(
		Vector2(16.0, 54.0),
		Vector2(size.x - 32.0, size.y - 76.0)
	)

	var scale_x := map_rect.size.x / (WORLD_HALF_SIZE * 2.0)
	var scale_y := map_rect.size.y / (WORLD_HALF_SIZE * 2.0)

	return Vector2(
		(position.x - map_rect.position.x) / scale_x - WORLD_HALF_SIZE,
		(position.y - map_rect.position.y) / scale_y - WORLD_HALF_SIZE
	)


func _world_to_minimap(world_x: float, world_z: float) -> Vector2:
	if not is_instance_valid(player):
		return Vector2(size.x * 0.5, size.y * 0.57)

	var center := Vector2(size.x * 0.5, size.y * 0.57)
	var relative := Vector2(
		world_x - player.global_position.x,
		world_z - player.global_position.z
	)
	return center + relative * 0.45

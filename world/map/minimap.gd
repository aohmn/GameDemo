extends Control
class_name WorldMinimap

var player: Node3D
var map_type: String = "residential"

const MAP_RECT := Rect2(12.0, 24.0, 136.0, 136.0)
const MAP_ORIGIN := Vector2(12.0, 24.0)
const MAP_SCALE := 1.36


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_INHERIT


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(
		Rect2(Vector2.ZERO, size),
		Color(0.025, 0.04, 0.055, 0.90),
		true
	)
	draw_rect(
		Rect2(Vector2.ZERO, size),
		Color(0.72, 0.78, 0.78, 0.95),
		false,
		1.5
	)

	var title := "HO CAU" if map_type == "fishing_lake" else "KHU DAN CU"
	draw_string(
		ThemeDB.fallback_font,
		Vector2(10.0, 17.0),
		title,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		11,
		Color(0.95, 0.95, 0.88)
	)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(142.0, 17.0),
		"N",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		10,
		Color(0.95, 0.95, 0.88)
	)

	draw_rect(MAP_RECT, Color(0.19, 0.29, 0.19), true)

	if map_type == "fishing_lake":
		_draw_lake()
	else:
		_draw_residential()

	draw_rect(
		MAP_RECT,
		Color(0.66, 0.73, 0.67),
		false,
		1.0
	)

	if is_instance_valid(player):
		var marker := _world_to_map(
			player.global_position.x,
			player.global_position.z
		)
		marker.x = clampf(marker.x, MAP_RECT.position.x + 3.0, MAP_RECT.end.x - 3.0)
		marker.y = clampf(marker.y, MAP_RECT.position.y + 3.0, MAP_RECT.end.y - 3.0)

		draw_circle(marker, 5.0, Color(1.0, 1.0, 1.0, 0.95))
		draw_circle(marker, 3.2, Color(1.0, 0.35, 0.08, 1.0))


func _world_to_map(world_x: float, world_z: float) -> Vector2:
	return Vector2(
		MAP_ORIGIN.x + (world_x + 50.0) * MAP_SCALE,
		MAP_ORIGIN.y + (world_z + 50.0) * MAP_SCALE
	)


func _draw_world_rect(
	center_x: float,
	center_z: float,
	world_width: float,
	world_depth: float,
	color: Color
) -> void:
	var top_left := _world_to_map(
		center_x - world_width * 0.5,
		center_z - world_depth * 0.5
	)
	var bottom_right := _world_to_map(
		center_x + world_width * 0.5,
		center_z + world_depth * 0.5
	)
	draw_rect(
		Rect2(top_left, bottom_right - top_left),
		color,
		true
	)


func _draw_residential() -> void:
	# Duong chinh va duong ngang.
	draw_line(
		_world_to_map(0.0, -50.0),
		_world_to_map(0.0, 50.0),
		Color(0.25, 0.27, 0.28),
		10.0
	)
	draw_line(
		_world_to_map(-50.0, -12.0),
		_world_to_map(50.0, -12.0),
		Color(0.25, 0.27, 0.28),
		10.0
	)

	# Kenh nuoc ben phai.
	draw_line(
		_world_to_map(25.0, -50.0),
		_world_to_map(25.0, 50.0),
		Color(0.08, 0.36, 0.52),
		7.0
	)

	# Cac day nha.
	for index in range(6):
		var z_position := -34.0 + float(index) * 13.0
		_draw_world_rect(
			-13.0,
			z_position,
			5.0,
			6.0,
			Color(0.72, 0.57, 0.39)
		)
		_draw_world_rect(
			13.0,
			z_position,
			5.0,
			6.0,
			Color(0.77, 0.65, 0.48)
		)

	# Via he.
	draw_line(
		_world_to_map(-5.8, -50.0),
		_world_to_map(-5.8, 50.0),
		Color(0.58, 0.56, 0.47),
		2.0
	)
	draw_line(
		_world_to_map(5.8, -50.0),
		_world_to_map(5.8, 50.0),
		Color(0.58, 0.56, 0.47),
		2.0
	)


func _draw_lake() -> void:
	# Bo ho.
	_draw_world_rect(
		0.0,
		-6.0,
		35.0,
		29.0,
		Color(0.48, 0.40, 0.27)
	)

	# Mat nuoc.
	_draw_world_rect(
		0.0,
		-6.0,
		31.0,
		25.0,
		Color(0.07, 0.34, 0.49)
	)

	# Duong dat va ben cau.
	_draw_world_rect(
		0.0,
		14.0,
		4.0,
		15.0,
		Color(0.65, 0.48, 0.29)
	)
	_draw_world_rect(
		0.0,
		0.0,
		3.5,
		12.0,
		Color(0.35, 0.22, 0.13)
	)

	# Cay quanh ho.
	var tree_positions: Array[Vector2] = [
		Vector2(-23.0, -24.0),
		Vector2(-30.0, -8.0),
		Vector2(-23.0, 12.0),
		Vector2(23.0, -24.0),
		Vector2(30.0, -8.0),
		Vector2(23.0, 12.0),
		Vector2(-10.0, 30.0),
		Vector2(10.0, 30.0)
	]

	for tree_position in tree_positions:
		draw_circle(
			_world_to_map(tree_position.x, tree_position.y),
			2.2,
			Color(0.16, 0.42, 0.19)
		)

extends Node3D
class_name Map3DController

const WORLD_SIZE := 300.0
const TRAVEL_META_KEY := "projectgame_spawn_point_id"

const MINIMAP_SCRIPT: Script = preload("res://world/map/minimap.gd")
const SURFACE_SHADER: Shader = preload("res://world/map/shaders/procedural_surface.gdshader")

@export var map_type: String = "residential"
@export_file("*.tscn") var destination_scene_path: String = ""
@export var destination_name: String = ""
@export var destination_spawn_point_id: StringName = &""
@export var local_spawn_point_id: StringName = &"residential_entry"
@export var local_spawn_position: Vector3 = Vector3(0.0, 0.05, 12.0)

@onready var player: CharacterBody3D = $Player

var _transitioning := false


func _ready() -> void:
	map_type = "open_world"

	_build_environment()
	_build_ground()
	_build_roads()
	_build_canal()
	_build_buildings()
	_build_trees()
	_build_expanded_world()
	_build_world_boundaries()

	_apply_spawn()
	_build_minimap()

	print("[World] Continuous world loaded.")


# --------------------------------------------------
# ENVIRONMENT
# --------------------------------------------------

func _build_environment() -> void:
	var world_environment := WorldEnvironment.new()
	var environment_data := Environment.new()

	environment_data.background_mode = Environment.BG_COLOR
	environment_data.background_color = Color(0.52, 0.72, 0.86)
	environment_data.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment_data.ambient_light_color = Color(0.82, 0.86, 0.92)
	environment_data.ambient_light_energy = 0.82
	environment_data.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment_data.tonemap_exposure = 1.0
	environment_data.fog_enabled = true
	environment_data.fog_light_color = Color(0.66, 0.76, 0.81)
	environment_data.fog_density = 0.0018

	world_environment.environment = environment_data
	add_child(world_environment)

	var sunlight := DirectionalLight3D.new()
	sunlight.rotation_degrees = Vector3(-52.0, -32.0, 0.0)
	sunlight.light_energy = 1.25
	sunlight.light_color = Color(1.0, 0.93, 0.82)
	sunlight.shadow_enabled = true
	sunlight.directional_shadow_max_distance = 85.0
	add_child(sunlight)


func _build_ground() -> void:
	_add_ground_piece(
		"Ground",
		Vector3(WORLD_SIZE, 0.5, WORLD_SIZE),
		Vector3(0.0, -0.25, 0.0)
	)


func _build_lake_ground() -> void:
	# Chừa khoảng trống bên dưới hồ để nhân vật không đi trên mặt nước.
	_add_ground_piece(
		"GroundNorth",
		Vector3(100.0, 0.5, 31.0),
		Vector3(0.0, -0.25, -34.5)
	)

	_add_ground_piece(
		"GroundSouth",
		Vector3(100.0, 0.5, 43.0),
		Vector3(0.0, -0.25, 28.5)
	)

	_add_ground_piece(
		"GroundWest",
		Vector3(34.0, 0.5, 100.0),
		Vector3(-33.0, -0.25, 0.0)
	)

	_add_ground_piece(
		"GroundEast",
		Vector3(34.0, 0.5, 100.0),
		Vector3(33.0, -0.25, 0.0)
	)


func _add_ground_piece(
	object_name: String,
	box_size: Vector3,
	world_position: Vector3
) -> void:
	_add_box(
		object_name,
		box_size,
		world_position,
		Color(0.29, 0.48, 0.23)
	)

	var body := StaticBody3D.new()
	body.name = object_name + "Collision"

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = box_size
	collision.shape = shape

	body.position = world_position
	body.add_child(collision)
	add_child(body)


# --------------------------------------------------
# WORLD BOUNDARIES AND FALL PROTECTION
# --------------------------------------------------

func _build_world_boundaries() -> void:
	# Tường collision vô hình giữ Player trong phạm vi mặt đất.
	_add_collision_wall(
		"BoundaryWest",
		Vector3(2.0, 8.0, WORLD_SIZE),
		Vector3(-149.0, 4.0, 0.0)
	)
	_add_collision_wall(
		"BoundaryEast",
		Vector3(2.0, 8.0, WORLD_SIZE),
		Vector3(149.0, 4.0, 0.0)
	)
	_add_collision_wall(
		"BoundaryNorth",
		Vector3(WORLD_SIZE, 8.0, 2.0),
		Vector3(0.0, 4.0, -149.0)
	)
	_add_collision_wall(
		"BoundarySouth",
		Vector3(WORLD_SIZE, 8.0, 2.0),
		Vector3(0.0, 4.0, 149.0)
	)


func _build_lake_water_barriers() -> void:
	# Chặn ba cạnh hồ và chừa lối đi ở giữa bờ phía nam.
	_add_collision_wall(
		"LakeBarrierNorth",
		Vector3(31.0, 2.0, 1.0),
		Vector3(0.0, 1.0, -18.5)
	)
	_add_collision_wall(
		"LakeBarrierWest",
		Vector3(1.0, 2.0, 25.0),
		Vector3(-15.5, 1.0, -6.0)
	)
	_add_collision_wall(
		"LakeBarrierEast",
		Vector3(1.0, 2.0, 25.0),
		Vector3(15.5, 1.0, -6.0)
	)

	# Hai đoạn tường phía nam, chừa lối rộng 4.5 đơn vị.
	_add_collision_wall(
		"LakeBarrierSouthLeft",
		Vector3(13.25, 2.0, 1.0),
		Vector3(-8.875, 1.0, 6.5)
	)
	_add_collision_wall(
		"LakeBarrierSouthRight",
		Vector3(13.25, 2.0, 1.0),
		Vector3(8.875, 1.0, 6.5)
	)


func _add_collision_wall(
	object_name: String,
	box_size: Vector3,
	world_position: Vector3
) -> void:
	var body := StaticBody3D.new()
	body.name = object_name
	body.position = world_position
	body.collision_layer = 1
	body.collision_mask = 1

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = box_size
	collision.shape = shape

	body.add_child(collision)
	add_child(body)


# --------------------------------------------------
# MAP 01: RESIDENTIAL DISTRICT
# --------------------------------------------------

func _build_roads() -> void:
	_add_box(
		"RoadShoulderMain",
		Vector3(11.0, 0.12, WORLD_SIZE),
		Vector3(0.0, 0.02, 0.0),
		Color(0.48, 0.43, 0.34)
	)

	_add_box(
		"MainRoad",
		Vector3(8.0, 0.10, WORLD_SIZE),
		Vector3(0.0, 0.09, 0.0),
		Color(0.17, 0.19, 0.20)
	)

	_add_box(
		"CrossRoad",
		Vector3(WORLD_SIZE, 0.10, 8.0),
		Vector3(0.0, 0.10, -12.0),
		Color(0.17, 0.19, 0.20)
	)

	for index in range(-16, 17, 3):
		_add_box(
			"RoadMarking",
			Vector3(0.16, 0.025, 1.5),
			Vector3(0.0, 0.16, float(index) * 2.5),
			Color(0.90, 0.87, 0.72)
		)

	_add_box(
		"SidewalkLeft",
		Vector3(1.5, 0.20, WORLD_SIZE),
		Vector3(-5.8, 0.10, 0.0),
		Color(0.57, 0.55, 0.47)
	)

	_add_box(
		"SidewalkRight",
		Vector3(1.5, 0.20, WORLD_SIZE),
		Vector3(5.8, 0.10, 0.0),
		Color(0.57, 0.55, 0.47)
	)


func _build_canal() -> void:
	_add_box(
		"CanalBankLeft",
		Vector3(1.2, 0.45, WORLD_SIZE),
		Vector3(21.8, 0.20, 0.0),
		Color(0.43, 0.48, 0.31)
	)

	_add_box(
		"CanalBankRight",
		Vector3(1.2, 0.45, WORLD_SIZE),
		Vector3(28.2, 0.20, 0.0),
		Color(0.43, 0.48, 0.31)
	)

	_add_box(
		"CanalWater",
		Vector3(5.2, 0.12, WORLD_SIZE),
		Vector3(25.0, -0.08, 0.0),
		Color(0.08, 0.34, 0.48)
	)


func _build_buildings() -> void:
	var wall_colors: Array[Color] = [
		Color(0.78, 0.65, 0.48),
		Color(0.76, 0.75, 0.63),
		Color(0.72, 0.49, 0.37),
		Color(0.67, 0.72, 0.65),
		Color(0.82, 0.76, 0.62)
	]

	for index in range(6):
		var z_position := -34.0 + float(index) * 13.0
		var wall_color: Color = wall_colors[index % wall_colors.size()]

		_build_house(
			Vector3(-13.0, 0.0, z_position),
			wall_color
		)

		_build_house(
			Vector3(13.0, 0.0, z_position),
			wall_color.darkened(0.08)
		)


func _build_house(
	world_position: Vector3,
	wall_color: Color
) -> void:
	var house := StaticBody3D.new()
	house.name = "VietnameseHouse"
	house.position = world_position
	add_child(house)

	var body := _make_box_node(
		"HouseBody",
		Vector3(5.0, 3.0, 6.0),
		Vector3(0.0, 1.5, 0.0),
		wall_color
	)
	house.add_child(body)

	var collision := CollisionShape3D.new()
	var collision_shape := BoxShape3D.new()
	collision_shape.size = Vector3(5.0, 3.0, 6.0)
	collision.shape = collision_shape
	collision.position.y = 1.5
	house.add_child(collision)

	house.add_child(
		_make_box_node(
			"FlatRoof",
			Vector3(5.4, 0.35, 6.4),
			Vector3(0.0, 3.15, 0.0),
			Color(0.35, 0.27, 0.23)
		)
	)

	var front_direction := 1.0
	if world_position.x > 0.0:
		front_direction = -1.0

	house.add_child(
		_make_box_node(
			"FrontDoor",
			Vector3(0.08, 1.8, 0.9),
			Vector3(front_direction * 2.54, 0.9, 0.0),
			Color(0.30, 0.19, 0.12)
		)
	)

	for index in range(2):
		var window_z := -1.45 + float(index) * 2.9

		house.add_child(
			_make_box_node(
				"FrontWindow",
				Vector3(0.08, 0.75, 1.0),
				Vector3(front_direction * 2.55, 2.0, window_z),
				Color(0.20, 0.48, 0.59)
			)
		)


func _build_trees() -> void:
	for index in range(12):
		var z_position := -35.0 + float(index) * 6.0
		_build_tree(Vector3(-8.0, 0.0, z_position))
		_build_tree(Vector3(8.0, 0.0, z_position))


# --------------------------------------------------
# EXPANDED WORLD: OUTER DISTRICTS
# --------------------------------------------------

func _build_expanded_world() -> void:
	# Hai truc duong phu ket noi cac cum dan cu.
	for x_position in [-65.0, 65.0]:
		_add_box(
			"DistrictRoad",
			Vector3(7.0, 0.10, WORLD_SIZE),
			Vector3(x_position, 0.08, 0.0),
			Color(0.20, 0.22, 0.22)
		)

	# Duong ngang ket noi cac khu vuc.
	for z_position in [-90.0, 70.0]:
		_add_box(
			"DistrictCrossRoad",
			Vector3(WORLD_SIZE, 0.10, 7.0),
			Vector3(0.0, 0.08, z_position),
			Color(0.20, 0.22, 0.22)
		)

	# Cum nha dan cu phia bac va phia nam.
	var district_colors: Array[Color] = [
		Color(0.76, 0.67, 0.53),
		Color(0.72, 0.74, 0.66),
		Color(0.78, 0.58, 0.43),
		Color(0.68, 0.72, 0.70)
	]

	for row in range(4):
		var z_position := -125.0 + float(row) * 22.0
		var wall_color: Color = district_colors[row % district_colors.size()]

		_build_house(Vector3(-85.0, 0.0, z_position), wall_color)
		_build_house(Vector3(85.0, 0.0, z_position), wall_color.darkened(0.08))

	for row in range(3):
		var z_position := 88.0 + float(row) * 20.0
		var wall_color: Color = district_colors[(row + 1) % district_colors.size()]

		_build_house(Vector3(-85.0, 0.0, z_position), wall_color)
		_build_house(Vector3(85.0, 0.0, z_position), wall_color.darkened(0.08))

	# Mang cay xanh o cac khu vuc chuyen tiep.
	for index in range(12):
		var z_position := -135.0 + float(index) * 24.0
		_build_tree(Vector3(-112.0, 0.0, z_position))
		_build_tree(Vector3(112.0, 0.0, z_position))

	# Cac o dat xanh phia ngoai khu dan cu.
	_add_box(
		"GreenFieldWest",
		Vector3(28.0, 0.06, 250.0),
		Vector3(-130.0, 0.01, 0.0),
		Color(0.25, 0.43, 0.20)
	)
	_add_box(
		"GreenFieldEast",
		Vector3(28.0, 0.06, 250.0),
		Vector3(130.0, 0.01, 0.0),
		Color(0.25, 0.43, 0.20)
	)


# --------------------------------------------------
# MAP 02: FISHING LAKE
# --------------------------------------------------

func _build_fishing_lake() -> void:
	# Mặt hồ.
	_add_box(
		"LakeWater",
		Vector3(31.0, 0.12, 25.0),
		Vector3(0.0, -0.12, -6.0),
		Color(0.06, 0.32, 0.47)
	)

	# Bờ hồ.
	_add_box(
		"LakeBankNorth",
		Vector3(35.0, 0.35, 1.5),
		Vector3(0.0, 0.12, -19.5),
		Color(0.48, 0.43, 0.29)
	)

	_add_box(
		"LakeBankSouth",
		Vector3(35.0, 0.35, 1.5),
		Vector3(0.0, 0.12, 7.5),
		Color(0.48, 0.43, 0.29)
	)

	_add_box(
		"LakeBankWest",
		Vector3(1.5, 0.35, 27.0),
		Vector3(-16.5, 0.12, -6.0),
		Color(0.48, 0.43, 0.29)
	)

	_add_box(
		"LakeBankEast",
		Vector3(1.5, 0.35, 27.0),
		Vector3(16.5, 0.12, -6.0),
		Color(0.48, 0.43, 0.29)
	)

	# Đường đất từ Spawn Point đến bến câu.
	_add_box(
		"DirtPath",
		Vector3(4.0, 0.08, 15.0),
		Vector3(0.0, 0.04, 14.0),
		Color(0.52, 0.39, 0.24)
	)

	# Bến câu có va chạm để nhân vật đi lên được.
	_add_static_box(
		"FishingDock",
		Vector3(3.5, 0.35, 12.0),
		Vector3(0.0, 0.25, 0.0),
		Color(0.39, 0.25, 0.14)
	)

	# Cây quanh hồ.
	_build_tree(Vector3(-23.0, 0.0, -24.0))
	_build_tree(Vector3(-30.0, 0.0, -8.0))
	_build_tree(Vector3(-23.0, 0.0, 12.0))
	_build_tree(Vector3(23.0, 0.0, -24.0))
	_build_tree(Vector3(30.0, 0.0, -8.0))
	_build_tree(Vector3(23.0, 0.0, 12.0))
	_build_tree(Vector3(-10.0, 0.0, 30.0))
	_build_tree(Vector3(10.0, 0.0, 30.0))


func _add_static_box(
	object_name: String,
	box_size: Vector3,
	world_position: Vector3,
	color: Color
) -> void:
	var body := StaticBody3D.new()
	body.name = object_name
	body.position = world_position

	var mesh_node := _make_box_node(
		object_name + "Mesh",
		box_size,
		Vector3.ZERO,
		color
	)
	body.add_child(mesh_node)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = box_size
	collision.shape = shape
	body.add_child(collision)

	add_child(body)


# --------------------------------------------------
# SHARED TREE AND MESH HELPERS
# --------------------------------------------------

func _build_tree(world_position: Vector3) -> void:
	var tree := Node3D.new()
	tree.name = "LowPolyTree"
	tree.position = world_position
	add_child(tree)

	var trunk := CylinderMesh.new()
	trunk.top_radius = 0.16
	trunk.bottom_radius = 0.24
	trunk.height = 2.0

	var trunk_node := MeshInstance3D.new()
	trunk_node.mesh = trunk
	trunk_node.position.y = 1.0
	trunk_node.material_override = _make_material(
		Color(0.31, 0.20, 0.12)
	)
	tree.add_child(trunk_node)

	var crown := SphereMesh.new()
	crown.radius = 1.0
	crown.height = 2.0
	crown.radial_segments = 8
	crown.rings = 4

	var crown_node := MeshInstance3D.new()
	crown_node.mesh = crown
	crown_node.position.y = 2.5
	crown_node.material_override = _make_material(
		Color(0.17, 0.39, 0.17)
	)
	tree.add_child(crown_node)


func _add_box(
	object_name: String,
	box_size: Vector3,
	world_position: Vector3,
	color: Color
) -> void:
	add_child(
		_make_box_node(
			object_name,
			box_size,
			world_position,
			color
		)
	)


func _make_box_node(
	object_name: String,
	box_size: Vector3,
	local_position: Vector3,
	color: Color
) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = box_size

	var instance := MeshInstance3D.new()
	instance.name = object_name
	instance.mesh = mesh
	instance.position = local_position
	instance.material_override = _make_material(color)
	return instance


func _make_material(color: Color) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = SURFACE_SHADER
	material.set_shader_parameter("base_color", color)
	material.set_shader_parameter("roughness_value", 0.88)
	material.set_shader_parameter("surface_detail", 0.018)
	return material


# --------------------------------------------------
# MAP TRANSITION
# --------------------------------------------------

func _build_transition() -> void:
	var transition := Area3D.new()
	transition.name = "MapTransition"
	transition.collision_layer = 0
	transition.collision_mask = 1

	if map_type == "fishing_lake":
		transition.position = Vector3(0.0, 1.0, 43.0)
	else:
		transition.position = Vector3(0.0, 1.0, -43.0)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(5.0, 3.0, 5.0)
	collision.shape = shape
	transition.add_child(collision)

	var sign := Label3D.new()
	sign.name = "DestinationName"
	sign.text = destination_name
	sign.position = Vector3(0.0, 2.0, 0.0)
	sign.font_size = 48
	sign.outline_size = 8
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sign.no_depth_test = true
	transition.add_child(sign)

	transition.body_entered.connect(_on_transition_body_entered)
	add_child(transition)


func _on_transition_body_entered(body: Node3D) -> void:
	if body != player or _transitioning:
		return

	if destination_scene_path.is_empty():
		push_error("[World] Destination scene path is empty.")
		return

	if not ResourceLoader.exists(destination_scene_path, "PackedScene"):
		push_error(
			"[World] Destination scene not found: "
			+ destination_scene_path
		)
		return

	_transitioning = true

	get_tree().set_meta(
		TRAVEL_META_KEY,
		String(destination_spawn_point_id)
	)

	# Đổi scene sau khi kết thúc physics callback.
	call_deferred("_change_destination_scene")


func _change_destination_scene() -> void:
	var result := get_tree().change_scene_to_file(
		destination_scene_path
	)

	if result != OK:
		push_error(
			"[World] Cannot change scene. Error: "
			+ str(result)
		)
		get_tree().remove_meta(TRAVEL_META_KEY)
		_transitioning = false


func _apply_spawn() -> void:
	var spawn_position := local_spawn_position

	if get_tree().has_meta(TRAVEL_META_KEY):
		var requested_spawn := StringName(
			str(get_tree().get_meta(TRAVEL_META_KEY))
		)
		get_tree().remove_meta(TRAVEL_META_KEY)

		if requested_spawn != local_spawn_point_id:
			push_warning(
				"[World] Spawn Point ID does not match this map: "
				+ str(requested_spawn)
			)

	player.global_position = spawn_position

	print(
		"[World] Spawn: ",
		local_spawn_point_id,
		" at ",
		spawn_position
	)


# --------------------------------------------------
# MINIMAP
# --------------------------------------------------

func _build_minimap() -> void:
	var hud := get_node_or_null("HUD") as CanvasLayer
	if hud == null:
		push_warning("[World] HUD not found. Minimap skipped.")
		return

	var minimap := Control.new()
	minimap.name = "WorldMinimap"
	minimap.set_script(MINIMAP_SCRIPT)
	minimap.set("player", player)
	minimap.set("map_type", "open_world")

	minimap.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	minimap.offset_left = -176.0
	minimap.offset_top = 16.0
	minimap.offset_right = -16.0
	minimap.offset_bottom = 176.0
	minimap.z_index = 100

	hud.add_child(minimap)

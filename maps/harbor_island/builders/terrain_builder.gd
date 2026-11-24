extends RefCounted

const WATER_SHADER: Shader = preload("res://maps/harbor_island/water.gdshader")
const SAND_COLOR: Color = Color(0.92, 0.84, 0.62)
const GRASS_COLOR: Color = Color(0.38, 0.72, 0.32)
const CLIFF_COLOR: Color = Color(0.48, 0.44, 0.40)


static func build(root_node: Node3D) -> void:
	_make_environment(root_node)
	_make_ocean(root_node)
	_make_island_terrain(root_node)
	_make_mountains(root_node)
	_make_island_boundaries(root_node)


static func _make_environment(root_node: Node3D) -> void:
	var env := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_SKY
	settings.sky = Sky.new()
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	settings.ambient_light_energy = 0.85
	env.environment = settings
	root_node.add_child(env)

	var sun := DirectionalLight3D.new()
	sun.name = "TropicalSun"
	sun.rotation_degrees = Vector3(-50.0, -35.0, 0.0)
	sun.light_color = Color(1.0, 0.96, 0.88)
	sun.light_energy = 1.3
	sun.shadow_enabled = true
	root_node.add_child(sun)


static func _make_ocean(root_node: Node3D) -> void:
	var water_mesh := PlaneMesh.new()
	water_mesh.size = Vector2(600.0, 600.0)
	water_mesh.subdivide_width = 0
	water_mesh.subdivide_depth = 0

	var water_mat := ShaderMaterial.new()
	water_mat.shader = WATER_SHADER

	var water_node := MeshInstance3D.new()
	water_node.name = "OceanSurface"
	water_node.mesh = water_mesh
	water_node.position = Vector3(0.0, -0.15, 0.0)
	water_node.material_override = water_mat
	root_node.add_child(water_node)

	var seabed_pos := Vector3(0.0, -4.0, 0.0)
	var seabed_size := Vector3(80.0, 1.0, 80.0)
	_box(root_node, "Seabed", seabed_pos, seabed_size, Color(0.12, 0.35, 0.42))


static func _make_island_terrain(root_node: Node3D) -> void:
	var beach_pos := Vector3(0.0, -0.2, 4.0)
	var beach_size := Vector3(44.0, 0.4, 38.0)
	_box(root_node, "SandyBeach", beach_pos, beach_size, SAND_COLOR)
	_add_box_collider(root_node, "BeachCollision", beach_pos, beach_size)

	var plateaus: Array[Dictionary] = [
		{"name": "PlateauCenter", "pos": Vector3(0.0, 0.01, 7.0), "size": Vector3(32.0, 0.02, 22.0)},
		{"name": "PlateauNorth", "pos": Vector3(0.0, 0.01, -6.0), "size": Vector3(22.0, 0.02, 14.0)},
		{"name": "PlateauWest", "pos": Vector3(-12.0, 0.01, 3.0), "size": Vector3(14.0, 0.02, 18.0)},
		{"name": "PlateauEast", "pos": Vector3(12.0, 0.01, 3.0), "size": Vector3(14.0, 0.02, 18.0)},
	]
	for p in plateaus:
		_box(root_node, p["name"], p["pos"], p["size"], GRASS_COLOR)


static func _make_mountains(root_node: Node3D) -> void:
	var cliffs: Array[Dictionary] = [
		{"pos": Vector3(-18.0, 3.0, -4.0), "r_top": 2.5, "r_bot": 6.5, "h": 6.0},
		{"pos": Vector3(-16.0, 4.5, -12.0), "r_top": 2.0, "r_bot": 7.0, "h": 9.0},
		{"pos": Vector3(-12.5, 5.0, -18.5), "r_top": 1.5, "r_bot": 5.5, "h": 10.0},
		{"pos": Vector3(-20.0, 2.5, 6.0), "r_top": 3.0, "r_bot": 6.0, "h": 5.0},
		{"pos": Vector3(18.0, 3.0, -4.0), "r_top": 2.5, "r_bot": 6.5, "h": 6.0},
		{"pos": Vector3(16.0, 4.5, -12.0), "r_top": 2.0, "r_bot": 7.0, "h": 9.0},
		{"pos": Vector3(12.5, 5.0, -18.5), "r_top": 1.5, "r_bot": 5.5, "h": 10.0},
		{"pos": Vector3(20.0, 2.5, 6.0), "r_top": 3.0, "r_bot": 6.0, "h": 5.0},
	]

	var idx := 0
	for c in cliffs:
		idx += 1
		var cyl := CylinderMesh.new()
		cyl.top_radius = c["r_top"]
		cyl.bottom_radius = c["r_bot"]
		cyl.height = c["h"]
		var name_str := "Cliff_" + str(idx)
		_mesh(root_node, name_str, cyl, c["pos"], CLIFF_COLOR)

		var body := StaticBody3D.new()
		body.name = name_str + "Col"
		body.position = c["pos"]
		var col := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = c["r_bot"] * 0.85
		shape.height = c["h"]
		col.shape = shape
		body.add_child(col)
		root_node.add_child(body)


static func _make_island_boundaries(root_node: Node3D) -> void:
	var wall_h := 4.0
	var bounds: Array[Dictionary] = [
		{"name": "BoundWest", "pos": Vector3(-23.0, 2.0, 3.0), "size": Vector3(1.0, wall_h, 42.0)},
		{"name": "BoundEast", "pos": Vector3(23.0, 2.0, 3.0), "size": Vector3(1.0, wall_h, 42.0)},
		{"name": "BoundSouthLeft", "pos": Vector3(-16.0, 2.0, 23.5), "size": Vector3(14.0, wall_h, 1.0)},
		{"name": "BoundSouthMidLeft", "pos": Vector3(-6.75, 2.0, 10.5), "size": Vector3(4.5, wall_h, 1.0)},
		{"name": "BoundSouthRight", "pos": Vector3(11.0, 2.0, 23.5), "size": Vector3(24.0, wall_h, 1.0)},
		{"name": "BoundCoastNorthL", "pos": Vector3(-9.75, 2.0, -15.5), "size": Vector3(6.5, wall_h, 1.0)},
		{"name": "BoundCoastNorthR", "pos": Vector3(9.75, 2.0, -15.5), "size": Vector3(6.5, wall_h, 1.0)},
		{"name": "BoundBayNorthWall", "pos": Vector3(0.0, 2.0, -16.0), "size": Vector3(14.0, wall_h, 1.0)},
		{"name": "BoundCoastNorthBack", "pos": Vector3(0.0, 2.0, -18.5), "size": Vector3(46.0, wall_h, 1.0)},
	]
	for b in bounds:
		_add_box_collider(root_node, b["name"], b["pos"], b["size"])


static func _add_box_collider(root_node: Node3D, node_name: String, pos: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = pos

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape

	body.add_child(collision)
	root_node.add_child(body)


static func _box(root_node: Node3D, node_name: String, pos: Vector3, size: Vector3, color: Color) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	_mesh(root_node, node_name, mesh, pos, color)


static func _mesh(root_node: Node3D, node_name: String, mesh: Mesh, pos: Vector3, color: Color) -> void:
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = pos
	node.material_override = _mat(color)
	root_node.add_child(node)


static func _mat(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	return material

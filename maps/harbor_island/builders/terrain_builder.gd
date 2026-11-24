extends RefCounted

## TerrainBuilder — Kiến tạo địa hình Đảo Bến Cảng (Genshin x Sea of Thieves):
## Vịnh biển, bờ cát thoai thoải, cao nguyên trung tâm, vách đá dựng đứng,
## kết hợp Procedural Terrain Shader và Ocean Shader.

const WATER_SHADER: Shader = preload("res://maps/harbor_island/water.gdshader")
const TERRAIN_SHADER: Shader = preload("res://maps/harbor_island/terrain.gdshader")


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
	settings.ambient_light_energy = 0.88
	# Sương mù biển nhẹ nhàng thơ mộng phong cách Genshin
	settings.fog_enabled = true
	settings.fog_light_color = Color(0.68, 0.85, 0.95)
	settings.fog_density = 0.003
	settings.fog_sky_affect = 0.3
	env.environment = settings
	root_node.add_child(env)

	var sun := DirectionalLight3D.new()
	sun.name = "TropicalSun"
	sun.rotation_degrees = Vector3(-50.0, -35.0, 0.0)
	sun.light_color = Color(1.0, 0.96, 0.88)
	sun.light_energy = 1.35
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

	# Đáy biển sâu
	var seabed_pos := Vector3(0.0, -4.0, 0.0)
	var seabed_size := Vector3(80.0, 1.0, 80.0)
	_box(root_node, "Seabed", seabed_pos, seabed_size, Color(0.12, 0.35, 0.42))


static func _make_island_terrain(root_node: Node3D) -> void:
	var terrain_mat := ShaderMaterial.new()
	terrain_mat.shader = TERRAIN_SHADER

	# Bãi cát thoai thoải bờ biển (Beach Base)
	var beach_pos := Vector3(0.0, -0.2, 3.5)
	var beach_size := Vector3(45.0, 0.4, 38.0)
	_mesh_with_mat(root_node, "SandyBeach", _box_mesh(beach_size), beach_pos, terrain_mat)
	_add_box_collider(root_node, "BeachCollision", beach_pos, beach_size)

	# Cao nguyên đồi cỏ tự nhiên (Plateau Layers)
	var plateaus: Array[Dictionary] = [
		{"name": "PlateauCenter", "pos": Vector3(0.0, 0.02, 3.0), "size": Vector3(32.0, 0.04, 22.0)},
		{"name": "PlateauNorth", "pos": Vector3(0.0, 0.35, -7.0), "size": Vector3(22.0, 0.7, 15.0)},
		{"name": "PlateauWest", "pos": Vector3(-12.5, 0.1, 2.0), "size": Vector3(14.0, 0.2, 18.0)},
		{"name": "PlateauEast", "pos": Vector3(12.5, 0.1, 2.0), "size": Vector3(14.0, 0.2, 18.0)},
	]
	for p in plateaus:
		_mesh_with_mat(root_node, p["name"], _box_mesh(p["size"]), p["pos"], terrain_mat)
		_add_box_collider(root_node, p["name"] + "Col", p["pos"], p["size"])


static func _make_mountains(root_node: Node3D) -> void:
	var terrain_mat := ShaderMaterial.new()
	terrain_mat.shader = TERRAIN_SHADER

	var cliffs: Array[Dictionary] = [
		{"pos": Vector3(-18.5, 3.5, -4.0), "r_top": 2.5, "r_bot": 6.5, "h": 7.0},
		{"pos": Vector3(-16.0, 5.0, -13.0), "r_top": 2.0, "r_bot": 7.0, "h": 10.0},
		{"pos": Vector3(-12.5, 5.5, -19.0), "r_top": 1.5, "r_bot": 5.5, "h": 11.0},
		{"pos": Vector3(-20.0, 3.0, 7.0), "r_top": 3.0, "r_bot": 6.0, "h": 6.0},
		{"pos": Vector3(18.5, 3.5, -4.0), "r_top": 2.5, "r_bot": 6.5, "h": 7.0},
		{"pos": Vector3(16.0, 5.0, -13.0), "r_top": 2.0, "r_bot": 7.0, "h": 10.0},
		{"pos": Vector3(12.5, 5.5, -19.0), "r_top": 1.5, "r_bot": 5.5, "h": 11.0},
		{"pos": Vector3(20.0, 3.0, 7.0), "r_top": 3.0, "r_bot": 6.0, "h": 6.0},
	]

	var idx := 0
	for c in cliffs:
		idx += 1
		var cyl := CylinderMesh.new()
		cyl.top_radius = c["r_top"]
		cyl.bottom_radius = c["r_bot"]
		cyl.height = c["h"]
		var name_str := "Cliff_" + str(idx)
		_mesh_with_mat(root_node, name_str, cyl, c["pos"], terrain_mat)

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
	var wall_h := 5.0
	var bounds: Array[Dictionary] = [
		{"name": "BoundWest", "pos": Vector3(-24.0, 2.5, 3.0), "size": Vector3(1.0, wall_h, 44.0)},
		{"name": "BoundEast", "pos": Vector3(24.0, 2.5, 3.0), "size": Vector3(1.0, wall_h, 44.0)},
		{"name": "BoundSouthLeft", "pos": Vector3(-16.0, 2.5, 23.5), "size": Vector3(14.0, wall_h, 1.0)},
		{"name": "BoundSouthMidLeft", "pos": Vector3(-6.75, 2.5, 10.5), "size": Vector3(4.5, wall_h, 1.0)},
		{"name": "BoundSouthRight", "pos": Vector3(11.0, 2.5, 23.5), "size": Vector3(24.0, wall_h, 1.0)},
		{"name": "BoundCoastNorthL", "pos": Vector3(-10.0, 2.5, -16.5), "size": Vector3(7.0, wall_h, 1.0)},
		{"name": "BoundCoastNorthR", "pos": Vector3(10.0, 2.5, -16.5), "size": Vector3(7.0, wall_h, 1.0)},
		{"name": "BoundBayNorthWall", "pos": Vector3(0.0, 2.5, -18.5), "size": Vector3(16.0, wall_h, 1.0)},
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


static func _box_mesh(size: Vector3) -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh


static func _box(root_node: Node3D, node_name: String, pos: Vector3, size: Vector3, color: Color) -> void:
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = _box_mesh(size)
	node.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	node.material_override = mat
	root_node.add_child(node)


static func _mesh_with_mat(root_node: Node3D, node_name: String, mesh: Mesh, pos: Vector3, mat: Material) -> void:
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = pos
	node.material_override = mat
	root_node.add_child(node)

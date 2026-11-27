extends RefCounted

## TerrainBuilder — môi trường, ánh sáng, biển và đáy biển của Tiên Đảo Bến Cảng.
## Nền đảo bậc thang do IslandBuilder dựng, núi đá vôi do PeakBuilder dựng.

const WATER_SHADER: Shader = preload("res://maps/harbor_island/water.gdshader")
const TERRAIN_SHADER: Shader = preload("res://maps/harbor_island/terrain.gdshader")


static func build(root_node: Node3D) -> void:
	_make_environment(root_node)
	_make_ocean(root_node)


static func _make_environment(root_node: Node3D) -> void:
	var env := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_SKY
	settings.sky = Sky.new()
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	settings.ambient_light_energy = 0.8
	settings.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	# Sương mù biển nhẹ nhàng thơ mộng phong cách Genshin
	settings.fog_enabled = true
	settings.fog_light_color = Color(0.82, 0.92, 0.93)
	settings.fog_density = 0.0035
	settings.fog_sky_affect = 0.55
	env.environment = settings
	root_node.add_child(env)

	var sun := DirectionalLight3D.new()
	sun.name = "TropicalSun"
	sun.rotation_degrees = Vector3(-50.0, -35.0, 0.0)
	sun.light_color = Color(1.0, 0.93, 0.8)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	# 2 tầng bóng + làm mờ ranh giới tầng: bỏ vệt đen ngang đảo, nhẹ hơn cho Android
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	sun.directional_shadow_blend_splits = true
	sun.directional_shadow_max_distance = 70.0
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

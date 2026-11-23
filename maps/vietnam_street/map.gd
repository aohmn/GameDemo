extends Node3D

func _ready() -> void:
	_make_environment()
	_make_ground()
	_make_road()
	_make_sidewalks()
	_make_buildings()
	_make_trees()

func _make_environment() -> void:
	var env := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_SKY
	settings.sky = Sky.new()
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	settings.ambient_light_energy = 0.7
	env.environment = settings
	add_child(env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45.0, -30.0, 0.0)
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	add_child(sun)

func _make_ground() -> void:
	_box("Ground", Vector3(0.0, -0.2, 0.0), Vector3(42.0, 0.4, 42.0), Color("#82916c"))

func _make_road() -> void:
	_box("Road", Vector3(0.0, 0.02, 0.0), Vector3(7.0, 0.05, 34.0), Color("#36383b"))
	for z in range(-14, 15, 5):
		_box("LaneMark", Vector3(0.0, 0.06, float(z)), Vector3(0.15, 0.03, 2.0), Color("#e5ddbd"))

func _make_sidewalks() -> void:
	for side in [-1.0, 1.0]:
		_box("Sidewalk", Vector3(side * 4.3, 0.12, 0.0), Vector3(1.5, 0.22, 34.0), Color("#b9b4a5"))
		_box("Curb", Vector3(side * 3.62, 0.17, 0.0), Vector3(0.16, 0.28, 34.0), Color("#d4d0c3"))

func _make_buildings() -> void:
	_box("BuildingA", Vector3(-8.0, 2.8, -7.0), Vector3(5.0, 5.6, 8.0), Color("#c9a98c"))
	_box("BuildingB", Vector3(-8.0, 2.0, 8.0), Vector3(5.0, 4.0, 7.0), Color("#d4c4a4"))
	_box("BuildingC", Vector3(8.0, 3.4, -8.0), Vector3(5.0, 6.8, 7.0), Color("#aeb8b5"))
	_box("BuildingD", Vector3(8.0, 2.5, 7.0), Vector3(5.0, 5.0, 8.0), Color("#c6b39b"))

func _make_trees() -> void:
	for side in [-1.0, 1.0]:
		for z in [-12.0, -4.0, 4.0, 12.0]:
			var trunk := CylinderMesh.new()
			trunk.top_radius = 0.16
			trunk.bottom_radius = 0.22
			trunk.height = 1.6
			_mesh("TreeTrunk", trunk, Vector3(side * 5.4, 0.8, z), Color("#73533b"))

			var crown := SphereMesh.new()
			crown.radius = 0.85
			crown.height = 1.7
			_mesh("TreeCrown", crown, Vector3(side * 5.4, 2.0, z), Color("#527d4d"))

func _box(node_name: String, pos: Vector3, size: Vector3, color: Color) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	_mesh(node_name, mesh, pos, color)

func _mesh(node_name: String, mesh: Mesh, pos: Vector3, color: Color) -> void:
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = pos
	node.material_override = _mat(color)
	add_child(node)

func _mat(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	return material

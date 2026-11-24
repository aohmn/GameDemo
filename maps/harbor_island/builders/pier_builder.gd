extends RefCounted

const WOOD_COLOR: Color = Color(0.55, 0.38, 0.24)
const WOOD_DARK: Color = Color(0.40, 0.26, 0.16)


static func build(root_node: Node3D) -> void:
	_make_pier_and_harbor(root_node)
	_make_pier_boundaries(root_node)


static func _make_pier_and_harbor(root_node: Node3D) -> void:
	# Cầu tàu vươn từ bờ cát (mặt trên y = 0.05)
	var main_pier_pos := Vector3(-2.0, -0.05, 16.5)
	var main_pier_size := Vector3(4.5, 0.2, 13.0)
	_box(root_node, "MainPierPlanks", main_pier_pos, main_pier_size, WOOD_COLOR)
	_add_box_collider(root_node, "MainPierCol", main_pier_pos, main_pier_size)

	# Dốc thoai thoải nối bãi cát (y=0.0) lên cầu tàu (y=0.05)
	var ramp_pos := Vector3(-2.0, -0.02, 9.5)
	var ramp_size := Vector3(4.5, 0.08, 1.2)
	_box(root_node, "PierRamp", ramp_pos, ramp_size, WOOD_COLOR)
	_add_box_collider(root_node, "PierRampCol", ramp_pos, ramp_size)

	# Cầu tàu ngang chữ T bến đỗ thuyền
	var t_pier_pos := Vector3(-6.5, -0.05, 22.0)
	var t_pier_size := Vector3(8.0, 0.2, 3.5)
	_box(root_node, "TPierPlanks", t_pier_pos, t_pier_size, WOOD_COLOR)
	_add_box_collider(root_node, "TPierCol", t_pier_pos, t_pier_size)

	# Cọc gỗ cầu tàu
	var post_positions: Array[Vector3] = [
		Vector3(-4.0, -0.4, 11.0), Vector3(0.0, -0.4, 11.0),
		Vector3(-4.0, -0.4, 16.5), Vector3(0.0, -0.4, 16.5),
		Vector3(-4.0, -0.4, 22.0), Vector3(0.0, -0.4, 22.0),
		Vector3(-8.0, -0.4, 22.0), Vector3(-10.5, -0.4, 22.0),
	]
	var p_idx := 0
	for p in post_positions:
		p_idx += 1
		var post := CylinderMesh.new()
		post.top_radius = 0.16
		post.bottom_radius = 0.18
		post.height = 1.4
		var post_name := "PierPost" if p_idx == 1 else "PierPost_" + str(p_idx)
		_mesh(root_node, post_name, post, p, WOOD_DARK)

	# Thuyền gỗ neo đậu bên ngoài cầu tàu (không đè lên lối đi cầu tàu)
	_boat(root_node, "DockedBoat1", Vector3(-6.5, 0.05, 25.5), Vector3(2.2, 0.8, 3.2), 0.0)
	_boat(root_node, "DockedBoat2", Vector3(3.5, 0.05, 17.5), Vector3(2.0, 0.75, 3.8), -15.0)


static func _make_pier_boundaries(root_node: Node3D) -> void:
	var wall_h := 4.0
	var bounds: Array[Dictionary] = [
		{"name": "BoundMainPierWest", "pos": Vector3(-4.35, 2.0, 15.0), "size": Vector3(0.2, wall_h, 11.0)},
		{"name": "BoundMainPierEast", "pos": Vector3(0.35, 2.0, 16.5), "size": Vector3(0.2, wall_h, 14.0)},
		{"name": "BoundPierTNorth", "pos": Vector3(-7.5, 2.0, 20.15), "size": Vector3(6.5, wall_h, 0.3)},
		{"name": "BoundPierTSouth", "pos": Vector3(-6.5, 2.0, 23.85), "size": Vector3(8.5, wall_h, 0.3)},
		{"name": "BoundPierTWest", "pos": Vector3(-10.6, 2.0, 22.0), "size": Vector3(0.3, wall_h, 4.0)},
	]
	for b in bounds:
		_add_box_collider(root_node, b["name"], b["pos"], b["size"])


static func _boat(root_node: Node3D, b_name: String, pos: Vector3, size: Vector3, rot_y: float) -> void:
	var hull := BoxMesh.new()
	hull.size = size
	var node := MeshInstance3D.new()
	node.name = b_name
	node.mesh = hull
	node.position = pos
	node.rotation_degrees.y = rot_y
	node.material_override = _mat(WOOD_COLOR)
	root_node.add_child(node)

	var body := StaticBody3D.new()
	body.name = b_name + "Col"
	body.position = pos
	body.rotation_degrees.y = rot_y
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	root_node.add_child(body)


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

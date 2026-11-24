extends RefCounted

const WOOD_COLOR: Color = Color(0.55, 0.38, 0.24)
const WOOD_DARK: Color = Color(0.40, 0.26, 0.16)
const ROOF_COLOR: Color = Color(0.82, 0.45, 0.28)
const LEAF_COLOR: Color = Color(0.24, 0.58, 0.22)


static func build(root_node: Node3D) -> void:
	_make_harbor_structures(root_node)
	_make_tropical_trees(root_node)


static func _make_harbor_structures(root_node: Node3D) -> void:
	_building(root_node, "FisheryWarehouse", Vector3(6.5, 1.4, 8.5), Vector3(6.0, 2.8, 5.0), WOOD_DARK, ROOF_COLOR)
	_building(root_node, "BaitHut", Vector3(-9.0, 1.1, 7.0), Vector3(4.0, 2.2, 4.0), WOOD_COLOR, Color(0.28, 0.55, 0.65))

	var crates: Array[Vector3] = [
		Vector3(2.5, 0.35, 10.5), Vector3(3.5, 0.35, 10.5),
		Vector3(3.0, 1.05, 10.5), Vector3(-5.0, 0.35, 9.5)
	]
	var idx := 0
	for cr in crates:
		idx += 1
		var sz := Vector3(0.7, 0.7, 0.7)
		_box(root_node, "Crate_" + str(idx), cr, sz, WOOD_COLOR)
		_add_box_collider(root_node, "CrateCol_" + str(idx), cr, sz)


static func _building(root_node: Node3D, b_name: String, pos: Vector3, size: Vector3, wall_color: Color, roof_color: Color) -> void:
	_box(root_node, b_name + "Wall", pos, size, wall_color)
	_add_box_collider(root_node, b_name + "Col", pos, size)

	var roof := PrismMesh.new()
	roof.size = Vector3(size.x + 0.6, 1.3, size.z + 0.6)
	_mesh(root_node, b_name + "Roof", roof, pos + Vector3(0.0, size.y * 0.5 + 0.65, 0.0), roof_color)


static func _make_tropical_trees(root_node: Node3D) -> void:
	var tree_locs: Array[Vector3] = [
		Vector3(-14.0, 0.0, 12.0),
		Vector3(-11.0, 0.0, 15.0),
		Vector3(12.0, 0.0, 13.0),
		Vector3(15.0, 0.0, 7.0),
		Vector3(7.5, 0.0, -2.0),
		Vector3(-7.5, 0.0, -2.0),
		Vector3(0.0, 0.0, -10.0),
	]

	var t_idx := 0
	for loc in tree_locs:
		t_idx += 1
		var trunk := CylinderMesh.new()
		trunk.top_radius = 0.14
		trunk.bottom_radius = 0.22
		trunk.height = 2.4
		_mesh(root_node, "PalmTrunk_" + str(t_idx), trunk, loc + Vector3(0.0, 1.2, 0.0), WOOD_DARK)

		var crown := SphereMesh.new()
		crown.radius = 1.15
		crown.height = 1.3
		_mesh(root_node, "PalmCrown_" + str(t_idx), crown, loc + Vector3(0.0, 2.5, 0.0), LEAF_COLOR)

		var body := StaticBody3D.new()
		body.name = "TreeCol_" + str(t_idx)
		body.position = loc + Vector3(0.0, 1.2, 0.0)
		var col := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = 0.25
		shape.height = 2.4
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

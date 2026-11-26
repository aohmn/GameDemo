extends RefCounted

const ProcMaterial: Script = preload("res://assets/shaders/proc_material.gd")

## PropBuilder — Bố trí thùng hàng, cảnh vật và cây cỏ nhiệt đới tiên hiệp.

const WOOD_COLOR: Color = Color(0.55, 0.38, 0.24)
const WOOD_DARK: Color = Color(0.40, 0.26, 0.16)
const LEAF_COLOR: Color = Color(0.24, 0.62, 0.28)
const FLOWER_PINK: Color = Color(0.92, 0.55, 0.68)


static func build(root_node: Node3D) -> void:
	_make_harbor_decorations(root_node)
	_make_spiritual_trees(root_node)


static func _make_harbor_decorations(root_node: Node3D) -> void:
	# Thùng hàng và hòm vật tư tập kết ven bến tàu (xếp gọn, không cản lối đi)
	var crates: Array[Vector3] = [
		Vector3(2.5, 0.35, 11.5), Vector3(3.5, 0.35, 11.5),
		Vector3(3.0, 1.05, 11.5), Vector3(-5.2, 0.35, 10.5)
	]
	var idx := 0
	for cr in crates:
		idx += 1
		var sz := Vector3(0.7, 0.7, 0.7)
		_box(root_node, "Crate_" + str(idx), cr, sz, WOOD_COLOR)
		_add_box_collider(root_node, "CrateCol_" + str(idx), cr, sz)


static func _make_spiritual_trees(root_node: Node3D) -> void:
	# Bố trí cây linh thụ và cọ tiên đảo quanh các sườn đồi, tạo mảng xanh Genshin
	var tree_locs: Array[Vector3] = [
		Vector3(-14.5, 0.2, 12.0),
		Vector3(-12.0, 0.2, 15.5),
		Vector3(12.5, 0.2, 13.5),
		Vector3(15.5, 0.2, 7.5),
		Vector3(7.5, 0.1, -1.5),
		Vector3(-7.5, 0.1, -1.5),
		Vector3(-4.5, 0.7, -11.0),
		Vector3(4.5, 0.7, -11.0),
	]

	var t_idx := 0
	for loc in tree_locs:
		t_idx += 1
		var trunk := CylinderMesh.new()
		trunk.top_radius = 0.14
		trunk.bottom_radius = 0.22
		trunk.height = 2.4
		_mesh(root_node, "TreeTrunk_" + str(t_idx), trunk, loc + Vector3(0.0, 1.2, 0.0), WOOD_DARK)

		var crown := SphereMesh.new()
		crown.radius = 1.2
		crown.height = 1.4
		_mesh(root_node, "TreeCrown_" + str(t_idx), crown, loc + Vector3(0.0, 2.5, 0.0), LEAF_COLOR)

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
	node.material_override = ProcMaterial.make(node_name, color)
	root_node.add_child(node)

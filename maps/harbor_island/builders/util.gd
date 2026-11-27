extends RefCounted

## Tiện ích dựng node cho builder: mesh + vật liệu procedural, collider.

const ProcMaterial: Script = preload("res://assets/shaders/proc_material.gd")


static func add(root: Node, node_name: String, mesh: Mesh, pos: Vector3, kind: String, color: Color, rot_y_deg: float = 0.0, radial: bool = false) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = pos
	node.rotation_degrees.y = rot_y_deg
	node.material_override = ProcMaterial.of_kind(kind, color, radial)
	root.add_child(node)
	return node


static func box(root: Node, node_name: String, pos: Vector3, size: Vector3, kind: String, color: Color, rot_y_deg: float = 0.0) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return add(root, node_name, mesh, pos, kind, color, rot_y_deg)


static func cylinder(root: Node, node_name: String, pos: Vector3, r_top: float, r_bot: float, height: float, kind: String, color: Color, sides: int = 12) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = r_top
	mesh.bottom_radius = r_bot
	mesh.height = height
	mesh.radial_segments = sides
	mesh.rings = 1
	return add(root, node_name, mesh, pos, kind, color)


static func sphere(root: Node, node_name: String, pos: Vector3, radius: float, kind: String, color: Color, squash: float = 1.0) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0 * squash
	mesh.radial_segments = 12
	mesh.rings = 6
	return add(root, node_name, mesh, pos, kind, color)


static func collide_box(root: Node, node_name: String, pos: Vector3, size: Vector3, rot_y_deg: float = 0.0) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = pos
	body.rotation_degrees.y = rot_y_deg
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	root.add_child(body)
	return body


## Collider chính xác theo lưới tam giác (nền bậc, cầu vòm).
static func collide_mesh(root: Node, node_name: String, mesh: Mesh, pos: Vector3, rot_y_deg: float = 0.0) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = pos
	body.rotation_degrees.y = rot_y_deg
	var col := CollisionShape3D.new()
	col.shape = mesh.create_trimesh_shape()
	body.add_child(col)
	root.add_child(body)
	return body

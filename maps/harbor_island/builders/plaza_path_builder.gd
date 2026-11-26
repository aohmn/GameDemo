extends RefCounted

const ProcMaterial: Script = preload("res://assets/shaders/proc_material.gd")

## PlazaPathBuilder — Quảng trường trung tâm, Trận pháp truyền tống,
## Hồ Linh Ngư và mạng lưới đường + dốc nối lên các cao nguyên.

const STONE_PATH: Color = Color(0.74, 0.72, 0.67)
const SQUARE_STONE: Color = Color(0.85, 0.86, 0.83)
const POND_BORDER: Color = Color(0.48, 0.50, 0.46)
const POND_WATER: Color = Color(0.12, 0.55, 0.60)
const LOTUS_GREEN: Color = Color(0.28, 0.68, 0.48)
const TELEPORT_RING: Color = Color(0.20, 0.60, 0.65)
const TELEPORT_CORE: Color = Color(0.88, 0.75, 0.30)


static func build(root_node: Node3D) -> void:
	_make_central_plaza(root_node)
	_make_teleport_formation(root_node)
	_make_spiritual_pond(root_node)
	_make_connecting_paths(root_node)


static func _make_central_plaza(root_node: Node3D) -> void:
	_box(root_node, "CentralSquarePlaza", Vector3(0.0, 0.03, 2.5), Vector3(12.0, 0.03, 8.0), SQUARE_STONE)


static func _make_teleport_formation(root_node: Node3D) -> void:
	var array_center := Vector3(0.0, 0.05, 2.5)

	var outer_ring := CylinderMesh.new()
	outer_ring.top_radius = 2.4
	outer_ring.bottom_radius = 2.4
	outer_ring.height = 0.03
	_mesh(root_node, "TeleportOuterRing", outer_ring, array_center, TELEPORT_RING)

	var inner_ring := CylinderMesh.new()
	inner_ring.top_radius = 1.6
	inner_ring.bottom_radius = 1.6
	inner_ring.height = 0.04
	_mesh(root_node, "TeleportInnerRing", inner_ring, array_center + Vector3(0.0, 0.01, 0.0), SQUARE_STONE)

	var core_circle := CylinderMesh.new()
	core_circle.top_radius = 0.8
	core_circle.bottom_radius = 0.8
	core_circle.height = 0.05
	_mesh(root_node, "TeleportCore", core_circle, array_center + Vector3(0.0, 0.02, 0.0), TELEPORT_CORE)

	var pillar_offsets: Array[Vector3] = [
		Vector3(-2.2, 0.6, -2.2), Vector3(2.2, 0.6, -2.2),
		Vector3(-2.2, 0.6, 2.2), Vector3(2.2, 0.6, 2.2)
	]
	var p_id := 0
	for off in pillar_offsets:
		p_id += 1
		var pillar := CylinderMesh.new()
		pillar.top_radius = 0.18
		pillar.bottom_radius = 0.22
		pillar.height = 1.2
		_mesh(root_node, "TeleportPillar_" + str(p_id), pillar, array_center + off, TELEPORT_RING)


static func _make_spiritual_pond(root_node: Node3D) -> void:
	var rims: Array[Dictionary] = [
		{"name": "PondBorderNorth", "pos": Vector3(0.0, 0.08, -5.75), "size": Vector3(9.0, 0.24, 0.5)},
		{"name": "PondBorderSouth", "pos": Vector3(0.0, 0.08, -1.25), "size": Vector3(9.0, 0.24, 0.5)},
		{"name": "PondBorderWest", "pos": Vector3(-4.25, 0.08, -3.5), "size": Vector3(0.5, 0.24, 4.0)},
		{"name": "PondBorderEast", "pos": Vector3(4.25, 0.08, -3.5), "size": Vector3(0.5, 0.24, 4.0)},
	]
	for r in rims:
		_box(root_node, r["name"], r["pos"], r["size"], POND_BORDER)
		_add_box_collider(root_node, r["name"] + "Col", r["pos"], r["size"])

	# Mặt nước hồ không có collider để is_water_at() trả true khi đứng quanh bờ hồ
	_box(root_node, "SpiritualPondWater", Vector3(0.0, -0.13, -3.5), Vector3(8.0, 0.04, 4.0), POND_WATER)

	var lotus := CylinderMesh.new()
	lotus.top_radius = 0.85
	lotus.bottom_radius = 0.65
	lotus.height = 0.3
	_mesh(root_node, "LotusPlatform", lotus, Vector3(0.0, -0.05, -3.5), LOTUS_GREEN)


static func _make_connecting_paths(root_node: Node3D) -> void:
	# Cầu tàu -> Quảng trường
	_box(root_node, "PathPierToSquare", Vector3(-2.0, 0.02, 7.6), Vector3(3.2, 0.02, 3.0), STONE_PATH)

	# Quảng trường -> Thương Hội (dốc lên y = 0.44 tại x = 6.8)
	_ramp(root_node, "PathRampEast", Vector3(5.7, 0.16, 1.0), Vector3(2.4, 0.16, 2.4), Vector3(0.0, 0.0, 10.3), STONE_PATH)
	_box(root_node, "PathSquareToEast", Vector3(8.2, 0.45, 1.0), Vector3(2.8, 0.02, 2.2), STONE_PATH)

	# Quảng trường -> Lò & Kho (dốc lên y = 0.44 tại x = -6.8)
	_ramp(root_node, "PathRampWest", Vector3(-5.7, 0.16, 1.0), Vector3(2.4, 0.16, 2.4), Vector3(0.0, 0.0, -10.3), STONE_PATH)
	_box(root_node, "PathSquareToWest", Vector3(-8.2, 0.45, 1.0), Vector3(2.8, 0.02, 2.2), STONE_PATH)

	# Lối đi ôm hai bên Hồ Linh Ngư tới chân bậc thang Tiên Các
	_box(root_node, "PathPondWest", Vector3(-5.2, 0.02, -4.1), Vector3(1.2, 0.02, 5.4), STONE_PATH)
	_box(root_node, "PathPondEast", Vector3(5.2, 0.02, -4.1), Vector3(1.2, 0.02, 5.4), STONE_PATH)
	_box(root_node, "PathToTienCac", Vector3(0.0, 0.02, -6.5), Vector3(11.6, 0.02, 1.2), STONE_PATH)

	# Lối + dốc nhẹ từ đồi Đông (y=0.44) lên Đài Quan Hải (y=0.60)
	_ramp(root_node, "PathToObservationDeck", Vector3(13.5, 0.44, -7.1), Vector3(2.6, 0.16, 2.0), Vector3(5.0, 0.0, 0.0), STONE_PATH)


static func _ramp(root_node: Node3D, node_name: String, pos: Vector3, size: Vector3, rot_deg: Vector3, color: Color) -> void:
	var node := MeshInstance3D.new()
	node.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.position = pos
	node.rotation_degrees = rot_deg
	node.material_override = ProcMaterial.make(node_name, color)
	root_node.add_child(node)

	var body := StaticBody3D.new()
	body.name = node_name + "Col"
	body.position = pos
	body.rotation_degrees = rot_deg
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
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
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

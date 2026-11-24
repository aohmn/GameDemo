extends RefCounted

## PlazaPathBuilder — Kiến tạo Quảng trường trung tâm, Trận pháp truyền tống,
## Hồ Linh Ngư cảnh quan và Mạng lưới đường đi kết nối toàn bộ hòn đảo.

const STONE_PATH: Color = Color(0.74, 0.72, 0.67)      # Đá phiến lát đường
const SQUARE_STONE: Color = Color(0.85, 0.86, 0.83)    # Đá hoa cương quảng trường
const POND_BORDER: Color = Color(0.48, 0.50, 0.46)     # Kè đá bờ hồ
const POND_WATER: Color = Color(0.12, 0.55, 0.60)      # Mặt nước hồ linh ngư (xanh ngọc)
const LOTUS_GREEN: Color = Color(0.28, 0.68, 0.48)     # Đài sen ngọc giữa hồ
const TELEPORT_RING: Color = Color(0.20, 0.60, 0.65)   # Vòng trận pháp truyền tống
const TELEPORT_CORE: Color = Color(0.88, 0.75, 0.30)   # Tâm trận hoàng kim


static func build(root_node: Node3D) -> void:
	_make_central_plaza(root_node)
	_make_teleport_formation(root_node)
	_make_spiritual_pond(root_node)
	_make_connecting_paths(root_node)


## 2. Quảng trường trung tâm: khu sinh hoạt cộng đồng
static func _make_central_plaza(root_node: Node3D) -> void:
	var sq_pos := Vector3(0.0, 0.03, 2.5)
	var sq_size := Vector3(12.0, 0.03, 8.0)
	_box(root_node, "CentralSquarePlaza", sq_pos, sq_size, SQUARE_STONE)


## Trận pháp truyền tống liên map tại Quảng trường trung tâm
static func _make_teleport_formation(root_node: Node3D) -> void:
	var array_center := Vector3(0.0, 0.05, 2.5)

	# Vòng ngoài trận pháp
	var outer_ring := CylinderMesh.new()
	outer_ring.top_radius = 2.4
	outer_ring.bottom_radius = 2.4
	outer_ring.height = 0.03
	_mesh(root_node, "TeleportOuterRing", outer_ring, array_center, TELEPORT_RING)

	# Vòng bát quái linh văn bên trong
	var inner_ring := CylinderMesh.new()
	inner_ring.top_radius = 1.6
	inner_ring.bottom_radius = 1.6
	inner_ring.height = 0.04
	_mesh(root_node, "TeleportInnerRing", inner_ring, array_center + Vector3(0.0, 0.01, 0.0), SQUARE_STONE)

	# Tâm trận hoàng kim rực sáng
	var core_circle := CylinderMesh.new()
	core_circle.top_radius = 0.8
	core_circle.bottom_radius = 0.8
	core_circle.height = 0.05
	_mesh(root_node, "TeleportCore", core_circle, array_center + Vector3(0.0, 0.02, 0.0), TELEPORT_CORE)

	# 4 trụ thạch trận phong tỏa linh lực
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


## 6. Hồ Linh Ngư: khu câu cá khởi đầu nước ngọt/linh khí (x=0, z=-3.5)
static func _make_spiritual_pond(root_node: Node3D) -> void:
	var pond_pos := Vector3(0.0, 0.03, -3.5)

	# Kè đá bờ hồ tự nhiên
	var border_size := Vector3(9.0, 0.15, 5.0)
	_box(root_node, "PondBorder", pond_pos, border_size, POND_BORDER)

	# Mặt nước hồ linh ngư ngọc bích
	var water_size := Vector3(8.0, 0.16, 4.0)
	_box(root_node, "SpiritualPondWater", pond_pos + Vector3(0.0, 0.02, 0.0), water_size, POND_WATER)

	# Đài sen tĩnh tâm giữa hồ
	var lotus := CylinderMesh.new()
	lotus.top_radius = 0.85
	lotus.bottom_radius = 0.65
	lotus.height = 0.3
	_mesh(root_node, "LotusPlatform", lotus, pond_pos + Vector3(0.0, 0.12, 0.0), LOTUS_GREEN)


## 8. Đường đi bộ kết nối toàn bộ khu vực
static func _make_connecting_paths(root_node: Node3D) -> void:
	# Tuyến 1: Bến cảng / Cầu tàu -> Quảng trường trung tâm
	_box(root_node, "PathPierToSquare", Vector3(-2.0, 0.02, 6.5), Vector3(3.2, 0.02, 6.5), STONE_PATH)

	# Tuyến 2: Quảng trường -> Thương Hội (Đông)
	_box(root_node, "PathSquareToEast", Vector3(4.8, 0.02, 1.0), Vector3(6.5, 0.02, 2.2), STONE_PATH)

	# Tuyến 3: Quảng trường -> Lò Chế Tạo & Kho Linh Ngư (Tây)
	_box(root_node, "PathSquareToWest", Vector3(-4.8, 0.02, 1.0), Vector3(6.5, 0.02, 2.2), STONE_PATH)

	# Tuyến 4: Quảng trường -> Bờ Hồ -> Tiên Các trên cao (Bắc)
	_box(root_node, "PathToTienCac", Vector3(0.0, 0.02, -6.5), Vector3(3.0, 0.02, 3.0), STONE_PATH)

	# Tuyến 5: Lối đi sườn đồi từ Tiên Các rẽ sang Đài Quan Hải (Đông Bắc)
	_box(root_node, "PathToObservationDeck", Vector3(8.5, 0.02, -5.5), Vector3(8.0, 0.02, 1.8), STONE_PATH)


static func _box(root_node: Node3D, node_name: String, pos: Vector3, size: Vector3, color: Color) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	_mesh(root_node, node_name, mesh, pos, color)


static func _mesh(root_node: Node3D, node_name: String, mesh: Mesh, pos: Vector3, color: Color) -> void:
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.8
	node.material_override = mat
	root_node.add_child(node)

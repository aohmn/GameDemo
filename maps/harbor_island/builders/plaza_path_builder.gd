extends RefCounted

## Xây dựng Quảng trường trung tâm, Hồ Linh Ngư cảnh quan và các lối đi đá kết nối:
## - Quảng trường trung tâm (x=0, z=2): Đan đài bát quái hoa văn thanh thạch
## - Hồ Linh Ngư cảnh quan (x=0, z=-3.5): Mặt hồ trong xanh, bờ kè đá
## - Đường đi kết nối: Cầu tàu -> Quảng trường -> Tiên Các, Thương Hội, Lò Rèn

const STONE_PATH: Color = Color(0.72, 0.70, 0.65)   # Đá phiến lát đường
const SQUARE_STONE: Color = Color(0.82, 0.84, 0.80) # Đá hoa cương quảng trường
const POND_BORDER: Color = Color(0.45, 0.48, 0.45)  # Kè đá bờ hồ
const POND_WATER: Color = Color(0.12, 0.52, 0.58)   # Mặt nước hồ linh ngư (xanh lục bảo)
const JADE_GREEN: Color = Color(0.25, 0.65, 0.45)   # Đài sen giữa hồ


static func build(root_node: Node3D) -> void:
	_make_central_square(root_node)
	_make_spiritual_pond(root_node)
	_make_connecting_paths(root_node)


## 3. Quảng trường trung tâm (Trung tâm đảo x=0, z=2.0)
static func _make_central_square(root_node: Node3D) -> void:
	# Nền quảng trường lớn hình bát giác/tròn ghép
	var sq_pos := Vector3(0.0, 0.02, 2.0)
	var sq_size := Vector3(10.0, 0.03, 7.0)
	_box(root_node, "CentralSquarePlaza", sq_pos, sq_size, SQUARE_STONE)

	# Đài hoa văn trung tâm
	var center_circle := CylinderMesh.new()
	center_circle.top_radius = 2.2
	center_circle.bottom_radius = 2.2
	center_circle.height = 0.05
	_mesh(root_node, "CentralMandala", center_circle, Vector3(0.0, 0.04, 2.0), JADE_GREEN)


## 7. Hồ Linh Ngư và Điểm câu cảnh quan (x=0, z=-3.5)
static func _make_spiritual_pond(root_node: Node3D) -> void:
	var pond_pos := Vector3(0.0, 0.02, -3.5)

	# Bờ kè đá bao quanh hồ hình oval
	var border_size := Vector3(8.5, 0.15, 4.5)
	_box(root_node, "PondBorder", pond_pos, border_size, POND_BORDER)

	# Mặt nước hồ linh ngư trong xanh ngọc bích
	var water_size := Vector3(7.5, 0.16, 3.5)
	_box(root_node, "SpiritualPondWater", pond_pos + Vector3(0.0, 0.02, 0.0), water_size, POND_WATER)

	# Đài sen tĩnh tâm giữa hồ
	var lotus := CylinderMesh.new()
	lotus.top_radius = 0.8
	lotus.bottom_radius = 0.6
	lotus.height = 0.3
	_mesh(root_node, "LotusPlatform", lotus, pond_pos + Vector3(0.0, 0.12, 0.0), JADE_GREEN)


## 8. Đường đi đá phiến kết nối các khu vực
static func _make_connecting_paths(root_node: Node3D) -> void:
	# Trục Bắc - Nam: Từ Cầu tàu (z=9) xuyên qua Quảng trường (z=2) tới Hồ Linh Ngư & Tiên Các (z=-6)
	var main_road_pos := Vector3(-2.0, 0.015, 6.0)
	var main_road_size := Vector3(3.2, 0.02, 6.5)
	_box(root_node, "PathPierToSquare", main_road_pos, main_road_size, STONE_PATH)

	# Đường từ Quảng trường rẽ sang Thương Hội (phía Đông: x=0 tới x=7, z=0)
	var east_road_pos := Vector3(4.5, 0.015, 0.5)
	var east_road_size := Vector3(6.5, 0.02, 2.2)
	_box(root_node, "PathSquareToEast", east_road_pos, east_road_size, STONE_PATH)

	# Đường từ Quảng trường rẽ sang Lò Chế Tạo (phía Tây: x=0 tới x=-7, z=0)
	var west_road_pos := Vector3(-4.5, 0.015, 0.5)
	var west_road_size := Vector3(6.5, 0.02, 2.2)
	_box(root_node, "PathSquareToWest", west_road_pos, west_road_size, STONE_PATH)

	# Lối cầu đá qua Hồ Linh Ngư tiến vào Tiên Các
	var north_road_pos := Vector3(0.0, 0.015, -6.5)
	var north_road_size := Vector3(3.0, 0.02, 2.8)
	_box(root_node, "PathToTienCac", north_road_pos, north_road_size, STONE_PATH)


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
	material.roughness = 0.75
	return material

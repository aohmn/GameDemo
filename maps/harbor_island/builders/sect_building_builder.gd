extends RefCounted

const ProcMaterial: Script = preload("res://assets/shaders/proc_material.gd")

## SectBuildingBuilder — Kiến tạo các kiến trúc môn phái và cơ sở hạ tầng:
## 3. Tiên Các (Công trình trên cao, nơi tu luyện và đột phá)
## 4. Thương Hội (Kinh doanh cần câu, dây, mồi và pháp bảo)
## 5. Lò Chế Tạo & Kho Linh Ngư
## 7. Đài Quan Hải (Ngắm biển và chiêm nghiệm thiên địa chi đạo)

const JADE_WHITE: Color = Color(0.92, 0.96, 0.94)    # Bạch ngọc tường Tiên Các
const JADE_ROOF: Color = Color(0.18, 0.45, 0.40)     # Ngọc bích mái ngói Tiên Các
const GOLD_ACCENT: Color = Color(0.85, 0.70, 0.28)   # Kim sắc hoa văn hoàng kim
const WOOD_RED: Color = Color(0.55, 0.22, 0.18)      # Gỗ đỏ phong cách Thương Hội
const ROOF_TILES: Color = Color(0.25, 0.30, 0.38)    # Ngói xanh thanh phong
const FURNACE_STONE: Color = Color(0.35, 0.32, 0.30) # Huyền thạch lò rèn
const FURNACE_FIRE: Color = Color(0.95, 0.45, 0.15)  # Ánh lửa chân hỏa
const WAREHOUSE_WOOD: Color = Color(0.48, 0.35, 0.24)# Gỗ kho linh ngư
const OBSERVATION_STONE: Color = Color(0.80, 0.82, 0.85) # Thạch đài Quan Hải


static func build(root_node: Node3D) -> void:
	_make_tien_cac(root_node)
	_make_thuong_hoi(root_node)
	_make_crafting_furnace_and_warehouse(root_node)
	_make_observation_deck(root_node)


## 3. Tiên Các — Công trình trên cao nguyên phía Bắc (y=0.7 tới y=5.0)
static func _make_tien_cac(root_node: Node3D) -> void:
	# Bậc thềm ngọc bích dẫn lên cao đài
	var stairs_pos := Vector3(0.0, 0.45, -6.5)
	var stairs_size := Vector3(5.0, 0.5, 2.0)
	_box(root_node, "TienCacStairs", stairs_pos, stairs_size, JADE_WHITE)
	_add_box_collider(root_node, "TienCacStairsCol", stairs_pos, stairs_size)

	# Nền móng Tiên Các đài sen
	var base_pos := Vector3(0.0, 0.9, -10.5)
	var platform_size := Vector3(9.5, 0.6, 8.5)
	_box(root_node, "TienCacPlatform", base_pos, platform_size, JADE_WHITE)
	_add_box_collider(root_node, "TienCacPlatformCol", base_pos, platform_size)

	# Đại điện tầng 1 — Nơi tĩnh tọa tu luyện
	var hall_pos := base_pos + Vector3(0.0, 2.0, 0.0)
	var hall_size := Vector3(6.5, 3.4, 5.5)
	_box(root_node, "TienCacHall", hall_pos, hall_size, JADE_WHITE)
	_add_box_collider(root_node, "TienCacHallCol", hall_pos, hall_size)

	# Mái ngói cong cổ phong tầng 1
	var roof1 := PrismMesh.new()
	roof1.size = Vector3(8.2, 1.3, 7.2)
	_mesh(root_node, "TienCacRoof1", roof1, hall_pos + Vector3(0.0, 2.2, 0.0), JADE_ROOF)

	# Tầng các thứ 2 — Nơi đón thiên kiếp đột phá cảnh giới
	var tower_pos := hall_pos + Vector3(0.0, 3.2, 0.0)
	var tower_size := Vector3(4.0, 2.0, 3.5)
	_box(root_node, "TienCacTower", tower_pos, tower_size, JADE_WHITE)

	var roof2 := PrismMesh.new()
	roof2.size = Vector3(5.4, 1.1, 4.8)
	_mesh(root_node, "TienCacRoof2", roof2, tower_pos + Vector3(0.0, 1.4, 0.0), GOLD_ACCENT)

	# Đỉnh hồ lô pháp bảo tụ linh khí
	var pinnacle := SphereMesh.new()
	pinnacle.radius = 0.4
	pinnacle.height = 0.8
	_mesh(root_node, "TienCacPinnacle", pinnacle, tower_pos + Vector3(0.0, 2.2, 0.0), GOLD_ACCENT)


## 4. Thương Hội — Giao thương sầm uất phía Đông (x=11.5, z=0.5)
static func _make_thuong_hoi(root_node: Node3D) -> void:
	var base_pos := Vector3(11.5, 0.25, 0.5)
	var base_size := Vector3(7.5, 0.4, 7.5)
	_box(root_node, "ThuongHoiBase", base_pos, base_size, WOOD_RED)
	_add_box_collider(root_node, "ThuongHoiBaseCol", base_pos, base_size)

	var hall_pos := base_pos + Vector3(0.0, 1.6, 0.0)
	var hall_size := Vector3(5.8, 2.8, 5.8)
	_box(root_node, "ThuongHoiHall", hall_pos, hall_size, WOOD_RED)
	_add_box_collider(root_node, "ThuongHoiHallCol", hall_pos, hall_size)

	var roof := PrismMesh.new()
	roof.size = Vector3(7.4, 1.5, 7.4)
	_mesh(root_node, "ThuongHoiRoof", roof, hall_pos + Vector3(0.0, 1.9, 0.0), ROOF_TILES)

	# Biển hiệu thương hội cổ phong mạ vàng
	var sign_pos := hall_pos + Vector3(-3.0, 0.8, 0.0)
	var sign_size := Vector3(0.15, 0.7, 2.4)
	_box(root_node, "ThuongHoiSign", sign_pos, sign_size, GOLD_ACCENT)


## 5. Lò Chế Tạo và Kho Linh Ngư (Tây x=-11.0, z=0.5)
static func _make_crafting_furnace_and_warehouse(root_node: Node3D) -> void:
	# Lò luyện chân hỏa chế tạo pháp bảo
	var furnace_pos := Vector3(-10.5, 0.9, -2.5)
	var furnace_body := CylinderMesh.new()
	furnace_body.top_radius = 1.3
	furnace_body.bottom_radius = 1.7
	furnace_body.height = 1.8
	_mesh(root_node, "FurnaceBody", furnace_body, furnace_pos, FURNACE_STONE)

	# Miệng lò tỏa ánh linh hỏa
	var fire_mesh := CylinderMesh.new()
	fire_mesh.top_radius = 0.9
	fire_mesh.bottom_radius = 0.9
	fire_mesh.height = 0.2
	_mesh(root_node, "FurnaceFire", fire_mesh, furnace_pos + Vector3(0.0, 0.95, 0.0), FURNACE_FIRE)

	var f_col_size := Vector3(3.4, 2.0, 3.4)
	_add_box_collider(root_node, "FurnaceCol", furnace_pos, f_col_size)

	# Kho Linh Ngư chứa cá & tài nguyên thu hoạch
	var wh_pos := Vector3(-11.5, 1.4, 3.5)
	var wh_size := Vector3(5.5, 2.8, 5.5)
	_box(root_node, "WarehouseBody", wh_pos, wh_size, WAREHOUSE_WOOD)
	_add_box_collider(root_node, "WarehouseCol", wh_pos, wh_size)

	var wh_roof := PrismMesh.new()
	wh_roof.size = Vector3(6.8, 1.2, 6.8)
	_mesh(root_node, "WarehouseRoof", wh_roof, wh_pos + Vector3(0.0, 1.8, 0.0), ROOF_TILES)


## 7. Đài Quan Hải — Vọng cảnh lâu ngắm biển và cảm ngộ thiên đạo (x=13.5, z=-7.5)
static func _make_observation_deck(root_node: Node3D) -> void:
	var deck_pos := Vector3(13.5, 0.8, -7.5)

	# Nền thạch đài nhô ra biển
	var platform := CylinderMesh.new()
	platform.top_radius = 3.6
	platform.bottom_radius = 4.0
	platform.height = 1.6
	_mesh(root_node, "ObservationPlatform", platform, deck_pos, OBSERVATION_STONE)

	var col_size := Vector3(7.2, 1.6, 7.2)
	_add_box_collider(root_node, "ObservationDeckCol", deck_pos, col_size)

	# Trụ đình bát giác ngắm biển
	var pavilion_roof := CylinderMesh.new()
	pavilion_roof.top_radius = 0.2
	pavilion_roof.bottom_radius = 3.8
	pavilion_roof.height = 1.4
	_mesh(root_node, "ObservationRoof", pavilion_roof, deck_pos + Vector3(0.0, 3.2, 0.0), JADE_ROOF)

	# 4 cột đá chống đình
	var pillar_angles: Array[float] = [0.0, 1.5708, 3.14159, 4.71239]
	var p_id := 0
	for ang in pillar_angles:
		p_id += 1
		var col_mesh := CylinderMesh.new()
		col_mesh.top_radius = 0.15
		col_mesh.bottom_radius = 0.15
		col_mesh.height = 2.4
		var p_offset := Vector3(cos(ang) * 2.8, 2.0, sin(ang) * 2.8)
		_mesh(root_node, "PavilionPillar_" + str(p_id), col_mesh, deck_pos + p_offset, JADE_WHITE)


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

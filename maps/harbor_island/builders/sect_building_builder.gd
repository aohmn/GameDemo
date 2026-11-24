extends RefCounted

## Kiến tạo các công trình Tiên Hiệp trên Đảo Bến Cảng:
## - Tiên Các (Tu luyện & Đột phá)
## - Thương Hội (Giao thương pháp bảo, cần câu, vật phẩm)
## - Lò Chế Tạo & Kho Linh Ngư
## Hoàn toàn bằng Primitive Mesh và Shader/Color Material không dùng texture.

const JADE_WHITE: Color = Color(0.92, 0.96, 0.94)    # Màu bạch ngọc tường tiên các
const JADE_ROOF: Color = Color(0.18, 0.45, 0.40)     # Màu ngọc bích mái ngói tiên các
const GOLD_ACCENT: Color = Color(0.85, 0.70, 0.28)   # Màu hoàng kim điểm xuyết
const WOOD_RED: Color = Color(0.55, 0.22, 0.18)      # Màu gỗ đỏ cổ phong thương hội
const ROOF_TILES: Color = Color(0.25, 0.30, 0.38)    # Màu ngói thanh phong
const FURNACE_STONE: Color = Color(0.35, 0.32, 0.30) # Màu huyền thạch lò rèn
const FURNACE_FIRE: Color = Color(0.95, 0.45, 0.15)  # Ánh lửa chân hỏa
const WAREHOUSE_WOOD: Color = Color(0.48, 0.35, 0.24)# Gỗ kho linh ngư


static func build(root_node: Node3D) -> void:
	_make_tien_cac(root_node)
	_make_thuong_hoi(root_node)
	_make_crafting_furnace_and_warehouse(root_node)


## 4. Tiên Các — Nơi tĩnh tọa tu luyện và đột phá cảnh giới (Tọa độ: x=0, z=-9 phía Bắc đảo)
static func _make_tien_cac(root_node: Node3D) -> void:
	var base_pos := Vector3(0.0, 0.2, -9.0)
	var platform_size := Vector3(9.0, 0.4, 8.0)
	# Đài sen ngọc bích nền móng
	_box(root_node, "TienCacPlatform", base_pos, platform_size, JADE_WHITE)
	_add_box_collider(root_node, "TienCacPlatformCol", base_pos, platform_size)

	# Thân điện chính
	var hall_pos := base_pos + Vector3(0.0, 1.8, 0.0)
	var hall_size := Vector3(6.5, 3.2, 5.5)
	_box(root_node, "TienCacHall", hall_pos, hall_size, JADE_WHITE)
	_add_box_collider(root_node, "TienCacHallCol", hall_pos, hall_size)

	# Mái ngói cong cổ phong tầng 1
	var roof1_pos := hall_pos + Vector3(0.0, 2.0, 0.0)
	var roof1 := PrismMesh.new()
	roof1.size = Vector3(8.0, 1.2, 7.0)
	_mesh(root_node, "TienCacRoof1", roof1, roof1_pos, JADE_ROOF)

	# Tầng các thứ 2 thanh tao
	var tower_pos := roof1_pos + Vector3(0.0, 1.1, 0.0)
	var tower_size := Vector3(4.0, 1.8, 3.5)
	_box(root_node, "TienCacTower", tower_pos, tower_size, JADE_WHITE)

	var roof2_pos := tower_pos + Vector3(0.0, 1.3, 0.0)
	var roof2 := PrismMesh.new()
	roof2.size = Vector3(5.2, 1.0, 4.5)
	_mesh(root_node, "TienCacRoof2", roof2, roof2_pos, GOLD_ACCENT)

	# Đỉnh hồ lô pháp bảo trên nóc
	var pinnacle := SphereMesh.new()
	pinnacle.radius = 0.35
	pinnacle.height = 0.7
	_mesh(root_node, "TienCacPinnacle", pinnacle, roof2_pos + Vector3(0.0, 0.7, 0.0), GOLD_ACCENT)


## 5. Thương Hội — Nơi giao thương trao đổi linh thạch và pháp bảo (Tọa độ: x=10, z=0 phía Đông)
static func _make_thuong_hoi(root_node: Node3D) -> void:
	var base_pos := Vector3(10.5, 0.15, 0.0)
	var base_size := Vector3(7.0, 0.3, 7.0)
	_box(root_node, "ThuongHoiBase", base_pos, base_size, WOOD_RED)
	_add_box_collider(root_node, "ThuongHoiBaseCol", base_pos, base_size)

	var hall_pos := base_pos + Vector3(0.0, 1.5, 0.0)
	var hall_size := Vector3(5.5, 2.7, 5.5)
	_box(root_node, "ThuongHoiHall", hall_pos, hall_size, WOOD_RED)
	_add_box_collider(root_node, "ThuongHoiHallCol", hall_pos, hall_size)

	var roof_pos := hall_pos + Vector3(0.0, 1.8, 0.0)
	var roof := PrismMesh.new()
	roof.size = Vector3(7.2, 1.4, 7.2)
	_mesh(root_node, "ThuongHoiRoof", roof, roof_pos, ROOF_TILES)

	# Bảng hiệu thương hội
	var sign_pos := hall_pos + Vector3(-2.8, 0.8, 0.0)
	var sign_size := Vector3(0.15, 0.6, 2.2)
	_box(root_node, "ThuongHoiSign", sign_pos, sign_size, GOLD_ACCENT)


## 6. Lò Chế Tạo và Kho Linh Ngư (Tọa độ: x=-10, z=0 phía Tây)
static func _make_crafting_furnace_and_warehouse(root_node: Node3D) -> void:
	# Lò luyện chế pháp bảo
	var furnace_pos := Vector3(-9.5, 0.8, -2.5)
	var furnace_body := CylinderMesh.new()
	furnace_body.top_radius = 1.2
	furnace_body.bottom_radius = 1.6
	furnace_body.height = 1.6
	_mesh(root_node, "FurnaceBody", furnace_body, furnace_pos, FURNACE_STONE)

	# Miệng lò rực ánh chân hỏa
	var fire_mesh := CylinderMesh.new()
	fire_mesh.top_radius = 0.85
	fire_mesh.bottom_radius = 0.85
	fire_mesh.height = 0.2
	_mesh(root_node, "FurnaceFire", fire_mesh, furnace_pos + Vector3(0.0, 0.85, 0.0), FURNACE_FIRE)

	var f_col_size := Vector3(3.2, 1.8, 3.2)
	_add_box_collider(root_node, "FurnaceCol", furnace_pos, f_col_size)

	# Kho Linh Ngư chứa cá & bảo vật
	var wh_pos := Vector3(-10.5, 1.3, 3.5)
	var wh_size := Vector3(5.0, 2.6, 5.0)
	_box(root_node, "WarehouseBody", wh_pos, wh_size, WAREHOUSE_WOOD)
	_add_box_collider(root_node, "WarehouseCol", wh_pos, wh_size)

	var wh_roof_pos := wh_pos + Vector3(0.0, 1.7, 0.0)
	var wh_roof := PrismMesh.new()
	wh_roof.size = Vector3(6.2, 1.1, 6.2)
	_mesh(root_node, "WarehouseRoof", wh_roof, wh_roof_pos, ROOF_TILES)


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
	material.roughness = 0.8
	return material

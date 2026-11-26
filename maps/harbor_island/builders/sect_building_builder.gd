extends RefCounted

const ProcMaterial: Script = preload("res://assets/shaders/proc_material.gd")

## SectBuildingBuilder — Kiến tạo Tiên Các, Thương Hội, Lò Chế Tạo, Kho và Đài Quan Hải
## căn đúng cao độ từng cao nguyên để nhân vật đi bộ tới được mọi công trình.

const JADE_WHITE: Color = Color(0.92, 0.96, 0.94)
const JADE_ROOF: Color = Color(0.18, 0.45, 0.40)
const GOLD_ACCENT: Color = Color(0.85, 0.70, 0.28)
const WOOD_RED: Color = Color(0.55, 0.22, 0.18)
const ROOF_TILES: Color = Color(0.25, 0.30, 0.38)
const FURNACE_STONE: Color = Color(0.35, 0.32, 0.30)
const FURNACE_FIRE: Color = Color(0.95, 0.45, 0.15)
const WAREHOUSE_WOOD: Color = Color(0.48, 0.35, 0.24)
const OBSERVATION_STONE: Color = Color(0.80, 0.82, 0.85)


static func build(root_node: Node3D) -> void:
	_make_tien_cac(root_node)
	_make_thuong_hoi(root_node)
	_make_crafting_furnace_and_warehouse(root_node)
	_make_observation_deck(root_node)


## 3. Tiên Các trên PlateauNorth (y = 0.70)
static func _make_tien_cac(root_node: Node3D) -> void:
	# Dốc bậc thềm đi lên từ lối sau Hồ Linh Ngư (z=-6.0, y=0.02) lên cao nguyên (z=-7.6, y=0.70)
	var stairs_pos := Vector3(0.0, 0.28, -6.8)
	var stairs_size := Vector3(4.0, 0.16, 1.85)
	_ramp(root_node, "TienCacStairs", stairs_pos, stairs_size, Vector3(23.0, 0.0, 0.0), JADE_WHITE)

	# Nền đài sen (cao 0.08m trên mặt cao nguyên 0.70 để bước lên mượt)
	var base_pos := Vector3(0.0, 0.74, -11.2)
	var platform_size := Vector3(9.5, 0.08, 7.0)
	_box(root_node, "TienCacPlatform", base_pos, platform_size, JADE_WHITE)
	_add_box_collider(root_node, "TienCacPlatformCol", base_pos, platform_size)

	var hall_pos := base_pos + Vector3(0.0, 1.74, 0.0)
	var hall_size := Vector3(6.5, 3.4, 5.5)
	_box(root_node, "TienCacHall", hall_pos, hall_size, JADE_WHITE)
	_add_box_collider(root_node, "TienCacHallCol", hall_pos, hall_size)

	var roof1 := PrismMesh.new()
	roof1.size = Vector3(8.2, 1.3, 7.2)
	_mesh(root_node, "TienCacRoof1", roof1, hall_pos + Vector3(0.0, 2.2, 0.0), JADE_ROOF)

	var tower_pos := hall_pos + Vector3(0.0, 3.2, 0.0)
	_box(root_node, "TienCacTower", tower_pos, Vector3(4.0, 2.0, 3.5), JADE_WHITE)

	var roof2 := PrismMesh.new()
	roof2.size = Vector3(5.4, 1.1, 4.8)
	_mesh(root_node, "TienCacRoof2", roof2, tower_pos + Vector3(0.0, 1.4, 0.0), GOLD_ACCENT)

	var pinnacle := SphereMesh.new()
	pinnacle.radius = 0.4
	pinnacle.height = 0.8
	_mesh(root_node, "TienCacPinnacle", pinnacle, tower_pos + Vector3(0.0, 2.2, 0.0), GOLD_ACCENT)


## 4. Thương Hội trên PlateauEast (y = 0.44)
static func _make_thuong_hoi(root_node: Node3D) -> void:
	var base_pos := Vector3(12.5, 0.48, 0.5)
	var base_size := Vector3(7.0, 0.08, 7.0)
	_box(root_node, "ThuongHoiBase", base_pos, base_size, WOOD_RED)
	_add_box_collider(root_node, "ThuongHoiBaseCol", base_pos, base_size)

	var hall_pos := base_pos + Vector3(0.0, 1.44, 0.0)
	var hall_size := Vector3(5.6, 2.8, 5.6)
	_box(root_node, "ThuongHoiHall", hall_pos, hall_size, WOOD_RED)
	_add_box_collider(root_node, "ThuongHoiHallCol", hall_pos, hall_size)

	var roof := PrismMesh.new()
	roof.size = Vector3(7.2, 1.5, 7.2)
	_mesh(root_node, "ThuongHoiRoof", roof, hall_pos + Vector3(0.0, 1.9, 0.0), ROOF_TILES)

	_box(root_node, "ThuongHoiSign", hall_pos + Vector3(-2.9, 0.8, 0.0), Vector3(0.15, 0.7, 2.4), GOLD_ACCENT)


## 5. Lò Chế Tạo và Kho Linh Ngư trên PlateauWest (y = 0.44)
static func _make_crafting_furnace_and_warehouse(root_node: Node3D) -> void:
	var furnace_pos := Vector3(-11.0, 1.34, -2.5)
	var furnace_body := CylinderMesh.new()
	furnace_body.top_radius = 1.3
	furnace_body.bottom_radius = 1.7
	furnace_body.height = 1.8
	_mesh(root_node, "FurnaceBody", furnace_body, furnace_pos, FURNACE_STONE)

	var fire_mesh := CylinderMesh.new()
	fire_mesh.top_radius = 0.9
	fire_mesh.bottom_radius = 0.9
	fire_mesh.height = 0.2
	_mesh(root_node, "FurnaceFire", fire_mesh, furnace_pos + Vector3(0.0, 0.95, 0.0), FURNACE_FIRE)

	_add_box_collider(root_node, "FurnaceCol", furnace_pos, Vector3(3.4, 2.0, 3.4))

	var wh_pos := Vector3(-12.0, 1.84, 3.5)
	var wh_size := Vector3(5.5, 2.8, 5.5)
	_box(root_node, "WarehouseBody", wh_pos, wh_size, WAREHOUSE_WOOD)
	_add_box_collider(root_node, "WarehouseCol", wh_pos, wh_size)

	var wh_roof := PrismMesh.new()
	wh_roof.size = Vector3(6.8, 1.2, 6.8)
	_mesh(root_node, "WarehouseRoof", wh_roof, wh_pos + Vector3(0.0, 1.8, 0.0), ROOF_TILES)


## 7. Đài Quan Hải (mặt đài y = 0.60, nối từ đồi Đông)
static func _make_observation_deck(root_node: Node3D) -> void:
	var deck_pos := Vector3(14.0, 0.25, -8.5)
	var platform := CylinderMesh.new()
	platform.top_radius = 3.6
	platform.bottom_radius = 4.0
	platform.height = 0.7
	_mesh(root_node, "ObservationPlatform", platform, deck_pos, OBSERVATION_STONE)
	_add_box_collider(root_node, "ObservationDeckCol", deck_pos, Vector3(7.2, 0.7, 7.2))

	var top_y := 0.35
	var pavilion_roof := CylinderMesh.new()
	pavilion_roof.top_radius = 0.2
	pavilion_roof.bottom_radius = 3.8
	pavilion_roof.height = 1.4
	_mesh(root_node, "ObservationRoof", pavilion_roof, deck_pos + Vector3(0.0, top_y + 2.6, 0.0), JADE_ROOF)

	var pillar_angles: Array[float] = [0.0, 1.5708, 3.14159, 4.71239]
	var p_id := 0
	for ang in pillar_angles:
		p_id += 1
		var col_mesh := CylinderMesh.new()
		col_mesh.top_radius = 0.15
		col_mesh.bottom_radius = 0.15
		col_mesh.height = 2.4
		var p_offset := Vector3(cos(ang) * 2.8, top_y + 1.2, sin(ang) * 2.8)
		_mesh(root_node, "PavilionPillar_" + str(p_id), col_mesh, deck_pos + p_offset, JADE_WHITE)


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

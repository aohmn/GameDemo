## BuildingBuilder: Dựng các khối kiến trúc tòa nhà theo MapLayout.
## Thiết kế theo phong cách nhà phố / hẻm Việt Nam hiện đại, hoàn toàn không texture:
## - Khối thân nhà chính (BoxMesh, màu tường đặc trưng theo tầng).
## - Mái hiên / Mái bằng có gờ viền (Parapet/Flat roof).
## - Cửa chính (Front door), cửa sổ kính mờ (Front window).
## - Biển hiệu (Label3D + khung nền) ghi tên bảng hiệu từ BuildingSpec.
## - Bậc thềm tam cấp kết nối từ vỉa hè (Y = 0.08) lên sàn nhà (Y = 0.12).
## - Toàn bộ phần va chạm (StaticBody3D + BoxShape3D) phủ trọn vẹn khối kiến trúc.
extends RefCounted
class_name BuildingBuilder

const SURFACE_SHADER: Shader = preload("res://world/map/shaders/procedural_surface.gdshader")

## Độ cao chuẩn
const SIDEWALK_Y: float = 0.08
const FLOOR_HEIGHT: float = 3.2
const BASE_ELEVATION: float = 0.12

## Màu sắc kiến trúc mặc định
const COLOR_ROOF: Color = Color(0.32, 0.28, 0.26)
const COLOR_DOOR_WOOD: Color = Color(0.35, 0.22, 0.14)
const COLOR_DOOR_GLASS: Color = Color(0.20, 0.35, 0.45)
const COLOR_WINDOW: Color = Color(0.25, 0.48, 0.58)
const COLOR_SIGN_BOARD: Color = Color(0.15, 0.18, 0.22)
const COLOR_STEP: Color = Color(0.42, 0.42, 0.44)
const COLOR_AWNING_FABRIC: Color = Color(0.75, 0.25, 0.20)


## Dựng toàn bộ các tòa nhà có trong MapLayout
static func build_from_layout(layout: MapLayout, parent: Node3D) -> void:
	if layout == null:
		return

	# Tạo từ điển lot_id -> LotSpec để tra cứu nhanh hướng mặt tiền và vị trí lô đất
	var lots_dict: Dictionary = {}
	for lot: LotSpec in layout.lots:
		lots_dict[lot.id] = lot

	for building: BuildingSpec in layout.buildings:
		var lot: LotSpec = lots_dict.get(building.lot_id, null)
		_build_single_building(building, lot, parent)


static func _build_single_building(spec: BuildingSpec, lot: LotSpec, parent: Node3D) -> void:
	var building_root := StaticBody3D.new()
	building_root.name = spec.id

	# Xác định kích thước và tâm nhà dựa vào LotSpec
	var width_x: float = 7.0
	var depth_z: float = 8.0
	var center_x: float = spec.door_point.x
	var center_z: float = spec.door_point.z
	var facing: String = "east"

	if lot != null:
		facing = lot.facing
		width_x = maxf(4.0, lot.rect.size.x - 1.0)
		depth_z = maxf(4.0, lot.rect.size.y - 1.0)
		center_x = lot.rect.position.x + lot.rect.size.x * 0.5
		center_z = lot.rect.position.y + lot.rect.size.y * 0.5

	var total_floors := clampi(spec.floors, 1, 4)
	var total_height: float = float(total_floors) * FLOOR_HEIGHT

	building_root.position = Vector3(center_x, BASE_ELEVATION, center_z)
	parent.add_child(building_root)

	# 1. Khối va chạm chính (Collision)
	var collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(width_x, total_height, depth_z)
	collision.shape = box_shape
	collision.position = Vector3(0.0, total_height * 0.5, 0.0)
	building_root.add_child(collision)

	# 2. Khối thân nhà từng tầng
	for f in range(total_floors):
		var floor_y := float(f) * FLOOR_HEIGHT
		var wall_col := spec.color
		if f > 0:
			# Các tầng trên có sắc độ nhạt hơn nhẹ để tạo chi tiết kiến trúc tầng
			wall_col = Color(
				clampf(spec.color.r * 1.05, 0.0, 1.0),
				clampf(spec.color.g * 1.05, 0.0, 1.0),
				clampf(spec.color.b * 1.05, 0.0, 1.0)
			)

		var floor_mesh := _make_box_node(
			"Floor_%d" % f,
			Vector3(width_x, FLOOR_HEIGHT - 0.05, depth_z),
			Vector3(0.0, floor_y + (FLOOR_HEIGHT - 0.05) * 0.5, 0.0),
			wall_col
		)
		building_root.add_child(floor_mesh)

		# Gờ phào chỉ phân tầng (Ledge)
		if f > 0:
			var ledge := _make_box_node(
				"Ledge_%d" % f,
				Vector3(width_x + 0.3, 0.15, depth_z + 0.3),
				Vector3(0.0, floor_y, 0.0),
				COLOR_ROOF
			)
			building_root.add_child(ledge)

	# 3. Mái bằng có gờ chắn (Parapet roof)
	var roof := _make_box_node(
		"Roof",
		Vector3(width_x + 0.4, 0.25, depth_z + 0.4),
		Vector3(0.0, total_height + 0.125, 0.0),
		COLOR_ROOF
	)
	building_root.add_child(roof)

	# 4. Chi tiết mặt tiền theo hướng (Cửa chính, cửa sổ, bảng hiệu)
	_build_facade(spec, building_root, width_x, depth_z, total_floors, facing)


## Dựng các chi tiết kiến trúc mặt tiền theo hướng nhìn ra vỉa hè
static func _build_facade(
	spec: BuildingSpec,
	building_root: Node3D,
	width_x: float,
	depth_z: float,
	floors: int,
	facing: String
) -> void:
	var door_w: float = 1.4
	var door_h: float = 2.2
	var door_color := COLOR_DOOR_WOOD
	if spec.type == "cafe" or spec.type == "pharmacy" or spec.type == "grocery":
		door_color = COLOR_DOOR_GLASS

	var half_w := width_x * 0.5
	var half_d := depth_z * 0.5

	# Tính vector vị trí và góc quay theo hướng mặt tiền
	var front_offset := Vector3.ZERO
	var sign_rot_y := 0.0

	match facing:
		"east":
			# Mặt tiền quay về phía trục +X (nhìn ra đường ở phía đông)
			front_offset = Vector3(half_w, 0.0, 0.0)
			sign_rot_y = 90.0

			# Cửa chính tầng 1
			building_root.add_child(
				_make_box_node("Door", Vector3(0.10, door_h, door_w), Vector3(half_w + 0.04, door_h * 0.5, 0.0), door_color)
			)
			# Bậc tam cấp
			building_root.add_child(
				_make_box_node("Step", Vector3(0.60, 0.10, door_w + 0.4), Vector3(half_w + 0.30, 0.05, 0.0), COLOR_STEP)
			)
			# Bảng hiệu trên cửa
			_add_sign_board(spec.sign_text, building_root, Vector3(half_w + 0.15, door_h + 0.6, 0.0), sign_rot_y, depth_z * 0.7)

			# Cửa sổ các tầng trên
			for f in range(1, floors):
				var fy := float(f) * FLOOR_HEIGHT + 1.6
				building_root.add_child(
					_make_box_node("Win_L_%d" % f, Vector3(0.08, 1.2, 1.2), Vector3(half_w + 0.03, fy, -half_d * 0.45), COLOR_WINDOW)
				)
				building_root.add_child(
					_make_box_node("Win_R_%d" % f, Vector3(0.08, 1.2, 1.2), Vector3(half_w + 0.03, fy, half_d * 0.45), COLOR_WINDOW)
				)

		"west":
			# Mặt tiền quay về phía trục -X (nhìn ra đường ở phía tây)
			front_offset = Vector3(-half_w, 0.0, 0.0)
			sign_rot_y = -90.0

			building_root.add_child(
				_make_box_node("Door", Vector3(0.10, door_h, door_w), Vector3(-half_w - 0.04, door_h * 0.5, 0.0), door_color)
			)
			building_root.add_child(
				_make_box_node("Step", Vector3(0.60, 0.10, door_w + 0.4), Vector3(-half_w - 0.30, 0.05, 0.0), COLOR_STEP)
			)
			_add_sign_board(spec.sign_text, building_root, Vector3(-half_w - 0.15, door_h + 0.6, 0.0), sign_rot_y, depth_z * 0.7)

			for f in range(1, floors):
				var fy := float(f) * FLOOR_HEIGHT + 1.6
				building_root.add_child(
					_make_box_node("Win_L_%d" % f, Vector3(0.08, 1.2, 1.2), Vector3(-half_w - 0.03, fy, -half_d * 0.45), COLOR_WINDOW)
				)
				building_root.add_child(
					_make_box_node("Win_R_%d" % f, Vector3(0.08, 1.2, 1.2), Vector3(-half_w - 0.03, fy, half_d * 0.45), COLOR_WINDOW)
				)

		"south":
			# Mặt tiền quay về phía trục +Z (nhìn ra hẻm ở phía nam)
			front_offset = Vector3(0.0, 0.0, half_d)
			sign_rot_y = 0.0

			building_root.add_child(
				_make_box_node("Door", Vector3(door_w, door_h, 0.10), Vector3(0.0, door_h * 0.5, half_d + 0.04), door_color)
			)
			building_root.add_child(
				_make_box_node("Step", Vector3(door_w + 0.4, 0.10, 0.60), Vector3(0.0, 0.05, half_d + 0.30), COLOR_STEP)
			)
			_add_sign_board(spec.sign_text, building_root, Vector3(0.0, door_h + 0.6, half_d + 0.15), sign_rot_y, width_x * 0.7)

			for f in range(1, floors):
				var fy := float(f) * FLOOR_HEIGHT + 1.6
				building_root.add_child(
					_make_box_node("Win_L_%d" % f, Vector3(1.2, 1.2, 0.08), Vector3(-half_w * 0.45, fy, half_d + 0.03), COLOR_WINDOW)
				)
				building_root.add_child(
					_make_box_node("Win_R_%d" % f, Vector3(1.2, 1.2, 0.08), Vector3(half_w * 0.45, fy, half_d + 0.03), COLOR_WINDOW)
				)

		"north":
			# Mặt tiền quay về phía trục -Z (nhìn ra hẻm ở phía bắc)
			front_offset = Vector3(0.0, 0.0, -half_d)
			sign_rot_y = 180.0

			building_root.add_child(
				_make_box_node("Door", Vector3(door_w, door_h, 0.10), Vector3(0.0, door_h * 0.5, -half_d - 0.04), door_color)
			)
			building_root.add_child(
				_make_box_node("Step", Vector3(door_w + 0.4, 0.10, 0.60), Vector3(0.0, 0.05, -half_d - 0.30), COLOR_STEP)
			)
			_add_sign_board(spec.sign_text, building_root, Vector3(0.0, door_h + 0.6, -half_d - 0.15), sign_rot_y, width_x * 0.7)

			for f in range(1, floors):
				var fy := float(f) * FLOOR_HEIGHT + 1.6
				building_root.add_child(
					_make_box_node("Win_L_%d" % f, Vector3(1.2, 1.2, 0.08), Vector3(-half_w * 0.45, fy, -half_d - 0.03), COLOR_WINDOW)
				)
				building_root.add_child(
					_make_box_node("Win_R_%d" % f, Vector3(1.2, 1.2, 0.08), Vector3(half_w * 0.45, fy, -half_d - 0.03), COLOR_WINDOW)
				)


static func _add_sign_board(
	text: String,
	parent: Node3D,
	pos: Vector3,
	rot_y_deg: float,
	board_width: float
) -> void:
	if text.is_empty():
		return

	var board_node := Node3D.new()
	board_node.name = "SignBoardRoot"
	board_node.position = pos
	board_node.rotation_degrees = Vector3(0.0, rot_y_deg, 0.0)
	parent.add_child(board_node)

	# Nền bảng hiệu
	var bg_mesh := _make_box_node(
		"SignBg",
		Vector3(minf(board_width, 4.0), 0.75, 0.12),
		Vector3.ZERO,
		COLOR_SIGN_BOARD
	)
	board_node.add_child(bg_mesh)

	# Chữ trên bảng hiệu
	var label := Label3D.new()
	label.name = "SignText"
	label.text = text
	label.position = Vector3(0.0, 0.0, 0.08)
	label.font_size = 38
	label.outline_size = 6
	label.modulate = Color(1.0, 0.95, 0.75)
	label.outline_modulate = Color(0.1, 0.1, 0.1)
	label.no_depth_test = false
	board_node.add_child(label)


static func _make_box_node(object_name: String, box_size: Vector3, local_position: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = box_size
	var instance := MeshInstance3D.new()
	instance.name = object_name
	instance.mesh = mesh
	instance.position = local_position
	instance.material_override = _make_material(color)
	return instance


static func _make_material(color: Color) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = SURFACE_SHADER
	material.set_shader_parameter("base_color", color)
	material.set_shader_parameter("roughness_value", 0.88)
	material.set_shader_parameter("surface_detail", 0.018)
	return material


## Tương thích ngược logic cũ
static func build_buildings(specs: Array[Dictionary], parent: Node3D) -> void:
	for i in range(specs.size()):
		var spec: Dictionary = specs[i]
		_build_house(parent, spec["position"], spec["wall_color"])


static func _build_house(parent: Node3D, world_position: Vector3, wall_color: Color) -> void:
	var house := StaticBody3D.new()
	house.name = "VietnameseHouse"
	house.position = world_position
	parent.add_child(house)

	house.add_child(
		_make_box_node("HouseBody", Vector3(5.0, 3.0, 6.0), Vector3(0.0, 1.5, 0.0), wall_color)
	)

	var collision := CollisionShape3D.new()
	var collision_shape := BoxShape3D.new()
	collision_shape.size = Vector3(5.0, 3.0, 6.0)
	collision.shape = collision_shape
	collision.position.y = 1.5
	house.add_child(collision)

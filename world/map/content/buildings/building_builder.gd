## BuildingBuilder: Dựng 6 mẫu tòa nhà chức năng theo MapLayout:
## - nha_pho (Nhà phố hiện đại)
## - nha_tro (Nhà trọ sinh viên / người lao động)
## - tap_hoa (Cửa hàng tạp hóa)
## - quan_an (Quán cơm / phở / bún)
## - quan_ca_phe (Quán cà phê phố)
## - tiem_sua_xe (Tiệm sửa xe máy)
##
## Quy tắc kỹ thuật:
## - Mỗi mẫu là hàm dựng tham số (số tầng, bề rộng, sâu, màu, mái), dùng Primitive Mesh.
## - Tái sử dụng Mesh/Material (ShaderMaterial procedural_surface, không texture).
## - Chiều cao tối đa 2 tầng (~6.4m) để ít che khuất tầm nhìn của Player.
## - Cơ chế làm mờ tòa nhà khi che giữa Camera và Player (Shader transparency).
## - Biển hiệu tiếng Việt bằng Label3D kích thước lớn, nhìn rõ từ camera chơi.
## - Collision StaticBody3D theo thân nhà.
## - Cửa là điểm tương tác: Area3D phát WorldEvents.BUILDING_DOOR_ENTERED.
extends RefCounted
class_name BuildingBuilder

const SURFACE_SHADER: Shader = preload("res://world/map/shaders/procedural_surface.gdshader")
const FADER_SCRIPT: Script = preload("res://world/map/content/buildings/building_occlusion_fader.gd")

const SIDEWALK_Y: float = 0.08
const FLOOR_HEIGHT: float = 3.2
const MAX_BUILDING_HEIGHT: float = 6.5
const BASE_ELEVATION: float = 0.12

# Bảng màu kiến trúc không texture chuẩn Việt Nam
const COLOR_ROOF_DARK: Color = Color(0.28, 0.25, 0.24)
const COLOR_ROOF_CLAY: Color = Color(0.65, 0.30, 0.22) # Mái ngói đỏ/cam
const COLOR_DOOR_WOOD: Color = Color(0.35, 0.22, 0.14)
const COLOR_DOOR_GLASS: Color = Color(0.20, 0.38, 0.48)
const COLOR_DOOR_ROLLING: Color = Color(0.40, 0.44, 0.46) # Cửa cuốn
const COLOR_WINDOW: Color = Color(0.25, 0.48, 0.58)
const COLOR_SIGN_BOARD: Color = Color(0.12, 0.14, 0.16)
const COLOR_STEP: Color = Color(0.42, 0.42, 0.44)
const COLOR_AWNING: Color = Color(0.72, 0.22, 0.18) # Bạt che di động


## Dựng toàn bộ các tòa nhà có trong MapLayout
static func build_from_layout(layout: MapLayout, parent: Node3D) -> void:
	if layout == null:
		return

	var lots_dict: Dictionary = {}
	for lot: LotSpec in layout.lots:
		lots_dict[lot.id] = lot

	for building: BuildingSpec in layout.buildings:
		var lot: LotSpec = lots_dict.get(building.lot_id, null)
		_dispatch_building_sample(building, lot, parent)


## Điều phối gọi hàm dựng theo từng mẫu tòa nhà
static func _dispatch_building_sample(spec: BuildingSpec, lot: LotSpec, parent: Node3D) -> void:
	var width_x: float = 7.0
	var depth_z: float = 8.0
	var center_x: float = spec.door_point.x
	var center_z: float = spec.door_point.z
	var facing: String = "east"

	if lot != null:
		facing = lot.facing
		width_x = maxf(4.0, lot.rect.size.x - 0.8)
		depth_z = maxf(4.0, lot.rect.size.y - 0.8)
		center_x = lot.rect.position.x + lot.rect.size.x * 0.5
		center_z = lot.rect.position.y + lot.rect.size.y * 0.5

	# Chiều cao tối đa 2 tầng (~6.4m - 6.5m)
	var floors: int = clampi(spec.floors, 1, 2)

	match spec.type:
		"nha_pho":
			build_nha_pho(parent, spec, center_x, center_z, width_x, depth_z, floors, facing)
		"nha_tro":
			build_nha_tro(parent, spec, center_x, center_z, width_x, depth_z, floors, facing)
		"tap_hoa":
			build_tap_hoa(parent, spec, center_x, center_z, width_x, depth_z, floors, facing)
		"quan_an":
			build_quan_an(parent, spec, center_x, center_z, width_x, depth_z, floors, facing)
		"quan_ca_phe":
			build_quan_ca_phe(parent, spec, center_x, center_z, width_x, depth_z, floors, facing)
		"tiem_sua_xe":
			build_tiem_sua_xe(parent, spec, center_x, center_z, width_x, depth_z, floors, facing)
		_:
			# Dự phòng mẫu chung
			build_nha_pho(parent, spec, center_x, center_z, width_x, depth_z, floors, facing)


# ==============================================================================
# 6 MẪU TÒA NHÀ THAM SỐ
# ==============================================================================

## 1. Mẫu Nhà Phố: Hiện đại, mái bằng có gờ chắn parapet, ban công tầng 2, cửa gỗ kính
static func build_nha_pho(
	parent: Node3D,
	spec: BuildingSpec,
	cx: float,
	cz: float,
	w: float,
	d: float,
	floors: int,
	facing: String
) -> StaticBody3D:
	var b := _create_building_base(parent, spec, cx, cz, w, d, floors)
	_build_body_floors(b, w, d, floors, spec.color, COLOR_ROOF_DARK)
	_build_flat_roof(b, w, d, floors, COLOR_ROOF_DARK)
	_build_facade(b, spec, w, d, floors, facing, COLOR_DOOR_WOOD, "standard", false)
	_add_door_interaction_area(b, spec.id, spec.door_point - b.position)
	return b


## 2. Mẫu Nhà Trọ: Dãy phòng trọ 2 tầng, hành lang lan can mở phía trước, cửa sổ song sắt
static func build_nha_tro(
	parent: Node3D,
	spec: BuildingSpec,
	cx: float,
	cz: float,
	w: float,
	d: float,
	floors: int,
	facing: String
) -> StaticBody3D:
	var b := _create_building_base(parent, spec, cx, cz, w, d, floors)
	_build_body_floors(b, w, d, floors, spec.color, COLOR_ROOF_DARK)
	_build_flat_roof(b, w, d, floors, COLOR_ROOF_DARK)
	_build_facade(b, spec, w, d, floors, facing, COLOR_DOOR_WOOD, "corridor", false)
	_add_door_interaction_area(b, spec.id, spec.door_point - b.position)
	return b


## 3. Mẫu Tạp Hóa: Tầng trệt cửa kính thoáng, biển hiệu lớn nổi bật, mái hiên che nắng
static func build_tap_hoa(
	parent: Node3D,
	spec: BuildingSpec,
	cx: float,
	cz: float,
	w: float,
	d: float,
	floors: int,
	facing: String
) -> StaticBody3D:
	var b := _create_building_base(parent, spec, cx, cz, w, d, floors)
	_build_body_floors(b, w, d, floors, spec.color, COLOR_ROOF_CLAY)
	_build_sloped_roof(b, w, d, floors, COLOR_ROOF_CLAY)
	_build_facade(b, spec, w, d, floors, facing, COLOR_DOOR_GLASS, "wide_store", true)
	_add_door_interaction_area(b, spec.id, spec.door_point - b.position)
	return b


## 4. Mẫu Quán Ăn: Bạt che hiên đỏ/cam, biển hiệu to, cửa rộng đón khách
static func build_quan_an(
	parent: Node3D,
	spec: BuildingSpec,
	cx: float,
	cz: float,
	w: float,
	d: float,
	floors: int,
	facing: String
) -> StaticBody3D:
	var b := _create_building_base(parent, spec, cx, cz, w, d, floors)
	_build_body_floors(b, w, d, floors, spec.color, COLOR_ROOF_CLAY)
	_build_sloped_roof(b, w, d, floors, COLOR_ROOF_CLAY)
	_build_facade(b, spec, w, d, floors, facing, COLOR_DOOR_WOOD, "restaurant", true)
	_add_door_interaction_area(b, spec.id, spec.door_point - b.position)
	return b


## 5. Mẫu Quán Cà Phê: Tone ấm cúng, cửa kính ngắm phố, mái bằng, hiên nhỏ có đèn
static func build_quan_ca_phe(
	parent: Node3D,
	spec: BuildingSpec,
	cx: float,
	cz: float,
	w: float,
	d: float,
	floors: int,
	facing: String
) -> StaticBody3D:
	var b := _create_building_base(parent, spec, cx, cz, w, d, floors)
	_build_body_floors(b, w, d, floors, spec.color, COLOR_ROOF_DARK)
	_build_flat_roof(b, w, d, floors, COLOR_ROOF_DARK)
	_build_facade(b, spec, w, d, floors, facing, COLOR_DOOR_GLASS, "cafe", true)
	_add_door_interaction_area(b, spec.id, spec.door_point - b.position)
	return b


## 6. Mẫu Tiệm Sửa Xe: 1 tầng trần cao, cửa cuốn rộng kim loại, sàn bê tông chịu lực
static func build_tiem_sua_xe(
	parent: Node3D,
	spec: BuildingSpec,
	cx: float,
	cz: float,
	w: float,
	d: float,
	floors: int,
	facing: String
) -> StaticBody3D:
	var b := _create_building_base(parent, spec, cx, cz, w, d, 1) # Sửa xe luôn 1 tầng thoáng
	_build_body_floors(b, w, d, 1, spec.color, COLOR_ROOF_DARK)
	_build_flat_roof(b, w, d, 1, COLOR_ROOF_DARK)
	_build_facade(b, spec, w, d, 1, facing, COLOR_DOOR_ROLLING, "garage", false)
	_add_door_interaction_area(b, spec.id, spec.door_point - b.position)
	return b


# ==============================================================================
# HÀM DỰNG HÌNH HỌC VÀ TIỆN ÍCH DÙNG CHUNG
# ==============================================================================

static func _create_building_base(
	parent: Node3D,
	spec: BuildingSpec,
	cx: float,
	cz: float,
	w: float,
	d: float,
	floors: int
) -> StaticBody3D:
	var b := StaticBody3D.new()
	b.name = spec.id
	b.position = Vector3(cx, BASE_ELEVATION, cz)
	parent.add_child(b)

	var h: float = minf(float(floors) * FLOOR_HEIGHT, MAX_BUILDING_HEIGHT)

	# Khối va chạm toàn thân nhà
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(w, h, d)
	col.shape = shape
	col.position = Vector3(0.0, h * 0.5, 0.0)
	b.add_child(col)

	# Gắn component làm mờ khi che khuất (Occlusion Fader)
	var fader := Node.new()
	fader.set_script(FADER_SCRIPT)
	b.add_child(fader)

	return b


static func _build_body_floors(
	b: StaticBody3D,
	w: float,
	d: float,
	floors: int,
	base_color: Color,
	ledge_color: Color
) -> void:
	var materials: Array[ShaderMaterial] = []
	for f in range(floors):
		var fy := float(f) * FLOOR_HEIGHT
		var col := base_color
		if f > 0:
			col = Color(
				clampf(base_color.r * 1.05, 0.0, 1.0),
				clampf(base_color.g * 1.05, 0.0, 1.0),
				clampf(base_color.b * 1.05, 0.0, 1.0)
			)
		var mesh_inst := _make_box_node(
			"Floor_%d" % f,
			Vector3(w, FLOOR_HEIGHT - 0.05, d),
			Vector3(0.0, fy + (FLOOR_HEIGHT - 0.05) * 0.5, 0.0),
			col
		)
		b.add_child(mesh_inst)
		materials.append(mesh_inst.material_override as ShaderMaterial)

		if f > 0:
			var ledge := _make_box_node(
				"Ledge_%d" % f,
				Vector3(w + 0.25, 0.15, d + 0.25),
				Vector3(0.0, fy, 0.0),
				ledge_color
			)
			b.add_child(ledge)
			materials.append(ledge.material_override as ShaderMaterial)

	# Cấu hình danh sách materials cho fader
	var fader: Node = b.get_node_or_null("BuildingOcclusionFader")
	if fader != null and fader.has_method("configure"):
		var radius: float = maxf(w, d) * 0.5
		fader.call("configure", materials, b.global_position, radius)


static func _build_flat_roof(b: StaticBody3D, w: float, d: float, floors: int, color: Color) -> void:
	var h: float = float(floors) * FLOOR_HEIGHT
	var roof := _make_box_node(
		"FlatRoof",
		Vector3(w + 0.35, 0.25, d + 0.35),
		Vector3(0.0, h + 0.125, 0.0),
		color
	)
	b.add_child(roof)


static func _build_sloped_roof(b: StaticBody3D, w: float, d: float, floors: int, color: Color) -> void:
	var h: float = float(floors) * FLOOR_HEIGHT
	# Mái ngói dốc (dựng giả lập bằng tầng mái nhô dốc)
	var roof_base := _make_box_node(
		"SlopedRoofBase",
		Vector3(w + 0.5, 0.20, d + 0.5),
		Vector3(0.0, h + 0.10, 0.0),
		color
	)
	b.add_child(roof_base)

	var roof_top := _make_box_node(
		"SlopedRoofTop",
		Vector3(w * 0.7, 0.50, d * 0.8),
		Vector3(0.0, h + 0.45, 0.0),
		color
	)
	b.add_child(roof_top)


static func _build_facade(
	b: StaticBody3D,
	spec: BuildingSpec,
	w: float,
	d: float,
	floors: int,
	facing: String,
	door_color: Color,
	style: String,
	has_awning: bool
) -> void:
	var half_w := w * 0.5
	var half_d := d * 0.5
	var door_w: float = 2.4 if style == "garage" else (1.6 if style == "wide_store" else 1.3)
	var door_h: float = 2.4 if style == "garage" else 2.2
	var sign_rot_y := 0.0

	var sign_local_pos := Vector3.ZERO
	var door_local_pos := Vector3.ZERO
	var step_local_pos := Vector3.ZERO
	var step_size := Vector3.ZERO

	match facing:
		"east":
			sign_rot_y = 90.0
			door_local_pos = Vector3(half_w + 0.04, door_h * 0.5, 0.0)
			step_local_pos = Vector3(half_w + 0.30, 0.05, 0.0)
			step_size = Vector3(0.60, 0.10, door_w + 0.4)
			sign_local_pos = Vector3(half_w + 0.20, door_h + 0.6, 0.0)

			# Cửa chính & Bậc thềm
			b.add_child(_make_box_node("Door", Vector3(0.08, door_h, door_w), door_local_pos, door_color))
			b.add_child(_make_box_node("Step", step_size, step_local_pos, COLOR_STEP))

			# Bạt che hiên (nếu có)
			if has_awning:
				b.add_child(_make_box_node("Awning", Vector3(1.2, 0.12, door_w + 1.2), Vector3(half_w + 0.6, door_h + 0.1, 0.0), COLOR_AWNING))

			# Cửa sổ các tầng trên
			for f in range(1, floors):
				var fy := float(f) * FLOOR_HEIGHT + 1.6
				b.add_child(_make_box_node("Win_L_%d" % f, Vector3(0.08, 1.2, 1.2), Vector3(half_w + 0.03, fy, -half_d * 0.45), COLOR_WINDOW))
				b.add_child(_make_box_node("Win_R_%d" % f, Vector3(0.08, 1.2, 1.2), Vector3(half_w + 0.03, fy, half_d * 0.45), COLOR_WINDOW))

		"west":
			sign_rot_y = -90.0
			door_local_pos = Vector3(-half_w - 0.04, door_h * 0.5, 0.0)
			step_local_pos = Vector3(-half_w - 0.30, 0.05, 0.0)
			step_size = Vector3(0.60, 0.10, door_w + 0.4)
			sign_local_pos = Vector3(-half_w - 0.20, door_h + 0.6, 0.0)

			b.add_child(_make_box_node("Door", Vector3(0.08, door_h, door_w), door_local_pos, door_color))
			b.add_child(_make_box_node("Step", step_size, step_local_pos, COLOR_STEP))

			if has_awning:
				b.add_child(_make_box_node("Awning", Vector3(1.2, 0.12, door_w + 1.2), Vector3(-half_w - 0.6, door_h + 0.1, 0.0), COLOR_AWNING))

			for f in range(1, floors):
				var fy := float(f) * FLOOR_HEIGHT + 1.6
				b.add_child(_make_box_node("Win_L_%d" % f, Vector3(0.08, 1.2, 1.2), Vector3(-half_w - 0.03, fy, -half_d * 0.45), COLOR_WINDOW))
				b.add_child(_make_box_node("Win_R_%d" % f, Vector3(0.08, 1.2, 1.2), Vector3(-half_w - 0.03, fy, half_d * 0.45), COLOR_WINDOW))

		"south":
			sign_rot_y = 0.0
			door_local_pos = Vector3(0.0, door_h * 0.5, half_d + 0.04)
			step_local_pos = Vector3(0.0, 0.05, half_d + 0.30)
			step_size = Vector3(door_w + 0.4, 0.10, 0.60)
			sign_local_pos = Vector3(0.0, door_h + 0.6, half_d + 0.20)

			b.add_child(_make_box_node("Door", Vector3(door_w, door_h, 0.08), door_local_pos, door_color))
			b.add_child(_make_box_node("Step", step_size, step_local_pos, COLOR_STEP))

			if has_awning:
				b.add_child(_make_box_node("Awning", Vector3(door_w + 1.2, 0.12, 1.2), Vector3(0.0, door_h + 0.1, half_d + 0.6), COLOR_AWNING))

			for f in range(1, floors):
				var fy := float(f) * FLOOR_HEIGHT + 1.6
				b.add_child(_make_box_node("Win_L_%d" % f, Vector3(1.2, 1.2, 0.08), Vector3(-half_w * 0.45, fy, half_d + 0.03), COLOR_WINDOW))
				b.add_child(_make_box_node("Win_R_%d" % f, Vector3(1.2, 1.2, 0.08), Vector3(half_w * 0.45, fy, half_d + 0.03), COLOR_WINDOW))

		"north":
			sign_rot_y = 180.0
			door_local_pos = Vector3(0.0, door_h * 0.5, -half_d - 0.04)
			step_local_pos = Vector3(0.0, 0.05, -half_d - 0.30)
			step_size = Vector3(door_w + 0.4, 0.10, 0.60)
			sign_local_pos = Vector3(0.0, door_h + 0.6, -half_d - 0.20)

			b.add_child(_make_box_node("Door", Vector3(door_w, door_h, 0.08), door_local_pos, door_color))
			b.add_child(_make_box_node("Step", step_size, step_local_pos, COLOR_STEP))

			if has_awning:
				b.add_child(_make_box_node("Awning", Vector3(door_w + 1.2, 0.12, 1.2), Vector3(0.0, door_h + 0.1, -half_d - 0.6), COLOR_AWNING))

			for f in range(1, floors):
				var fy := float(f) * FLOOR_HEIGHT + 1.6
				b.add_child(_make_box_node("Win_L_%d" % f, Vector3(1.2, 1.2, 0.08), Vector3(-half_w * 0.45, fy, -half_d - 0.03), COLOR_WINDOW))
				b.add_child(_make_box_node("Win_R_%d" % f, Vector3(1.2, 1.2, 0.08), Vector3(half_w * 0.45, fy, -half_d - 0.03), COLOR_WINDOW))

	_add_sign_board(spec.sign_text, b, sign_local_pos, sign_rot_y, 4.0)


## Điểm tương tác cửa: Area3D phát WorldEvents.BUILDING_DOOR_ENTERED
static func _add_door_interaction_area(b: StaticBody3D, building_id: String, local_door_pos: Vector3) -> void:
	var area := Area3D.new()
	area.name = "DoorArea"
	area.position = local_door_pos + Vector3(0.0, 1.0, 0.0)
	area.collision_layer = 0
	area.collision_mask = 1 # Va chạm với Player

	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.5, 2.0, 1.5)
	col.shape = box
	area.add_child(col)

	area.body_entered.connect(func(body: Node3D) -> void:
		if body.is_in_group("player"):
			EventBus.emit_event(WorldEvents.BUILDING_DOOR_ENTERED, {"building_id": building_id})
			print("[Building] Player entered door: ", building_id)
	)

	b.add_child(area)


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

	var bg_mesh := _make_box_node(
		"SignBg",
		Vector3(minf(board_width, 3.8), 0.75, 0.12),
		Vector3.ZERO,
		COLOR_SIGN_BOARD
	)
	board_node.add_child(bg_mesh)

	var label := Label3D.new()
	label.name = "SignText"
	label.text = text
	label.position = Vector3(0.0, 0.0, 0.08)
	label.font_size = 42 # Đủ lớn để đọc rõ từ camera chơi
	label.outline_size = 8
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
	material.set_shader_parameter("transparency_alpha", 1.0)
	return material

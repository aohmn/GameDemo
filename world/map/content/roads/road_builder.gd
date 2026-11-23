## RoadBuilder: Dựng đường, vỉa hè, vạch kẻ đường, nền từ MapLayout.
## Quy định độ cao mặt trên (m):
## - Nền đất (Ground): 0.00
## - Gờ lề (Curb): 0.04
## - Lòng đường (Road): 0.05
## - Vạch sơn (Marking): 0.062
## - Vỉa hè (Sidewalk): 0.08
## Đảm bảo: Không để hai khối khác màu cùng độ cao. Mọi mặt đi được đều có collision.
extends RefCounted
class_name RoadBuilder

const SURFACE_SHADER: Shader = preload("res://world/map/shaders/procedural_surface.gdshader")

## Độ dày các khối hình học (để collision và mặt hiển thị ổn định, tâm đặt ở Y - dày/2)
const GROUND_TOP_Y: float = 0.00
const CURB_TOP_Y: float = 0.04
const ROAD_TOP_Y: float = 0.05
const MARKING_TOP_Y: float = 0.062
const SIDEWALK_TOP_Y: float = 0.08
const SLAB_THICKNESS: float = 0.40

const COLOR_GROUND: Color = Color(0.32, 0.45, 0.28)
const COLOR_ROAD: Color = Color(0.18, 0.18, 0.19)
const COLOR_CURB: Color = Color(0.38, 0.38, 0.39)
const COLOR_SIDEWALK: Color = Color(0.48, 0.47, 0.45)
const COLOR_MARKING_WHITE: Color = Color(0.92, 0.92, 0.90)
const COLOR_MARKING_YELLOW: Color = Color(0.92, 0.78, 0.15)


## Dựng toàn bộ hạ tầng đường bộ từ MapLayout.
static func build_from_layout(layout: MapLayout, parent: Node3D) -> void:
	if layout == null:
		return

	# 1. Dựng nền đất tổng thể phủ toàn bộ map bounds
	_build_ground(layout.bounds, parent)

	# 2. Dựng từng tuyến đường, vỉa hè và vạch kẻ
	for road: RoadSpec in layout.roads:
		_build_road_spec(road, parent)


## Khối nền đất bao quanh
static func _build_ground(bounds: Rect2, parent: Node3D) -> void:
	var center_x := bounds.position.x + bounds.size.x * 0.5
	var center_z := bounds.position.y + bounds.size.y * 0.5
	var size_x := bounds.size.x
	var size_z := bounds.size.y
	_create_slab("GroundBase", parent, Vector3(center_x, GROUND_TOP_Y, center_z), Vector2(size_x, size_z), COLOR_GROUND, true)


## Dựng một RoadSpec (phố chính, hẻm cụt, quảng trường)
static func _build_road_spec(road: RoadSpec, parent: Node3D) -> void:
	var start := road.start_point
	var end := road.end_point
	var dir := end - start
	var length := dir.length()
	if length < 0.001:
		return

	var center_2d := (start + end) * 0.5
	var road_width := road.width

	if road.kind == "plaza":
		# Quảng trường: lòng đường phẳng rộng 24m, có vỉa hè bao quanh 2m
		_create_slab(
			road.id + "_Surface",
			parent,
			Vector3(center_2d.x, ROAD_TOP_Y, center_2d.y),
			Vector2(road_width, length),
			COLOR_ROAD,
			true
		)
		# Vỉa hè phía đông và tây của quảng trường
		_create_slab(
			road.id + "_Sidewalk_W",
			parent,
			Vector3(center_2d.x - road_width * 0.5 - 1.0, SIDEWALK_TOP_Y, center_2d.y),
			Vector2(2.0, length),
			COLOR_SIDEWALK,
			true
		)
		_create_slab(
			road.id + "_Sidewalk_E",
			parent,
			Vector3(center_2d.x + road_width * 0.5 + 1.0, SIDEWALK_TOP_Y, center_2d.y),
			Vector2(2.0, length),
			COLOR_SIDEWALK,
			true
		)
		# Gờ lề
		_create_slab(
			road.id + "_Curb_W",
			parent,
			Vector3(center_2d.x - road_width * 0.5 + 0.075, CURB_TOP_Y, center_2d.y),
			Vector2(0.15, length),
			COLOR_CURB,
			false
		)
		_create_slab(
			road.id + "_Curb_E",
			parent,
			Vector3(center_2d.x + road_width * 0.5 - 0.075, CURB_TOP_Y, center_2d.y),
			Vector2(0.15, length),
			COLOR_CURB,
			false
		)
		return

	# Tuyến đường thẳng (dọc theo trục z hoặc ngang theo trục x)
	var is_vertical := absf(dir.y) >= absf(dir.x)

	if is_vertical:
		# Đường chạy dọc trục Z (ví dụ: Phố chính)
		# Lòng đường
		_create_slab(
			road.id + "_Road",
			parent,
			Vector3(center_2d.x, ROAD_TOP_Y, center_2d.y),
			Vector2(road_width, length),
			COLOR_ROAD,
			true
		)

		# Vỉa hè hai bên (mỗi bên rộng 2m đối với phố chính, 1m đối với hẻm nếu có)
		var sidewalk_w := 2.0 if road.kind == "main" else 1.0
		var sw_offset := road_width * 0.5 + sidewalk_w * 0.5

		_create_slab(
			road.id + "_Sidewalk_W",
			parent,
			Vector3(center_2d.x - sw_offset, SIDEWALK_TOP_Y, center_2d.y),
			Vector2(sidewalk_w, length),
			COLOR_SIDEWALK,
			true
		)
		_create_slab(
			road.id + "_Sidewalk_E",
			parent,
			Vector3(center_2d.x + sw_offset, SIDEWALK_TOP_Y, center_2d.y),
			Vector2(sidewalk_w, length),
			COLOR_SIDEWALK,
			true
		)

		# Gờ lề (curb) mép vỉa hè tiếp giáp lòng đường
		_create_slab(
			road.id + "_Curb_W",
			parent,
			Vector3(center_2d.x - road_width * 0.5 + 0.075, CURB_TOP_Y, center_2d.y),
			Vector2(0.15, length),
			COLOR_CURB,
			false
		)
		_create_slab(
			road.id + "_Curb_E",
			parent,
			Vector3(center_2d.x + road_width * 0.5 - 0.075, CURB_TOP_Y, center_2d.y),
			Vector2(0.15, length),
			COLOR_CURB,
			false
		)

		# Vạch sơn tim đường đứt đoạn (chỉ trên phố chính)
		if road.kind == "main":
			_build_road_stripes_vertical(road.id, center_2d.x, start.y, end.y, parent)

	else:
		# Đường chạy ngang trục X (ví dụ: Hẻm cụt)
		# Lòng đường
		_create_slab(
			road.id + "_Road",
			parent,
			Vector3(center_2d.x, ROAD_TOP_Y, center_2d.y),
			Vector2(length, road_width),
			COLOR_ROAD,
			true
		)

		# Vỉa hè hẻm hai bên (rộng 1m)
		var sw_w := 1.0
		var sw_off := road_width * 0.5 + sw_w * 0.5

		_create_slab(
			road.id + "_Sidewalk_N",
			parent,
			Vector3(center_2d.x, SIDEWALK_TOP_Y, center_2d.y - sw_off),
			Vector2(length, sw_w),
			COLOR_SIDEWALK,
			true
		)
		_create_slab(
			road.id + "_Sidewalk_S",
			parent,
			Vector3(center_2d.x, SIDEWALK_TOP_Y, center_2d.y + sw_off),
			Vector2(length, sw_w),
			COLOR_SIDEWALK,
			true
		)

		# Gờ lề hẻm
		_create_slab(
			road.id + "_Curb_N",
			parent,
			Vector3(center_2d.x, CURB_TOP_Y, center_2d.y - road_width * 0.5 + 0.075),
			Vector2(length, 0.15),
			COLOR_CURB,
			false
		)
		_create_slab(
			road.id + "_Curb_S",
			parent,
			Vector3(center_2d.x, CURB_TOP_Y, center_2d.y + road_width * 0.5 - 0.075),
			Vector2(length, 0.15),
			COLOR_CURB,
			false
		)


## Dựng vạch kẻ tim đường đứt đoạn cho đường dọc
static func _build_road_stripes_vertical(prefix: String, x_pos: float, z_start: float, z_end: float, parent: Node3D) -> void:
	var min_z := minf(z_start, z_end)
	var max_z := maxf(z_start, z_end)
	var stripe_len := 3.0
	var gap_len := 3.0
	var current_z := min_z + 2.0
	var stripe_index := 0

	while current_z + stripe_len <= max_z - 2.0:
		var stripe_center_z := current_z + stripe_len * 0.5
		_create_slab(
			prefix + "_Stripe_%d" % stripe_index,
			parent,
			Vector3(x_pos, MARKING_TOP_Y, stripe_center_z),
			Vector2(0.20, stripe_len),
			COLOR_MARKING_WHITE,
			false
		)
		current_z += stripe_len + gap_len
		stripe_index += 1


## Tạo một phiến slab 3D với MeshInstance3D và StaticBody3D collision tùy chọn
static func _create_slab(
	slab_name: String,
	parent: Node3D,
	top_center: Vector3,
	size_2d: Vector2,
	color: Color,
	has_collision: bool
) -> void:
	var box_size := Vector3(size_2d.x, SLAB_THICKNESS, size_2d.y)
	var box_center := Vector3(top_center.x, top_center.y - SLAB_THICKNESS * 0.5, top_center.z)

	var node_root: Node3D
	if has_collision:
		var body := StaticBody3D.new()
		body.name = slab_name
		body.position = box_center

		var col_shape := CollisionShape3D.new()
		var box_shape := BoxShape3D.new()
		box_shape.size = box_size
		col_shape.shape = box_shape
		body.add_child(col_shape)

		var mesh_inst := _make_box_mesh(box_size, Vector3.ZERO, color)
		mesh_inst.name = slab_name + "Mesh"
		body.add_child(mesh_inst)

		parent.add_child(body)
	else:
		var mesh_inst := _make_box_mesh(box_size, box_center, color)
		mesh_inst.name = slab_name
		parent.add_child(mesh_inst)


static func _make_box_mesh(box_size: Vector3, local_pos: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = box_size
	var inst := MeshInstance3D.new()
	inst.mesh = mesh
	inst.position = local_pos
	inst.material_override = _make_material(color)
	return inst


static func _make_material(color: Color) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = SURFACE_SHADER
	mat.set_shader_parameter("base_color", color)
	mat.set_shader_parameter("roughness_value", 0.88)
	mat.set_shader_parameter("surface_detail", 0.018)
	return mat


## Tương thích ngược: Cho phép gọi build() dạng từ điển cũ nếu còn nơi sử dụng.
static func build(specs: Array[Dictionary], parent: Node3D) -> void:
	for i in range(specs.size()):
		var spec: Dictionary = specs[i]
		var body := StaticBody3D.new()
		body.name = spec["name"]
		body.position = spec["position"]

		var mesh := _make_box_mesh(spec["size"], Vector3.ZERO, spec["color"])
		mesh.name = spec["name"] + "Mesh"
		body.add_child(mesh)

		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = spec["size"]
		collision.shape = shape
		body.add_child(collision)
		parent.add_child(body)

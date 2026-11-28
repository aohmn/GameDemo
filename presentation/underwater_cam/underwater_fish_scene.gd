extends Node3D
## Tạo mô hình cá 3D hoàn toàn bằng Mesh + Shader (không texture) và điều khiển chuyển động.

const FISH_SHADER: Shader = preload("res://presentation/underwater_cam/underwater_fish_shader.gdshader")
const LINE_SCRIPT: Script = preload("res://presentation/underwater_cam/underwater_line.gd")
const VFX_SCRIPT: Script = preload("res://presentation/underwater_cam/underwater_vfx.gd")

var _body_mat: ShaderMaterial
var _fin_mat: ShaderMaterial
var _eye_mat: StandardMaterial3D
var _line_node: Node3D
var _vfx_node: Node3D
var _rig_ref: Node

var _water_anchor: Vector3 = Vector3.ZERO
var _tension_ratio: float = 0.0
var _target_pos: Vector3 = Vector3.ZERO
var _current_pos: Vector3 = Vector3.ZERO
var _swim_time: float = 0.0
var _swim_speed: float = 1.0
var _facing_dir: int = 1
var _target_yaw: float = 0.0


func _ready() -> void:
	add_to_group("shared_fishing_fish")
	_build_materials()
	_build_fish_meshes()
	_line_node = LINE_SCRIPT.new() as Node3D
	_line_node.top_level = true
	add_child(_line_node)
	_vfx_node = VFX_SCRIPT.new() as Node3D
	_vfx_node.top_level = true
	add_child(_vfx_node)
	var bus: Node = get_node_or_null("/root/EventBus")
	if bus != null:
		var ev: Script = load("res://core/contracts/fishing_events.gd") as Script
		if ev != null:
			bus.call("subscribe", ev.STATE_CHANGED, Callable(self, "_on_state_changed"))
			bus.call("subscribe", ev.FIGHT_UPDATE, Callable(self, "_on_fight_update"))
			bus.call("subscribe", ev.FISH_CAUGHT, Callable(self, "_on_fight_ended"))
			bus.call("subscribe", ev.FISH_ESCAPED, Callable(self, "_on_fight_ended"))
	visible = false


func _on_state_changed(payload: Dictionary) -> void:
	var in_fight: bool = (str(payload.get("to_state", "")) == "FIGHT")
	visible = in_fight
	if in_fight:
		_rig_ref = get_tree().get_first_node_in_group("fishing_rig")
		if _rig_ref != null and _rig_ref.has_method("get_line_end"):
			_water_anchor = _rig_ref.call("get_line_end")
		_current_pos = _water_anchor + Vector3(0.0, -1.0, 0.0)
		global_position = _current_pos


func _process(_delta: float) -> void:
	if not visible or _line_node == null or not _line_node.has_method("update_line"):
		return
	if _rig_ref == null or not is_instance_valid(_rig_ref):
		_rig_ref = get_tree().get_first_node_in_group("fishing_rig")
	var rod_tip_world: Vector3 = _water_anchor + Vector3(0.0, 1.2, 0.0)
	if _rig_ref != null and _rig_ref.has_method("get_rod_tip_position"):
		rod_tip_world = _rig_ref.call("get_rod_tip_position")
	_line_node.call("update_line", rod_tip_world, get_mouth_world_position(), _tension_ratio)


func _on_fight_ended(_payload: Dictionary) -> void:
	visible = false


func _on_fight_update(payload: Dictionary) -> void:
	if not visible:
		return
	var tension: float = float(payload.get("line_tension", 0.0))
	var max_t: float = maxf(float(payload.get("max_tension", 100.0)), 1.0)
	_tension_ratio = clampf(tension / max_t, 0.0, 1.0)
	var is_tele: bool = bool(payload.get("fish_telegraphing", false))
	var delta: float = get_process_delta_time()
	update_fish(
		float(payload.get("fish_pos_norm", 0.0)),
		float(payload.get("fish_depth_norm", 0.5)),
		int(payload.get("fish_swim_dir", 1)),
		_tension_ratio,
		is_tele,
		delta
	)
	if _vfx_node != null and _vfx_node.has_method("update_vfx"):
		_vfx_node.call("update_vfx", global_position, is_tele, delta)


## Điểm mở rộng cho hiệu ứng kỹ năng / giật cần dưới nước.
func trigger_skill_fx(color: Color = Color(0.55, 0.92, 1.0)) -> void:
	if _vfx_node != null and _vfx_node.has_method("trigger_shockwave"):
		_vfx_node.call("trigger_shockwave", global_position, color)


func _build_materials() -> void:
	_body_mat = ShaderMaterial.new()
	_body_mat.shader = FISH_SHADER
	_body_mat.set_shader_parameter("is_fin", 0.0)

	_fin_mat = ShaderMaterial.new()
	_fin_mat.shader = FISH_SHADER
	_fin_mat.set_shader_parameter("is_fin", 1.0)

	_eye_mat = StandardMaterial3D.new()
	_eye_mat.albedo_color = Color(0.06, 0.08, 0.1)
	_eye_mat.roughness = 0.15


func _build_fish_meshes() -> void:
	# Thân cá (SphereMesh kéo dẹt thành hình thoi)
	var body := MeshInstance3D.new()
	var body_mesh := SphereMesh.new()
	body_mesh.radius = 0.24
	body_mesh.height = 0.48
	body_mesh.radial_segments = 16
	body_mesh.rings = 10
	body.mesh = body_mesh
	body.scale = Vector3(1.85, 0.85, 0.55)
	body.material_override = _body_mat
	add_child(body)

	# Đuôi cá (PrismMesh dẹt)
	var tail := MeshInstance3D.new()
	var tail_mesh := PrismMesh.new()
	tail_mesh.size = Vector3(0.32, 0.36, 0.04)
	tail.mesh = tail_mesh
	tail.position = Vector3(-0.50, 0.0, 0.0)
	tail.rotation_degrees = Vector3(0.0, 0.0, 90.0)
	tail.material_override = _fin_mat
	add_child(tail)

	# Vây lưng
	var dorsal := MeshInstance3D.new()
	var dorsal_mesh := PrismMesh.new()
	dorsal_mesh.size = Vector3(0.28, 0.18, 0.03)
	dorsal.mesh = dorsal_mesh
	dorsal.position = Vector3(-0.04, 0.22, 0.0)
	dorsal.material_override = _fin_mat
	add_child(dorsal)

	# Hai vây ngực
	for side in [-1.0, 1.0]:
		var pec := MeshInstance3D.new()
		var pec_mesh := PrismMesh.new()
		pec_mesh.size = Vector3(0.18, 0.12, 0.025)
		pec.mesh = pec_mesh
		pec.position = Vector3(0.12, -0.08, side * 0.13)
		pec.rotation_degrees = Vector3(side * 35.0, 0.0, -25.0)
		pec.material_override = _fin_mat
		add_child(pec)

		# Mắt cá
		var eye := MeshInstance3D.new()
		var eye_mesh := SphereMesh.new()
		eye_mesh.radius = 0.038
		eye_mesh.height = 0.076
		eye.mesh = eye_mesh
		eye.position = Vector3(0.30, 0.05, side * 0.095)
		eye.material_override = _eye_mat
		add_child(eye)


func set_fish_tier(tier: int) -> void:
	var scale_val: float = 1.0 + float(clampi(tier - 1, 0, 3)) * 0.18
	scale = Vector3.ONE * scale_val
	if _body_mat != null:
		if tier >= 3:
			_body_mat.set_shader_parameter("body_color", Color(0.68, 0.22, 0.35))
			_body_mat.set_shader_parameter("fin_color", Color(0.98, 0.72, 0.25))
		elif tier == 2:
			_body_mat.set_shader_parameter("body_color", Color(0.22, 0.62, 0.48))
			_body_mat.set_shader_parameter("fin_color", Color(0.45, 0.92, 0.85))
		else:
			_body_mat.set_shader_parameter("body_color", Color(0.16, 0.52, 0.68))
			_body_mat.set_shader_parameter("fin_color", Color(0.92, 0.55, 0.25))


func update_fish(
	pos_norm: float,
	depth_norm: float,
	swim_dir: int,
	tension_ratio: float,
	is_telegraphing: bool,
	delta: float
) -> void:
	# Ánh xạ tọa độ chuẩn hóa [-1..1] / [0..1] quanh điểm thả câu thực tế
	var world_x: float = clampf(pos_norm, -1.0, 1.0) * 2.6
	var world_y: float = lerpf(-0.4, -2.4, clampf(depth_norm, 0.0, 1.0))
	_target_pos = _water_anchor + Vector3(world_x, world_y, 0.0)

	_current_pos = _current_pos.lerp(_target_pos, clampf(delta * 6.5, 0.0, 1.0))
	global_position = _current_pos

	if swim_dir != 0:
		_facing_dir = 1 if swim_dir > 0 else -1
	_target_yaw = 0.0 if _facing_dir > 0 else PI
	rotation.y = lerp_angle(rotation.y, _target_yaw, clampf(delta * 8.0, 0.0, 1.0))

	_swim_speed = clampf(0.8 + tension_ratio * 1.6, 0.6, 2.6)
	if is_telegraphing:
		_swim_speed = 2.8
	_swim_time += delta

	if _body_mat != null:
		_body_mat.set_shader_parameter("swim_time", _swim_time)
		_body_mat.set_shader_parameter("swim_speed", _swim_speed)
		_body_mat.set_shader_parameter("alert_level", 1.0 if is_telegraphing else 0.0)
	if _fin_mat != null:
		_fin_mat.set_shader_parameter("swim_time", _swim_time)
		_fin_mat.set_shader_parameter("swim_speed", _swim_speed)
		_fin_mat.set_shader_parameter("alert_level", 1.0 if is_telegraphing else 0.0)


func get_mouth_world_position() -> Vector3:
	return global_transform * Vector3(0.42, 0.02, 0.0)

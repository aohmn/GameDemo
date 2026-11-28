extends Node3D
## Tạo mô hình cá 3D hoàn toàn bằng Mesh + Shader (không texture) và điều khiển chuyển động.

const FISH_SHADER: Shader = preload("res://presentation/underwater_cam/underwater_fish_shader.gdshader")

var _body_mat: ShaderMaterial
var _fin_mat: ShaderMaterial
var _eye_mat: StandardMaterial3D

var _target_pos: Vector3 = Vector3.ZERO
var _current_pos: Vector3 = Vector3.ZERO
var _swim_time: float = 0.0
var _swim_speed: float = 1.0
var _facing_dir: int = 1
var _target_yaw: float = 0.0


func _ready() -> void:
	_build_materials()
	_build_fish_meshes()


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
	# Ánh xạ tọa độ chuẩn hóa [-1..1] / [0..1] sang không gian 3D dưới nước
	var world_x: float = clampf(pos_norm, -1.0, 1.0) * 2.6
	var world_y: float = lerpf(-0.4, -2.4, clampf(depth_norm, 0.0, 1.0))
	_target_pos = Vector3(world_x, world_y, 0.0)

	_current_pos = _current_pos.lerp(_target_pos, clampf(delta * 6.5, 0.0, 1.0))
	position = _current_pos

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
	return position + Vector3(0.42 * float(_facing_dir), 0.02, 0.0)

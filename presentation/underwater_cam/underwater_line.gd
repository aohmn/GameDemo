extends Node3D
## Vẽ đầu cần câu 3D (cong theo rod_bend), dây câu 3D (cong theo lực căng) và lưỡi câu.

var _line_mesh: ImmediateMesh
var _line_instance: MeshInstance3D
var _line_mat: StandardMaterial3D
var _hook_instance: MeshInstance3D
var _rod_tip: MeshInstance3D


func _ready() -> void:
	_line_mesh = ImmediateMesh.new()
	_line_mat = StandardMaterial3D.new()
	_line_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_line_mat.albedo_color = Color(0.75, 0.92, 1.0)

	_line_instance = MeshInstance3D.new()
	_line_instance.mesh = _line_mesh
	_line_instance.material_override = _line_mat
	add_child(_line_instance)

	_rod_tip = MeshInstance3D.new()
	var rod_mesh := CylinderMesh.new()
	rod_mesh.top_radius = 0.015
	rod_mesh.bottom_radius = 0.028
	rod_mesh.height = 0.65
	rod_mesh.radial_segments = 8
	var rod_mat := StandardMaterial3D.new()
	rod_mat.albedo_color = Color(0.22, 0.36, 0.28)
	rod_mat.roughness = 0.4
	rod_mesh.material = rod_mat
	_rod_tip.mesh = rod_mesh
	_rod_tip.position = Vector3(0.0, 1.05, 0.0)
	add_child(_rod_tip)

	_hook_instance = MeshInstance3D.new()
	var hook_mesh := SphereMesh.new()
	hook_mesh.radius = 0.035
	hook_mesh.height = 0.07
	var hook_mat := StandardMaterial3D.new()
	hook_mat.albedo_color = Color(0.85, 0.88, 0.92)
	hook_mat.metallic = 0.85
	hook_mat.roughness = 0.2
	hook_mesh.material = hook_mat
	_hook_instance.mesh = hook_mesh
	add_child(_hook_instance)


func update_line(mouth_pos: Vector3, tension_ratio: float, rod_bend: float = 0.0) -> void:
	if _line_mesh == null:
		return

	# Đầu cần cong thực tế theo rod_bend
	var bend_clamped: float = clampf(rod_bend, 0.0, 1.0)
	var tip_pos := Vector3(mouth_pos.x * 0.35, 0.92 - bend_clamped * 0.28, 0.0)
	if _rod_tip != null:
		_rod_tip.position = tip_pos + Vector3(0.0, 0.28, 0.0)
		_rod_tip.rotation.z = lerpf(0.0, -0.45, bend_clamped) * (1.0 if mouth_pos.x >= 0.0 else -1.0)

	# Độ võng dây tỉ lệ nghịch với lực căng, có giới hạn không xuyên đáy (-2.6)
	var sag: float = lerpf(0.32, 0.01, clampf(tension_ratio, 0.0, 1.0))
	var ctrl_pos: Vector3 = tip_pos.lerp(mouth_pos, 0.5) + Vector3(0.0, -sag, 0.0)
	ctrl_pos.y = maxf(ctrl_pos.y, -2.55)

	if tension_ratio > 0.82:
		_line_mat.albedo_color = Color(1.0, 0.28, 0.22)
	elif tension_ratio > 0.58:
		_line_mat.albedo_color = Color(1.0, 0.82, 0.25)
	else:
		_line_mat.albedo_color = Color(0.75, 0.92, 1.0)

	_line_mesh.clear_surfaces()
	_line_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for i in range(7):
		var t: float = float(i) / 6.0
		var p: Vector3 = tip_pos.lerp(ctrl_pos, t).lerp(ctrl_pos.lerp(mouth_pos, t), t)
		p.y = maxf(p.y, -2.55)
		_line_mesh.surface_add_vertex(p)
	_line_mesh.surface_end()

	if _hook_instance != null:
		_hook_instance.position = mouth_pos

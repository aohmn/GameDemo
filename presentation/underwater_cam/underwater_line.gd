extends Node3D
## Vẽ dây câu 3D nối từ đầu cần thật (rod_tip_world) đến lưỡi câu tại miệng cá (fish_mouth_world).

var _line_mesh: ImmediateMesh
var _line_instance: MeshInstance3D
var _line_mat: StandardMaterial3D
var _hook_instance: MeshInstance3D


func _ready() -> void:
	_line_mesh = ImmediateMesh.new()
	_line_mat = StandardMaterial3D.new()
	_line_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_line_mat.albedo_color = Color(0.75, 0.92, 1.0)

	_line_instance = MeshInstance3D.new()
	_line_instance.mesh = _line_mesh
	_line_instance.material_override = _line_mat
	add_child(_line_instance)

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


func update_line(
	rod_tip_world: Vector3,
	fish_mouth_world: Vector3,
	tension_ratio: float
) -> void:
	if _line_mesh == null:
		return

	var sag: float = lerpf(0.35, 0.02, clampf(tension_ratio, 0.0, 1.0))
	var ctrl_pos: Vector3 = rod_tip_world.lerp(fish_mouth_world, 0.5) + Vector3(0.0, -sag, 0.0)
	ctrl_pos.y = maxf(ctrl_pos.y, fish_mouth_world.y - 0.5)

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
		var p: Vector3 = rod_tip_world.lerp(ctrl_pos, t).lerp(ctrl_pos.lerp(fish_mouth_world, t), t)
		_line_mesh.surface_add_vertex(p)
	_line_mesh.surface_end()

	if _hook_instance != null:
		_hook_instance.global_position = fish_mouth_world

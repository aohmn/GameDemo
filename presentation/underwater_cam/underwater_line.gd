extends Node3D
## Vẽ dây câu 3D nối từ đầu cần thật (rod_tip_world) đến lưỡi câu tại miệng cá (fish_mouth_world).

var _line_mesh: ImmediateMesh
var _line_instance: MeshInstance3D
var _line_mat: StandardMaterial3D
var _hook_root: Node3D


func _ready() -> void:
	_line_mesh = ImmediateMesh.new()
	_line_mat = StandardMaterial3D.new()
	_line_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_line_mat.albedo_color = Color(0.75, 0.92, 1.0)

	_line_instance = MeshInstance3D.new()
	_line_instance.mesh = _line_mesh
	_line_instance.material_override = _line_mat
	add_child(_line_instance)

	_build_hook_mesh()


func _build_hook_mesh() -> void:
	_hook_root = Node3D.new()
	add_child(_hook_root)

	var hook_mat := StandardMaterial3D.new()
	hook_mat.albedo_color = Color(0.85, 0.88, 0.92)
	hook_mat.metallic = 0.85
	hook_mat.roughness = 0.2
	hook_mat.cull_mode = BaseMaterial3D.CULL_DISABLED

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Thân thẳng -> đoạn uốn chữ J liên tục -> mũi nhọn
	var spine: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, -0.032, 0.0),
		Vector3(0.0, -0.062, 0.0),
	]
	var radii: Array[float] = [0.007, 0.0065, 0.0065]

	var bend_center := Vector3(0.026, -0.062, 0.0)
	var bend_r: float = 0.026
	for i in range(1, 9):
		var ang: float = PI + (float(i) / 8.0) * PI
		spine.append(bend_center + Vector3(cos(ang) * bend_r, sin(ang) * bend_r, 0.0))
		radii.append(0.0065)

	spine.append(Vector3(0.052, -0.044, 0.0))
	radii.append(0.0055)
	spine.append(Vector3(0.050, -0.026, 0.0))
	radii.append(0.0012)
	_add_tube(st, spine, radii, 8)

	# Ngạnh lưỡi câu
	var barb_spine: Array[Vector3] = [
		Vector3(0.051, -0.036, 0.0),
		Vector3(0.040, -0.049, 0.0),
	]
	var barb_radii: Array[float] = [0.004, 0.001]
	_add_tube(st, barb_spine, barb_radii, 6)

	st.generate_normals()
	var hook_mesh: ArrayMesh = st.commit()
	var hook_inst := MeshInstance3D.new()
	hook_inst.mesh = hook_mesh
	hook_inst.material_override = hook_mat
	_hook_root.add_child(hook_inst)


func _add_tube(st: SurfaceTool, spine: Array[Vector3], radii: Array[float], segs: int) -> void:
	if spine.size() < 2 or spine.size() != radii.size():
		return
	var rings: Array = []
	for i in range(spine.size()):
		var tang: Vector3
		if i == 0:
			tang = (spine[1] - spine[0]).normalized()
		elif i == spine.size() - 1:
			tang = (spine[i] - spine[i - 1]).normalized()
		else:
			tang = (spine[i + 1] - spine[i - 1]).normalized()
		var side: Vector3 = tang.cross(Vector3.BACK)
		if side.length_squared() < 0.0001:
			side = tang.cross(Vector3.RIGHT)
		side = side.normalized()
		var binorm: Vector3 = tang.cross(side).normalized()
		var ring: Array[Vector3] = []
		for j in range(segs):
			var a: float = (float(j) / float(segs)) * TAU
			ring.append(spine[i] + (side * cos(a) + binorm * sin(a)) * radii[i])
		rings.append(ring)

	for i in range(rings.size() - 1):
		var r0: Array = rings[i]
		var r1: Array = rings[i + 1]
		for j in range(segs):
			var jn: int = (j + 1) % segs
			st.add_vertex(r0[j])
			st.add_vertex(r1[jn])
			st.add_vertex(r1[j])
			st.add_vertex(r0[j])
			st.add_vertex(r0[jn])
			st.add_vertex(r1[jn])


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

	if _hook_root != null:
		_hook_root.global_position = fish_mouth_world

extends RefCounted

## PeakBuilder — non cao tiên cảnh: núi đá vôi thon cao mờ sương vây quanh đảo, đỉnh chính có thác nước,
## biển mây, đá lơ lửng phát linh quang.

const Util: Script = preload("res://maps/harbor_island/builders/util.gd")

const KARST_COLOR: Color = Color(0.46, 0.48, 0.47)
const CAP_COLOR: Color = Color(0.30, 0.58, 0.30)

# x, z, bán kính đáy, chiều cao, hạt giống
const PEAKS: Array = [
	[-38.0, -20.0, 6.0, 40.0, 1], [-30.0, -40.0, 7.0, 52.0, 2], [4.0, -52.0, 10.0, 64.0, 3],
	[32.0, -38.0, 7.0, 46.0, 4], [40.0, -14.0, 5.5, 34.0, 5], [-45.0, -2.0, 5.5, 32.0, 6],
	[20.0, -56.0, 6.5, 42.0, 7], [-14.0, -60.0, 7.0, 50.0, 8], [46.0, 8.0, 5.0, 28.0, 9],
	[-46.0, 16.0, 5.0, 26.0, 10],
]


static func build(root_node: Node3D) -> void:
	for p in PEAKS:
		_make_peak(root_node, p)
	_make_waterfall(root_node)
	_make_mist(root_node)
	_make_floating_rocks(root_node)


static func _make_peak(root_node: Node3D, p: Array) -> void:
	var seed_val: int = int(p[4])
	var mesh: ArrayMesh = karst_mesh(float(p[2]), float(p[3]), seed_val)
	Util.add(root_node, "KarstPeak_%d" % seed_val, mesh, Vector3(float(p[0]), -2.0, float(p[1])), "karst", KARST_COLOR)
	var cap: MeshInstance3D = Util.sphere(root_node, "KarstCap_%d" % seed_val, Vector3(float(p[0]), -2.0 + float(p[3]) - 0.4, float(p[1])), float(p[2]) * 0.34, "foliage", CAP_COLOR, 0.5)
	cap.scale = Vector3(1.0, 0.7, 1.0)


## Thân núi đá vôi dạng lathe: eo thắt, phình, mũi thon; bán kính nhiễu theo hạt giống để mỗi ngọn một dáng.
static func karst_mesh(radius: float, height: float, seed_val: int, sides: int = 16, rings: int = 14) -> ArrayMesh:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val * 7919
	var phase: float = rng.randf() * 6.28
	var noise: Array = []
	for i in range(sides):
		noise.append(rng.randf_range(0.82, 1.18))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(0)
	var grid: Array = []
	for i in range(sides + 1):
		var col: Array = []
		var a: float = float(i) / sides * TAU
		var nz: float = float(noise[i % sides])
		for j in range(rings + 1):
			var t: float = float(j) / rings
			var prof: float = 0.42 + 0.58 * pow(1.0 - t, 0.75)
			prof *= 1.0 + 0.16 * sin(t * 9.0 + phase) * (1.0 - t * 0.5)
			var tip: float = sqrt(maxf(1.0 - pow(t, 6.0), 0.0))
			var r: float = radius * prof * tip * nz
			col.append(Vector3(cos(a) * r, t * height, sin(a) * r))
		grid.append(col)
	for i in range(sides):
		for j in range(rings):
			var a: Vector3 = grid[i][j]
			var b: Vector3 = grid[i + 1][j]
			var c: Vector3 = grid[i + 1][j + 1]
			var d: Vector3 = grid[i][j + 1]
			for v in [a, c, d, a, b, c]:
				st.add_vertex(v)
	st.generate_normals()
	return st.commit()


## Thác nước đổ từ đỉnh chính phía bắc xuống biển mây.
static func _make_waterfall(root_node: Node3D) -> void:
	var quad := QuadMesh.new()
	quad.size = Vector2(5.0, 38.0)
	var node: MeshInstance3D = Util.add(root_node, "Waterfall", quad, Vector3(4.0, 16.0, -37.5), "waterfall", Color(0.9, 0.98, 1.0))
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


## Biển mây: các tấm sương trôi ở nhiều độ cao quanh đảo và chân núi.
static func _make_mist(root_node: Node3D) -> void:
	# [x, z, rộng, cao độ, mật độ]: tầng thấp quanh đảo (trên mặt biển) và tầng cao ở sau đảo, không che tầm nhìn từ phía nam
	var layers: Array = [
		[-30.0, 6.0, 46.0, -0.5, 0.32], [30.0, 6.0, 46.0, -0.5, 0.32], [0.0, 22.0, 70.0, -0.6, 0.28],
		[-26.0, -22.0, 60.0, 4.0, 0.4], [28.0, -22.0, 60.0, 5.0, 0.4], [0.0, -40.0, 90.0, 9.0, 0.5],
		[0.0, -52.0, 90.0, 22.0, 0.45],
	]
	var i: int = 0
	for l in layers:
		i += 1
		var plane := PlaneMesh.new()
		plane.size = Vector2(float(l[2]), float(l[2]) * 0.6)
		var node: MeshInstance3D = Util.add(root_node, "MistLayer_%d" % i, plane, Vector3(float(l[0]), float(l[3]), float(l[1])), "mist", Color(0.94, 0.98, 0.98))
		(node.material_override as ShaderMaterial).set_shader_parameter("density", float(l[4]))
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


## Đá lơ lửng phát linh quang quanh Tiên Các (tụ linh khí).
static func _make_floating_rocks(root_node: Node3D) -> void:
	var spots: Array = [[-12.0, 9.0, -22.0, 1.3], [13.0, 11.5, -24.0, 1.7], [-6.0, 14.0, -32.0, 1.1], [9.0, 8.0, -18.0, 0.9]]
	var i: int = 0
	for s in spots:
		i += 1
		var pos := Vector3(float(s[0]), float(s[1]), float(s[2]))
		var rock: ArrayMesh = karst_mesh(float(s[3]), float(s[3]) * 1.8, 20 + i, 10, 6)
		var node: MeshInstance3D = Util.add(root_node, "FloatingRock_%d" % i, rock, pos, "karst", KARST_COLOR)
		node.rotation_degrees.x = 180.0
		Util.sphere(root_node, "SpiritOrb_%d" % i, pos + Vector3(0.0, 0.5, 0.0), 0.28, "glow", Color(0.55, 0.95, 1.0))

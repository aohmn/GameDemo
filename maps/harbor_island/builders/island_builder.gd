extends RefCounted

## IslandBuilder — nền đảo tiên theo bậc thang: bến cảng/quảng trường (y=0), tầng Thương Hội & ao sen (y=1),
## sân Tiên Các (y=2.2). Mỗi bậc là một khối đa giác có mặt cỏ và vách đá; có bậc thang, collider và tường chắn vô hình.

const Util: Script = preload("res://maps/harbor_island/builders/util.gd")
const TERRAIN_SHADER: Shader = preload("res://maps/harbor_island/terrain.gdshader")

const ROCK_COLOR: Color = Color(0.56, 0.57, 0.54)
const STEP_COLOR: Color = Color(0.80, 0.80, 0.76)

# Mỗi bậc: tên, cao độ mặt, cao độ đáy, đa giác (x, z) theo vòng khép kín.
const TIER_DATA: Array[Dictionary] = [
	{"name": "TierHarbor", "top": 0.0, "bottom": -3.0, "pts": [
		Vector2(-19, -4), Vector2(-20.5, 3), Vector2(-17.5, 9), Vector2(-11, 12), Vector2(-5.5, 12.6),
		Vector2(2.5, 12.6), Vector2(9, 12), Vector2(15.5, 9.5), Vector2(20, 3), Vector2(18.5, -4),
		Vector2(12, -6.5), Vector2(-12, -6.5)]},
	{"name": "TierPond", "top": 1.0, "bottom": -3.0, "pts": [
		Vector2(-15, -6.5), Vector2(-16.5, -11), Vector2(-13.5, -15.5), Vector2(-8, -17.5), Vector2(8, -17.5),
		Vector2(13.5, -15.5), Vector2(16.5, -11), Vector2(15, -6.5)]},
	{"name": "TierSect", "top": 2.2, "bottom": -3.0, "pts": [
		Vector2(-10, -17.5), Vector2(-11.5, -21), Vector2(-8, -25.5), Vector2(0, -27), Vector2(8, -25.5),
		Vector2(11.5, -21), Vector2(10, -17.5)]},
]

const WALL_HEIGHT: float = 3.0


static func build(root_node: Node3D) -> void:
	var top_mat := ShaderMaterial.new()
	top_mat.shader = TERRAIN_SHADER
	var side_mat: Material = Util.ProcMaterial.of_kind("karst", ROCK_COLOR)
	for t in TIER_DATA:
		var pts := PackedVector2Array(t["pts"])
		var mesh: ArrayMesh = _slab(pts, float(t["top"]), float(t["bottom"]))
		var node := MeshInstance3D.new()
		node.name = t["name"]
		node.mesh = mesh
		node.set_surface_override_material(0, top_mat)
		node.set_surface_override_material(1, side_mat)
		root_node.add_child(node)
		Util.collide_mesh(root_node, str(t["name"]) + "Col", mesh, Vector3.ZERO)
	add_stairs(root_node, "StairsHarborToPond", 0.0, -3.5, -6.5, 0.0, 1.0, 4.0, 6)
	add_stairs(root_node, "StairsPondToSect", 0.0, -15.0, -17.5, 1.0, 2.2, 6.0, 8)
	_add_walls(root_node)


static func _slab(pts: PackedVector2Array, y_top: float, y_bot: float) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var tri: PackedInt32Array = Geometry2D.triangulate_polygon(pts)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1)
	for k in range(0, tri.size(), 3):
		var tri_pts: Array[Vector3] = []
		for q in range(3):
			var p: Vector2 = pts[tri[k + q]]
			tri_pts.append(Vector3(p.x, y_top, p.y))
		if (tri_pts[1] - tri_pts[0]).cross(tri_pts[2] - tri_pts[0]).y > 0.0:
			tri_pts = [tri_pts[0], tri_pts[2], tri_pts[1]]
		for v in tri_pts:
			st.add_vertex(v)
	st.generate_normals()
	st.commit(mesh)

	var centroid := Vector2.ZERO
	for p in pts:
		centroid += p
	centroid /= float(pts.size())
	var sides := SurfaceTool.new()
	sides.begin(Mesh.PRIMITIVE_TRIANGLES)
	sides.set_smooth_group(-1)
	for i in range(pts.size()):
		var p: Vector2 = pts[i]
		var q: Vector2 = pts[(i + 1) % pts.size()]
		var quad: Array[Vector3] = [Vector3(p.x, y_top, p.y), Vector3(q.x, y_top, q.y), Vector3(q.x, y_bot, q.y), Vector3(p.x, y_bot, p.y)]
		var out_dir := Vector3((p.x + q.x) * 0.5 - centroid.x, 0.0, (p.y + q.y) * 0.5 - centroid.y)
		var n: Vector3 = (quad[1] - quad[0]).cross(quad[2] - quad[0])
		var order: Array[int] = [0, 1, 2, 0, 2, 3]
		if n.dot(out_dir) > 0.0:
			order = [0, 2, 1, 0, 3, 2]
		for idx in order:
			sides.add_vertex(quad[idx])
	sides.generate_normals()
	sides.commit(mesh)
	return mesh


## Bậc thang: hình khối từng bậc (mắt nhìn) + một mặt dốc vô hình làm collider để đi lên mượt.
static func add_stairs(root_node: Node3D, node_name: String, x: float, z_from: float, z_to: float, y_from: float, y_to: float, width: float, steps: int) -> void:
	var dz: float = z_to - z_from
	var dy: float = y_to - y_from
	for i in range(steps):
		var t0: float = float(i) / steps
		var t1: float = float(i + 1) / steps
		var z_mid: float = z_from + dz * (t0 + t1) * 0.5
		var y_top: float = y_from + dy * t1
		var depth: float = absf(dz) / steps
		var h: float = y_top - (y_from - 0.4)
		Util.box(root_node, "%s_%d" % [node_name, i], Vector3(x, y_top - h * 0.5, z_mid), Vector3(width, h, depth + 0.02), "paving", STEP_COLOR)
	var length: float = sqrt(dz * dz + dy * dy)
	var body := StaticBody3D.new()
	body.name = node_name + "Ramp"
	body.position = Vector3(x, (y_from + y_to) * 0.5 - 0.1, (z_from + z_to) * 0.5)
	body.rotation.x = atan2(dy, absf(dz)) * (1.0 if dz < 0.0 else -1.0)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(width, 0.2, length)
	col.shape = shape
	body.add_child(col)
	root_node.add_child(body)


## Tường chắn vô hình dọc mép ngoài mỗi bậc (bỏ qua mép giáp bậc khác và lối cầu tàu).
static func _add_walls(root_node: Node3D) -> void:
	var idx: int = 0
	for t in TIER_DATA:
		var pts: Array = t["pts"]
		for i in range(pts.size()):
			var p: Vector2 = pts[i]
			var q: Vector2 = pts[(i + 1) % pts.size()]
			var mid: Vector2 = (p + q) * 0.5
			if _edge_is_interior(mid, p, q, str(t["name"])) or _is_pier_gap(mid):
				continue
			var len: float = p.distance_to(q)
			var angle: float = atan2(q.x - p.x, q.y - p.y)
			idx += 1
			Util.collide_box(root_node, "BoundIsland_%d" % idx, Vector3(mid.x, float(t["top"]) + WALL_HEIGHT * 0.5, mid.y), Vector3(0.4, WALL_HEIGHT, len), rad_to_deg(angle))


static func _edge_is_interior(mid: Vector2, p: Vector2, q: Vector2, own: String) -> bool:
	var dir: Vector2 = (q - p).normalized()
	var normal := Vector2(-dir.y, dir.x)
	for t in TIER_DATA:
		if str(t["name"]) == own:
			continue
		var poly := PackedVector2Array(t["pts"])
		if Geometry2D.is_point_in_polygon(mid + normal * 0.6, poly) or Geometry2D.is_point_in_polygon(mid - normal * 0.6, poly):
			return true
	return false


static func _is_pier_gap(mid: Vector2) -> bool:
	return mid.y > 11.0 and mid.x > -6.5 and mid.x < 3.0

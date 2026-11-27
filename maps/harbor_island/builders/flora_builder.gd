extends RefCounted

## FloraBuilder — tùng cổ thụ, đào hoa, rừng trúc (MultiMesh), đá Thái Hồ, thùng hàng ở bến.

const Util: Script = preload("res://maps/harbor_island/builders/util.gd")
const Peak: Script = preload("res://maps/harbor_island/builders/peak_builder.gd")

const PINE_GREEN: Color = Color(0.16, 0.42, 0.26)
const PEACH_PINK: Color = Color(0.97, 0.66, 0.74)
const BARK: Color = Color(0.40, 0.28, 0.20)
const BAMBOO: Color = Color(0.46, 0.68, 0.30)


static func build(root_node: Node3D) -> void:
	var pines: Array = [Vector3(-16.0, 0.0, 4.0), Vector3(-17.5, 0.0, -1.5), Vector3(16.5, 0.0, 9.0), Vector3(-9.0, 0.0, 9.5),
		Vector3(-14.0, 1.0, -13.0), Vector3(14.0, 1.0, -13.5), Vector3(-6.5, 2.2, -19.0), Vector3(6.5, 2.2, -24.5)]
	var i: int = 0
	for p in pines:
		i += 1
		_make_pine(root_node, "Pine_%d" % i, p, 1.0 + float(i % 3) * 0.18)
	var peaches: Array = [Vector3(-5.2, 0.0, -1.8), Vector3(5.4, 0.0, -2.0), Vector3(-6.2, 1.0, -7.8), Vector3(6.4, 1.0, -7.8),
		Vector3(-6.0, 1.0, -15.0), Vector3(6.0, 1.0, -15.2), Vector3(11.5, 0.0, 6.0), Vector3(-12.5, 0.0, 6.5)]
	i = 0
	for p in peaches:
		i += 1
		_make_peach(root_node, "Peach_%d" % i, p, 0.9 + float(i % 3) * 0.12)
	_make_bamboo_grove(root_node, "BambooWest", Vector3(-14.5, 1.0, -9.0), 38, 11)
	_make_bamboo_grove(root_node, "BambooEast", Vector3(14.2, 1.0, -8.0), 30, 12)
	_make_bamboo_grove(root_node, "BambooGate", Vector3(-17.0, 0.0, 6.5), 26, 13)
	_make_rocks(root_node)
	_make_crates(root_node)


static func _make_pine(root_node: Node3D, node_name: String, pos: Vector3, s: float) -> void:
	Util.cylinder(root_node, node_name + "Trunk", pos + Vector3(0.0, 1.4 * s, 0.0), 0.16 * s, 0.26 * s, 2.8 * s, "wood", BARK, 8)
	Util.collide_box(root_node, node_name + "Col", pos + Vector3(0.0, 1.0, 0.0), Vector3(0.5, 2.0, 0.5))
	for k in range(4):
		var w: float = (1.9 - float(k) * 0.38) * s
		var crown: MeshInstance3D = Util.sphere(root_node, "%sTreeCrown_%d" % [node_name, k], pos + Vector3(0.0, (2.2 + float(k) * 0.72) * s, 0.0), w, "foliage", PINE_GREEN, 0.38)
		crown.rotation_degrees.y = float(k) * 37.0


static func _make_peach(root_node: Node3D, node_name: String, pos: Vector3, s: float) -> void:
	Util.cylinder(root_node, node_name + "Trunk", pos + Vector3(0.0, 0.9 * s, 0.0), 0.12 * s, 0.2 * s, 1.8 * s, "wood", BARK, 8)
	Util.collide_box(root_node, node_name + "Col", pos + Vector3(0.0, 0.8, 0.0), Vector3(0.4, 1.6, 0.4))
	var offsets: Array = [Vector3(0.0, 2.3, 0.0), Vector3(0.8, 1.9, 0.3), Vector3(-0.7, 2.0, -0.3), Vector3(0.1, 2.0, 0.8)]
	for k in range(offsets.size()):
		var o: Vector3 = offsets[k]
		Util.sphere(root_node, "%sTreeCrown_%d" % [node_name, k], pos + o * s, (1.0 - float(k) * 0.08) * s, "foliage", PEACH_PINK, 0.82)


## Rừng trúc: một MultiMesh cho thân, một cho cụm lá, vị trí/độ cao ngẫu nhiên theo hạt giống.
static func _make_bamboo_grove(root_node: Node3D, node_name: String, center: Vector3, count: int, seed_val: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val
	var stalk := CylinderMesh.new()
	stalk.top_radius = 0.04
	stalk.bottom_radius = 0.06
	stalk.height = 1.0
	stalk.radial_segments = 5
	stalk.rings = 1
	var leaf := SphereMesh.new()
	leaf.radius = 0.5
	leaf.height = 0.5
	leaf.radial_segments = 6
	leaf.rings = 3
	var stalks := MultiMesh.new()
	stalks.transform_format = MultiMesh.TRANSFORM_3D
	stalks.mesh = stalk
	stalks.instance_count = count
	var leaves := MultiMesh.new()
	leaves.transform_format = MultiMesh.TRANSFORM_3D
	leaves.mesh = leaf
	leaves.instance_count = count
	for i in range(count):
		var off := Vector3(rng.randf_range(-2.4, 2.4), 0.0, rng.randf_range(-2.4, 2.4))
		var h: float = rng.randf_range(4.2, 6.6)
		stalks.set_instance_transform(i, Transform3D(Basis().scaled(Vector3(1.0, h, 1.0)), center + off + Vector3(0.0, h * 0.5, 0.0)))
		leaves.set_instance_transform(i, Transform3D(Basis().scaled(Vector3(rng.randf_range(0.9, 1.5), rng.randf_range(0.9, 1.3), rng.randf_range(0.9, 1.5))), center + off + Vector3(0.0, h - 0.2, 0.0)))
	_multimesh_node(root_node, node_name + "Stalks", stalks, "wood", BAMBOO)
	_multimesh_node(root_node, node_name + "Leaves", leaves, "foliage", Color(0.34, 0.60, 0.28))
	Util.collide_box(root_node, node_name + "Col", center + Vector3(0.0, 1.0, 0.0), Vector3(4.6, 2.0, 4.6))


static func _multimesh_node(root_node: Node3D, node_name: String, mm: MultiMesh, kind: String, color: Color) -> void:
	var node := MultiMeshInstance3D.new()
	node.name = node_name
	node.multimesh = mm
	node.material_override = Util.ProcMaterial.of_kind(kind, color)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root_node.add_child(node)


static func _make_rocks(root_node: Node3D) -> void:
	var spots: Array = [[Vector3(-3.6, 1.0, -14.2), 0.7, 40], [Vector3(3.8, 1.0, -8.2), 0.6, 41], [Vector3(-12.0, 0.0, 1.0), 0.9, 42],
		[Vector3(12.8, 0.0, 8.5), 0.8, 43], [Vector3(-4.5, 2.2, -26.0), 0.8, 44], [Vector3(5.0, 2.2, -26.0), 0.7, 45]]
	var i: int = 0
	for s in spots:
		i += 1
		var r: float = float(s[1])
		var mesh: ArrayMesh = Peak.karst_mesh(r, r * 2.4, int(s[2]), 10, 7)
		Util.add(root_node, "TaihuRock_%d" % i, mesh, s[0], "karst", Color(0.62, 0.62, 0.58))
		Util.collide_box(root_node, "TaihuRockCol_%d" % i, s[0] + Vector3(0.0, r, 0.0), Vector3(r * 1.5, r * 2.0, r * 1.5))


static func _make_crates(root_node: Node3D) -> void:
	var crates: Array = [[Vector3(3.6, 0.3, 7.4), 0.6], [Vector3(4.3, 0.3, 7.9), 0.6], [Vector3(3.9, 0.9, 7.6), 0.5]]
	var i: int = 0
	for c in crates:
		i += 1
		var s: float = float(c[1])
		Util.box(root_node, "Crate_%d" % i, c[0], Vector3(s, s, s), "wood", Color(0.58, 0.42, 0.26))
		Util.collide_box(root_node, "CrateCol_%d" % i, c[0], Vector3(s, s, s))

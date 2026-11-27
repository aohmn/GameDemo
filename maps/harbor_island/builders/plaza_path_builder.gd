extends RefCounted

## PlazaPathBuilder — quảng trường tròn + Trận Pháp Truyền Tống (bậc bến cảng), bài phường đầu cầu tàu,
## lối đá lát, và ao sen với cầu đá vòm (bậc ao sen).

const Util: Script = preload("res://maps/harbor_island/builders/util.gd")
const Parts: Script = preload("res://maps/harbor_island/builders/parts.gd")
const Kit: Script = preload("res://maps/harbor_island/builders/arch_kit.gd")

const PLAZA_CENTER: Vector3 = Vector3(0.0, 0.0, 1.5)
const POND_CENTER: Vector3 = Vector3(0.0, 1.0, -11.2)
const BRIDGE_LENGTH: float = 7.0
const BRIDGE_RISE: float = 0.8


static func build(root_node: Node3D) -> void:
	_make_plaza(root_node)
	_make_teleport(root_node)
	_make_paths(root_node)
	Parts.paifang(root_node, "PaifangPier", Vector3(-2.0, 0.0, 8.7), 5.0, 4.3)
	_make_pond(root_node)
	_make_bridge(root_node)


static func _make_plaza(root_node: Node3D) -> void:
	Util.cylinder(root_node, "CentralSquarePlaza", PLAZA_CENTER + Vector3(0.0, 0.04, 0.0), 5.2, 5.3, 0.08, "paving", Color(0.72, 0.71, 0.66), 24)
	Util.cylinder(root_node, "PlazaRim", PLAZA_CENTER + Vector3(0.0, 0.07, 0.0), 5.5, 5.5, 0.06, "marble", Parts.MARBLE, 24)
	for k in range(4):
		var a: float = float(k) / 4.0 * TAU + PI * 0.25
		Parts.stone_lantern(root_node, "LanternPlaza_%d" % k, PLAZA_CENTER + Vector3(cos(a) * 4.6, 0.0, sin(a) * 4.6))


## Trận Pháp Truyền Tống: vòng bạch ngọc, tám ký hiệu phát sáng, lõi linh quang và bốn trụ đá.
static func _make_teleport(root_node: Node3D) -> void:
	var c: Vector3 = PLAZA_CENTER
	Util.cylinder(root_node, "TeleportInnerRing", c + Vector3(0.0, 0.12, 0.0), 2.4, 2.5, 0.1, "marble", Parts.MARBLE, 24)
	Util.cylinder(root_node, "TeleportCore", c + Vector3(0.0, 0.18, 0.0), 1.5, 1.5, 0.05, "glow", Color(0.45, 0.9, 1.0), 24)
	for k in range(8):
		var a: float = float(k) / 8.0 * TAU
		var rune: MeshInstance3D = Util.box(root_node, "TeleportRune_%d" % k, c + Vector3(cos(a) * 2.0, 0.2, sin(a) * 2.0), Vector3(0.34, 0.05, 0.12), "glow", Parts.GOLD)
		rune.rotation.y = -a
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			var p: Vector3 = c + Vector3(sx * 3.3, 0.0, sz * 3.3)
			Util.cylinder(root_node, "TeleportPillar_%d_%d" % [int(sx), int(sz)], p + Vector3(0.0, 0.8, 0.0), 0.28, 0.34, 1.6, "rough", Color(0.55, 0.56, 0.54), 8)
			Util.sphere(root_node, "TeleportPillarOrb_%d_%d" % [int(sx), int(sz)], p + Vector3(0.0, 1.8, 0.0), 0.22, "glow", Color(0.45, 0.9, 1.0))
			Util.collide_box(root_node, "TeleportPillarCol_%d_%d" % [int(sx), int(sz)], p + Vector3(0.0, 0.8, 0.0), Vector3(0.6, 1.6, 0.6))


static func _make_paths(root_node: Node3D) -> void:
	Util.box(root_node, "PathPierToSquare", Vector3(-2.0, 0.03, 6.8), Vector3(3.0, 0.06, 5.4), "paving", Color(0.68, 0.67, 0.62))
	Util.box(root_node, "PathSquareToStairs", Vector3(0.0, 0.03, -3.9), Vector3(3.4, 0.06, 3.0), "paving", Color(0.68, 0.67, 0.62))
	Util.box(root_node, "PathToObservation", Vector3(8.0, 0.03, 8.0), Vector3(13.0, 0.06, 1.8), "paving", Color(0.68, 0.67, 0.62))
	Util.box(root_node, "PathPondToMerchant", Vector3(5.0, POND_CENTER.y + 0.03, -9.2), Vector3(5.6, 0.06, 1.8), "paving", Color(0.68, 0.67, 0.62))
	Util.box(root_node, "PathPondToFurnace", Vector3(-5.0, POND_CENTER.y + 0.03, -9.2), Vector3(5.6, 0.06, 1.8), "paving", Color(0.68, 0.67, 0.62))
	for i in range(3):
		Parts.stone_lantern(root_node, "LanternPathW_%d" % i, Vector3(-3.9, 0.0, 6.0 - float(i) * 0.0 + float(i) * 1.1 - 1.1))
		Parts.stone_lantern(root_node, "LanternPathE_%d" % i, Vector3(0.0 + 0.0, 0.0, 0.0) + Vector3(0.0, 0.0, 0.0) + Vector3(0.1, 0.0, 6.0 + float(i) * 1.1 - 1.1))


static func _make_pond(root_node: Node3D) -> void:
	var c: Vector3 = POND_CENTER
	Util.cylinder(root_node, "PondBorder", c + Vector3(0.0, 0.1, 0.0), 3.5, 3.6, 0.2, "rough", Color(0.66, 0.66, 0.62), 24)
	Util.cylinder(root_node, "PondWater", c + Vector3(0.0, 0.21, 0.0), 3.0, 3.0, 0.04, "pond", Color(0.20, 0.64, 0.62), 24)
	for k in range(8):
		if k == 2 or k == 6:
			continue # hai đầu cầu (trục Z) để thông
		var a: float = float(k) / 8.0 * TAU
		Util.collide_box(root_node, "PondRimCol_%d" % k, c + Vector3(cos(a) * 3.75, 0.5, sin(a) * 3.75), Vector3(1.6, 1.0, 0.5), -rad_to_deg(a) + 90.0)
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	for i in range(14):
		var a: float = rng.randf() * TAU
		var r: float = sqrt(rng.randf()) * 2.6
		var pad: MeshInstance3D = Util.cylinder(root_node, "LotusPad_%d" % i, c + Vector3(cos(a) * r, 0.25, sin(a) * r), 0.36, 0.36, 0.02, "foliage", Color(0.22, 0.58, 0.30), 10)
		pad.rotation_degrees.y = rng.randf() * 360.0
		if i % 3 == 0:
			Util.sphere(root_node, "LotusBloom_%d" % i, c + Vector3(cos(a) * r, 0.34, sin(a) * r), 0.16, "foliage", Color(0.98, 0.70, 0.78), 0.8)
	Util.sphere(root_node, "PondLantern", c + Vector3(0.0, 0.6, 2.0), 0.2, "glow", Color(1.0, 0.8, 0.5))


## Cầu đá vòm bắc qua ao theo trục Bắc-Nam, thành cầu bạch ngọc.
static func _make_bridge(root_node: Node3D) -> void:
	var mesh: ArrayMesh = Kit.arch_bridge_mesh(BRIDGE_LENGTH, 2.4, BRIDGE_RISE, 0.4)
	var pos: Vector3 = POND_CENTER + Vector3(0.0, 0.0, 0.0)
	Util.add(root_node, "ArchBridge", mesh, pos, "marble", Color(0.86, 0.88, 0.84), 90.0)
	Util.collide_mesh(root_node, "ArchBridgeCol", mesh, pos, 90.0)
	for i in range(9):
		var x: float = (float(i) / 8.0 - 0.5) * (BRIDGE_LENGTH - 0.4)
		var y: float = Kit.arch_height_at(x, BRIDGE_LENGTH, BRIDGE_RISE)
		for side in [-1.0, 1.0]:
			Util.box(root_node, "BridgePost_%d_%d" % [i, int(side)], pos + Vector3(side * 1.1, y + 0.35, x), Vector3(0.16, 0.7, 0.16), "marble", Parts.MARBLE)
	for side in [-1.0, 1.0]:
		Util.collide_box(root_node, "BridgeSideCol_%d" % int(side), pos + Vector3(side * 1.3, 1.6, 0.0), Vector3(0.2, 2.0, BRIDGE_LENGTH))

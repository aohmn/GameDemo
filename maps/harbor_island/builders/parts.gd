extends RefCounted

## Bộ chi tiết kiến trúc dùng lại: cột sơn son, đèn đá, đèn lồng, lan can, mái, đình.

const Util: Script = preload("res://maps/harbor_island/builders/util.gd")
const Kit: Script = preload("res://maps/harbor_island/builders/arch_kit.gd")

const LACQUER: Color = Color(0.64, 0.14, 0.10)
const MARBLE: Color = Color(0.84, 0.88, 0.86)
const JADE_ROOF: Color = Color(0.20, 0.50, 0.44)
const GOLD: Color = Color(0.88, 0.72, 0.28)
const INK_ROOF: Color = Color(0.24, 0.28, 0.34)
const STONE: Color = Color(0.66, 0.65, 0.61)
const TIMBER: Color = Color(0.56, 0.38, 0.24)


static func pillar(root: Node, node_name: String, pos: Vector3, height: float, radius: float = 0.16) -> void:
	Util.cylinder(root, node_name, pos + Vector3(0.0, height * 0.5, 0.0), radius, radius * 1.08, height, "lacquer", LACQUER, 10)
	Util.cylinder(root, node_name + "Base", pos + Vector3(0.0, 0.08, 0.0), radius * 1.5, radius * 1.6, 0.16, "marble", MARBLE, 10)


static func roof(root: Node, node_name: String, pos: Vector3, hw: float, hd: float, height: float, color: Color, upturn: float = 0.55) -> void:
	Util.add(root, node_name + "Roof", Kit.roof_mesh(hw, hd, height, upturn), pos, "roof", color)


static func round_roof(root: Node, node_name: String, pos: Vector3, radius: float, height: float, color: Color) -> void:
	Util.add(root, node_name + "Roof", Kit.round_roof_mesh(radius, height, 0.3, 2.1, 16, 9), pos, "roof", color, 0.0, true)


## Đình mở bốn góc: 4 cột sơn son, mái cong, bệ đá.
static func pavilion(root: Node, node_name: String, pos: Vector3, half: float, height: float, roof_color: Color) -> void:
	Util.box(root, node_name + "Base", pos + Vector3(0.0, 0.12, 0.0), Vector3(half * 2.0 + 0.8, 0.24, half * 2.0 + 0.8), "paving", STONE)
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			pillar(root, "%sPillar_%d_%d" % [node_name, int(sx), int(sz)], pos + Vector3(sx * half, 0.24, sz * half), height)
	Util.box(root, node_name + "Beam", pos + Vector3(0.0, 0.24 + height, 0.0), Vector3(half * 2.0 + 0.5, 0.22, half * 2.0 + 0.5), "lacquer", LACQUER)
	roof(root, node_name, pos + Vector3(0.0, 0.24 + height + 0.1, 0.0), half + 1.1, half + 1.1, height * 0.55, roof_color)
	Util.sphere(root, node_name + "Finial", pos + Vector3(0.0, 0.24 + height + 0.1 + height * 0.55 + 0.1, 0.0), 0.16, "glow", GOLD)


static func stone_lantern(root: Node, node_name: String, pos: Vector3) -> void:
	Util.box(root, node_name + "Foot", pos + Vector3(0.0, 0.15, 0.0), Vector3(0.5, 0.3, 0.5), "rough", STONE)
	Util.cylinder(root, node_name + "Shaft", pos + Vector3(0.0, 0.7, 0.0), 0.1, 0.12, 0.8, "rough", STONE, 8)
	Util.box(root, node_name + "Lamp", pos + Vector3(0.0, 1.25, 0.0), Vector3(0.34, 0.3, 0.34), "glow", Color(1.0, 0.85, 0.5))
	var cap: MeshInstance3D = Util.box(root, node_name + "Cap", pos + Vector3(0.0, 1.5, 0.0), Vector3(0.62, 0.12, 0.62), "rough", STONE)
	cap.rotation_degrees.y = 45.0
	Util.sphere(root, node_name + "Top", pos + Vector3(0.0, 1.62, 0.0), 0.1, "rough", STONE)


static func hanging_lantern(root: Node, node_name: String, pos: Vector3, color: Color = Color(1.0, 0.35, 0.2)) -> void:
	Util.cylinder(root, node_name + "Cord", pos + Vector3(0.0, 0.3, 0.0), 0.015, 0.015, 0.6, "plain", Color(0.2, 0.1, 0.05), 4)
	Util.sphere(root, node_name, pos, 0.22, "glow", color, 1.25)


## Lan can bạch ngọc: hàng trụ nhỏ và thanh ngang dọc theo đoạn thẳng từ a đến b.
static func railing(root: Node, node_name: String, a: Vector3, b: Vector3, posts: int = 5) -> void:
	var dir: Vector3 = b - a
	for i in range(posts):
		var t: float = float(i) / float(maxi(posts - 1, 1))
		Util.box(root, "%sPost_%d" % [node_name, i], a + dir * t + Vector3(0.0, 0.3, 0.0), Vector3(0.14, 0.6, 0.14), "marble", MARBLE)
	var rail: MeshInstance3D = Util.box(root, node_name + "Rail", (a + b) * 0.5 + Vector3(0.0, 0.58, 0.0), Vector3(0.1, 0.08, dir.length()), "marble", MARBLE)
	rail.rotation.y = atan2(dir.x, dir.z)


## Bài phường (cổng): hai trụ chính sơn son, xà ngang, mái cong giữa và hai mái phụ.
static func paifang(root: Node, node_name: String, pos: Vector3, span: float, height: float) -> void:
	var hs: float = span * 0.5
	for sx in [-1.0, 1.0]:
		pillar(root, "%sPillar_%d" % [node_name, int(sx)], pos + Vector3(sx * hs, 0.0, 0.0), height, 0.22)
		Util.collide_box(root, "%sCol_%d" % [node_name, int(sx)], pos + Vector3(sx * hs, height * 0.5, 0.0), Vector3(0.5, height, 0.5))
		pillar(root, "%sSide_%d" % [node_name, int(sx)], pos + Vector3(sx * (hs + 1.4), 0.0, 0.0), height * 0.78, 0.16)
	Util.box(root, node_name + "BeamMain", pos + Vector3(0.0, height - 0.3, 0.0), Vector3(span + 0.6, 0.38, 0.34), "lacquer", LACQUER)
	Util.box(root, node_name + "BeamLow", pos + Vector3(0.0, height - 1.0, 0.0), Vector3(span + 0.2, 0.22, 0.26), "lacquer", LACQUER)
	Util.box(root, node_name + "Plaque", pos + Vector3(0.0, height - 0.65, 0.0), Vector3(span * 0.34, 0.5, 0.1), "plain", Color(0.12, 0.1, 0.1))
	Util.box(root, node_name + "PlaqueTrim", pos + Vector3(0.0, height - 0.65, 0.06), Vector3(span * 0.34 + 0.1, 0.06, 0.06), "glow", GOLD)
	roof(root, node_name + "Mid", pos + Vector3(0.0, height - 0.05, 0.0), hs + 0.9, 0.9, 0.85, JADE_ROOF, 0.6)
	for sx in [-1.0, 1.0]:
		var sy: float = height * 0.78
		Util.box(root, "%sBeamSide_%d" % [node_name, int(sx)], pos + Vector3(sx * (hs + 0.7), sy - 0.2, 0.0), Vector3(1.6, 0.26, 0.28), "lacquer", LACQUER)
		roof(root, "%sSide_%d" % [node_name, int(sx)], pos + Vector3(sx * (hs + 0.7), sy + 0.05, 0.0), 1.2, 0.75, 0.6, JADE_ROOF, 0.45)

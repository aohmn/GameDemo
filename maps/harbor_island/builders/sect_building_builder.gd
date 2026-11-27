extends RefCounted

## SectBuildingBuilder — Thương Hội (đông), Lò Luyện đan (tây) trên bậc ao sen, Đài Quan Hải ở mũi đông bến cảng.

const Util: Script = preload("res://maps/harbor_island/builders/util.gd")
const Parts: Script = preload("res://maps/harbor_island/builders/parts.gd")

const POND_Y: float = 1.0
const Island: Script = preload("res://maps/harbor_island/builders/island_builder.gd")


static func build(root_node: Node3D) -> void:
	_make_merchant_hall(root_node, Vector3(9.8, POND_Y, -11.0))
	_make_alchemy_furnace(root_node, Vector3(-9.8, POND_Y, -11.0))
	_make_observation(root_node, Vector3(14.2, 0.0, 3.2))


## Thương Hội: lầu gỗ hai tầng, cột sơn son, mái ngói mực cong, biển vàng, đèn lồng đỏ.
static func _make_merchant_hall(root_node: Node3D, c: Vector3) -> void:
	Util.box(root_node, "ThuongHoiBase", c + Vector3(0.0, 0.2, 0.0), Vector3(7.4, 0.4, 5.6), "paving", Parts.STONE)
	Util.collide_box(root_node, "ThuongHoiBaseCol", c + Vector3(0.0, 0.2, 0.0), Vector3(7.4, 0.4, 5.6))
	var y: float = c.y + 0.4
	Util.box(root_node, "ThuongHoiHall", c + Vector3(0.0, 0.4 + 1.3, 0.0), Vector3(6.0, 2.6, 4.2), "wood", Color(0.58, 0.20, 0.15))
	Util.collide_box(root_node, "ThuongHoiHallCol", c + Vector3(0.0, 1.7, 0.0), Vector3(6.0, 2.6, 4.2))
	for sx in [-1.0, 1.0, 0.0]:
		for sz in [-1.0, 1.0]:
			Parts.pillar(root_node, "ThuongHoiPillar_%d_%d" % [int(sx), int(sz)], Vector3(c.x + sx * 3.1, y, c.z + sz * 2.2), 2.6, 0.17)
	Util.box(root_node, "ThuongHoiDoor", c + Vector3(0.0, 1.3, 2.13), Vector3(1.6, 1.9, 0.1), "plain", Color(0.2, 0.1, 0.07))
	Parts.roof(root_node, "ThuongHoiLow", Vector3(c.x, y + 2.7, c.z), 4.6, 3.4, 1.0, Parts.INK_ROOF, 0.5)
	Util.box(root_node, "ThuongHoiUpper", Vector3(c.x, y + 3.7 + 0.8, c.z), Vector3(3.4, 1.6, 2.6), "wood", Color(0.58, 0.20, 0.15))
	Parts.roof(root_node, "ThuongHoiTop", Vector3(c.x, y + 5.4, c.z), 3.3, 2.5, 1.2, Parts.INK_ROOF, 0.6)
	Util.box(root_node, "ThuongHoiSign", Vector3(c.x, y + 2.95, c.z + 2.45), Vector3(2.4, 0.5, 0.1), "glow", Parts.GOLD)
	for i in range(4):
		var lx: float = c.x - 2.7 + float(i) * 1.8
		Parts.hanging_lantern(root_node, "ThuongHoiLantern_%d" % i, Vector3(lx, y + 2.4, c.z + 2.6))


## Lò Luyện: đan lô đá ba chân giữa đình tròn mái ngọc, lửa chân hỏa cam, nhà kho gỗ bên cạnh.
static func _make_alchemy_furnace(root_node: Node3D, c: Vector3) -> void:
	Util.cylinder(root_node, "FurnacePlatform", c + Vector3(0.0, 0.2, 0.0), 3.4, 3.6, 0.4, "paving", Parts.STONE, 16)
	Util.collide_box(root_node, "FurnacePlatformCol", c + Vector3(0.0, 0.2, 0.0), Vector3(6.4, 0.4, 6.4))
	var y: float = c.y + 0.4
	for k in range(3):
		var a: float = float(k) / 3.0 * TAU
		Util.cylinder(root_node, "FurnaceLeg_%d" % k, Vector3(c.x + cos(a) * 0.9, y + 0.35, c.z + sin(a) * 0.9), 0.14, 0.2, 0.7, "rough", Color(0.22, 0.2, 0.19), 8)
	Util.cylinder(root_node, "FurnaceBody", Vector3(c.x, y + 1.35, c.z), 1.15, 1.0, 1.3, "rough", Color(0.28, 0.25, 0.23), 14)
	Util.cylinder(root_node, "FurnaceBand", Vector3(c.x, y + 1.45, c.z), 1.2, 1.2, 0.14, "glow", Parts.GOLD, 14)
	Util.cylinder(root_node, "FurnaceLid", Vector3(c.x, y + 2.25, c.z), 0.55, 1.05, 0.6, "rough", Color(0.3, 0.27, 0.25), 14)
	Util.sphere(root_node, "FurnaceKnob", Vector3(c.x, y + 2.7, c.z), 0.2, "glow", Parts.GOLD)
	Util.sphere(root_node, "FurnaceFire", Vector3(c.x, y + 0.95, c.z + 1.0), 0.3, "glow", Color(1.0, 0.55, 0.15), 1.2)
	Util.collide_box(root_node, "FurnaceCol", Vector3(c.x, y + 1.3, c.z), Vector3(2.2, 2.6, 2.2))
	for k in range(4):
		var a: float = float(k) / 4.0 * TAU + PI * 0.25
		Parts.pillar(root_node, "FurnacePillar_%d" % k, Vector3(c.x + cos(a) * 3.0, y, c.z + sin(a) * 3.0), 3.4, 0.14)
	Parts.round_roof(root_node, "Furnace", Vector3(c.x, y + 3.5, c.z), 3.5, 1.7, Parts.JADE_ROOF)
	var hut: Vector3 = Vector3(c.x - 0.5, c.y, c.z - 5.6 + 1.4)
	Util.box(root_node, "WarehouseBody", hut + Vector3(0.0, 1.0, 0.0), Vector3(3.6, 2.0, 2.4), "wood", Color(0.52, 0.36, 0.24))
	Util.collide_box(root_node, "WarehouseCol", hut + Vector3(0.0, 1.0, 0.0), Vector3(3.6, 2.0, 2.4))
	Parts.roof(root_node, "Warehouse", hut + Vector3(0.0, 2.0, 0.0), 2.5, 1.7, 0.9, Parts.INK_ROOF, 0.4)


## Đài Quan Hải: đình sáu cột mái tròn ngọc bích nhô ra mũi đông, nhìn ra biển.
static func _make_observation(root_node: Node3D, c: Vector3) -> void:
	Util.cylinder(root_node, "ObservationPlatform", c + Vector3(0.0, 0.25, 0.0), 2.9, 3.1, 0.5, "paving", Parts.STONE, 16)
	Util.collide_box(root_node, "ObservationPlatformCol", c + Vector3(0.0, 0.25, 0.0), Vector3(5.6, 0.5, 5.6))
	Island.add_stairs(root_node, "StairsObservation", c.x, c.z + 5.4, c.z + 2.8, c.y, c.y + 0.5, 2.4, 4)
	for k in range(6):
		var a: float = float(k) / 6.0 * TAU
		Parts.pillar(root_node, "ObservationPillar_%d" % k, Vector3(c.x + cos(a) * 2.3, c.y + 0.5, c.z + sin(a) * 2.3), 3.0, 0.14)
	Parts.round_roof(root_node, "Observation", Vector3(c.x, c.y + 3.6, c.z), 3.3, 1.6, Parts.JADE_ROOF)
	Util.sphere(root_node, "ObservationFinial", Vector3(c.x, c.y + 4.95, c.z), 0.2, "glow", Parts.GOLD)
	Parts.hanging_lantern(root_node, "ObservationLantern", Vector3(c.x, c.y + 3.2, c.z), Color(1.0, 0.8, 0.35))

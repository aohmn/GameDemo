extends RefCounted

## PagodaBuilder — Tiên Các: sân thượng bạch ngọc trên đỉnh bậc cao nhất, bài phường, hai đình bên,
## tháp ba tầng mái cong ngọc bích, đỉnh hồ lô vàng.

const Util: Script = preload("res://maps/harbor_island/builders/util.gd")
const Parts: Script = preload("res://maps/harbor_island/builders/parts.gd")
const Island: Script = preload("res://maps/harbor_island/builders/island_builder.gd")

const BASE_Y: float = 2.2
const CENTER: Vector3 = Vector3(0.0, BASE_Y, -23.2)
const PLATFORM_TOP: float = BASE_Y + 0.45


static func build(root_node: Node3D) -> void:
	_make_courtyard(root_node)
	_make_pagoda(root_node)
	Parts.paifang(root_node, "PaifangSect", Vector3(0.0, BASE_Y, -18.4), 5.2, 4.4)
	Parts.pavilion(root_node, "PavilionWest", Vector3(-7.2, BASE_Y, -21.5), 1.4, 2.6, Parts.JADE_ROOF)
	Parts.pavilion(root_node, "PavilionEast", Vector3(7.2, BASE_Y, -21.5), 1.4, 2.6, Parts.JADE_ROOF)
	for i in range(3):
		var z: float = -19.2 - float(i) * 0.0
		Parts.stone_lantern(root_node, "LanternSectW_%d" % i, Vector3(-3.6, BASE_Y, z - 0.9 + float(i) * 0.0 + float(i) * 0.0))
		Parts.stone_lantern(root_node, "LanternSectE_%d" % i, Vector3(3.6, BASE_Y, z - 0.9))
		break


static func _make_courtyard(root_node: Node3D) -> void:
	# Ba lớp bệ bạch ngọc thu nhỏ dần; bậc lên bệ nằm sau bài phường; lan can hai bên và phía sau
	var sizes: Array = [Vector2(13.0, 8.4), Vector2(11.4, 7.2), Vector2(9.8, 6.0)]
	for i in range(sizes.size()):
		var sz: Vector2 = sizes[i]
		Util.box(root_node, "SectPlatform_%d" % i, Vector3(CENTER.x, BASE_Y + 0.075 + float(i) * 0.15, CENTER.z), Vector3(sz.x, 0.15, sz.y), "marble", Parts.MARBLE)
	Util.collide_box(root_node, "SectPlatformCol", Vector3(CENTER.x, BASE_Y + 0.225, CENTER.z), Vector3(9.8, 0.45, 6.0))
	Island.add_stairs(root_node, "StairsSectPlatform", 0.0, -18.9, -20.2, BASE_Y, PLATFORM_TOP, 3.2, 3)
	var hx: float = 4.9
	var hz: float = 3.0
	Parts.railing(root_node, "RailBack", Vector3(-hx, PLATFORM_TOP, CENTER.z - hz), Vector3(hx, PLATFORM_TOP, CENTER.z - hz), 9)
	Parts.railing(root_node, "RailWest", Vector3(-hx, PLATFORM_TOP, CENTER.z - hz), Vector3(-hx, PLATFORM_TOP, CENTER.z + hz - 0.8), 5)
	Parts.railing(root_node, "RailEast", Vector3(hx, PLATFORM_TOP, CENTER.z - hz), Vector3(hx, PLATFORM_TOP, CENTER.z + hz - 0.8), 5)


static func _make_pagoda(root_node: Node3D) -> void:
	var y: float = PLATFORM_TOP
	var widths: Array = [5.2, 4.2, 3.2]
	var heights: Array = [2.8, 2.4, 2.1]
	for i in range(3):
		var w: float = float(widths[i])
		var h: float = float(heights[i])
		var half: float = w * 0.5
		Util.box(root_node, "PagodaWall_%d" % i, Vector3(CENTER.x, y + h * 0.5, CENTER.z), Vector3(w - 0.5, h, w - 0.5), "marble", Parts.MARBLE)
		Util.box(root_node, "PagodaDoor_%d" % i, Vector3(CENTER.x, y + h * 0.42, CENTER.z + (w - 0.5) * 0.5 + 0.02), Vector3(1.1, h * 0.7, 0.08), "lacquer", Parts.LACQUER)
		for sx in [-1.0, 1.0]:
			for sz in [-1.0, 1.0]:
				Parts.pillar(root_node, "PagodaPillar_%d_%d_%d" % [i, int(sx), int(sz)], Vector3(CENTER.x + sx * half, y, CENTER.z + sz * half), h, 0.17)
		Util.box(root_node, "PagodaBeam_%d" % i, Vector3(CENTER.x, y + h, CENTER.z), Vector3(w + 0.3, 0.24, w + 0.3), "lacquer", Parts.LACQUER)
		var roof_color: Color = Parts.GOLD if i == 2 else Parts.JADE_ROOF
		Parts.roof(root_node, "Pagoda_%d" % i, Vector3(CENTER.x, y + h + 0.1, CENTER.z), half + 1.5, half + 1.5, 1.25 - float(i) * 0.15, roof_color, 0.7)
		for k in range(4):
			var ang: float = float(k) * PI * 0.5 + PI * 0.25
			var r: float = (half + 1.45) * 1.38
			Parts.hanging_lantern(root_node, "PagodaLantern_%d_%d" % [i, k], Vector3(CENTER.x + cos(ang) * r * 0.72, y + h - 0.2, CENTER.z + sin(ang) * r * 0.72))
		y += h + 1.2 - float(i) * 0.15
	# Đỉnh hồ lô vàng tụ linh khí
	Util.cylinder(root_node, "FinialMast", Vector3(CENTER.x, y + 0.5, CENTER.z), 0.07, 0.1, 1.0, "lacquer", Parts.LACQUER, 8)
	Util.sphere(root_node, "FinialGourdLow", Vector3(CENTER.x, y + 1.15, CENTER.z), 0.34, "glow", Parts.GOLD)
	Util.sphere(root_node, "FinialGourdTop", Vector3(CENTER.x, y + 1.62, CENTER.z), 0.22, "glow", Parts.GOLD)
	Util.collide_box(root_node, "PagodaCol", Vector3(CENTER.x, BASE_Y + 3.7, CENTER.z), Vector3(4.9, 6.5, 4.9))

extends RefCounted

## Tạo vật liệu procedural (không texture) theo tên node. Một nơi duy nhất quyết định node nào
## dùng shader nào, để builder của mọi map dùng chung phong cách bề mặt.

const SHADER_DIR: String = "res://assets/shaders/"

static var _cache: Dictionary = {}


## Loại bề mặt theo từ khóa trong tên node.
static func kind_for_name(n: String) -> String:
	if n.contains("Roof"):
		return "roof"
	if n.contains("TreeCrown"):
		return "foliage"
	if n.contains("Mast") or n.contains("Trunk") or n.contains("Post") or n.contains("Crate"):
		return "wood"
	if n.contains("Planks") or n.contains("PierRamp") or n.contains("Boat"):
		return "planks"
	if n.contains("Warehouse") or (n.contains("ThuongHoi") and not n.contains("Sign")):
		return "wood"
	if n.contains("Pillar") or n.contains("TeleportInnerRing"):
		return "marble"
	if n.contains("TienCac") and not n.contains("Pinnacle"):
		return "marble"
	if n.contains("Plaza") or n.begins_with("Path") or n.contains("Observation") or n.contains("PondBorder"):
		return "paving"
	if n.contains("Furnace") and not n.contains("Fire"):
		return "rough"
	return "plain"


## Vật liệu theo loại bề mặt chỉ định rõ (planks, wood, roof, paving, marble, rough, foliage, lacquer, karst, glow, plain).
static func of_kind(kind: String, color: Color, radial: bool = false) -> Material:
	var key: String = "%s|%s|%s" % [kind, color.to_html(), str(radial)]
	if _cache.has(key):
		return _cache[key]
	var mat: Material
	if kind == "plain":
		var std := StandardMaterial3D.new()
		std.albedo_color = color
		std.roughness = 0.8
		mat = std
	else:
		var sm := ShaderMaterial.new()
		sm.shader = load(SHADER_DIR + "proc_%s.gdshader" % kind) as Shader
		sm.set_shader_parameter("base_color", color)
		sm.set_shader_parameter("dark_color", color.darkened(0.38))
		if kind == "roof":
			sm.set_shader_parameter("radial", radial)
		mat = sm
	_cache[key] = mat
	return mat


static func make(node_name: String, color: Color) -> Material:
	var radial: bool = node_name.contains("Observation") and node_name.contains("Roof")
	return of_kind(kind_for_name(node_name), color, radial)

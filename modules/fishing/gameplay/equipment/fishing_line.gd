class_name FishingLine
extends RefCounted

## Quản lý chỉ số dây câu: Sức chịu tải, độ bền thực tế và giảm chấn xung lực.

var id: String = "line_soi_gai"
var display_name: String = "Dây Sợi Gai Thô"
var tier: int = 0
var max_durability: float = 100.0
var current_durability: float = 100.0
var max_tension_bonus: float = 0.0 # Bổ sung vào giới hạn đứt dây của cần
var tension_damping: float = 1.0     # Hệ số giảm chấn xung giật của cá


static func from_resource(spec: Resource) -> FishingLine:
	var line := FishingLine.new()
	if spec == null:
		return line

	line.id = str(spec.get("id")) if "id" in spec else "line_soi_gai"
	line.display_name = str(spec.get("display_name")) if "display_name" in spec else "Dây Câu"
	line.tier = int(spec.get("tier")) if "tier" in spec else 0
	line.max_durability = float(spec.get("max_durability")) if "max_durability" in spec else 100.0
	line.current_durability = float(spec.get("current_durability")) if "current_durability" in spec else line.max_durability
	line.max_tension_bonus = float(spec.get("tension_bonus")) if "tension_bonus" in spec else float(line.tier * 10.0)
	line.tension_damping = float(spec.get("tension_damping")) if "tension_damping" in spec else (1.0 + float(line.tier) * 0.1)
	return line


static func create_default() -> FishingLine:
	return FishingLine.new()

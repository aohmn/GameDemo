class_name FishingLine
extends RefCounted

## Quản lý chỉ số dây câu: Sức bền, độ co giãn, khả năng giảm chấn xung lực.

var id: String = "line_soi_gai"
var display_name: String = "Dây Sợi Gai"
var tier: int = 1
var max_durability: float = 100.0
var current_durability: float = 100.0
var tension_damping: float = 1.0 # Hệ số giảm chấn xung giật của cá


static func create_default() -> FishingLine:
	var line := FishingLine.new()
	line.id = "line_soi_gai"
	line.display_name = "Dây Sợi Gai Thô"
	line.tier = 1
	line.max_durability = 100.0
	line.current_durability = 100.0
	line.tension_damping = 1.0
	return line

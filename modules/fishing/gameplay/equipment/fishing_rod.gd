class_name FishingRod
extends RefCounted

## Quản lý và chuyển đổi chỉ số cần câu (RodSpec) phục vụ gameplay câu cá:
## Lực chịu tải, độ dẻo, tốc độ thu xả dây và độ bền thực tế.

var id: String = "rod_truc_nhiem"
var display_name: String = "Cần Trúc Nhiệm"
var tier: int = 0
var max_tension: float = 100.0
var safe_min: float = 30.0
var safe_max: float = 70.0
var reel_speed: float = 35.0
var release_speed: float = 25.0
var fatigue_rate: float = 12.0
var control_power: float = 1.0
var max_durability: float = 100.0
var current_durability: float = 100.0


static func from_resource(spec: Resource) -> FishingRod:
	var rod := FishingRod.new()
	if spec == null:
		return rod

	rod.id = str(spec.get("id")) if "id" in spec else "rod_truc_nhiem"
	rod.display_name = str(spec.get("display_name")) if "display_name" in spec else "Cần Trúc"
	rod.tier = int(spec.get("tier")) if "tier" in spec else 0
	rod.max_tension = float(spec.get("max_tension")) if "max_tension" in spec else 100.0
	rod.safe_min = float(spec.get("safe_tension_min")) if "safe_tension_min" in spec else 30.0
	rod.safe_max = float(spec.get("safe_tension_max")) if "safe_tension_max" in spec else 70.0
	rod.reel_speed = float(spec.get("reel_speed")) if "reel_speed" in spec else 35.0
	rod.release_speed = float(spec.get("release_speed")) if "release_speed" in spec else 25.0
	rod.fatigue_rate = float(spec.get("fatigue_rate")) if "fatigue_rate" in spec else 12.0
	rod.control_power = float(spec.get("control_power")) if "control_power" in spec else 1.0
	rod.max_durability = float(spec.get("max_durability")) if "max_durability" in spec else 100.0
	rod.current_durability = float(spec.get("current_durability")) if "current_durability" in spec else rod.max_durability
	return rod

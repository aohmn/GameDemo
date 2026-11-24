class_name FishingRod
extends RefCounted

## Quản lý chỉ số cần câu: Lực chịu tải, độ dẻo, tốc độ thu xả dây.

var id: String = "rod_truc_nhiem"
var display_name: String = "Cần Trúc Nhiệm"
var tier: int = 1
var max_tension: float = 100.0
var safe_min: float = 30.0
var safe_max: float = 70.0
var reel_speed: float = 35.0
var release_speed: float = 40.0
var fatigue_rate: float = 12.0
var durability: float = 100.0


static func from_resource(spec: Resource) -> FishingRod:
	var rod := FishingRod.new()
	if spec == null:
		return rod

	rod.id = str(spec.get("id"))
	rod.display_name = str(spec.get("display_name"))
	rod.tier = int(spec.get("tier")) if "tier" in spec else 1
	rod.max_tension = float(spec.get("max_tension")) if "max_tension" in spec else 100.0
	rod.safe_min = float(spec.get("safe_tension_min")) if "safe_tension_min" in spec else 30.0
	rod.safe_max = float(spec.get("safe_tension_max")) if "safe_tension_max" in spec else 70.0
	rod.reel_speed = float(spec.get("reel_speed")) if "reel_speed" in spec else 35.0
	rod.release_speed = float(spec.get("release_speed")) if "release_speed" in spec else 40.0
	rod.fatigue_rate = float(spec.get("fatigue_rate")) if "fatigue_rate" in spec else 12.0
	return rod

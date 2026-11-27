class_name FishData
extends RefCounted

## Thông số sinh học & tu vi của cá theo mục 5 TASK 11:
## Sức mạnh, Thể lực, Tốc độ bơi, Khả năng phản kháng, Độ lì, Độ hiếm, Linh khí.

var id: String = ""
var display_name: String = ""
var tier: int = 1         # Phẩm cấp (1: Phàm, 2: Linh, 3: Yêu, 4: Tiên, 5: Thần, 6: Thái Cổ)
var rarity: int = 1       # Độ hiếm (1 đến 5 sao)
var strength: float = 30.0    # Sức mạnh kéo
var stamina: float = 100.0    # Thể lực ban đầu
var swim_speed: float = 1.0   # Tốc độ bơi / tần số đổi hướng
var resistance: float = 1.0   # Khả năng phản kháng (biên độ giật)
var tenacity: float = 1.0     # Độ lì lợm (chống mệt mỏi)
var qi_value: int = 10        # Linh khí / tu vi chứa trong cá
var weight_g: int = 150       # Khối lượng thực tế cá câu được
var max_hp: float = 100.0     # Sinh lực tối đa trong trận
var max_qi: float = 100.0     # Nội năng tối đa dùng cho kỹ năng


static func from_resource(spec: Resource, rng: RandomNumberGenerator) -> FishData:
	var data := FishData.new()
	if spec == null:
		return data

	data.id = str(spec.get("id"))
	data.display_name = str(spec.get("display_name"))
	data.tier = int(spec.get("tier")) if "tier" in spec else 1
	data.rarity = int(spec.get("rarity")) if "rarity" in spec else 1
	data.strength = float(spec.get("strength")) if "strength" in spec else 30.0
	data.stamina = data.strength * 3.5 # Thể lực tỷ lệ với sức mạnh
	data.resistance = float(spec.get("pull_force")) / 20.0 if "pull_force" in spec else 1.0
	data.tenacity = 1.0 + (float(data.rarity - 1) * 0.25)
	data.swim_speed = 1.0 + (float(data.tier - 1) * 0.2)
	data.qi_value = int(spec.get("spirit_qi")) if "spirit_qi" in spec else (data.tier * 25)

	var w_min: int = int(spec.get("min_weight_g")) if "min_weight_g" in spec else 100
	var w_max: int = int(spec.get("max_weight_g")) if "max_weight_g" in spec else 300
	data.weight_g = rng.randi_range(w_min, w_max)
	data.max_hp = float(spec.get("max_hp")) if "max_hp" in spec else (data.stamina * 1.2 + float(data.weight_g) * 0.05)
	data.max_qi = float(spec.get("max_qi")) if "max_qi" in spec else (float(data.tier) * 30.0 + float(data.qi_value) * 0.5)
	return data

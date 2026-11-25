class_name FishSpawner
extends RefCounted

## Bộ sinh cá và điều phối tỷ lệ xuất hiện dựa trên SpotSpec và Mồi câu.


static func spawn_fish_for_spot(
	spot: Resource,
	bait_pref_tier: int,
	rng: RandomNumberGenerator
) -> Resource:
	if spot == null:
		return null

	var table: Array = spot.get("fish_table") as Array
	if table == null or table.is_empty():
		return null

	var weighted_list: Array[Dictionary] = []
	var total_weight: int = 0

	for entry in table:
		var fish_res: Resource = entry.get("fish") as Resource if "fish" in entry else null
		var weight: int = int(entry["weight"]) if "weight" in entry else 1

		if fish_res != null and bait_pref_tier > 0:
			var tier: int = int(fish_res.get("tier")) if "tier" in fish_res else 1
			# Nếu mồi phù hợp phẩm cấp cá, tăng gấp đôi tỷ lệ cắn câu
			if tier == bait_pref_tier:
				weight *= 2

		total_weight += weight
		weighted_list.append({"fish": fish_res, "weight": weight})

	if total_weight <= 0:
		return table[0].get("fish") as Resource

	var roll: int = rng.randi_range(1, total_weight)
	var accumulated: int = 0
	for item in weighted_list:
		accumulated += int(item["weight"])
		if roll <= accumulated:
			return item["fish"] as Resource

	return table[0].get("fish") as Resource

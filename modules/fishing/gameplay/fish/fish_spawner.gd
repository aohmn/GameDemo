class_name FishSpawner
extends RefCounted

## Bộ sinh cá và điều phối tỷ lệ xuất hiện dựa trên SpotSpec và Mồi câu.


static func matches_condition(required: String, current: String) -> bool:
	if required.is_empty() or required == "tat_ca":
		return true
	if required == "ngay":
		return current in ["ngay", "binh_minh", "hoang_hon"]
	return required == current


static func spawn_fish_for_spot(
	spot: Resource,
	bait_pref_tier: int,
	rng: RandomNumberGenerator,
	max_fish_tier: int = 99,
	time_period: String = "ngay",
	weather: String = "nang"
) -> Resource:
	if spot == null:
		return null

	var table: Array = spot.get("fish_table") as Array
	if table == null or table.is_empty():
		return null

	var weighted_list: Array[Dictionary] = []
	var total_weight: int = 0
	var spot_water: String = str(spot.get("water_type")) if "water_type" in spot else ""

	for entry in table:
		var fish_res: Resource = entry.get("fish") as Resource if "fish" in entry else null
		var weight: int = int(entry["weight"]) if "weight" in entry else 1

		if fish_res == null:
			continue
		if not spot_water.is_empty() and "habitat_water_type" in fish_res:
			var f_water: String = str(fish_res.get("habitat_water_type"))
			if not f_water.is_empty() and f_water != "tat_ca" and f_water != spot_water:
				continue
		var fish_tier: int = int(fish_res.get("tier")) if "tier" in fish_res else 0
		if fish_tier > max_fish_tier:
			continue # Cá quá phẩm cấp so với cần câu: không thể mắc câu
		var f_time: String = str(fish_res.get("time_condition")) if "time_condition" in fish_res else "tat_ca"
		if not matches_condition(f_time, time_period):
			continue
		var f_weather: String = str(fish_res.get("weather_condition")) if "weather_condition" in fish_res else "tat_ca"
		if not matches_condition(f_weather, weather):
			continue

		if bait_pref_tier > 0:
			var tier: int = fish_tier
			# Nếu mồi phù hợp phẩm cấp cá, tăng gấp đôi tỷ lệ cắn câu
			if tier == bait_pref_tier:
				weight *= 2

		total_weight += weight
		weighted_list.append({"fish": fish_res, "weight": weight})

	if weighted_list.is_empty():
		return null
	if total_weight <= 0:
		return weighted_list[0]["fish"] as Resource

	var roll: int = rng.randi_range(1, total_weight)
	var accumulated: int = 0
	for item in weighted_list:
		accumulated += int(item["weight"])
		if roll <= accumulated:
			return item["fish"] as Resource

	return weighted_list[0]["fish"] as Resource

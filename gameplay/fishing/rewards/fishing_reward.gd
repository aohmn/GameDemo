class_name FishingReward
extends RefCounted

## Đóng gói dữ liệu kết quả thu hoạch cá để phát sự kiện cho Inventory và Cultivation.


static func create_reward_payload(
	fish_data: FishData,
	qi_multiplier: float = 1.0
) -> Dictionary:
	if fish_data == null:
		return {}

	var final_qi := int(float(fish_data.qi_value) * qi_multiplier)

	return {
		"fish_id": fish_data.id,
		"name": fish_data.display_name,
		"tier": fish_data.tier,
		"rarity": fish_data.rarity,
		"weight_g": fish_data.weight_g,
		"qi_value": final_qi
	}

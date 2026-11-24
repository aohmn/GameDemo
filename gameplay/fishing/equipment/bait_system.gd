class_name BaitSystem
extends RefCounted

## Quản lý hệ thống mồi câu: Thu hút cá theo phẩm cấp, giảm thời gian chờ.

var current_bait_id: String = ""
var attraction_power: float = 1.0
var preferred_tier: int = 1
var remaining_uses: int = 0


func set_bait(bait_id: String, tier_pref: int = 1, attraction: float = 1.0, uses: int = 5) -> void:
	current_bait_id = bait_id
	preferred_tier = tier_pref
	attraction_power = attraction
	remaining_uses = uses


func consume_bait() -> bool:
	if remaining_uses > 0:
		remaining_uses -= 1
		if remaining_uses == 0:
			current_bait_id = ""
		return true
	return false

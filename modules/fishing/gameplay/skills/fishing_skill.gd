class_name FishingSkill
extends RefCounted

## Quản lý và kích hoạt 5 kỹ năng câu cá tu đạo theo yêu cầu mục 5 TASK 12:
## 1. Linh Nhãn (Nhìn thấu phẩm cấp và độ hiếm cá trước khi cắn câu)
## 2. Thính Thủy (Cảm nhận dao động nước, tăng thời gian cửa sổ giật cần)
## 3. Ngự Câu (Khống chế lực kéo, mở rộng vùng an toàn safe_tension)
## 4. Tỏa Ngư (Phong tỏa kình lực cá, giảm lực giật và tốc độ bơi)
## 5. Thu Linh (Gia tăng linh khí hấp thu khi câu thành công)

enum SkillType {
	LINH_NHAN,
	THINH_THUY,
	NGU_CAU,
	TOA_NGU,
	THU_LINH
}

var unlocked_skills: Dictionary = {
	SkillType.LINH_NHAN: false,
	SkillType.THINH_THUY: false,
	SkillType.NGU_CAU: false,
	SkillType.TOA_NGU: false,
	SkillType.THU_LINH: false
}

# Giới hạn số lần thi triển kỹ năng chủ động trong 1 phiên câu
var toa_ngu_uses: int = 1


const SKILL_DEFS: Array[Dictionary] = [
	{"type": SkillType.LINH_NHAN, "name": "Linh Nhãn", "req_realm": 0, "effect": "+0.5 thu hút & thấu thị cá cắn"},
	{"type": SkillType.THINH_THUY, "name": "Thính Thủy", "req_realm": 1, "effect": "+0.35s cửa sổ giật cần"},
	{"type": SkillType.NGU_CAU, "name": "Ngự Câu", "req_realm": 2, "effect": "+10 vùng an toàn lực căng"},
	{"type": SkillType.TOA_NGU, "name": "Tỏa Ngư", "req_realm": 3, "effect": "-35% lực giật của cá"},
	{"type": SkillType.THU_LINH, "name": "Thu Linh", "req_realm": 4, "effect": "+35% linh khí hấp thu"},
]


func unlock_skill(skill: int) -> void:
	unlocked_skills[skill] = true


func sync_with_realm(realm_index: int) -> void:
	for def in SKILL_DEFS:
		var st: int = int(def["type"])
		if realm_index >= int(def["req_realm"]):
			unlocked_skills[st] = true


func get_skills_summary(realm_index: int = 0) -> Array[Dictionary]:
	sync_with_realm(realm_index)
	var out: Array[Dictionary] = []
	for def in SKILL_DEFS:
		var st: int = int(def["type"])
		out.append({
			"type": st,
			"name": str(def["name"]),
			"req_realm": int(def["req_realm"]),
			"unlocked": is_unlocked(st),
			"effect": str(def["effect"])
		})
	return out


func get_attraction_bonus() -> float:
	return 0.5 if is_unlocked(SkillType.LINH_NHAN) else 0.0


func is_unlocked(skill: int) -> bool:
	return bool(unlocked_skills.get(skill, false))


func reset_session_skills() -> void:
	toa_ngu_uses = 1 if is_unlocked(SkillType.TOA_NGU) else 0


## 1. Linh Nhãn: Thấu thị phẩm cấp cá mục tiêu
func activate_linh_nhan(target_fish: Resource) -> Dictionary:
	if not is_unlocked(SkillType.LINH_NHAN) or target_fish == null:
		return {}
	return {
		"id": str(target_fish.get("id")),
		"name": str(target_fish.get("display_name")),
		"tier": int(target_fish.get("tier")) if "tier" in target_fish else 0,
		"rarity": int(target_fish.get("rarity")) if "rarity" in target_fish else 1
	}


## 2. Thính Thủy: Gia tăng cửa sổ giật cần (strike window)
func get_bite_window_bonus() -> float:
	return 0.35 if is_unlocked(SkillType.THINH_THUY) else 0.0


## 3. Ngự Câu: Mở rộng vùng an toàn lực căng (safe zone)
func get_safe_zone_bonus() -> float:
	return 10.0 if is_unlocked(SkillType.NGU_CAU) else 0.0


## 4. Tỏa Ngư: Làm chậm và giảm 35% lực giật xung kích của cá
func get_fish_pull_reduction() -> float:
	if is_unlocked(SkillType.TOA_NGU) and toa_ngu_uses > 0:
		return 0.65
	return 1.0


## 5. Thu Linh: Gia tăng 35% linh khí nhận được khi thu phục cá
func get_qi_multiplier() -> float:
	return 1.35 if is_unlocked(SkillType.THU_LINH) else 1.0

class_name FishingSkill
extends RefCounted

## Quản lý các kỹ năng câu cá tu đạo định hướng theo mục 6 TASK 11:
## 1. Linh Nhãn (Nhìn thấu phẩm cấp và độ hiếm cá trước khi cắn câu)
## 2. Thính Thủy (Cảm nhận dao động nước, tăng cửa sổ giật cần strike window)
## 3. Ngự Câu (Khống chế lực kéo, mở rộng vùng an toàn safe_tension)
## 4. Tỏa Ngư (Phong tỏa kình lực cá, làm chậm tốc độ bơi)
## 5. Thu Linh (Gia tăng 20-50% linh khí hấp thu khi câu thành công)

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


func unlock_skill(skill: int) -> void:
	unlocked_skills[skill] = true


func is_unlocked(skill: int) -> bool:
	return bool(unlocked_skills.get(skill, false))


## Lấy phần thưởng cửa sổ thời gian giật cần từ Thính Thủy
func get_bite_window_bonus() -> float:
	return 0.35 if is_unlocked(SkillType.THINH_THUY) else 0.0


## Lấy phần thưởng mở rộng vùng an toàn từ Ngự Câu
func get_safe_zone_bonus() -> float:
	return 8.0 if is_unlocked(SkillType.NGU_CAU) else 0.0


## Hệ số nhân linh khí từ Thu Linh
func get_qi_multiplier() -> float:
	return 1.35 if is_unlocked(SkillType.THU_LINH) else 1.0

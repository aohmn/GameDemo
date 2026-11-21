extends RefCounted
class_name JobService

## Lịch làm việc dùng chung cho NPC prototype.

static func get_activity(hour: int) -> StringName:
	if hour >= 7 and hour < 17:
		return &"work"
	if hour >= 17 and hour < 19:
		return &"shopping"
	return &"home"


static func get_shift_start() -> int:
	return 7


static func get_shift_end() -> int:
	return 17

class_name FishingData
extends RefCounted

## Quản lý dữ liệu phiên câu cá hiện tại:
## Vị trí câu, cần câu, dây câu, mồi câu, cá mục tiêu và thống kê phiên.

var spot_id: String = ""
var spot_resource: Resource
var rod_resource: Resource
var line_resource: Resource
var bait_resource: Resource
var target_fish_resource: Resource

# Thông số phiên câu
var session_time: float = 0.0
var fight_duration: float = 0.0
var tension: float = 40.0
var fish_stamina: float = 100.0
var fish_max_stamina: float = 100.0
var line_durability: float = 100.0
var rod_durability: float = 100.0

# Trạng thái đầu vào người chơi
var is_reeling: bool = false
var is_releasing: bool = false
var pull_strength_factor: float = 1.0 # 0.5 đến 1.5 điều chỉnh theo thời gian thực


func reset() -> void:
	spot_id = ""
	spot_resource = null
	rod_resource = null
	line_resource = null
	bait_resource = null
	target_fish_resource = null
	session_time = 0.0
	fight_duration = 0.0
	tension = 40.0
	fish_stamina = 100.0
	fish_max_stamina = 100.0
	line_durability = 100.0
	rod_durability = 100.0
	is_reeling = false
	is_releasing = false
	pull_strength_factor = 1.0

class_name FishingBattle
extends RefCounted

## Quản lý quá trình giằng co (Fight FSM):
## Đồng bộ giữa TensionSystem, FishAI, sức chịu đựng của cá và độ bền trang bị thực tế.

const TensionSystemScript: Script = preload("res://modules/fishing/gameplay/battle/tension_system.gd")
const ReelDragSystemScript: Script = preload("res://modules/fishing/gameplay/battle/reel_drag_system.gd")
const FishAIScript: Script = preload("res://modules/fishing/gameplay/fish/fish_ai.gd")
const FishingCalculatorScript: Script = preload("res://modules/fishing/gameplay/core/fishing_calculator.gd")

var tension_system: TensionSystem
var reel_drag: ReelDragSystem = ReelDragSystemScript.new()
var fish_ai: FishAI
var fight_time: float = 0.0
var rod_steer: float = 0.0
var rod_bend: float = 0.0

var fish_stamina: float = 100.0
var line_durability: float = 100.0
var rod_durability: float = 100.0

var reel_speed: float = 35.0
var release_speed: float = 25.0
var fatigue_rate: float = 12.0
var pull_reduction: float = 1.0


func start_battle(
	rod_spec: Resource,
	line_item: FishingLine,
	fish_data: FishData,
	safe_zone_bonus: float,
	fish_pull_modifier: float,
	rng: RandomNumberGenerator,
	equipment_stats: Dictionary = {}
) -> void:
	tension_system = TensionSystemScript.new()
	var line_bonus := line_item.max_tension_bonus if line_item != null else 0.0
	line_bonus += float(equipment_stats.get("total_max_tension_bonus", 0.0))
	tension_system.setup(rod_spec, line_bonus, safe_zone_bonus)

	fish_ai = FishAIScript.new(rng)
	reel_drag.reset(15.0)
	rod_steer = 0.0
	rod_bend = 0.0
	fight_time = 0.0
	fish_stamina = fish_data.stamina
	pull_reduction = fish_pull_modifier

	# Khởi tạo độ bền thực tế từ trang bị thay vì mặc định 100
	if rod_spec != null and "current_durability" in rod_spec:
		rod_durability = float(rod_spec.get("current_durability"))
	else:
		rod_durability = 100.0

	if line_item != null:
		line_durability = line_item.current_durability
	else:
		line_durability = 100.0

	if rod_spec != null:
		reel_speed = float(rod_spec.get("reel_speed")) if "reel_speed" in rod_spec else 35.0
		release_speed = float(rod_spec.get("release_speed")) if "release_speed" in rod_spec else 25.0
		fatigue_rate = float(rod_spec.get("fatigue_rate")) if "fatigue_rate" in rod_spec else 12.0

	# Áp dụng bonus từ trang bị pháp bảo
	fatigue_rate += float(equipment_stats.get("total_fatigue_rate_bonus", 0.0))
	var ctrl_bonus: float = float(equipment_stats.get("total_control_power_bonus", 0.0))
	if ctrl_bonus > 0.0:
		reel_speed *= (1.0 + ctrl_bonus * 0.1)
		release_speed *= (1.0 + ctrl_bonus * 0.1)


## Cập nhật 1 frame chiến đấu, trả về mã trạng thái:
## "CONTINUE", "CAUGHT", "LINE_BREAK", "SLACK_ESCAPE", "ROD_BROKEN"
func update(
	fish_data: FishData,
	is_reeling: bool,
	is_releasing: bool,
	player_factor: float,
	delta: float
) -> String:
	fight_time += delta

	# Lấy lực kéo từ AI cá và áp dụng hệ số Tỏa Ngư
	var fish_pull: float = fish_ai.update_pull_force(fish_data, fight_time, delta) * pull_reduction

	# Cập nhật lực căng
	tension_system.update(
		is_reeling,
		is_releasing,
		reel_speed,
		release_speed,
		fish_pull,
		player_factor,
		delta
	)

	# Kiểm tra đứt dây do vượt ngưỡng căng tối đa
	if tension_system.is_line_broken():
		return "LINE_BREAK"

	var t_ratio: float = clampf(tension_system.current_tension / maxf(1.0, tension_system.max_tension), 0.0, 1.0)
	rod_bend = t_ratio
	if reel_drag != null:
		reel_drag.update(is_reeling, fish_pull, reel_speed, t_ratio, delta)

	# Kiểm tra cá tuột lưỡi do chùng dây quá lâu
	if tension_system.is_fish_slack_escaped():
		return "SLACK_ESCAPE"

	# Tiêu hao thể lực cá
	var drain: float = FishingCalculatorScript.calculate_fish_stamina_drain(
		tension_system.current_tension,
		tension_system.safe_min,
		tension_system.safe_max,
		fatigue_rate,
		fish_data.tenacity,
		delta
	)
	fish_stamina = clampf(fish_stamina - drain, 0.0, fish_data.stamina)

	# Hao mòn độ bền dây và cần câu hợp lý theo diễn biến
	var line_wear: float = FishingCalculatorScript.calculate_line_wear(
		tension_system.current_tension,
		tension_system.max_tension,
		tension_system.safe_max,
		delta
	)
	line_durability = maxf(0.0, line_durability - line_wear)
	rod_durability = maxf(0.0, rod_durability - line_wear * 0.25)

	if line_durability <= 0.0:
		return "LINE_BREAK"
	if rod_durability <= 0.0:
		return "ROD_BROKEN"

	# Thắng cuộc khi cá kiệt sức
	if fish_stamina <= 0.0:
		return "CAUGHT"

	return "CONTINUE"

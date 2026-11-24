class_name FishingBattle
extends RefCounted

## Quản lý quá trình giằng co (Fight FSM):
## Đồng bộ giữa TensionSystem, FishAI, sức chịu đựng của cá và độ bền trang bị.

const TensionSystemScript: Script = preload("res://gameplay/fishing/battle/tension_system.gd")
const FishAIScript: Script = preload("res://gameplay/fishing/fish/fish_ai.gd")
const FishingCalculatorScript: Script = preload("res://gameplay/fishing/core/fishing_calculator.gd")

var tension_system: TensionSystem
var fish_ai: FishAI
var fight_time: float = 0.0

var fish_stamina: float = 100.0
var line_durability: float = 100.0
var rod_durability: float = 100.0

var reel_speed: float = 35.0
var release_speed: float = 40.0
var fatigue_rate: float = 12.0


func start_battle(
	rod_spec: Resource,
	fish_data: FishData,
	rng: RandomNumberGenerator
) -> void:
	tension_system = TensionSystemScript.new()
	tension_system.setup(rod_spec)
	fish_ai = FishAIScript.new(rng)

	fight_time = 0.0
	fish_stamina = fish_data.stamina
	line_durability = 100.0
	rod_durability = 100.0

	if rod_spec != null:
		reel_speed = float(rod_spec.get("reel_speed")) if "reel_speed" in rod_spec else 35.0
		release_speed = float(rod_spec.get("release_speed")) if "release_speed" in rod_spec else 40.0
		fatigue_rate = float(rod_spec.get("fatigue_rate")) if "fatigue_rate" in rod_spec else 12.0


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

	# Lấy lực kéo từ AI cá
	var fish_pull := fish_ai.update_pull_force(fish_data, fight_time, delta)

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

	# Kiểm tra đứt dây
	if tension_system.is_line_broken():
		return "LINE_BREAK"

	# Kiểm tra cá tuột lưỡi do chùng dây quá lâu
	if tension_system.is_fish_slack_escaped():
		return "SLACK_ESCAPE"

	# Tiêu hao thể lực cá
	var drain := FishingCalculatorScript.calculate_fish_stamina_drain(
		tension_system.current_tension,
		tension_system.safe_min,
		tension_system.safe_max,
		fatigue_rate,
		fish_data.tenacity,
		delta
	)
	fish_stamina = clampf(fish_stamina - drain, 0.0, fish_data.stamina)

	# Hao mòn độ bền dây
	var line_wear := FishingCalculatorScript.calculate_line_wear(
		tension_system.current_tension,
		tension_system.max_tension,
		tension_system.safe_max,
		delta
	)
	line_durability = maxf(0.0, line_durability - line_wear)
	if line_durability <= 0.0:
		return "LINE_BREAK"

	# Thắng cuộc khi cá kiệt sức
	if fish_stamina <= 0.0:
		return "CAUGHT"

	return "CONTINUE"

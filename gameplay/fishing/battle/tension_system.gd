class_name TensionSystem
extends RefCounted

## Quản lý chỉ số lực căng, vùng an toàn, cảnh báo đứt dây hoặc tuột lưỡi.

const FishingCalculatorScript: Script = preload("res://gameplay/fishing/core/fishing_calculator.gd")

var current_tension: float = 40.0
var safe_min: float = 30.0
var safe_max: float = 70.0
var max_tension: float = 100.0

var slack_time: float = 0.0 # Thời gian dây bị chùng liên tục
var max_slack_tolerated: float = 3.5 # Quá 3.5s chùng dây thì cá sẽ tuột lưỡi trốn thoát


func setup(rod_spec: Resource, line_bonus: float = 0.0, safe_zone_bonus: float = 0.0) -> void:
	if rod_spec != null:
		safe_min = float(rod_spec.get("safe_tension_min")) if "safe_tension_min" in rod_spec else 30.0
		safe_max = float(rod_spec.get("safe_tension_max")) if "safe_tension_max" in rod_spec else 70.0
		max_tension = float(rod_spec.get("max_tension")) if "max_tension" in rod_spec else 100.0
	else:
		safe_min = 30.0
		safe_max = 70.0
		max_tension = 100.0

	# Bổ sung chỉ số từ Dây câu và Kỹ năng Ngự Câu
	max_tension += line_bonus
	safe_min = maxf(10.0, safe_min - safe_zone_bonus * 0.5)
	safe_max = safe_max + safe_zone_bonus * 0.5

	current_tension = (safe_min + safe_max) * 0.5
	slack_time = 0.0


func update(
	is_reeling: bool,
	is_releasing: bool,
	reel_speed: float,
	release_speed: float,
	fish_pull: float,
	player_factor: float,
	delta: float
) -> void:
	var delta_t: float = FishingCalculatorScript.calculate_tension_delta(
		is_reeling,
		is_releasing,
		reel_speed,
		release_speed,
		fish_pull,
		player_factor,
		delta
	)
	current_tension = maxf(0.0, current_tension + delta_t)

	# Theo dõi chùng dây
	if current_tension < safe_min * 0.35:
		slack_time += delta
	else:
		slack_time = maxf(0.0, slack_time - delta * 1.5)


func is_line_broken() -> bool:
	return current_tension > max_tension


func is_fish_slack_escaped() -> bool:
	return slack_time >= max_slack_tolerated


func is_in_safe_zone() -> bool:
	return current_tension >= safe_min and current_tension <= safe_max

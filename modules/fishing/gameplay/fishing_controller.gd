class_name FishingController
extends RefCounted

## FishingController — Bộ điều khiển trung tâm của module modules/fishing/gameplay/.
## Quản lý toàn bộ 8 trạng thái FSM, điều phối đấu sức, trang bị, kỹ năng và phát sự kiện.

const FishingStateScript: Script = preload("res://modules/fishing/gameplay/core/fishing_state.gd")
const FishingDataScript: Script = preload("res://modules/fishing/gameplay/core/fishing_data.gd")
const FishingCalculatorScript: Script = preload("res://modules/fishing/gameplay/core/fishing_calculator.gd")
const FishDataScript: Script = preload("res://modules/fishing/gameplay/fish/fish_data.gd")
const FishSpawnerScript: Script = preload("res://modules/fishing/gameplay/fish/fish_spawner.gd")
const FishingBattleScript: Script = preload("res://modules/fishing/gameplay/battle/fishing_battle.gd")
const FishingRodScript: Script = preload("res://modules/fishing/gameplay/equipment/fishing_rod.gd")
const FishingLineScript: Script = preload("res://modules/fishing/gameplay/equipment/fishing_line.gd")
const BaitSystemScript: Script = preload("res://modules/fishing/gameplay/equipment/bait_system.gd")
const FishingSkillScript: Script = preload("res://modules/fishing/gameplay/skills/fishing_skill.gd")
const FishingRewardScript: Script = preload("res://modules/fishing/gameplay/rewards/fishing_reward.gd")

# Callbacks xuất tín hiệu
var on_state_changed: Callable
var on_fish_bite: Callable
var on_fight_update: Callable
var on_fish_caught: Callable
var on_fish_lost: Callable

var current_state: int = FishingStateScript.State.IDLE
var fishing_data: FishingData
var battle: FishingBattle
var bait_system: BaitSystem
var skills: FishingSkill
var current_fish: FishData

var rng: RandomNumberGenerator
var _wait_timer: float = 0.0
var _bite_timer: float = 0.0
var _equipment_stats: Dictionary = {}
const BASE_BITE_WINDOW: float = 0.85


func _init(seed_val: int = -1) -> void:
	rng = RandomNumberGenerator.new()
	if seed_val >= 0:
		rng.seed = seed_val
	else:
		rng.randomize()

	fishing_data = FishingDataScript.new()
	battle = FishingBattleScript.new()
	bait_system = BaitSystemScript.new()
	skills = FishingSkillScript.new()


func set_seed(seed_val: int) -> void:
	rng.seed = seed_val


func get_state_name() -> String:
	return FishingStateScript.get_state_name(current_state)


## Thả câu (IDLE -> CASTING -> WAITING)
func cast(spot: Resource, rod: Resource, line_res: Resource = null, equipment_stats: Dictionary = {}, time_period: String = "ngay", weather: String = "nang") -> bool:
	if not FishingStateScript.can_transition(current_state, FishingStateScript.State.CASTING):
		return false
	if spot == null or rod == null:
		return false

	fishing_data.reset()
	fishing_data.spot_resource = spot
	fishing_data.rod_resource = rod
	fishing_data.line_resource = line_res if line_res != null else FishingLineScript.create_default()
	fishing_data.spot_id = str(spot.get("id"))
	_equipment_stats = equipment_stats

	# Chọn cá mục tiêu theo phẩm cấp cần câu; không có cá phù hợp thì không thả được
	var bait_pref := bait_system.preferred_tier if bait_system.remaining_uses > 0 else 0
	var rod_tier: int = int(rod.get("tier")) if "tier" in rod else 0
	var max_tier: int = FishingCalculatorScript.max_catchable_fish_tier(rod_tier)
	var fish_res: Resource = FishSpawnerScript.spawn_fish_for_spot(spot, bait_pref, rng, max_tier, time_period, weather)
	if fish_res == null:
		return false
	fishing_data.target_fish_resource = fish_res
	current_fish = FishDataScript.from_resource(fish_res, rng)

	# Reset trạng thái kỹ năng phiên câu
	skills.reset_session_skills()

	if not _transition_to(FishingStateScript.State.CASTING):
		return false

	# Tính thời gian chờ cá cắn
	var min_w: float = float(spot.get("min_wait_time")) if "min_wait_time" in spot else 2.0
	var max_w: float = float(spot.get("max_wait_time")) if "max_wait_time" in spot else 5.0
	var attraction := bait_system.attraction_power if bait_system.remaining_uses > 0 else 0.0
	attraction += skills.get_attraction_bonus()
	_wait_timer = FishingCalculatorScript.calculate_wait_time(
		min_w, max_w, current_fish.rarity, attraction, rng
	)

	return _transition_to(FishingStateScript.State.WAITING)


## Giật cần (WAITING/BITE -> FIGHT)
func strike() -> bool:
	if current_state == FishingStateScript.State.WAITING:
		# Giật quá sớm trước khi cá cắn -> Thất bại
		_end_fishing(FishingStateScript.State.FAILED, "early")
		return false

	if current_state == FishingStateScript.State.BITE:
		# Giật chuẩn xác -> Chuyển sang FIGHT
		if not _transition_to(FishingStateScript.State.FIGHT):
			return false

		var line_obj: FishingLine = null
		if fishing_data.line_resource is FishingLine:
			line_obj = fishing_data.line_resource as FishingLine
		if line_obj == null:
			line_obj = FishingLineScript.create_default()

		battle.start_battle(
			fishing_data.rod_resource,
			line_obj,
			current_fish,
			skills.get_safe_zone_bonus(),
			skills.get_fish_pull_reduction(),
			rng,
			_equipment_stats
		)
		# Tiêu hao 1 lần mồi câu
		bait_system.consume_bait()
		return true

	return false


func reel(held: bool) -> void:
	fishing_data.is_reeling = held


func release(held: bool) -> void:
	fishing_data.is_releasing = held


func set_pull_strength_factor(factor: float) -> void:
	fishing_data.pull_strength_factor = clampf(factor, 0.5, 1.5)


func cancel() -> void:
	if current_state != FishingStateScript.State.IDLE:
		_end_fishing(FishingStateScript.State.FAILED, "cancel")


## Cập nhật theo từng frame delta
func tick(delta: float) -> void:
	match current_state:
		FishingStateScript.State.WAITING:
			_wait_timer -= delta
			if _wait_timer <= 0.0:
				_trigger_bite()

		FishingStateScript.State.BITE:
			_bite_timer -= delta
			if _bite_timer <= 0.0:
				# Quá thời gian giật cần -> Cá trốn thoát
				_end_fishing(FishingStateScript.State.ESCAPED, "late")

		FishingStateScript.State.FIGHT:
			_process_fighting(delta)


func _trigger_bite() -> void:
	if not _transition_to(FishingStateScript.State.BITE):
		return
	var bonus_win: float = skills.get_bite_window_bonus()
	_bite_timer = BASE_BITE_WINDOW + bonus_win

	if on_fish_bite.is_valid():
		var bite_payload: Dictionary = {
			"spot_id": fishing_data.spot_id,
			"fish_id": current_fish.id,
			"window_seconds": _bite_timer
		}
		var insight: Dictionary = skills.activate_linh_nhan(fishing_data.target_fish_resource)
		if not insight.is_empty():
			bite_payload["linh_nhan"] = insight
		on_fish_bite.call(bite_payload)


func _process_fighting(delta: float) -> void:
	var result: String = battle.update(
		current_fish,
		fishing_data.is_reeling,
		fishing_data.is_releasing,
		fishing_data.pull_strength_factor,
		delta
	)

	# Cập nhật độ bền vào data
	fishing_data.line_durability = battle.line_durability
	fishing_data.rod_durability = battle.rod_durability
	if result != "CONTINUE":
		if fishing_data.rod_resource != null and "current_durability" in fishing_data.rod_resource:
			fishing_data.rod_resource.set("current_durability", int(roundf(battle.rod_durability)))
		if fishing_data.line_resource != null and "current_durability" in fishing_data.line_resource:
			fishing_data.line_resource.set("current_durability", battle.line_durability)

	# Phát cập nhật lực căng & thể lực
	if on_fight_update.is_valid():
		var fish_mode_val: int = battle.fish_ai.current_mode if battle.fish_ai != null else 1
		var fish_max_stam: float = current_fish.stamina if current_fish != null else 100.0
		on_fight_update.call({
			"fish_strength": battle.fish_stamina,
			"fish_max_stamina": fish_max_stam,
			"line_tension": battle.tension_system.current_tension,
			"safe_min": battle.tension_system.safe_min,
			"safe_max": battle.tension_system.safe_max,
			"max_tension": battle.tension_system.max_tension,
			"line_durability": battle.line_durability,
			"rod_durability": battle.rod_durability,
			"fish_mode": fish_mode_val
		})

	match result:
		"CAUGHT":
			_catch_success()
		"LINE_BREAK":
			_end_fishing(FishingStateScript.State.FAILED, "line_break")
		"ROD_BROKEN":
			_end_fishing(FishingStateScript.State.FAILED, "rod_broken")
		"SLACK_ESCAPE":
			_end_fishing(FishingStateScript.State.ESCAPED, "slack")


func _catch_success() -> void:
	if not _transition_to(FishingStateScript.State.CAUGHT):
		return
	var qi_mult: float = skills.get_qi_multiplier()
	var eq_qi: float = float(_equipment_stats.get("total_qi_absorption_bonus", 0.0))
	qi_mult *= (1.0 + eq_qi / 100.0)
	var payload: Dictionary = FishingRewardScript.create_reward_payload(current_fish, qi_mult)

	if on_fish_caught.is_valid():
		on_fish_caught.call(payload)

	# Giải phóng và đưa về IDLE
	_cleanup_and_idle()


func _end_fishing(target_state: int, reason: String) -> void:
	if not _transition_to(target_state):
		return
	if on_fish_lost.is_valid():
		on_fish_lost.call({"reason": reason})

	# Giải phóng và đưa về IDLE
	_cleanup_and_idle()


func _cleanup_and_idle() -> void:
	fishing_data.reset()
	current_fish = null
	_transition_to(FishingStateScript.State.IDLE)


func _transition_to(next_state: int) -> bool:
	if current_state == next_state:
		return true

	# BẮT BUỘC: Kiểm tra chuyển trạng thái hợp lệ
	if not FishingStateScript.can_transition(current_state, next_state):
		push_warning("Chuyển trạng thái bất hợp lệ từ %s sang %s" % [
			FishingStateScript.get_state_name(current_state),
			FishingStateScript.get_state_name(next_state)
		])
		return false

	var from_str: String = FishingStateScript.get_state_name(current_state)
	var to_str: String = FishingStateScript.get_state_name(next_state)
	current_state = next_state

	if on_state_changed.is_valid():
		on_state_changed.call({
			"from_state": from_str,
			"to_state": to_str
		})
	return true

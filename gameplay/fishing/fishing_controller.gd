class_name FishingController
extends RefCounted

## FishingController — Bộ điều khiển trung tâm của module gameplay/fishing/.
## Quản lý toàn bộ 8 trạng thái FSM, điều phối đấu sức, trang bị, kỹ năng và phát sự kiện.

const FishingStateScript: Script = preload("res://gameplay/fishing/core/fishing_state.gd")
const FishingDataScript: Script = preload("res://gameplay/fishing/core/fishing_data.gd")
const FishingCalculatorScript: Script = preload("res://gameplay/fishing/core/fishing_calculator.gd")
const FishDataScript: Script = preload("res://gameplay/fishing/fish/fish_data.gd")
const FishSpawnerScript: Script = preload("res://gameplay/fishing/fish/fish_spawner.gd")
const FishingBattleScript: Script = preload("res://gameplay/fishing/battle/fishing_battle.gd")
const FishingRodScript: Script = preload("res://gameplay/fishing/equipment/fishing_rod.gd")
const FishingLineScript: Script = preload("res://gameplay/fishing/equipment/fishing_line.gd")
const BaitSystemScript: Script = preload("res://gameplay/fishing/equipment/bait_system.gd")
const FishingSkillScript: Script = preload("res://gameplay/fishing/skills/fishing_skill.gd")
const FishingRewardScript: Script = preload("res://gameplay/fishing/rewards/fishing_reward.gd")

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


## Thả câu (CASTING -> WAITING)
func cast(spot: Resource, rod: Resource) -> bool:
	if not FishingStateScript.can_transition(current_state, FishingStateScript.State.CASTING):
		return false
	if spot == null or rod == null:
		return false

	fishing_data.reset()
	fishing_data.spot_resource = spot
	fishing_data.rod_resource = rod
	fishing_data.spot_id = str(spot.get("id"))

	_transition_to(FishingStateScript.State.CASTING)

	# Sinh cá mục tiêu
	var bait_pref := bait_system.preferred_tier if bait_system.remaining_uses > 0 else 0
	var fish_res := FishSpawnerScript.spawn_fish_for_spot(spot, bait_pref, rng)
	fishing_data.target_fish_resource = fish_res
	current_fish = FishDataScript.from_resource(fish_res, rng)

	# Tính thời gian chờ
	var min_w: float = float(spot.get("min_wait_time")) if "min_wait_time" in spot else 2.0
	var max_w: float = float(spot.get("max_wait_time")) if "max_wait_time" in spot else 5.0
	var attraction := bait_system.attraction_power if bait_system.remaining_uses > 0 else 0.0
	_wait_timer = FishingCalculatorScript.calculate_wait_time(
		min_w, max_w, current_fish.rarity, attraction, rng
	)

	_transition_to(FishingStateScript.State.WAITING)
	return true


## Giật cần (WAITING/BITE -> FIGHTING)
func strike() -> bool:
	if current_state == FishingStateScript.State.WAITING:
		# Giật quá sớm trước khi cá cắn -> Thất bại
		_end_fishing(FishingStateScript.State.FAILED, "early")
		return false

	if current_state == FishingStateScript.State.BITE:
		# Giật chuẩn xác -> Bắt đầu đấu sức FIGHTING
		_transition_to(FishingStateScript.State.FIGHTING)
		battle.start_battle(fishing_data.rod_resource, current_fish, rng)
		# Tiêu hao 1 lần dùng mồi
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

		FishingStateScript.State.FIGHTING:
			_process_fighting(delta)


func _trigger_bite() -> void:
	_transition_to(FishingStateScript.State.BITE)
	var bonus_win: float = skills.get_bite_window_bonus()
	_bite_timer = BASE_BITE_WINDOW + bonus_win

	if on_fish_bite.is_valid():
		on_fish_bite.call({
			"spot_id": fishing_data.spot_id,
			"fish_id": current_fish.id,
			"window_seconds": _bite_timer
		})


func _process_fighting(delta: float) -> void:
	var result: String = battle.update(
		current_fish,
		fishing_data.is_reeling,
		fishing_data.is_releasing,
		fishing_data.pull_strength_factor,
		delta
	)

	# Phát cập nhật lực căng & thể lực
	if on_fight_update.is_valid():
		on_fight_update.call({
			"fish_strength": battle.fish_stamina,
			"line_tension": battle.tension_system.current_tension,
			"safe_min": battle.tension_system.safe_min,
			"safe_max": battle.tension_system.safe_max,
			"max_tension": battle.tension_system.max_tension
		})

	match result:
		"CAUGHT":
			_catch_success()
		"LINE_BREAK":
			_end_fishing(FishingStateScript.State.FAILED, "line_break")
		"SLACK_ESCAPE":
			_end_fishing(FishingStateScript.State.ESCAPED, "slack")


func _catch_success() -> void:
	_transition_to(FishingStateScript.State.CAUGHT)
	var qi_mult: float = skills.get_qi_multiplier()
	var payload := FishingRewardScript.create_reward_payload(current_fish, qi_mult)

	if on_fish_caught.is_valid():
		on_fish_caught.call(payload)

	# Tự động trả về IDLE sau khi hoàn tất
	_transition_to(FishingStateScript.State.IDLE)


func _end_fishing(target_state: int, reason: String) -> void:
	_transition_to(target_state)
	if on_fish_lost.is_valid():
		on_fish_lost.call({"reason": reason})
	_transition_to(FishingStateScript.State.IDLE)


func _transition_to(next_state: int) -> void:
	if current_state == next_state:
		return
	var from_str := FishingStateScript.get_state_name(current_state)
	var to_str := FishingStateScript.get_state_name(next_state)
	current_state = next_state

	if on_state_changed.is_valid():
		on_state_changed.call({
			"from_state": from_str,
			"to_state": to_str
		})

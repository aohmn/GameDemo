class_name FishingBattle
extends RefCounted

## Quản lý quá trình giằng co (Fight FSM):
## Đồng bộ giữa TensionSystem, FishAI, sức chịu đựng của cá và độ bền trang bị thực tế.

const TensionSystemScript: Script = preload("res://modules/fishing/gameplay/battle/tension_system.gd")
const ReelDragSystemScript: Script = preload("res://modules/fishing/gameplay/battle/reel_drag_system.gd")
const FishAIScript: Script = preload("res://modules/fishing/gameplay/fish/fish_ai.gd")
const FishingCalculatorScript: Script = preload("res://modules/fishing/gameplay/core/fishing_calculator.gd")
const BattleSkillRunnerScript: Script = preload("res://modules/fishing/gameplay/skills/battle_skill_runner.gd")

var tension_system: TensionSystem
var reel_drag: ReelDragSystem = ReelDragSystemScript.new()
var player_skills: BattleSkillRunner = BattleSkillRunnerScript.new()
var fish_skills: BattleSkillRunner = BattleSkillRunnerScript.new()
var fish_skill_specs: Array[Resource] = []
var fish_ai: FishAI
var fight_time: float = 0.0
var rod_steer: float = 0.0
var rod_bend: float = 0.0
var _twitch_cooldown: float = 0.0
var player_qi: float = 100.0

var fish_hp: float = 100.0
var fish_stamina: float = 100.0
var fish_qi: float = 100.0
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
	player_skills.reset()
	fish_skills.reset()
	fish_skill_specs.clear()
	player_qi = 100.0
	rod_steer = 0.0
	rod_bend = 0.0
	fight_time = 0.0
	fish_hp = fish_data.max_hp
	fish_stamina = fish_data.stamina
	fish_qi = fish_data.max_qi
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
	if _twitch_cooldown > 0.0:
		_twitch_cooldown = maxf(0.0, _twitch_cooldown - delta)

	# Lấy lực kéo từ AI cá (truyền HP, Sức, Nội năng thực tế)
	var ai_res: Dictionary = fish_ai.update_behavior(fish_data, fight_time, fish_hp, fish_stamina, fish_qi, delta)
	var fish_pull: float = float(ai_res.get("pull_force", 0.0)) * pull_reduction

	# Áp dụng hiệu ứng kỹ năng vào lực kéo và lực căng
	player_skills.tick(delta)
	var fs_tick: Dictionary = fish_skills.tick(delta)
	var pull_reduce_mod: float = player_skills.get_effect_multiplier("pull_reduce")
	if pull_reduce_mod > 0.0:
		fish_pull *= maxf(0.1, 1.0 - pull_reduce_mod)
	var fish_surge_mod: float = fish_skills.get_effect_multiplier("fish_surge")
	if fish_surge_mod > 0.0:
		fish_pull *= (1.0 + fish_surge_mod)
	var hp_dmg_mod: float = player_skills.get_effect_multiplier("hp_damage")
	if hp_dmg_mod > 0.0:
		fish_hp = maxf(0.0, fish_hp - hp_dmg_mod * delta * 15.0)
	var line_shock_mod: float = fish_skills.get_effect_multiplier("line_shock")
	if line_shock_mod > 0.0:
		line_durability = maxf(0.0, line_durability - line_shock_mod * delta * 5.0)
	var tension_damp_mod: float = player_skills.get_effect_multiplier("tension_damp")
	if tension_damp_mod > 0.0:
		tension_system.current_tension *= maxf(0.3, 1.0 - tension_damp_mod * 0.5)

	# Cá AI tự dùng kỹ năng khi có đủ nội năng
	_fish_try_skill()

	# Điều hướng cần câu: ghì ngược hướng cá bơi tạo lực cản, thuận hướng giảm căng
	var steer_oppose: float = -rod_steer * float(fish_ai.swim_dir)
	var steer_tension_delta: float = steer_oppose * 8.0 * delta
	tension_system.current_tension = clampf(tension_system.current_tension + steer_tension_delta, 0.0, tension_system.max_tension * 1.1)

	# Cập nhật lực căng (không dùng reel/release trong cơ chế đấu cần mới)
	tension_system.update(
		false,
		false,
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
		var rd_res: Dictionary = reel_drag.update(false, fish_pull, reel_speed, t_ratio, delta)
		var slip: float = float(rd_res.get("slip_speed", 0.0))
		if slip > 0.0:
			tension_system.current_tension = maxf(0.0, tension_system.current_tension - slip * 0.5 * delta)

	# Kiểm tra cá tuột lưỡi do chùng dây quá lâu
	if tension_system.is_fish_slack_escaped():
		return "SLACK_ESCAPE"

	# Tiêu hao thể lực cá (ghì ngược hướng cá bơi tăng tốc độ rút sức)
	var steer_fatigue_mult: float = 1.0 + maxf(0.0, -rod_steer * float(fish_ai.swim_dir)) * 0.45
	var drain: float = FishingCalculatorScript.calculate_fish_stamina_drain(
		tension_system.current_tension,
		tension_system.safe_min,
		tension_system.safe_max,
		fatigue_rate * steer_fatigue_mult,
		fish_data.tenacity,
		delta
	)
	fish_stamina = clampf(fish_stamina - drain, 0.0, fish_data.stamina)

	# HP giảm khi cá kiệt sức (sức < 25% -> HP bị hao)
	if fish_stamina < fish_data.stamina * 0.25:
		var hp_drain: float = (1.0 - fish_stamina / maxf(1.0, fish_data.stamina * 0.25)) * 8.0 * delta
		fish_hp = maxf(0.0, fish_hp - hp_drain)

	# Nội năng hồi phục chậm khi cá còn sức
	if fish_stamina > fish_data.stamina * 0.3:
		fish_qi = minf(fish_data.max_qi, fish_qi + 3.0 * delta)

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

	# Thắng cuộc khi cá mất khả năng chiến đấu (HP hoặc Sức về 0)
	if fish_hp <= 0.0 or fish_stamina <= 0.0:
		return "CAUGHT"

	return "CONTINUE"


func use_player_skill(spec: Resource) -> Dictionary:
	var res: Dictionary = player_skills.try_cast(spec, player_qi)
	if bool(res.get("ok", false)):
		player_qi = float(res.get("qi_left", player_qi))
	return res


func set_fish_skills(specs: Array[Resource]) -> void:
	fish_skill_specs = specs


func trigger_twitch(fish_data: FishData) -> Dictionary:
	if _twitch_cooldown > 0.0:
		return {"ok": false, "reason": "cooldown"}
	_twitch_cooldown = 0.45

	# Giật cần tạo xung lực căng dây; nếu dây đang quá căng có nguy cơ đứt dây
	tension_system.current_tension = minf(tension_system.max_tension * 1.15, tension_system.current_tension + 12.0)

	var tier_mult: float = 1.0 / (1.0 + 0.25 * float(maxi(1, fish_data.tier) - 1))
	var stamina_ratio: float = clampf(fish_stamina / maxf(1.0, fish_data.stamina), 0.0, 1.0)
	var state_mult: float = 1.35 if stamina_ratio < 0.35 else 0.85

	var hp_dmg: float = 10.0 * tier_mult * state_mult
	var stam_dmg: float = 14.0 * tier_mult
	fish_hp = maxf(0.0, fish_hp - hp_dmg)
	fish_stamina = maxf(0.0, fish_stamina - stam_dmg)
	return {"ok": true, "hp_damage": hp_dmg, "stamina_damage": stam_dmg}


func _fish_try_skill() -> void:
	for spec in fish_skill_specs:
		if fish_qi < float(spec.get("qi_cost")) if "qi_cost" in spec else 0.0:
			continue
		var res: Dictionary = fish_skills.try_cast(spec, fish_qi)
		if bool(res.get("ok", false)):
			fish_qi = maxf(0.0, float(res.get("qi_left", fish_qi)))
			break

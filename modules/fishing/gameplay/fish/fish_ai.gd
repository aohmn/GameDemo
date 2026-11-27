class_name FishAI
extends RefCounted

## Trí tuệ nhân tạo (Hành vi) của cá khi đấu sức:
## Mô phỏng chuyển động có hướng, phản kháng theo loài/kích thước/phẩm cấp, HP/Sức/Nội năng.

enum BehaviorMode {
	TIRED,
	NORMAL,
	RUSH,
	REST,
}

enum SwimAction {
	SWIM_SIDE,
	DIVE_DEEP,
	SURFACE,
	TURN,
	JUMP,
	THRASH,
}

var current_mode: int = BehaviorMode.NORMAL
var current_action: int = SwimAction.SWIM_SIDE
var mode_timer: float = 0.0
var pos_x: float = 0.5
var depth: float = 0.45
var swim_dir: int = 1
var rng: RandomNumberGenerator


func _init(random_gen: RandomNumberGenerator) -> void:
	rng = random_gen


## Cập nhật hành vi đầy đủ (tương thích ngược với update_pull_force).
func update_behavior(
	fish_data: FishData,
	fight_time: float,
	cur_hp: float,
	cur_stamina: float,
	_cur_qi: float,
	delta: float
) -> Dictionary:
	if cur_hp <= 0.0:
		current_mode = BehaviorMode.TIRED
		swim_dir = 0
		return {"pull_force": 0.0, "pos_x": pos_x, "depth": depth, "swim_dir": 0, "action": current_action}

	mode_timer -= delta
	if mode_timer <= 0.0:
		_switch_mode(fish_data, cur_stamina)

	var stamina_ratio: float = clampf(cur_stamina / maxf(1.0, fish_data.stamina), 0.0, 1.0)
	var fatigue_mult: float = 0.5 if stamina_ratio < 0.25 else 1.0
	var size_mult: float = clampf(0.85 + float(fish_data.weight_g) / 2000.0, 0.85, 1.8)
	var base_pull: float = fish_data.strength * 0.6 * fatigue_mult * size_mult
	var pulse: float = maxf(0.0, sin(fight_time * (TAU / (1.2 / maxf(0.5, fish_data.swim_speed)))))

	# Cập nhật vị trí & hướng bơi theo hành động
	var move_spd: float = fish_data.swim_speed * 0.22 * (1.35 if current_mode == BehaviorMode.RUSH else 1.0) * fatigue_mult
	pos_x += float(swim_dir) * move_spd * delta
	if pos_x <= 0.1:
		pos_x = 0.1
		swim_dir = 1
		current_action = SwimAction.TURN
	elif pos_x >= 0.9:
		pos_x = 0.9
		swim_dir = -1
		current_action = SwimAction.TURN

	if current_action == SwimAction.DIVE_DEEP:
		depth = minf(0.85, depth + 0.18 * delta)
	elif current_action == SwimAction.SURFACE or current_action == SwimAction.JUMP:
		depth = maxf(0.22, depth - 0.22 * delta)

	var pull: float = base_pull
	match current_mode:
		BehaviorMode.RUSH:
			pull = base_pull * (1.8 + pulse * fish_data.resistance)
		BehaviorMode.NORMAL:
			pull = base_pull * (1.0 + pulse * 0.8)
		BehaviorMode.REST:
			pull = base_pull * 0.2
		BehaviorMode.TIRED:
			pull = base_pull * 0.4

	return {
		"pull_force": pull,
		"pos_x": pos_x,
		"depth": depth,
		"swim_dir": swim_dir,
		"action": current_action,
	}


## Wrapper tương thích ngược
func update_pull_force(fish_data: FishData, fight_time: float, delta: float) -> float:
	var res: Dictionary = update_behavior(fish_data, fight_time, fish_data.max_hp, fish_data.stamina, fish_data.max_qi, delta)
	return float(res.get("pull_force", 0.0))


func _switch_mode(fish_data: FishData, cur_stamina: float) -> void:
	if cur_stamina < fish_data.stamina * 0.25:
		current_mode = BehaviorMode.TIRED
		current_action = SwimAction.SWIM_SIDE
		mode_timer = rng.randf_range(1.2, 2.2)
		return

	var roll: float = rng.randf()
	var rush_chance: float = clampf(0.20 + float(fish_data.tier) * 0.04, 0.20, 0.45)
	if roll < rush_chance:
		current_mode = BehaviorMode.RUSH
		current_action = SwimAction.JUMP if rng.randf() < 0.35 else (SwimAction.THRASH if rng.randf() < 0.5 else SwimAction.DIVE_DEEP)
		mode_timer = rng.randf_range(1.0, 2.2)
	elif roll < 0.65:
		current_mode = BehaviorMode.NORMAL
		current_action = SwimAction.SWIM_SIDE if rng.randf() < 0.6 else SwimAction.SURFACE
		mode_timer = rng.randf_range(1.8, 3.5)
	else:
		current_mode = BehaviorMode.REST
		current_action = SwimAction.SWIM_SIDE
		mode_timer = rng.randf_range(1.0, 1.8)

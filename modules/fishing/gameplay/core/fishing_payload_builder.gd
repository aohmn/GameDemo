extends RefCounted
## Tạo payload FIGHT_UPDATE cho FishingController.


static func build_fight_update(battle: RefCounted, current_fish: RefCounted) -> Dictionary:
	var fish_mode_val: int = battle.fish_ai.current_mode if battle.fish_ai != null else 1
	var fish_max_stam: float = current_fish.stamina if current_fish != null else 100.0
	var fish_max_hp: float = current_fish.max_hp if current_fish != null else 100.0
	var fish_max_qi: float = current_fish.max_qi if current_fish != null else 100.0
	var swim_dir: int = battle.fish_ai.swim_dir if battle.fish_ai != null else 0
	var pos_norm: float = battle.fish_ai.pos_x if battle.fish_ai != null else 0.5
	var depth_norm: float = battle.fish_ai.depth if battle.fish_ai != null else 0.45
	var fish_tele: bool = battle.fish_skills.is_telegraphing() if battle.fish_skills != null else false
	return {
		"fish_hp": battle.fish_hp,
		"fish_max_hp": fish_max_hp,
		"fish_strength": battle.fish_stamina,
		"fish_max_stamina": fish_max_stam,
		"fish_qi": battle.fish_qi,
		"fish_max_qi": fish_max_qi,
		"line_tension": battle.tension_system.current_tension,
		"safe_min": battle.tension_system.safe_min,
		"safe_max": battle.tension_system.safe_max,
		"max_tension": battle.tension_system.max_tension,
		"line_durability": battle.line_durability,
		"rod_durability": battle.rod_durability,
		"fish_mode": fish_mode_val,
		"fish_swim_dir": swim_dir,
		"fish_pos_norm": pos_norm,
		"fish_depth_norm": depth_norm,
		"rod_bend": battle.rod_bend,
		"fish_telegraphing": fish_tele,
	}

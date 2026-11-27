extends Control
## Dev scene: mô phỏng dữ liệu để kiểm thử Fishing Battle UI độc lập.

const BattleUIScript: Script = preload("res://presentation/fishing_battle_ui/fishing_battle_ui.gd")

var _ui: Control
var _t: float = 0.0


func _ready() -> void:
	_ui = BattleUIScript.new()
	add_child(_ui)
	_ui.visible = true


func _process(delta: float) -> void:
	_t += delta
	if _ui == null:
		return
	var sd: int = 1 if sin(_t * 1.3) >= 0.0 else -1
	var pn: float = 0.5 + 0.35 * sin(_t * 1.3)
	var dn: float = 0.45 + 0.15 * sin(_t * 0.7)
	var t_ratio: float = 0.5 + 0.4 * sin(_t * 2.0)
	var tele: bool = fmod(_t, 8.0) > 6.5
	_ui.call("_on_fight_update", {
		"fish_max_hp": 120.0,
		"fish_hp": maxf(0.0, 100.0 - _t * 2.0),
		"fish_max_stamina": 100.0,
		"fish_strength": 60.0 + 20.0 * cos(_t),
		"fish_max_qi": 80.0,
		"fish_qi": fmod(_t * 15.0, 80.0),
		"max_tension": 100.0,
		"line_tension": t_ratio * 100.0,
		"line_durability": maxf(0.0, 90.0 - _t * 0.5),
		"fish_swim_dir": sd,
		"fish_pos_norm": pn,
		"fish_depth_norm": dn,
		"rod_bend": clampf(t_ratio, 0.0, 1.0),
		"fish_telegraphing": tele,
	})

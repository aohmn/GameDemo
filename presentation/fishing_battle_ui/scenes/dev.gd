extends Control
## Scene dev độc lập để kiểm thử màn hình đấu cá mà không cần boot toàn game.

const BattleUIScript: Script = preload("res://presentation/fishing_battle_ui/fishing_battle_ui.gd")

var _battle_ui: Control
var _t: float = 0.0


func _ready() -> void:
	_battle_ui = BattleUIScript.new()
	add_child(_battle_ui)
	_battle_ui.visible = true


func _process(delta: float) -> void:
	_t += delta
	if _battle_ui == null:
		return
	var swim_dir: int = 1 if sin(_t * 1.3) >= 0.0 else -1
	var pos_norm: float = 0.5 + 0.35 * sin(_t * 1.3)
	_battle_ui.call("_on_fight_update", {
		"fish_max_hp": 100.0,
		"fish_hp": 72.0,
		"fish_max_stamina": 100.0,
		"fish_strength": 60.0 + 20.0 * cos(_t),
		"fish_max_qi": 100.0,
		"fish_qi": fmod(_t * 18.0, 100.0),
		"max_tension": 100.0,
		"line_tension": 45.0 + 35.0 * absf(sin(_t * 2.0)),
		"fish_swim_dir": swim_dir,
		"fish_pos_norm": pos_norm,
	})

extends Control
## Scene kiểm thử độc lập cho Camera Dưới Nước (không cần gameplay câu cá).

const CAM_PANEL_SCRIPT: Script = preload("res://presentation/underwater_cam/underwater_cam_panel.gd")

var _panel: Control
var _t: float = 0.0


func _ready() -> void:
	_panel = CAM_PANEL_SCRIPT.new() as Control
	add_child(_panel)
	if _panel.has_method("set_standalone_mode"):
		_panel.call("set_standalone_mode", true)


func _process(delta: float) -> void:
	_t += delta
	if _panel != null and _panel.has_method("apply_fight_update"):
		var pos_norm: float = sin(_t * 0.9) * 0.75
		var depth_norm: float = 0.5 + cos(_t * 0.6) * 0.35
		var swim_dir: int = 1 if cos(_t * 0.9) >= 0.0 else -1
		var tension: float = 50.0 + sin(_t * 1.7) * 40.0
		_panel.call("apply_fight_update", {
			"fish_pos_norm": pos_norm,
			"fish_depth_norm": depth_norm,
			"fish_swim_dir": swim_dir,
			"line_tension": tension,
			"max_tension": 100.0,
			"fish_telegraphing": tension > 82.0,
		})

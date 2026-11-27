class_name ReelDragSystem
extends RefCounted
## Mô phỏng máy câu, lực cản (Drag), thu/xả dây tự động khi cá kéo vượt lực hãm và độ giãn dây.

var drag_level: float = 0.5 # 0.0 -> 1.0
var max_brake_force: float = 40.0
var line_distance: float = 15.0 # mét
var max_distance: float = 60.0
var line_stretch: float = 0.0 # 0.0 -> 1.0


func reset(initial_distance: float = 15.0) -> void:
	drag_level = 0.5
	line_distance = clampf(initial_distance, 1.0, max_distance)
	line_stretch = 0.0


func set_drag(level: float) -> void:
	drag_level = clampf(level, 0.0, 1.0)


func update(is_reeling: bool, fish_pull: float, reel_power: float, tension_ratio: float, delta: float) -> Dictionary:
	var brake_force: float = drag_level * max_brake_force
	var slip_speed: float = 0.0
	if fish_pull > brake_force:
		slip_speed = (fish_pull - brake_force) * 0.25
		line_distance = minf(max_distance, line_distance + slip_speed * delta)
	elif is_reeling:
		line_distance = maxf(0.0, line_distance - reel_power * 0.15 * delta)

	line_stretch = clampf(tension_ratio * (0.6 + drag_level * 0.4), 0.0, 1.0)
	return {
		"line_distance": line_distance,
		"slip_speed": slip_speed,
		"line_stretch": line_stretch,
		"brake_force": brake_force,
	}

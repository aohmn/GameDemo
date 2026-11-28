extends Control
## Scene kiểm thử độc lập cho Joystick đấu cá.

const JOYSTICK_SCRIPT: Script = preload("res://presentation/fishing_joystick/fishing_joystick.gd")

var _label: Label
var _twitch_count: int = 0


func _ready() -> void:
	var joy := JOYSTICK_SCRIPT.new() as Control
	add_child(joy)
	joy.call("set_standalone_mode", true)
	joy.connect("steer_changed", Callable(self, "_on_steer_changed"))
	joy.connect("twitch_triggered", Callable(self, "_on_twitch_triggered"))

	_label = Label.new()
	_label.position = Vector2(24.0, 24.0)
	_label.text = "Steer: 0.00 | Twitch: 0"
	add_child(_label)


func _on_steer_changed(steer_x: float) -> void:
	_label.text = "Steer: %.2f | Twitch: %d" % [steer_x, _twitch_count]


func _on_twitch_triggered() -> void:
	_twitch_count += 1
	_label.text = "Steer: 1.00 | Twitch: %d" % _twitch_count

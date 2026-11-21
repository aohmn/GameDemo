extends Control
class_name PlayerHUD

const PANEL_COLOR := Color(0.025, 0.04, 0.055, 0.90)
const HEALTH_COLOR := Color(0.20, 0.78, 0.38)
const HEALTH_LOW_COLOR := Color(0.88, 0.22, 0.16)
const HUNGER_COLOR := Color(0.91, 0.62, 0.22)
const THIRST_COLOR := Color(0.25, 0.66, 0.90)
const ENERGY_COLOR := Color(0.72, 0.62, 0.88)

var _player: CharacterBody3D
var _needs: Node
var _clock_accumulator: float = 0.0
var _health_ratio: float = 1.0
var _health_text: String = "100 / 100"
var _hunger: float = 100.0
var _thirst: float = 100.0
var _energy: float = 100.0
var _time_text: String = "06:00"
var _day_text: String = "Thứ Hai"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var map_root := get_parent().get_parent()
	_player = map_root.get_node_or_null("Player") as CharacterBody3D
	if is_instance_valid(_player):
		if _player.has_signal("health_changed"):
			_player.connect("health_changed", _on_health_changed)
			_on_health_changed(float(_player.get("current_health")), float(_player.get("maximum_health")))
		_needs = _player.get_node_or_null("Needs")
		if is_instance_valid(_needs):
			_needs.connect("needs_changed", _on_needs_changed)
			var state_value: Variant = _needs.call("get_state")
			if state_value is Dictionary:
				_on_needs_changed(float(state_value.get("hunger", 100.0)), float(state_value.get("thirst", 100.0)), float(state_value.get("energy", 100.0)))
	_create_action_buttons()
	_update_clock()
	queue_redraw()


func _create_action_buttons() -> void:
	var eat_button := Button.new()
	eat_button.text = "ĂN +35"
	eat_button.position = Vector2(8.0, 164.0)
	eat_button.size = Vector2(80.0, 44.0)
	eat_button.focus_mode = Control.FOCUS_NONE
	eat_button.add_theme_font_size_override("font_size", 10)
	eat_button.pressed.connect(_on_eat_pressed)
	add_child(eat_button)

	var drink_button := Button.new()
	drink_button.text = "UỐNG +40"
	drink_button.position = Vector2(98.0, 164.0)
	drink_button.size = Vector2(80.0, 44.0)
	drink_button.focus_mode = Control.FOCUS_NONE
	drink_button.add_theme_font_size_override("font_size", 10)
	drink_button.pressed.connect(_on_drink_pressed)
	add_child(drink_button)

	var rest_button := Button.new()
	rest_button.text = "NGHỈ 1H"
	rest_button.position = Vector2(188.0, 164.0)
	rest_button.size = Vector2(80.0, 44.0)
	rest_button.focus_mode = Control.FOCUS_NONE
	rest_button.add_theme_font_size_override("font_size", 10)
	rest_button.pressed.connect(_on_rest_pressed)
	add_child(rest_button)

func _on_eat_pressed() -> void:
	if is_instance_valid(_needs):
		_needs.call("consume_food", 35.0)


func _on_drink_pressed() -> void:
	if is_instance_valid(_needs):
		_needs.call("drink_water", 40.0)


func _on_rest_pressed() -> void:
	if is_instance_valid(_needs):
		_needs.call("rest", 60)


func _process(delta: float) -> void:
	_clock_accumulator += delta
	if _clock_accumulator >= 0.25:
		_clock_accumulator = 0.0
		_update_clock()
		queue_redraw()


func _on_health_changed(current_health: float, maximum_health: float) -> void:
	var safe_maximum: float = maxf(1.0, maximum_health)
	var safe_current: float = clampf(current_health, 0.0, safe_maximum)
	_health_ratio = safe_current / safe_maximum
	_health_text = "%d / %d" % [roundi(safe_current), roundi(safe_maximum)]
	queue_redraw()


func _on_needs_changed(hunger: float, thirst: float, energy: float) -> void:
	_hunger = clampf(hunger, 0.0, 100.0)
	_thirst = clampf(thirst, 0.0, 100.0)
	_energy = clampf(energy, 0.0, 100.0)
	queue_redraw()


func _update_clock() -> void:
	_time_text = "%02d:%02d" % [GameClock.get_hour(), GameClock.get_minute()]
	var weekday_names: Array[String] = ["Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy", "Chủ Nhật"]
	_day_text = weekday_names[int(GameClock.get_weekday())]


func _draw_bar(position: Vector2, width: float, value: float, color: Color, label_text: String) -> void:
	draw_string(ThemeDB.fallback_font, position + Vector2(0.0, -2.0), label_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 9, Color(0.82, 0.86, 0.85))
	var bar_rect := Rect2(position + Vector2(0.0, 3.0), Vector2(width, 7.0))
	draw_rect(bar_rect, Color(0.15, 0.18, 0.19), true)
	draw_rect(Rect2(bar_rect.position, Vector2(width * value / 100.0, bar_rect.size.y)), color, true)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(276.0, 158.0)), PANEL_COLOR, true)
	draw_rect(Rect2(Vector2.ZERO, Vector2(276.0, 158.0)), Color(0.72, 0.78, 0.78, 0.9), false, 1.2)

	# Avatar vector hình học, không dùng texture.
	draw_circle(Vector2(38.0, 43.0), 27.0, Color(0.16, 0.22, 0.25))
	draw_circle(Vector2(38.0, 36.0), 10.0, Color(0.88, 0.68, 0.52))
	draw_colored_polygon(PackedVector2Array([Vector2(22.0, 61.0), Vector2(26.0, 49.0), Vector2(38.0, 44.0), Vector2(50.0, 49.0), Vector2(54.0, 61.0)]), Color(0.22, 0.43, 0.62))
	draw_arc(Vector2(38.0, 36.0), 10.0, PI, TAU, 16, Color(0.20, 0.14, 0.11), 3.0, true)

	draw_string(ThemeDB.fallback_font, Vector2(76.0, 19.0), "SỨC KHỎE  " + _health_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10, Color.WHITE)
	var health_rect := Rect2(Vector2(76.0, 25.0), Vector2(184.0, 8.0))
	draw_rect(health_rect, Color(0.15, 0.18, 0.19), true)
	draw_rect(Rect2(health_rect.position, Vector2(health_rect.size.x * _health_ratio, health_rect.size.y)), HEALTH_COLOR if _health_ratio > 0.3 else HEALTH_LOW_COLOR, true)

	_draw_bar(Vector2(76.0, 48.0), 184.0, _hunger, HUNGER_COLOR, "ĐÓI  %d%%" % roundi(_hunger))
	_draw_bar(Vector2(76.0, 78.0), 184.0, _thirst, THIRST_COLOR, "KHÁT  %d%%" % roundi(_thirst))
	_draw_bar(Vector2(76.0, 108.0), 184.0, _energy, ENERGY_COLOR, "NĂNG LƯỢNG  %d%%" % roundi(_energy))
	draw_string(ThemeDB.fallback_font, Vector2(16.0, 146.0), _time_text + "  ·  " + _day_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, Color(1.0, 0.86, 0.58))

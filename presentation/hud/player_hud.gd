extends Control
class_name PlayerHUD

const PANEL_COLOR := Color(0.025, 0.04, 0.055, 0.90)
const HEALTH_COLOR := Color(0.20, 0.78, 0.38)
const HEALTH_LOW_COLOR := Color(0.88, 0.22, 0.16)
const HUNGER_COLOR := Color(0.91, 0.62, 0.22)
const THIRST_COLOR := Color(0.25, 0.66, 0.90)
const ENERGY_COLOR := Color(0.72, 0.62, 0.88)
const WEEKDAY_NAMES: Array[String] = ["Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy", "Chủ Nhật"]

var _health_ratio: float = 1.0
var _health_text: String = "100 / 100"
var _hunger: float = 100.0
var _thirst: float = 100.0
var _energy: float = 100.0
var _time_text: String = "06:00"
var _day_text: String = "Thứ Hai"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	EventBus.subscribe(PlayerEvents.HEALTH_CHANGED, _on_health_changed)
	EventBus.subscribe(PlayerEvents.NEEDS_CHANGED, _on_needs_changed)
	EventBus.subscribe(CoreEvents.HOUR_CHANGED, _on_hour_changed)

	_create_action_buttons()

	# UI mới khởi tạo yêu cầu các module phát lại trạng thái hiện tại.
	EventBus.emit_event(PlayerEvents.STATE_SNAPSHOT_REQUESTED)
	EventBus.emit_event(CoreEvents.TIME_SNAPSHOT_REQUESTED)
	queue_redraw()


func _exit_tree() -> void:
	if EventBus != null:
		EventBus.unsubscribe(PlayerEvents.HEALTH_CHANGED, _on_health_changed)
		EventBus.unsubscribe(PlayerEvents.NEEDS_CHANGED, _on_needs_changed)
		EventBus.unsubscribe(CoreEvents.HOUR_CHANGED, _on_hour_changed)


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
	EventBus.emit_event(PlayerEvents.NEEDS_ACTION_REQUESTED, {
		"action": "eat",
		"amount": 35.0
	})


func _on_drink_pressed() -> void:
	EventBus.emit_event(PlayerEvents.NEEDS_ACTION_REQUESTED, {
		"action": "drink",
		"amount": 40.0
	})


func _on_rest_pressed() -> void:
	EventBus.emit_event(PlayerEvents.NEEDS_ACTION_REQUESTED, {
		"action": "rest",
		"amount": 60.0
	})


func _on_health_changed(payload: Dictionary) -> void:
	var current_value: Variant = payload.get("current")
	var maximum_value: Variant = payload.get("maximum")
	if not _is_number(current_value) or not _is_number(maximum_value):
		return
	var safe_maximum: float = maxf(1.0, float(maximum_value))
	var safe_current: float = clampf(float(current_value), 0.0, safe_maximum)
	_health_ratio = safe_current / safe_maximum
	_health_text = "%d / %d" % [roundi(safe_current), roundi(safe_maximum)]
	queue_redraw()


func _on_needs_changed(payload: Dictionary) -> void:
	var hunger_value: Variant = payload.get("hunger")
	var thirst_value: Variant = payload.get("thirst")
	var energy_value: Variant = payload.get("energy")
	if not _is_number(hunger_value) or not _is_number(thirst_value) or not _is_number(energy_value):
		return
	_hunger = clampf(float(hunger_value), 0.0, 100.0)
	_thirst = clampf(float(thirst_value), 0.0, 100.0)
	_energy = clampf(float(energy_value), 0.0, 100.0)
	queue_redraw()


func _on_hour_changed(payload: Dictionary) -> void:
	var hour_value: Variant = payload.get("hour")
	var minute_value: Variant = payload.get("minute")
	var weekday_value: Variant = payload.get("weekday")
	if not _is_number(hour_value) or not _is_number(minute_value) or not _is_number(weekday_value):
		return
	_time_text = "%02d:%02d" % [int(hour_value), int(minute_value)]
	var weekday_index: int = int(weekday_value)
	if weekday_index >= 0 and weekday_index < WEEKDAY_NAMES.size():
		_day_text = WEEKDAY_NAMES[weekday_index]
	queue_redraw()


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


static func _is_number(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT

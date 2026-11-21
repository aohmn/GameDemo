extends Control
class_name PlayerHUD

const PANEL_COLOR := Color(0.025, 0.04, 0.055, 0.88)
const HEALTH_COLOR := Color(0.20, 0.78, 0.38)
const HEALTH_LOW_COLOR := Color(0.88, 0.22, 0.16)

var _player: CharacterBody3D
var _clock_accumulator: float = 0.0
var _health_ratio: float = 1.0
var _health_text: String = "100 / 100"
var _time_text: String = "06:00"
var _day_text: String = "Thứ Hai"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_player = get_parent().get_parent().get_node_or_null("Player") as CharacterBody3D
	if is_instance_valid(_player) and _player.has_signal("health_changed"):
		_player.connect("health_changed", _on_health_changed)
		_on_health_changed(
			float(_player.get("current_health")),
			float(_player.get("maximum_health"))
		)
	_update_clock()
	queue_redraw()


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


func _update_clock() -> void:
	if not is_instance_valid(GameClock):
		return
	_time_text = "%02d:%02d" % [GameClock.get_hour(), GameClock.get_minute()]
	var weekday_names: Array[String] = [
		"Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm",
		"Thứ Sáu", "Thứ Bảy", "Chủ Nhật"
	]
	_day_text = weekday_names[int(GameClock.get_weekday())]


func _draw() -> void:
	var panel_rect := Rect2(Vector2.ZERO, Vector2(244.0, 78.0))
	draw_rect(panel_rect, PANEL_COLOR, true)
	draw_rect(panel_rect, Color(0.72, 0.78, 0.78, 0.9), false, 1.2)

	# Avatar hình học đơn giản, không dùng texture.
	draw_circle(Vector2(39.0, 39.0), 27.0, Color(0.16, 0.22, 0.25))
	draw_circle(Vector2(39.0, 32.0), 10.0, Color(0.88, 0.68, 0.52))
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(23.0, 57.0), Vector2(27.0, 45.0),
			Vector2(39.0, 40.0), Vector2(51.0, 45.0), Vector2(55.0, 57.0)
		]),
		Color(0.22, 0.43, 0.62)
	)
	draw_arc(Vector2(39.0, 32.0), 10.0, PI, TAU, 16, Color(0.20, 0.14, 0.11), 3.0, true)

	draw_string(ThemeDB.fallback_font, Vector2(76.0, 20.0), "SỨC KHỎE", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10, Color(0.78, 0.83, 0.82))
	var bar_rect := Rect2(Vector2(76.0, 28.0), Vector2(154.0, 10.0))
	draw_rect(bar_rect, Color(0.16, 0.19, 0.20), true)
	var fill_color: Color = HEALTH_COLOR if _health_ratio > 0.3 else HEALTH_LOW_COLOR
	draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * _health_ratio, bar_rect.size.y)), fill_color, true)
	draw_string(ThemeDB.fallback_font, Vector2(76.0, 52.0), _health_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(76.0, 69.0), _time_text + "  ·  " + _day_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, Color(1.0, 0.86, 0.58))

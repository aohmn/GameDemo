extends Node
## Tự kiểm tra GameClock và EventBus. Mở tests/game_clock_selftest.tscn rồi chạy scene này.
## Output cuối cùng phải là: [SELFTEST] GameClock: PASS n/n
## Có 5 cảnh báo vàng "GameClock.deserialize" là BÌNH THƯỜNG (đang thử dữ liệu hỏng).

var _passed: int = 0
var _failed: int = 0
var _hour_events: int = 0
var _day_events: int = 0


func _ready() -> void:
	_run_logic()
	await _run_live()
	var total: int = _passed + _failed
	if _failed == 0:
		print("[SELFTEST] GameClock: PASS %d/%d" % [_passed, total])
	else:
		push_error("[SELFTEST] GameClock: FAIL %d/%d" % [_failed, total])


func _check(label: String, condition: bool) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		push_error("[SELFTEST] FAIL: " + label)


func _on_hour_changed(_payload: Dictionary) -> void:
	_hour_events += 1


func _on_day_changed(_payload: Dictionary) -> void:
	_day_events += 1


func _run_logic() -> void:
	var script: GDScript = load("res://core/services/game_clock.gd")
	var clock: Node = script.new()
	EventBus.subscribe(CoreEvents.HOUR_CHANGED, _on_hour_changed)
	EventBus.subscribe(CoreEvents.DAY_CHANGED, _on_day_changed)

	_check("khởi đầu 06:00", clock.get_hour() == 6 and clock.get_minute() == 0)
	_check("khởi đầu ngày 0, thứ hai", clock.get_day_index() == 0 and clock.get_weekday() == 0)

	clock.advance_minutes(90)
	_check("+90 phút = 07:30", clock.get_hour() == 7 and clock.get_minute() == 30)
	_check("phát hour_changed 1 lần", _hour_events == 1)

	var before: int = clock.get_total_minutes()
	clock.advance_minutes(0)
	clock.advance_minutes(-5)
	_check("bỏ qua số phút <= 0", clock.get_total_minutes() == before)

	clock.advance_minutes(990)
	_check("sang ngày 1 lúc 00:00", clock.get_day_index() == 1 and clock.get_hour() == 0 and clock.get_minute() == 0)
	_check("ngày 1 là thứ ba", clock.get_weekday() == 1)
	_check("phát day_changed 1 lần", _day_events == 1)
	_check("tua nhiều giờ chỉ phát 1 hour_changed", _hour_events == 2)

	clock.advance_minutes(6 * 1440)
	_check("sau 7 ngày quay về thứ hai", clock.get_day_index() == 7 and clock.get_weekday() == 0)

	var saved: Dictionary = clock.serialize()
	var other: Node = script.new()
	_check("deserialize dữ liệu hợp lệ", other.deserialize(saved))
	_check("khôi phục đúng total_minutes", other.get_total_minutes() == clock.get_total_minutes())
	_check("chấp nhận số nguyên dạng float", other.deserialize({"version": 1, "total_minutes": 500.0}) and other.get_total_minutes() == 500)

	var keep: int = other.get_total_minutes()
	_check("từ chối thiếu khóa", not other.deserialize({"version": 1}))
	_check("từ chối số âm", not other.deserialize({"version": 1, "total_minutes": -1}))
	_check("từ chối float lẻ", not other.deserialize({"version": 1, "total_minutes": 10.5}))
	_check("từ chối sai kiểu", not other.deserialize({"version": 1, "total_minutes": "abc"}))
	_check("từ chối sai version", not other.deserialize({"version": 99, "total_minutes": 10}))
	_check("dữ liệu hỏng không đổi trạng thái", other.get_total_minutes() == keep)

	other.set_speed(99999.0)
	_check("giới hạn tốc độ tối đa", other.get_speed() == 600.0)
	other.set_speed(-3.0)
	_check("không cho tốc độ âm", other.get_speed() == 0.0)

	EventBus.unsubscribe(CoreEvents.HOUR_CHANGED, _on_hour_changed)
	EventBus.unsubscribe(CoreEvents.DAY_CHANGED, _on_day_changed)
	clock.free()
	other.free()


func _run_live() -> void:
	var start: int = GameClock.get_total_minutes()
	GameClock.set_paused(false)
	GameClock.set_speed(60.0)
	await get_tree().create_timer(1.0).timeout
	var moved: int = GameClock.get_total_minutes() - start
	_check("autoload chạy ~60 phút game/giây (đo được %d)" % moved, moved >= 40 and moved <= 80)
	GameClock.set_paused(true)
	var frozen: int = GameClock.get_total_minutes()
	await get_tree().create_timer(0.5).timeout
	_check("tạm dừng thì thời gian đứng", GameClock.get_total_minutes() == frozen)
	GameClock.set_paused(false)
	GameClock.set_speed(GameClock.DEFAULT_SPEED)

extends Node
## GameClock: nguồn thời gian duy nhất của game (AGENTS §6, README §6.2).
## Thời gian lưu bằng số nguyên phút. Ngày 0 là Thứ Hai, bắt đầu lúc 06:00.
## Phát sự kiện qua EventBus: hour_changed, day_changed.

enum Weekday { MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY }

const MINUTES_PER_HOUR: int = 60
const MINUTES_PER_DAY: int = 1440
const DAYS_PER_WEEK: int = 7
const START_TOTAL_MINUTES: int = 360
const DEFAULT_SPEED: float = 1.0
const MAX_SPEED: float = 600.0
const MAX_MINUTES_PER_FRAME: int = 120
const MAX_TOTAL_MINUTES: int = 1000000000
const SAVE_VERSION: int = 1

var _total_minutes: int = START_TOTAL_MINUTES
var _speed: float = DEFAULT_SPEED
var _paused: bool = false
var _accumulator: float = 0.0


func _process(delta: float) -> void:
	if _paused or _speed <= 0.0:
		return
	_accumulator += delta * _speed
	var whole: int = int(_accumulator)
	if whole <= 0:
		return
	var step: int = mini(whole, MAX_MINUTES_PER_FRAME)
	_accumulator -= float(step)
	advance_minutes(step)


func get_total_minutes() -> int:
	return _total_minutes


func get_day_index() -> int:
	return _div(_total_minutes, MINUTES_PER_DAY)


func get_hour() -> int:
	return _div(_total_minutes % MINUTES_PER_DAY, MINUTES_PER_HOUR)


func get_minute() -> int:
	return _total_minutes % MINUTES_PER_HOUR


func get_weekday() -> Weekday:
	return (get_day_index() % DAYS_PER_WEEK) as Weekday


## Tua thời gian (ví dụ khi ngủ). Chỉ phát tối đa 1 hour_changed và 1 day_changed
## cho mỗi lần gọi, payload có elapsed_minutes để module khác biết đã trôi bao lâu.
func advance_minutes(minutes: int) -> void:
	if minutes <= 0:
		return
	var old_hour_index: int = _div(_total_minutes, MINUTES_PER_HOUR)
	var old_day_index: int = get_day_index()
	_total_minutes += minutes
	var payload: Dictionary = _build_payload(minutes)
	if get_day_index() != old_day_index:
		EventBus.emit_event(CoreEvents.DAY_CHANGED, payload)
	if _div(_total_minutes, MINUTES_PER_HOUR) != old_hour_index:
		EventBus.emit_event(CoreEvents.HOUR_CHANGED, payload)


func set_paused(paused: bool) -> void:
	_paused = paused


func is_paused() -> bool:
	return _paused


func set_speed(minutes_per_real_second: float) -> void:
	_speed = clampf(minutes_per_real_second, 0.0, MAX_SPEED)


func get_speed() -> float:
	return _speed


func serialize() -> Dictionary:
	return {"version": SAVE_VERSION, "total_minutes": _total_minutes}


## Trả về false và KHÔNG đổi trạng thái nếu dữ liệu không hợp lệ.
## Chấp nhận số nguyên dạng float (JSON trả số về dạng float).
func deserialize(data: Dictionary) -> bool:
	if not data.has("version") or not data.has("total_minutes"):
		push_warning("GameClock.deserialize: thiếu khóa version hoặc total_minutes")
		return false
	var version: int = _read_whole_int(data["version"])
	var total: int = _read_whole_int(data["total_minutes"])
	if version != SAVE_VERSION:
		push_warning("GameClock.deserialize: version không hỗ trợ")
		return false
	if total < 0 or total > MAX_TOTAL_MINUTES:
		push_warning("GameClock.deserialize: total_minutes ngoài giới hạn hoặc sai kiểu")
		return false
	_total_minutes = total
	_accumulator = 0.0
	return true


func _build_payload(elapsed_minutes: int) -> Dictionary:
	return {
		"total_minutes": _total_minutes,
		"day_index": get_day_index(),
		"hour": get_hour(),
		"minute": get_minute(),
		"weekday": get_weekday(),
		"elapsed_minutes": elapsed_minutes,
	}


static func _div(a: int, b: int) -> int:
	return floori(float(a) / float(b))


static func _read_whole_int(value: Variant) -> int:
	if typeof(value) == TYPE_INT:
		return int(value)
	if typeof(value) == TYPE_FLOAT and float(value) == floorf(float(value)):
		return int(value)
	return -1

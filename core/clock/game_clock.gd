extends Node

## Đồng hồ thời gian trò chơi (Autoload).
## Quản lý giờ trong ngày, tốc độ trôi thời gian và phát tín hiệu giờ mới.

signal hour_changed(new_hour: int)
signal day_changed(new_day: int)

# Giờ trong ngày (0.0 đến 24.0)
var current_time: float = 8.0

# Tốc độ thời gian: số giờ trong game tương ứng với 1 giây ngoài đời thực.
# Mặc định 0.1 (1 giờ game = 10 giây thực, 1 ngày 24h = 240 giây).
var time_speed: float = 0.1

# Số ngày đã trôi qua
var current_day: int = 1

# Thời tiết hiện tại (nang, mua, gio, bao, linh_trieu, trang_tron)
var current_weather: String = "nang"

# Theo dõi giờ nguyên gần nhất để phát signal
var _last_int_hour: int = 8


func _process(delta: float) -> void:
	if time_speed <= 0.0:
		return

	current_time += delta * time_speed
	if current_time >= 24.0:
		var days_passed: int = int(floorf(current_time / 24.0))
		current_day += days_passed
		current_time = fmod(current_time, 24.0)
		day_changed.emit(current_day)

	var hour_int: int = int(floorf(current_time))
	if hour_int != _last_int_hour:
		_last_int_hour = hour_int
		hour_changed.emit(hour_int)


## Đặt thời gian trong ngày trực tiếp (0.0 đến 24.0).
func set_time(hour: float) -> void:
	current_time = clampf(hour, 0.0, 24.0)
	_last_int_hour = int(floorf(current_time))
	hour_changed.emit(_last_int_hour)


## Lấy giờ nguyên hiện tại (0..23).
func get_hour() -> int:
	return int(floorf(current_time))


## Lấy chuỗi định dạng giờ:phút hiển thị (tiếng Việt).
func get_formatted_time() -> String:
	var total_minutes: int = int(floorf(current_time * 60.0))
	var hours: int = (total_minutes / 60) % 24
	var mins: int = total_minutes % 60
	return "%02d:%02d" % [hours, mins]


## Trả về buổi trong ngày: binh_minh (5-7), ngay (7-17), hoang_hon (17-19), dem (19-5).
func get_time_period() -> String:
	if current_time >= 5.0 and current_time < 7.0:
		return "binh_minh"
	if current_time >= 7.0 and current_time < 17.0:
		return "ngay"
	if current_time >= 17.0 and current_time < 19.0:
		return "hoang_hon"
	return "dem"


func is_night() -> bool:
	return get_time_period() == "dem"


func get_weather() -> String:
	return current_weather


func set_weather(weather: String) -> void:
	if not weather.is_empty():
		current_weather = weather

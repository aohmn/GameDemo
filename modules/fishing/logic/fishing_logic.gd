class_name FishingLogic
extends RefCounted

## Bộ xử lý logic trạng thái câu cá thuần (không gắn trực tiếp node scene).
## Sử dụng RNG có thể nhận seed để tái lập kết quả thử nghiệm.

const FishingEventsContract: Script = preload("res://core/contracts/fishing_events.gd")
const FishSpecScript: Script = preload("res://modules/fishing/data/fish_spec.gd")
const RodSpecScript: Script = preload("res://modules/fishing/data/rod_spec.gd")
const SpotSpecScript: Script = preload("res://modules/fishing/data/spot_spec.gd")

enum State {
	IDLE,
	CASTING,
	WAITING,
	BITE,
	FIGHT,
	RESULT
}

const STATE_NAMES: Dictionary = {
	State.IDLE: "IDLE",
	State.CASTING: "CASTING",
	State.WAITING: "WAITING",
	State.BITE: "BITE",
	State.FIGHT: "FIGHT",
	State.RESULT: "RESULT"
}

const BITE_WINDOW_DURATION: float = 0.8 
const PULSE_INTERVAL: float = 1.2       # Chu kỳ nhịp xung cá giật kéo

# Callbacks nhận tín hiệu từ logic
var on_state_changed: Callable
var on_fish_bite: Callable
var on_fight_update: Callable
var on_fish_caught: Callable
var on_fish_lost: Callable

var current_state: int = State.IDLE
var current_spot: Resource
var current_rod: Resource
var targeted_fish: Resource

var rng: RandomNumberGenerator

var _wait_timer: float = 0.0
var _bite_timer: float = 0.0
var _fight_time: float = 0.0

var _fish_strength: float = 0.0
var _line_tension: float = 40.0
var _is_reeling: bool = false
var _is_releasing: bool = false


func _init(seed_val: int = -1) -> void:
	rng = RandomNumberGenerator.new()
	if seed_val >= 0:
		rng.seed = seed_val
	else:
		rng.randomize()


func set_seed(seed_val: int) -> void:
	rng.seed = seed_val


func get_state_name() -> String:
	return str(STATE_NAMES.get(current_state, "UNKNOWN"))


func cast(spot: Resource, rod: Resource) -> bool:
	if current_state != State.IDLE and current_state != State.RESULT:
		return false

	if spot == null or rod == null:
		return false

	current_spot = spot
	current_rod = rod
	targeted_fish = null
	_line_tension = 40.0
	_is_reeling = false
	_is_releasing = false

	_change_state(State.CASTING)

	# Chọn cá theo tỷ lệ trong SpotSpec
	targeted_fish = _roll_fish(current_spot)

	# Thời gian chờ ngẫu nhiên theo SpotSpec và độ hiếm cá
	var min_w: float = float(current_spot.get("min_wait_time"))
	var max_w: float = float(current_spot.get("max_wait_time"))
	var base_wait: float = rng.randf_range(min_w, max_w)
	var rarity_bonus: float = 0.0
	if targeted_fish != null:
		var rarity: int = int(targeted_fish.get("rarity"))
		rarity_bonus = float(rarity - 1) * 0.75
	_wait_timer = base_wait + rarity_bonus

	_change_state(State.WAITING)
	return true


func strike() -> bool:
	if current_state == State.WAITING:
		# Giật quá sớm trước khi cá cắn
		_lose_fish("early")
		return false

	if current_state == State.BITE:
		# Giật đúng lúc trong cửa sổ 0.8s -> Chuyển sang giằng co FIGHT
		_start_fight()
		return true

	return false


func reel(held: bool) -> void:
	_is_reeling = held


func release(held: bool) -> void:
	_is_releasing = held


func cancel() -> void:
	if current_state != State.IDLE:
		_lose_fish("cancel")


func tick(delta: float) -> void:
	match current_state:
		State.WAITING:
			_wait_timer -= delta
			if _wait_timer <= 0.0:
				_trigger_bite()

		State.BITE:
			_bite_timer -= delta
			if _bite_timer <= 0.0:
				# Quá thời gian 0.8s mà không giật -> trễ
				_lose_fish("late")

		State.FIGHT:
			_process_fight(delta)


func _trigger_bite() -> void:
	_change_state(State.BITE)
	_bite_timer = BITE_WINDOW_DURATION
	var fish_id: String = ""
	var spot_id: String = ""
	if targeted_fish != null:
		fish_id = str(targeted_fish.get("id"))
	if current_spot != null:
		spot_id = str(current_spot.get("id"))

	if on_fish_bite.is_valid():
		on_fish_bite.call({
			"spot_id": spot_id,
			"fish_id": fish_id,
			"window_seconds": BITE_WINDOW_DURATION
		})


func _start_fight() -> void:
	_change_state(State.FIGHT)
	_fight_time = 0.0
	if targeted_fish != null:
		_fish_strength = float(targeted_fish.get("strength"))
	else:
		_fish_strength = 30.0

	var s_min: float = float(current_rod.get("safe_tension_min"))
	var s_max: float = float(current_rod.get("safe_tension_max"))
	_line_tension = (s_min + s_max) * 0.5


func _process_fight(delta: float) -> void:
	_fight_time += delta
	var max_t: float = float(current_rod.get("max_tension"))
	var safe_min: float = float(current_rod.get("safe_tension_min"))
	var safe_max: float = float(current_rod.get("safe_tension_max"))
	var r_speed: float = float(current_rod.get("reel_speed"))
	var rel_speed: float = float(current_rod.get("release_speed"))
	var fatigue: float = float(current_rod.get("fatigue_rate"))

	# Điều khiển người chơi
	if _is_reeling and not _is_releasing:
		_line_tension += r_speed * delta
	elif _is_releasing and not _is_reeling:
		_line_tension -= rel_speed * delta
	else:
		# Dây chùng tự nhiên
		_line_tension -= (rel_speed * 0.3) * delta

	# Cá giãy theo nhịp xung (sin wave)
	var pull_force: float = 20.0
	if targeted_fish != null:
		pull_force = float(targeted_fish.get("pull_force"))
	var pulse: float = maxf(0.0, sin(_fight_time * (TAU / PULSE_INTERVAL)))
	_line_tension += pulse * pull_force * delta

	# Nếu tension nằm trong vùng an toàn, sức cá giảm dần
	if _line_tension >= safe_min and _line_tension <= safe_max:
		_fish_strength -= fatigue * delta
	else:
		# Ngoài vùng an toàn, cá hồi phục một phần sức (tối đa bằng sức chịu đựng ban đầu của cá)
		var max_strength: float = 30.0
		if targeted_fish != null:
			max_strength = float(targeted_fish.get("strength"))
		_fish_strength = minf(max_strength, _fish_strength + (fatigue * 0.15) * delta)

	_line_tension = maxf(0.0, _line_tension)

	# Phát fight_update
	if on_fight_update.is_valid():
		on_fight_update.call({
			"fish_strength": maxf(0.0, _fish_strength),
			"line_tension": _line_tension,
			"safe_min": safe_min,
			"safe_max": safe_max,
			"max_tension": max_t
		})

	# Kiểm tra điều kiện đứt dây (line_break)
	if _line_tension > max_t:
		_lose_fish("line_break")
		return

	# Kiểm tra điều kiện câu thành công
	if _fish_strength <= 0.0:
		_catch_fish()


func _catch_fish() -> void:
	_change_state(State.RESULT)
	var fish_id: String = "unknown"
	var fish_name: String = "Cá Vô Danh"
	var weight: int = 100
	if targeted_fish != null:
		fish_id = str(targeted_fish.get("id"))
		fish_name = str(targeted_fish.get("display_name"))
		var w_min: int = int(targeted_fish.get("min_weight_g"))
		var w_max: int = int(targeted_fish.get("max_weight_g"))
		weight = rng.randi_range(w_min, w_max)

	var payload: Dictionary = {
		"fish_id": fish_id,
		"weight_g": weight,
		"name": fish_name
	}

	if on_fish_caught.is_valid():
		on_fish_caught.call(payload)


func _lose_fish(reason: String) -> void:
	_change_state(State.RESULT)
	var payload: Dictionary = {
		"reason": reason
	}

	if on_fish_lost.is_valid():
		on_fish_lost.call(payload)


func _change_state(next_state: int) -> void:
	if current_state == next_state:
		return
	var from_str: String = str(STATE_NAMES.get(current_state, ""))
	var to_str: String = str(STATE_NAMES.get(next_state, ""))
	current_state = next_state

	if on_state_changed.is_valid():
		on_state_changed.call({
			"from_state": from_str,
			"to_state": to_str
		})


func _roll_fish(spot: Resource) -> Resource:
	var table: Array = spot.get("fish_table") as Array
	if table == null or table.is_empty():
		return null

	var total_weight: int = 0
	for entry in table:
		total_weight += int(entry.get("weight", 1))

	var roll: int = rng.randi_range(1, total_weight)
	var accumulated: int = 0
	for entry in table:
		accumulated += int(entry.get("weight", 1))
		if roll <= accumulated:
			return entry.get("fish") as Resource

	return table[0].get("fish") as Resource

class_name FishingAPI
extends RefCounted

## Giao diện lập trình (API) công khai của module câu cá.
## Tích hợp động cơ modules/fishing/gameplay/FishingController mới làm lõi xử lý,
## giữ nguyên vẹn 100% hợp đồng FishingEvents với EventBus và UI hiện hành.

const FishingEventsContract: Script = preload("res://core/contracts/fishing_events.gd")
const FishingControllerScript: Script = preload("res://modules/fishing/gameplay/fishing_controller.gd")
const FishSpawnerScript: Script = preload("res://modules/fishing/gameplay/fish/fish_spawner.gd")

var _controller: FishingController
var _spots: Dictionary = {}
var _rods: Dictionary = {}
var _default_rod_id: String = "rod_truc_nhiem"
var _realm_provider: Callable = Callable() # trả về chỉ số cảnh giới hiện tại (int), do Bootstrap gắn
var _equipment_stats_provider: Callable = Callable() # trả về Dictionary stats từ EquipmentAPI
var _equipped_line_provider: Callable = Callable() # trả về Resource dây câu đang trang bị
var _line_durability_consumer: Callable = Callable() # nhận float độ bền đã tiêu hao
var _last_cast_line_durability: float = -1.0


func _init(seed_val: int = -1) -> void:
	_controller = FishingControllerScript.new(seed_val)
	_setup_callbacks()
	_load_default_resources()


func set_seed(seed_val: int) -> void:
	if _controller != null:
		_controller.set_seed(seed_val)


func register_spot(spot: Resource) -> void:
	if spot != null:
		var s_id: String = str(spot.get("id"))
		if not s_id.is_empty():
			_spots[s_id] = spot


func register_rod(rod: Resource) -> void:
	if rod != null:
		var r_id: String = str(rod.get("id"))
		if not r_id.is_empty():
			_rods[r_id] = rod


func get_all_rods() -> Array[Resource]:
	var out: Array[Resource] = []
	for r in _rods.values():
		out.append(r as Resource)
	return out


## Bootstrap gắn nguồn cảnh giới (ví dụ Cultivation.get_current_realm_index). Chưa gắn = cảnh giới 0.
func set_realm_provider(provider: Callable) -> void:
	_realm_provider = provider


func set_equipment_stats_provider(provider: Callable) -> void:
	_equipment_stats_provider = provider
func set_equipped_line_provider(provider: Callable) -> void:
	_equipped_line_provider = provider
func set_line_durability_consumer(consumer: Callable) -> void:
	_line_durability_consumer = consumer


func _get_equipped_line() -> Resource:
	if _equipped_line_provider.is_valid():
		return _equipped_line_provider.call() as Resource
	return null


func _sync_line_durability_after_fishing() -> void:
	if _last_cast_line_durability >= 0.0 and _line_durability_consumer.is_valid() and _controller != null:
		var used: float = maxf(0.0, _last_cast_line_durability - _controller.fishing_data.line_durability)
		if used > 0.0:
			_line_durability_consumer.call(used)
	_last_cast_line_durability = -1.0


func _get_equipment_stats() -> Dictionary:
	if _equipment_stats_provider.is_valid():
		return _equipment_stats_provider.call() as Dictionary
	return {}


func _current_realm() -> int:
	if _realm_provider.is_valid():
		return int(_realm_provider.call())
	return 0


func _deny_cast(reason: String, required: Variant, current: Variant) -> bool:
	_emit_event(FishingEventsContract.CAST_DENIED, {"reason": reason, "required": required, "current": current})
	return false


func _current_time_period() -> String:
	var ml: MainLoop = Engine.get_main_loop()
	if ml is SceneTree:
		var gc: Node = (ml as SceneTree).root.get_node_or_null("GameClock")
		if gc != null and gc.has_method("get_time_period"):
			return str(gc.call("get_time_period"))
	return "ngay"


func _current_weather() -> String:
	var ml: MainLoop = Engine.get_main_loop()
	if ml is SceneTree:
		var gc: Node = (ml as SceneTree).root.get_node_or_null("GameClock")
		if gc != null and gc.has_method("get_weather"):
			return str(gc.call("get_weather"))
	return "nang"


func set_default_rod(rod_id: String) -> void:
	if _rods.has(rod_id):
		_default_rod_id = rod_id


func repair_rod(rod_id: String = "") -> bool:
	var target_id: String = _default_rod_id if rod_id.is_empty() else rod_id
	var rod: Resource = _rods.get(target_id, null)
	if rod == null:
		return false
	if "max_durability" in rod and "current_durability" in rod:
		rod.set("current_durability", int(rod.get("max_durability")))
		return true
	return false


func get_state() -> String:
	if _controller != null:
		return _controller.get_state_name()
	return "UNKNOWN"


## Quăng câu vào điểm câu cá spot_id
func cast(spot_id: String = "spot_cau_tau_ben_cang") -> bool:
	if not _spots.has(spot_id):
		push_warning("Điểm câu không tồn tại: " + spot_id)
		return false

	var spot: Resource = _spots[spot_id]
	var rod: Resource = _rods.get(_default_rod_id, null)
	if rod == null and not _rods.is_empty():
		rod = _rods.values()[0]

	if rod == null:
		push_warning("Không có cần câu khả dụng.")
		return false

	var realm: int = _current_realm()
	var spot_req: int = int(spot.get("required_realm_level")) if "required_realm_level" in spot else 0
	if realm < spot_req:
		return _deny_cast("spot_realm", spot_req, realm)
	var rod_req: int = int(rod.get("required_realm_level")) if "required_realm_level" in rod else 0
	if realm < rod_req:
		return _deny_cast("rod_realm", rod_req, realm)
	if "current_durability" in rod and int(rod.get("current_durability")) <= 0:
		return _deny_cast("rod_broken", 1, 0)

	var cur_time: String = _current_time_period()
	var spot_time: String = str(spot.get("time_condition")) if "time_condition" in spot else "tat_ca"
	if not FishSpawnerScript.matches_condition(spot_time, cur_time):
		return _deny_cast("time_condition", spot_time, cur_time)
	var cur_weather: String = _current_weather()
	var spot_weather: String = str(spot.get("weather_condition")) if "weather_condition" in spot else "tat_ca"
	if not FishSpawnerScript.matches_condition(spot_weather, cur_weather):
		return _deny_cast("weather_condition", spot_weather, cur_weather)

	var eq_stats: Dictionary = _get_equipment_stats()
	var line_res: Resource = _get_equipped_line()
	_last_cast_line_durability = float(line_res.get("current_durability")) if line_res != null and "current_durability" in line_res else (float(line_res.get("durability")) if line_res != null and "durability" in line_res else -1.0)
	_controller.skills.sync_with_realm(realm)
	var success: bool = _controller.cast(spot, rod, line_res, eq_stats, cur_time, cur_weather)
	if not success and _controller.get_state_name() == "IDLE":
		return _deny_cast("no_fish_for_rod", 0, realm)
	if success:
		_emit_event(FishingEventsContract.CAST_STARTED, {
			"spot_id": spot_id,
			"rod_id": str(rod.get("id"))
		})
	return success


## Giật cần khi cá cắn câu
func strike() -> bool:
	return _controller.strike()


## Kéo dây cước (giữ reel)
func reel(held: bool) -> void:
	_controller.reel(held)


## Điều hướng cần câu trái/phải (-1.0 -> 1.0)
func set_rod_steer(dir: float) -> void:
	_controller.set_rod_steer(dir)


## Giật nhẹ cần câu (twitch) khi đang giằng co
func trigger_twitch() -> Dictionary:
	return _controller.trigger_twitch()


## Điều chỉnh lực cản máy câu (0.0 -> 1.0)
func set_drag(level: float) -> void:
	_controller.set_drag(level)


## Sử dụng kỹ năng tu tiên trong trận (Resource BattleSkillSpec)
func use_battle_skill(spec: Resource) -> Dictionary:
	return _controller.use_battle_skill(spec)


## Gán danh sách kỹ năng cá cho trận đấu
func set_fish_skills(specs: Array[Resource]) -> void:
	_controller.set_fish_skills(specs)


## Xả dây cước (giữ release)
func release(held: bool) -> void:
	_controller.release(held)


## Điều chỉnh lực kéo thời gian thực (0.5 đến 1.5)
func set_pull_strength_factor(factor: float) -> void:
	_controller.set_pull_strength_factor(factor)


## Hủy bỏ lần câu hiện tại
func cancel() -> void:
	_controller.cancel()


## Cập nhật theo thời gian (frame time)
func tick(delta: float) -> void:
	_controller.tick(delta)


## Cung cấp quyền truy cập kỹ năng câu cá cho tu luyện
func get_skills() -> RefCounted:
	return _controller.skills


## Trả về danh sách 5 kỹ năng đã đồng bộ mở khóa theo cảnh giới hiện tại.
func get_skills_info() -> Dictionary:
	var realm: int = _current_realm()
	return {
		"realm": realm,
		"skills": _controller.skills.get_skills_summary(realm)
	}


## Cung cấp quyền thiết lập mồi câu cho túi đồ / trang bị
func get_bait_system() -> RefCounted:
	return _controller.bait_system


func _setup_callbacks() -> void:
	_controller.on_state_changed = Callable(self, "_on_state_changed")
	_controller.on_fish_bite = Callable(self, "_on_fish_bite")
	_controller.on_fight_update = Callable(self, "_on_fight_update")
	_controller.on_fish_caught = Callable(self, "_on_fish_caught")
	_controller.on_fish_lost = Callable(self, "_on_fish_lost")


func _on_state_changed(payload: Dictionary) -> void:
	_emit_event(FishingEventsContract.STATE_CHANGED, payload)


func _on_fish_bite(payload: Dictionary) -> void:
	_emit_event(FishingEventsContract.FISH_BITING, payload)


func _on_fight_update(payload: Dictionary) -> void:
	_emit_event(FishingEventsContract.FIGHT_UPDATE, payload)


func _on_fish_caught(payload: Dictionary) -> void:
	_sync_line_durability_after_fishing()
	_emit_event(FishingEventsContract.FISH_CAUGHT, payload)


func _on_fish_lost(payload: Dictionary) -> void:
	_sync_line_durability_after_fishing()
	_emit_event(FishingEventsContract.FISH_ESCAPED, payload)


const ResourceLoaderScript: Script = preload("res://modules/fishing/api/fishing_resource_loader.gd")


func _emit_event(event_name: String, payload: Dictionary) -> void:
	ResourceLoaderScript.emit_event(event_name, payload)


func _load_default_resources() -> void:
	ResourceLoaderScript.load_defaults(self)

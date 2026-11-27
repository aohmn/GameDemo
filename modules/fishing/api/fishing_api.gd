class_name FishingAPI
extends RefCounted

## Giao diện lập trình (API) công khai của module câu cá.
## Tích hợp động cơ modules/fishing/gameplay/FishingController mới làm lõi xử lý,
## giữ nguyên vẹn 100% hợp đồng FishingEvents với EventBus và UI hiện hành.

const FishingEventsContract: Script = preload("res://core/contracts/fishing_events.gd")
const FishingControllerScript: Script = preload("res://modules/fishing/gameplay/fishing_controller.gd")

var _controller: FishingController
var _spots: Dictionary = {}
var _rods: Dictionary = {}
var _default_rod_id: String = "rod_truc_nhiem"
var _realm_provider: Callable = Callable() # trả về chỉ số cảnh giới hiện tại (int), do Bootstrap gắn
var _equipment_stats_provider: Callable = Callable() # trả về Dictionary stats từ EquipmentAPI


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


## Bootstrap gắn nguồn cảnh giới (ví dụ Cultivation.get_current_realm_index). Chưa gắn = cảnh giới 0.
func set_realm_provider(provider: Callable) -> void:
	_realm_provider = provider


## Bootstrap gắn nguồn chỉ số trang bị (EquipmentAPI.calculate_total_stats). Chưa gắn = không bonus.
func set_equipment_stats_provider(provider: Callable) -> void:
	_equipment_stats_provider = provider


func _get_equipment_stats() -> Dictionary:
	if _equipment_stats_provider.is_valid():
		return _equipment_stats_provider.call() as Dictionary
	return {}


func _current_realm() -> int:
	if _realm_provider.is_valid():
		return int(_realm_provider.call())
	return 0


func _deny_cast(reason: String, required: int, current: int) -> bool:
	_emit_event(FishingEventsContract.CAST_DENIED, {"reason": reason, "required": required, "current": current})
	return false


func set_default_rod(rod_id: String) -> void:
	if _rods.has(rod_id):
		_default_rod_id = rod_id


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

	var eq_stats: Dictionary = _get_equipment_stats()
	var success: bool = _controller.cast(spot, rod, null, eq_stats)
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
	_emit_event(FishingEventsContract.FISH_CAUGHT, payload)


func _on_fish_lost(payload: Dictionary) -> void:
	_emit_event(FishingEventsContract.FISH_ESCAPED, payload)


func _emit_event(event_name: String, payload: Dictionary) -> void:
	var main_loop: MainLoop = Engine.get_main_loop()
	if main_loop is SceneTree:
		var st := main_loop as SceneTree
		if st.root != null and st.root.has_node("EventBus"):
			var eb: Node = st.root.get_node("EventBus")
			if eb != null and eb.has_method("emit_event"):
				eb.call("emit_event", event_name, payload)


func _load_default_resources() -> void:
	var r_paths: Array[String] = [
		"res://modules/fishing/data/resources/rod_truc_nhiem.tres",
		"res://modules/fishing/data/resources/rod_carbon_bien_sau.tres"
	]
	for p in r_paths:
		if ResourceLoader.exists(p):
			var r: Resource = load(p)
			register_rod(r)

	var s_paths: Array[String] = [
		"res://modules/fishing/data/resources/spot_cau_tau_ben_cang.tres",
		"res://modules/fishing/data/resources/spot_ho_linh_ngu.tres"
	]
	for p in s_paths:
		if ResourceLoader.exists(p):
			var s: Resource = load(p)
			register_spot(s)

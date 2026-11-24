class_name FishingAPI
extends RefCounted

## Giao diện lập trình (API) công khai của module câu cá (modules/fishing/).
## Kết nối FishingLogic với EventBus và chuyển tiếp các hành vi thao tác của người chơi.

const FishingEventsContract: Script = preload("res://core/contracts/fishing_events.gd")
const FishingLogicScript: Script = preload("res://modules/fishing/logic/fishing_logic.gd")

var _logic: RefCounted
var _spots: Dictionary = {}
var _rods: Dictionary = {}
var _default_rod_id: String = "rod_truc_nhiem"


func _init(seed_val: int = -1) -> void:
	_logic = FishingLogicScript.new(seed_val)
	_setup_callbacks()
	_load_default_resources()


func set_seed(seed_val: int) -> void:
	if _logic != null and _logic.has_method("set_seed"):
		_logic.call("set_seed", seed_val)


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


func set_default_rod(rod_id: String) -> void:
	if _rods.has(rod_id):
		_default_rod_id = rod_id


func get_state() -> String:
	if _logic != null and _logic.has_method("get_state_name"):
		return str(_logic.call("get_state_name"))
	return "UNKNOWN"


## Quăng câu vào điểm câu cá spot_id.
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

	var success: bool = bool(_logic.call("cast", spot, rod))
	if success:
		_emit_event(FishingEventsContract.CAST_STARTED, {
			"spot_id": spot_id,
			"rod_id": str(rod.get("id"))
		})
	return success


## Giật cần khi cá cắn câu.
func strike() -> bool:
	return bool(_logic.call("strike"))


## Kéo dây cước (giữ reel).
func reel(held: bool) -> void:
	_logic.call("reel", held)


## Xả dây cước (giữ release).
func release(held: bool) -> void:
	_logic.call("release", held)


## Hủy bỏ lần câu hiện tại.
func cancel() -> void:
	_logic.call("cancel")


## Cập nhật theo thời gian (frame time).
func tick(delta: float) -> void:
	_logic.call("tick", delta)


func _setup_callbacks() -> void:
	_logic.set("on_state_changed", Callable(self, "_on_state_changed"))
	_logic.set("on_fish_bite", Callable(self, "_on_fish_bite"))
	_logic.set("on_fight_update", Callable(self, "_on_fight_update"))
	_logic.set("on_fish_caught", Callable(self, "_on_fish_caught"))
	_logic.set("on_fish_lost", Callable(self, "_on_fish_lost"))


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

	var s_path: String = "res://modules/fishing/data/resources/spot_cau_tau_ben_cang.tres"
	if ResourceLoader.exists(s_path):
		var s: Resource = load(s_path)
		register_spot(s)

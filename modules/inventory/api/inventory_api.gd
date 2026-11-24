class_name InventoryAPI
extends RefCounted

## Giao diện lập trình (API) công khai của module túi đồ (modules/inventory/).
## Độc lập hoàn toàn với Fishing module; kết nối và trao đổi qua EventBus.

const InventoryEventsContract: Script = preload("res://core/contracts/inventory_events.gd")
const FishingEventsContract: Script = preload("res://core/contracts/fishing_events.gd")
const InventoryLogicScript: Script = preload("res://modules/inventory/logic/inventory_logic.gd")

var _logic: RefCounted
var _listening: bool = false


func _init() -> void:
	_logic = InventoryLogicScript.new()
	_setup_callbacks()
	start_listening()


## Bắt đầu lắng nghe sự kiện từ EventBus.
func start_listening() -> void:
	if _listening:
		return
	var eb: Node = _get_event_bus()
	if eb != null and eb.has_method("subscribe"):
		eb.call("subscribe", FishingEventsContract.FISH_CAUGHT, _on_fish_caught_event)
		_listening = true


## Ngừng lắng nghe sự kiện.
func stop_listening() -> void:
	if not _listening:
		return
	var eb: Node = _get_event_bus()
	if eb != null and eb.has_method("unsubscribe"):
		eb.call("unsubscribe", FishingEventsContract.FISH_CAUGHT, _on_fish_caught_event)
		_listening = false


## Thêm cá thủ công hoặc từ hệ thống.
func add_fish(fish_id: String, weight_g: int) -> void:
	if _logic != null and _logic.has_method("add_fish"):
		_logic.call("add_fish", fish_id, weight_g)


## Trừ cá khỏi túi đồ (bán cá hoặc tiêu hao).
func remove_fish(fish_id: String, count: int) -> Dictionary:
	if _logic != null and _logic.has_method("remove_fish"):
		var res: Dictionary = _logic.call("remove_fish", fish_id, count) as Dictionary
		if bool(res.get("success", false)):
			_emit_event(InventoryEventsContract.ITEM_REMOVED, {
				"item_id": fish_id,
				"amount": count,
				"removed_weight_g": res.get("removed_weight_g", 0)
			})
		return res
	return {"success": false, "removed_count": 0, "removed_weight_g": 0}


## Lấy toàn bộ danh sách cá trong kho.
func get_all_items() -> Dictionary:
	if _logic != null and _logic.has_method("get_all_items"):
		return _logic.call("get_all_items") as Dictionary
	return {}


## Lấy thông tin chi tiết một loài cá.
func get_fish_info(fish_id: String) -> Dictionary:
	if _logic != null and _logic.has_method("get_fish_info"):
		return _logic.call("get_fish_info", fish_id) as Dictionary
	return {}


## Lấy tổng số lượng cá.
func get_total_fish_count() -> int:
	if _logic != null and _logic.has_method("get_total_fish_count"):
		return int(_logic.call("get_total_fish_count"))
	return 0


## Lấy tổng trọng lượng cá (gam).
func get_total_weight_g() -> int:
	if _logic != null and _logic.has_method("get_total_weight_g"):
		return int(_logic.call("get_total_weight_g"))
	return 0


## Lưu dữ liệu vào file config.
func save(custom_path: String = "") -> bool:
	if _logic != null and _logic.has_method("save_to_disk"):
		return bool(_logic.call("save_to_disk", custom_path))
	return false


## Tải dữ liệu từ file config.
func load_data(custom_path: String = "") -> bool:
	if _logic != null and _logic.has_method("load_from_disk"):
		return bool(_logic.call("load_from_disk", custom_path))
	return false


## Xóa túi đồ.
func clear() -> void:
	if _logic != null and _logic.has_method("clear"):
		_logic.call("clear")


func _setup_callbacks() -> void:
	if _logic == null:
		return
	_logic.set("on_item_added", Callable(self, "_on_logic_item_added"))
	_logic.set("on_inventory_updated", Callable(self, "_on_logic_inventory_updated"))


func _on_fish_caught_event(payload: Dictionary) -> void:
	var fish_id: String = str(payload.get("fish_id", ""))
	var weight_g: int = int(payload.get("weight_g", 0))
	if not fish_id.is_empty():
		add_fish(fish_id, weight_g)


func _on_logic_item_added(payload: Dictionary) -> void:
	_emit_event(InventoryEventsContract.ITEM_ADDED, payload)


func _on_logic_inventory_updated(all_items: Dictionary) -> void:
	_emit_event(InventoryEventsContract.INVENTORY_UPDATED, {
		"items": all_items,
		"total_count": get_total_fish_count(),
		"total_weight_g": get_total_weight_g()
	})


func _emit_event(event_name: String, payload: Dictionary) -> void:
	var eb: Node = _get_event_bus()
	if eb != null and eb.has_method("emit_event"):
		eb.call("emit_event", event_name, payload)


func _get_event_bus() -> Node:
	var engine_singleton: Object = Engine.get_singleton("EventBus")
	if engine_singleton != null and is_instance_valid(engine_singleton):
		return engine_singleton as Node

	var main_loop: MainLoop = Engine.get_main_loop()
	if main_loop is SceneTree:
		var st := main_loop as SceneTree
		if st.root != null and st.root.has_node("EventBus"):
			return st.root.get_node("EventBus")
	return null

class_name InventoryAPI
extends RefCounted

## Giao diện lập trình (API) công khai của module kho đồ (modules/inventory/).
## Độc lập hoàn toàn với Fishing, Economy, Shop hay Cultivation.

const InventoryEventsContract: Script = preload("res://core/contracts/inventory_events.gd")
const InventoryLogicScript: Script = preload("res://modules/inventory/logic/inventory_logic.gd")

var _logic: RefCounted


func _init() -> void:
	_logic = InventoryLogicScript.new()
	_setup_callbacks()
	_subscribe_events()


func _setup_callbacks() -> void:
	if _logic == null:
		return
	_logic.set("on_inventory_updated", Callable(self, "_on_logic_inventory_updated"))


func _subscribe_events() -> void:
	var ml: MainLoop = Engine.get_main_loop()
	if ml is SceneTree:
		var st := ml as SceneTree
		if st.root != null and st.root.has_node("EventBus"):
			var eb: Node = st.root.get_node("EventBus")
			if eb != null and eb.has_method("subscribe"):
				eb.call("subscribe", "fishing_fish_caught", Callable(self, "_on_fish_caught"))


func _on_fish_caught(payload: Dictionary) -> void:
	var fish_id: String = str(payload.get("fish_id", ""))
	var weight_g: int = int(payload.get("weight_g", 0))
	if not fish_id.is_empty():
		add_fish(fish_id, weight_g)


func add_fish(fish_id: String, weight_g: int) -> void:
	if _logic != null and _logic.has_method("add_fish"):
		_logic.call("add_fish", fish_id, weight_g)
		_emit_event(InventoryEventsContract.ITEM_ADDED, {
			"item_id": fish_id,
			"amount": 1,
			"weight_g": weight_g,
			"category": 0
		})


func add_item(item_id: String, count: int = 1, weight_g: int = 0, category: int = 0, tier: int = 0, is_stackable: bool = true, max_stack: int = 999) -> bool:
	if _logic != null and _logic.has_method("add_item"):
		var ok: bool = bool(_logic.call("add_item", item_id, count, weight_g, category, tier, is_stackable, max_stack))
		if ok:
			_emit_event(InventoryEventsContract.ITEM_ADDED, {
				"item_id": item_id,
				"amount": count,
				"weight_g": weight_g,
				"category": category,
				"tier": tier
			})
		return ok
	return false


func remove_fish(fish_id: String, count: int) -> Dictionary:
	return remove_item(fish_id, count)


func remove_item(item_id: String, count: int) -> Dictionary:
	if _logic != null and _logic.has_method("remove_item"):
		var res: Dictionary = _logic.call("remove_item", item_id, count) as Dictionary
		if bool(res.get("success", false)):
			_emit_event(InventoryEventsContract.ITEM_REMOVED, {
				"item_id": item_id,
				"amount": count,
				"removed_weight_g": res.get("removed_weight_g", 0)
			})
		return res
	return {"success": false, "removed_count": 0, "removed_weight_g": 0}


func restore_fish(fish_id: String, count: int, weight_g: int) -> bool:
	if _logic != null and _logic.has_method("restore_fish"):
		return bool(_logic.call("restore_fish", fish_id, count, weight_g))
	return false


func has_item(item_id: String, min_count: int = 1) -> bool:
	if _logic != null and _logic.has_method("has_item"):
		return bool(_logic.call("has_item", item_id, min_count))
	return false


func get_item_count(item_id: String) -> int:
	if _logic != null and _logic.has_method("get_item_count"):
		return int(_logic.call("get_item_count", item_id))
	return 0


func get_all_items() -> Dictionary:
	if _logic != null and _logic.has_method("get_all_items"):
		return _logic.call("get_all_items") as Dictionary
	return {}


func get_items_by_category(category: int) -> Dictionary:
	if _logic != null and _logic.has_method("get_items_by_category"):
		return _logic.call("get_items_by_category", category) as Dictionary
	return {}


func get_fish_info(fish_id: String) -> Dictionary:
	if _logic != null and _logic.has_method("get_fish_info"):
		return _logic.call("get_fish_info", fish_id) as Dictionary
	return {}


func get_item_info(item_id: String) -> Dictionary:
	if _logic != null and _logic.has_method("get_item_info"):
		return _logic.call("get_item_info", item_id) as Dictionary
	return {}


func get_total_fish_count() -> int:
	if _logic != null and _logic.has_method("get_total_fish_count"):
		return int(_logic.call("get_total_fish_count"))
	return 0


func get_total_weight_g() -> int:
	if _logic != null and _logic.has_method("get_total_weight_g"):
		return int(_logic.call("get_total_weight_g"))
	return 0


func clear() -> void:
	if _logic != null and _logic.has_method("clear"):
		_logic.call("clear")


func save(custom_path: String = "") -> bool:
	if _logic != null and _logic.has_method("save_to_disk"):
		return bool(_logic.call("save_to_disk", custom_path))
	return false


func load_save(custom_path: String = "") -> bool:
	if _logic != null and _logic.has_method("load_from_disk"):
		return bool(_logic.call("load_from_disk", custom_path))
	return false


func _on_logic_inventory_updated(all_items: Dictionary) -> void:
	_emit_event(InventoryEventsContract.INVENTORY_UPDATED, {
		"items": all_items,
		"total_count": get_total_fish_count(),
		"total_weight_g": get_total_weight_g()
	})


func _emit_event(event_name: String, payload: Dictionary) -> void:
	var ml: MainLoop = Engine.get_main_loop()
	if ml is SceneTree:
		var st := ml as SceneTree
		if st.root != null and st.root.has_node("EventBus"):
			var eb: Node = st.root.get_node("EventBus")
			if eb != null and eb.has_method("emit"):
				eb.call("emit", event_name, payload)

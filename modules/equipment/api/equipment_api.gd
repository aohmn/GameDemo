class_name EquipmentAPI
extends RefCounted

## Giao diện lập trình (API) công khai của module pháp bảo trang bị (modules/equipment/).
## Độc lập hoàn toàn với Fishing, Inventory, Economy hay Cultivation.

const EquipmentEventsContract: Script = preload("res://core/contracts/equipment_events.gd")
const EquipmentLogicScript: Script = preload("res://modules/equipment/logic/equipment_logic.gd")

var _logic: RefCounted


func _init() -> void:
	_logic = EquipmentLogicScript.new()
	_setup_callbacks()


func _setup_callbacks() -> void:
	if _logic == null:
		return
	_logic.set("on_item_equipped", Callable(self, "_on_logic_item_equipped"))
	_logic.set("on_item_unequipped", Callable(self, "_on_logic_item_unequipped"))
	_logic.set("on_stats_updated", Callable(self, "_on_logic_stats_updated"))


func equip_item(slot: String, item_id: String, current_realm_level: int = 0) -> bool:
	if _logic != null and _logic.has_method("equip_item"):
		return bool(_logic.call("equip_item", slot, item_id, current_realm_level))
	return false


func unequip_item(slot: String) -> bool:
	if _logic != null and _logic.has_method("unequip_item"):
		return bool(_logic.call("unequip_item", slot))
	return false


func can_equip(item_id: String, slot: String, current_realm_level: int = 0) -> bool:
	if _logic != null and _logic.has_method("can_equip"):
		return bool(_logic.call("can_equip", item_id, slot, current_realm_level))
	return false


func get_equipped_item_id(slot: String) -> String:
	if _logic != null and _logic.has_method("get_equipped_item_id"):
		return str(_logic.call("get_equipped_item_id", slot))
	return ""


func get_all_equipped() -> Dictionary:
	if _logic != null and _logic.has_method("get_all_equipped"):
		return _logic.call("get_all_equipped") as Dictionary
	return {}


func calculate_total_stats() -> Dictionary:
	if _logic != null and _logic.has_method("calculate_total_stats"):
		return _logic.call("calculate_total_stats") as Dictionary
	return {}


func register_item_spec(spec: Resource) -> void:
	if _logic != null and _logic.has_method("register_item_spec"):
		_logic.call("register_item_spec", spec)


func get_item_level(item_id: String) -> int:
	return int(_logic.call("get_item_level", item_id)) if _logic != null and _logic.has_method("get_item_level") else 1


func get_item_durability(item_id: String) -> float:
	return float(_logic.call("get_item_durability", item_id)) if _logic != null and _logic.has_method("get_item_durability") else 100.0


func get_item_spec(item_id: String) -> Resource:
	return _logic.call("get_item_spec", item_id) as Resource if _logic != null and _logic.has_method("get_item_spec") else null


func get_upgrade_cost(item_id: String) -> int:
	return int(_logic.call("get_upgrade_cost", item_id)) if _logic != null and _logic.has_method("get_upgrade_cost") else 50


func upgrade_item(item_id: String) -> bool:
	return bool(_logic.call("upgrade_item", item_id)) if _logic != null and _logic.has_method("upgrade_item") else false


func consume_durability(slot: String, amount: float) -> void:
	if _logic != null and _logic.has_method("consume_durability"):
		_logic.call("consume_durability", slot, amount)


func repair_item(item_id: String) -> bool:
	return bool(_logic.call("repair_item", item_id)) if _logic != null and _logic.has_method("repair_item") else false


func save(custom_path: String = "") -> bool:
	if _logic != null and _logic.has_method("save_to_disk"):
		return bool(_logic.call("save_to_disk", custom_path))
	return false


func load_save(custom_path: String = "") -> bool:
	if _logic != null and _logic.has_method("load_from_disk"):
		return bool(_logic.call("load_from_disk", custom_path))
	return false


func _on_logic_item_equipped(payload: Dictionary) -> void:
	_emit_event(EquipmentEventsContract.ITEM_EQUIPPED, payload)


func _on_logic_item_unequipped(payload: Dictionary) -> void:
	_emit_event(EquipmentEventsContract.ITEM_UNEQUIPPED, payload)


func _on_logic_stats_updated(payload: Dictionary) -> void:
	_emit_event(EquipmentEventsContract.STATS_UPDATED, payload)


func _emit_event(event_name: String, payload: Dictionary) -> void:
	var ml: MainLoop = Engine.get_main_loop()
	if ml is SceneTree:
		var st := ml as SceneTree
		if st.root != null and st.root.has_node("EventBus"):
			var eb: Node = st.root.get_node("EventBus")
			if eb != null and eb.has_method("emit_event"):
				eb.call("emit_event", event_name, payload)

class_name CultivationAPI
extends RefCounted

## Giao diện lập trình (API) công khai của module tu luyện (modules/cultivation/).
## Độc lập hoàn toàn với Fishing, Inventory, Economy hay Shop.

const CultivationEventsContract: Script = preload("res://core/contracts/cultivation_events.gd")
const CultivationLogicScript: Script = preload("res://modules/cultivation/logic/cultivation_logic.gd")

var _logic: RefCounted


func _init() -> void:
	_logic = CultivationLogicScript.new()
	_setup_callbacks()


func _setup_callbacks() -> void:
	if _logic == null:
		return
	_logic.set("on_exp_gained", Callable(self, "_on_exp_gained"))
	_logic.set("on_layer_upgraded", Callable(self, "_on_layer_upgraded"))
	_logic.set("on_breakthrough_success", Callable(self, "_on_breakthrough_success"))
	_logic.set("on_breakthrough_failed", Callable(self, "_on_breakthrough_failed"))


func get_cultivation_info() -> Dictionary:
	if _logic != null and _logic.has_method("get_cultivation_info"):
		return _logic.call("get_cultivation_info") as Dictionary
	return {}


func get_current_realm_index() -> int:
	if _logic != null and _logic.has_method("get_current_realm_index"):
		return int(_logic.call("get_current_realm_index"))
	return 0


func get_current_layer() -> int:
	if _logic != null and _logic.has_method("get_current_layer"):
		return int(_logic.call("get_current_layer"))
	return 1


func get_current_realm_name() -> String:
	if _logic != null and _logic.has_method("get_current_realm_name"):
		return str(_logic.call("get_current_realm_name"))
	return ""


func get_total_exp() -> int:
	if _logic != null and _logic.has_method("get_total_exp"):
		return int(_logic.call("get_total_exp"))
	return 0


func can_breakthrough() -> bool:
	if _logic != null and _logic.has_method("can_breakthrough"):
		return bool(_logic.call("can_breakthrough"))
	return false


func add_exp(amount: int, reason: String = "absorb") -> void:
	if _logic != null and _logic.has_method("add_exp"):
		_logic.call("add_exp", amount, reason)


func breakthrough() -> Dictionary:
	if _logic != null and _logic.has_method("breakthrough"):
		return _logic.call("breakthrough") as Dictionary
	return {"success": false, "reason": "uninitialized"}


func save(custom_path: String = "") -> bool:
	if _logic != null and _logic.has_method("save_to_disk"):
		return bool(_logic.call("save_to_disk", custom_path))
	return false


func load_save(custom_path: String = "") -> bool:
	if _logic != null and _logic.has_method("load_from_disk"):
		return bool(_logic.call("load_from_disk", custom_path))
	return false


func _on_exp_gained(payload: Dictionary) -> void:
	_emit_event(CultivationEventsContract.EXP_GAINED, payload)


func _on_layer_upgraded(payload: Dictionary) -> void:
	_emit_event(CultivationEventsContract.LAYER_UPGRADED, payload)


func _on_breakthrough_success(payload: Dictionary) -> void:
	_emit_event(CultivationEventsContract.BREAKTHROUGH_SUCCESS, payload)


func _on_breakthrough_failed(payload: Dictionary) -> void:
	_emit_event(CultivationEventsContract.BREAKTHROUGH_FAILED, payload)


func _emit_event(event_name: String, payload: Dictionary) -> void:
	var ml: MainLoop = Engine.get_main_loop()
	if ml is SceneTree:
		var st := ml as SceneTree
		if st.root != null and st.root.has_node("EventBus"):
			var eb: Node = st.root.get_node("EventBus")
			if eb != null and eb.has_method("emit_event"):
				eb.call("emit_event", event_name, payload)

class_name CraftingAPI
extends RefCounted

## Giao diện lập trình (API) công khai của module chế tạo (modules/crafting/).
## Độc lập hoàn toàn với Inventory, Cultivation hay Fishing.

const CraftingEventsContract: Script = preload("res://core/contracts/crafting_events.gd")
const CraftingLogicScript: Script = preload("res://modules/crafting/logic/crafting_logic.gd")

var _logic: RefCounted


func _init() -> void:
	_logic = CraftingLogicScript.new()
	_setup_callbacks()


func _setup_callbacks() -> void:
	if _logic == null:
		return
	_logic.set("on_craft_started", Callable(self, "_on_logic_craft_started"))
	_logic.set("on_craft_completed", Callable(self, "_on_logic_craft_completed"))
	_logic.set("on_craft_cancelled", Callable(self, "_on_logic_craft_cancelled"))
	_logic.set("on_craft_failed", Callable(self, "_on_logic_craft_failed"))


func get_recipe(recipe_id: String) -> Resource:
	if _logic != null and _logic.has_method("get_recipe"):
		return _logic.call("get_recipe", recipe_id) as Resource
	return null


func get_all_recipes() -> Dictionary:
	if _logic != null and _logic.has_method("get_all_recipes"):
		return _logic.call("get_all_recipes") as Dictionary
	return {}


func is_recipe_unlocked(recipe_id: String) -> bool:
	if _logic != null and _logic.has_method("is_recipe_unlocked"):
		return bool(_logic.call("is_recipe_unlocked", recipe_id))
	return false


func unlock_recipe(recipe_id: String) -> bool:
	if _logic != null and _logic.has_method("unlock_recipe"):
		return bool(_logic.call("unlock_recipe", recipe_id))
	return false


func can_craft_recipe(recipe_id: String, current_realm_level: int = 0) -> Dictionary:
	if _logic != null and _logic.has_method("can_craft_recipe"):
		return _logic.call("can_craft_recipe", recipe_id, current_realm_level) as Dictionary
	return {"can_craft": false, "reason": "uninitialized"}


func start_craft(recipe_id: String, current_realm_level: int = 0) -> Dictionary:
	if _logic != null and _logic.has_method("start_craft"):
		return _logic.call("start_craft", recipe_id, current_realm_level) as Dictionary
	return {"success": false, "reason": "uninitialized"}


func process_craft(delta: float) -> Dictionary:
	if _logic != null and _logic.has_method("process_craft"):
		return _logic.call("process_craft", delta) as Dictionary
	return {"is_active": false, "finished": false}


func cancel_craft() -> Dictionary:
	if _logic != null and _logic.has_method("cancel_craft"):
		return _logic.call("cancel_craft") as Dictionary
	return {"success": false, "reason": "uninitialized"}


func get_active_craft_info() -> Dictionary:
	if _logic != null and _logic.has_method("get_active_craft_info"):
		return _logic.call("get_active_craft_info") as Dictionary
	return {}


func register_recipe(spec: Resource) -> void:
	if _logic != null and _logic.has_method("register_recipe"):
		_logic.call("register_recipe", spec)


func save(custom_path: String = "") -> bool:
	if _logic != null and _logic.has_method("save_to_disk"):
		return bool(_logic.call("save_to_disk", custom_path))
	return false


func load_save(custom_path: String = "") -> bool:
	if _logic != null and _logic.has_method("load_from_disk"):
		return bool(_logic.call("load_from_disk", custom_path))
	return false


func _on_logic_craft_started(payload: Dictionary) -> void:
	_emit_event(CraftingEventsContract.CRAFT_STARTED, payload)


func _on_logic_craft_completed(payload: Dictionary) -> void:
	_emit_event(CraftingEventsContract.CRAFT_COMPLETED, payload)


func _on_logic_craft_cancelled(payload: Dictionary) -> void:
	_emit_event(CraftingEventsContract.CRAFT_CANCELLED, payload)


func _on_logic_craft_failed(payload: Dictionary) -> void:
	_emit_event(CraftingEventsContract.CRAFT_FAILED, payload)


func _emit_event(event_name: String, payload: Dictionary) -> void:
	var ml: MainLoop = Engine.get_main_loop()
	if ml is SceneTree:
		var st := ml as SceneTree
		if st.root != null and st.root.has_node("EventBus"):
			var eb: Node = st.root.get_node("EventBus")
			if eb != null and eb.has_method("emit"):
				eb.call("emit", event_name, payload)

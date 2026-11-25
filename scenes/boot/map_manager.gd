extends Node3D

## Quản lý đăng ký, mở khóa, chuyển đổi nhiều bản đồ (Multi-Map) trong thế giới tu tiên.
## Giữ nguyên 100% Player, Inventory, Cultivation, Economy, Equipment khi chuyển map.

const MapEventsContract: Script = preload("res://core/contracts/map_events.gd")
const HARBOR_ISLAND_DEF_PATH: String = "res://maps/harbor_island/map_definition.tres"

const SAVE_PATH: String = "user://maps.cfg"
const SECTION_UNLOCKED: String = "unlocked_maps"
const SECTION_META: String = "meta"
const SAVE_VERSION: int = 1

var current_map_id: String = ""
var _current_map: Node3D

# Danh bạ MapDefinition đã đăng ký: map_id -> Resource (MapDefinition)
var _map_definitions: Dictionary = {}

# Trạng thái mở khóa bản đồ: map_id -> bool
var _unlocked_maps: Dictionary = {}


func _init() -> void:
	_register_default_maps()
	_load_unlocked_status()


func _register_default_maps() -> void:
	if ResourceLoader.exists(HARBOR_ISLAND_DEF_PATH):
		var res: Resource = load(HARBOR_ISLAND_DEF_PATH) as Resource
		if res != null:
			register_map_definition(res)


func register_map_definition(definition: Resource) -> void:
	if definition != null:
		var m_id: String = str(definition.get("map_id"))
		if not m_id.is_empty():
			_map_definitions[m_id] = definition
			var is_def_unlocked: bool = bool(definition.get("is_unlocked_by_default")) if "is_unlocked_by_default" in definition else true
			if is_def_unlocked:
				_unlocked_maps[m_id] = true


func get_map_definition(map_id: String) -> Resource:
	return _map_definitions.get(map_id, null) as Resource


func get_all_map_definitions() -> Dictionary:
	return _map_definitions.duplicate()


func is_map_unlocked(map_id: String) -> bool:
	return bool(_unlocked_maps.get(map_id, false))


func unlock_map(map_id: String) -> bool:
	if _map_definitions.has(map_id):
		_unlocked_maps[map_id] = true
		_save_unlocked_status()
		_emit_event(MapEventsContract.MAP_UNLOCKED, {"map_id": map_id})
		return true
	return false


func can_travel_to(map_id: String, current_realm_level: int = 0) -> Dictionary:
	if not _map_definitions.has(map_id):
		return {"can_travel": false, "reason": "map_not_found"}

	if not is_map_unlocked(map_id):
		return {"can_travel": false, "reason": "map_locked"}

	var def: Resource = _map_definitions[map_id] as Resource
	var req_realm: int = int(def.get("required_realm_level")) if "required_realm_level" in def else 0
	if current_realm_level < req_realm:
		return {"can_travel": false, "reason": "insufficient_realm"}

	return {"can_travel": true, "reason": "ok"}


## Nạp hoặc chuyển đổi sang map_id mới.
## Trả về true nếu nạp thành công.
func load_map(map_id: String) -> bool:
	if map_id == current_map_id and is_instance_valid(_current_map):
		return true

	var def: Resource = get_map_definition(map_id)
	var path: String = ""
	if def != null:
		path = str(def.get("scene_path"))
	else:
		# Fallback cho đường dẫn cứng
		if map_id == "harbor_island":
			path = "res://maps/harbor_island/map.tscn"

	if path.is_empty() or not ResourceLoader.exists(path):
		push_warning("File scene map không tồn tại hoặc chưa đăng ký: " + map_id)
		return false

	var resource: Resource = load(path)
	var map_scene := resource as PackedScene
	if map_scene == null:
		push_warning("Scene map không hợp lệ: " + path)
		return false

	var next_node: Node = map_scene.instantiate()
	if not next_node is Node3D:
		next_node.free()
		push_warning("Map phải có node gốc Node3D: " + map_id)
		return false

	var next_map: Node3D = next_node as Node3D
	var previous_map: Node3D = _current_map
	var previous_id: String = current_map_id

	add_child(next_map)

	_current_map = next_map
	current_map_id = map_id

	if is_instance_valid(previous_map):
		remove_child(previous_map)
		previous_map.queue_free()

	var spawn_pos: Vector3 = Vector3(-2.0, 0.05, 10.0)
	if def != null:
		spawn_pos = def.get("default_spawn_position") as Vector3

	_emit_event(MapEventsContract.MAP_CHANGED, {
		"old_map_id": previous_id,
		"new_map_id": map_id,
		"spawn_pos": spawn_pos
	})

	return true


func get_default_spawn_position(map_id: String) -> Vector3:
	var def: Resource = get_map_definition(map_id)
	if def != null:
		return def.get("default_spawn_position") as Vector3
	return Vector3(-2.0, 0.05, 10.0)


func get_current_map() -> Node3D:
	return _current_map


func get_current_map_id() -> String:
	return current_map_id


func _save_unlocked_status() -> void:
	var config := ConfigFile.new()
	config.set_value(SECTION_META, "version", SAVE_VERSION)
	for m_id in _unlocked_maps.keys():
		config.set_value(SECTION_UNLOCKED, m_id, bool(_unlocked_maps[m_id]))
	config.save(SAVE_PATH)


func _load_unlocked_status() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		if config.has_section(SECTION_UNLOCKED):
			var keys: PackedStringArray = config.get_section_keys(SECTION_UNLOCKED)
			for k in keys:
				_unlocked_maps[k] = bool(config.get_value(SECTION_UNLOCKED, k, false))


func _emit_event(event_name: String, payload: Dictionary) -> void:
	var ml: MainLoop = Engine.get_main_loop()
	if ml is SceneTree:
		var st := ml as SceneTree
		if st.root != null and st.root.has_node("EventBus"):
			var eb: Node = st.root.get_node("EventBus")
			if eb != null and eb.has_method("emit_event"):
				eb.call("emit_event", event_name, payload)

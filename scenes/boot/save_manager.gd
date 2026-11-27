extends RefCounted
## Quản lý lưu/khôi phục toàn bộ trạng thái game.

var _map_manager: Node3D
var _player: CharacterBody3D
var _apis: Array[RefCounted] = []


func setup(
	map_manager: Node3D,
	player: CharacterBody3D,
	inventory_api: RefCounted,
	economy_api: RefCounted,
	shop_api: RefCounted,
	cultivation_api: RefCounted,
	equipment_api: RefCounted,
	crafting_api: RefCounted = null,
) -> void:
	_map_manager = map_manager
	_player = player
	_apis.clear()
	for api in [inventory_api, economy_api, shop_api, cultivation_api, equipment_api, crafting_api]:
		if api != null:
			_apis.append(api)


func save_all() -> void:
	if _map_manager != null and _player != null and is_instance_valid(_player) and _player.is_inside_tree():
		_map_manager.call("save_player_state", _player.global_position)
	for api in _apis:
		if api.has_method("save"):
			api.call("save")
	var ml: MainLoop = Engine.get_main_loop()
	if ml is SceneTree and (ml as SceneTree).root != null:
		var gc: Node = (ml as SceneTree).root.get_node_or_null("GameClock")
		if gc != null and gc.has_method("save"):
			gc.call("save")


func restore_player_state() -> bool:
	if _map_manager == null or _player == null:
		return false
	var st: Dictionary = _map_manager.call("load_player_state") as Dictionary
	if not bool(st.get("has_save", false)):
		return false
	var map_changed: bool = false
	var m_id: String = str(st.get("map_id", ""))
	if not m_id.is_empty() and m_id != str(_map_manager.call("get_current_map_id")):
		_map_manager.call("load_map", m_id)
		map_changed = true
	_player.global_position = st.get("position", _player.global_position) as Vector3
	_player.velocity = Vector3.ZERO
	return map_changed

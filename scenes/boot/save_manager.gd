extends RefCounted
## Quản lý lưu/khôi phục toàn bộ trạng thái game.

var _map_manager: Node3D
var _player: CharacterBody3D
var _inventory_api: RefCounted
var _economy_api: RefCounted
var _shop_api: RefCounted
var _cultivation_api: RefCounted
var _equipment_api: RefCounted


func setup(
	map_manager: Node3D,
	player: CharacterBody3D,
	inventory_api: RefCounted,
	economy_api: RefCounted,
	shop_api: RefCounted,
	cultivation_api: RefCounted,
	equipment_api: RefCounted,
) -> void:
	_map_manager = map_manager
	_player = player
	_inventory_api = inventory_api
	_economy_api = economy_api
	_shop_api = shop_api
	_cultivation_api = cultivation_api
	_equipment_api = equipment_api


func save_all() -> void:
	if _map_manager != null and _player != null and is_instance_valid(_player) and _player.is_inside_tree():
		_map_manager.call("save_player_state", _player.global_position)
	for api in [_inventory_api, _economy_api, _shop_api, _cultivation_api, _equipment_api]:
		if api != null and api.has_method("save"):
			api.call("save")


func restore_player_state() -> void:
	if _map_manager == null or _player == null:
		return
	var st: Dictionary = _map_manager.call("load_player_state") as Dictionary
	if not bool(st.get("has_save", false)):
		return
	var m_id: String = str(st.get("map_id", ""))
	if not m_id.is_empty() and m_id != str(_map_manager.call("get_current_map_id")):
		_map_manager.call("load_map", m_id)
	_player.global_position = st.get("position", _player.global_position) as Vector3
	_player.velocity = Vector3.ZERO

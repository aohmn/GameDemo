extends RefCounted

## Nối Player + Map + Fishing UI + cần câu: tính điểm rơi phao phía trước nhân vật,
## hỏi map điểm đó có phải mặt nước không, rồi báo cho UI và cần câu. Hủy câu nếu đi quá xa.

const CAST_DISTANCE: float = 4.0
const MAX_LINE_DISTANCE: float = 8.0
const SPOT_ID: String = "spot_cau_tau_ben_cang"

var _player: Node3D
var _map: Node
var _ui: Control
var _rig: Node3D
var _fishing_api: RefCounted


func setup(player: Node3D, map: Node, ui: Control, rig: Node3D, fishing_api: RefCounted) -> void:
	_player = player
	_map = map
	_ui = ui
	_rig = rig
	_fishing_api = fishing_api


func update() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var facing := Vector3(0.0, 0.0, 1.0)
	if _player.has_method("get_facing_vector"):
		facing = _player.call("get_facing_vector")
	var target: Vector3 = _player.global_position + facing * CAST_DISTANCE
	target.y = _map.call("get_water_height_at", target) if _map != null and _map.has_method("get_water_height_at") else -0.15
	var valid: bool = false
	if _map != null and _map.has_method("is_water_at"):
		valid = bool(_map.call("is_water_at", target))
	if _rig != null:
		_rig.call("set_aim", facing, target, valid)
		if bool(_rig.call("is_line_out")) and _fishing_api != null:
			var line_end: Vector3 = _rig.call("get_line_end")
			if _player.global_position.distance_to(line_end) > MAX_LINE_DISTANCE:
				_fishing_api.call("cancel")
	if _ui != null and _ui.has_method("set_near_fishing_spot"):
		var spot_id: String = SPOT_ID
		if _map != null and _map.has_method("get_fishing_spot_at"):
			spot_id = str(_map.call("get_fishing_spot_at", target))
		_ui.call("set_near_fishing_spot", valid, spot_id)

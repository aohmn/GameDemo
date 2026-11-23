## BuildingOcclusionFader: Quản lý làm mờ tòa nhà khi nằm giữa Camera và Player.
## Có thể bật/tắt toàn cục qua biến enable_occlusion_fade.
extends Node
class_name BuildingOcclusionFader

## Biến điều khiển bật/tắt làm mờ
@export var enable_occlusion_fade: bool = true

## Bán kính kiểm tra và độ mờ khi bị che khuất
@export var fade_alpha: float = 0.35
@export var fade_speed: float = 8.0

var _camera: Camera3D = null
var _player: CharacterBody3D = null
var _building_materials: Array[ShaderMaterial] = []
var _building_center: Vector3 = Vector3.ZERO
var _building_radius: float = 5.0


func configure(materials: Array[ShaderMaterial], center: Vector3, radius: float) -> void:
	_building_materials = materials
	_building_center = center
	_building_radius = radius


func _process(delta: float) -> void:
	if not enable_occlusion_fade or _building_materials.is_empty():
		_set_target_alpha(1.0, delta)
		return

	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as CharacterBody3D
		if not is_instance_valid(_player):
			return

	if not is_instance_valid(_camera):
		var viewport := get_viewport()
		if viewport != null:
			_camera = viewport.get_camera_3d()
		if not is_instance_valid(_camera):
			return

	var cam_pos := _camera.global_position
	var player_pos := _player.global_position + Vector3(0.0, 1.0, 0.0)

	var target_alpha := 1.0
	if _is_occluding(cam_pos, player_pos):
		target_alpha = fade_alpha

	_set_target_alpha(target_alpha, delta)


func _is_occluding(cam_pos: Vector3, player_pos: Vector3) -> bool:
	var seg := player_pos - cam_pos
	var seg_len := seg.length()
	if seg_len < 0.01:
		return false

	var seg_dir := seg / seg_len
	var to_center := _building_center - cam_pos
	var proj := to_center.dot(seg_dir)

	# Điểm gần nhất phải nằm giữa Camera và Player
	if proj < 1.0 or proj > seg_len - 0.5:
		return false

	var closest_point := cam_pos + seg_dir * proj
	var dist_sq := closest_point.distance_squared_to(_building_center)

	return dist_sq < (_building_radius * _building_radius)


func _set_target_alpha(target: float, delta: float) -> void:
	for mat: ShaderMaterial in _building_materials:
		if is_instance_valid(mat):
			var current: float = float(mat.get_shader_parameter("transparency_alpha"))
			var next_val := move_toward(current, target, fade_speed * delta)
			mat.set_shader_parameter("transparency_alpha", next_val)

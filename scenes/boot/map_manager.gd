extends Node3D

const MAP_SCENES: Dictionary = {
	"vietnam_street": preload("res://maps/vietnam_street/map.tscn"),
}

var current_map_id: String = ""
var _current_map: Node3D


func load_map(map_id: String) -> bool:
	if map_id == current_map_id and is_instance_valid(_current_map):
		return true

	if not MAP_SCENES.has(map_id):
		push_error("Không tìm thấy map ID: " + map_id)
		return false

	var map_scene: PackedScene = MAP_SCENES[map_id] as PackedScene
	if map_scene == null:
		push_error("Scene map không hợp lệ: " + map_id)
		return false

	var next_node: Node = map_scene.instantiate()
	if not next_node is Node3D:
		next_node.free()
		push_error("Map phải có node gốc Node3D: " + map_id)
		return false

	var next_map: Node3D = next_node as Node3D
	var previous_map: Node3D = _current_map

	add_child(next_map)

	_current_map = next_map
	current_map_id = map_id

	if is_instance_valid(previous_map):
		remove_child(previous_map)
		previous_map.queue_free()

	return true


func get_current_map_id() -> String:
	return current_map_id

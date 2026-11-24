extends Node3D

const MAP_PATHS: Dictionary = {
	"harbor_island": "res://maps/harbor_island/map.tscn",
}

var current_map_id: String = ""
var _current_map: Node3D


func load_map(map_id: String) -> bool:
	if map_id == current_map_id and is_instance_valid(_current_map):
		return true

	if not MAP_PATHS.has(map_id):
		push_warning("Không tìm thấy map ID trong danh sách: " + map_id)
		return false

	var path: String = MAP_PATHS[map_id]
	if not ResourceLoader.exists(path):
		push_warning("File scene map không tồn tại: " + path)
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

	add_child(next_map)

	_current_map = next_map
	current_map_id = map_id

	if is_instance_valid(previous_map):
		remove_child(previous_map)
		previous_map.queue_free()

	return true


func get_current_map_id() -> String:
	return current_map_id

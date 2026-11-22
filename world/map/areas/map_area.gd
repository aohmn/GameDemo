## MapArea: base class cho mọi map/khu vực.
## Quyền: data spawn của Player (get_entry_point, get_spawn_points), road points
## cho WorldNavigation, transition points, recovery Player khi rơi.
## Nội dung khu vực do subclass dựng qua content builders.
extends Node3D
class_name MapArea

var _transitioning := false


func _ready() -> void:
	EventBus.subscribe(WorldEvents.PLAYER_RECOVERY_REQUESTED, _on_player_recovery_requested)
	WorldNavigation.set_graph(get_road_points())
	build_content()
	_apply_spawn()


func _exit_tree() -> void:
	if EventBus != null:
		EventBus.unsubscribe(WorldEvents.PLAYER_RECOVERY_REQUESTED, _on_player_recovery_requested)


## Dựng nội dung map — gọi đúng 1 lần mỗi map instance (từ _ready).
func build_content() -> void:
	pass


## Điểm xuất phát của Player khi vào map này.
func get_entry_point() -> Vector3:
	return Vector3(0.0, 0.05, 0.0)


## Data vị trí Player theo spawn_point_id (khu vực tự quyết định).
func get_spawn_points() -> Dictionary:
	return {}


## Waypoints đường đi cho WorldNavigation (AStar2D), x,z theo thế giới.
func get_road_points() -> Array[Vector2]:
	return []


func _on_player_recovery_requested(payload: Dictionary) -> void:
	var player := get_tree().get_first_node_in_group("player") as CharacterBody3D
	if not is_instance_valid(player) or not player.has_method("recover_to"):
		push_warning("[World] Player thiếu API recover_to().")
		return
	player.call("recover_to", get_entry_point())
	print("[Player] Recovered after falling.")


func _apply_spawn() -> void:
	var player := get_tree().get_first_node_in_group("player") as CharacterBody3D
	if not is_instance_valid(player):
		return
	player.global_position = get_entry_point()
	player.velocity = Vector3.ZERO
	player.spawn_context = "transition"
	print("[World] Spawn: ", name, " at ", get_entry_point())


## Player Player đi vào transition area -> gửi yêu cầu chuyển map.
func _on_transition_entered(body: Node3D, dest_scene: String) -> void:
	var player := get_tree().get_first_node_in_group("player") as CharacterBody3D
	if not is_instance_valid(player) or body != player or _transitioning:
		return
	if not ResourceLoader.exists(dest_scene, "PackedScene"):
		push_error("[World] Destination scene not found: " + dest_scene)
		return
	_transitioning = true
	EventBus.emit_event(WorldEvents.MAP_CHANGE_REQUESTED, {
		"scene_path": dest_scene
	})

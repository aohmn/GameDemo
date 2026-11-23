extends Node3D

const MAP_MANAGER_SCRIPT: Script = preload("res://scenes/boot/map_manager.gd")

var _map_manager: Node3D


func _ready() -> void:
	_create_camera()
	_create_map_manager()


func _create_camera() -> void:
	var camera := Camera3D.new()
	camera.name = "MainCamera"
	camera.position = Vector3(0.0, 16.0, 23.0)
	camera.fov = 55.0
	add_child(camera)
	camera.look_at(Vector3.ZERO)
	camera.current = true


func _create_map_manager() -> void:
	_map_manager = MAP_MANAGER_SCRIPT.new() as Node3D
	if _map_manager == null:
		push_error("Không thể khởi tạo MapManager.")
		return

	_map_manager.name = "MapManager"
	add_child(_map_manager)

	var loaded: bool = bool(
		_map_manager.call("load_map", "vietnam_street")
	)

	if not loaded:
		push_error("Không thể tải map khởi đầu vietnam_street.")

extends Node3D

const MAP_MANAGER_SCRIPT: Script = preload("res://scenes/boot/map_manager.gd")
const JOYSTICK_SCENE_PATH: String = "res://presentation/joystick/joystick.tscn"

var _map_manager: Node3D


func _ready() -> void:
	_create_camera()
	_create_map_manager()
	_create_joystick()


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


func _create_joystick() -> void:
	if not ResourceLoader.exists(JOYSTICK_SCENE_PATH):
		return

	var joystick_resource: Resource = load(JOYSTICK_SCENE_PATH)
	var joystick_scene: PackedScene = joystick_resource as PackedScene

	if joystick_scene == null:
		push_error("Không thể tải scene joystick.")
		return

	var joystick_node: Node = joystick_scene.instantiate()
	if not joystick_node is Control:
		joystick_node.free()
		push_error("Scene joystick phải có node gốc Control.")
		return

	var hud := CanvasLayer.new()
	hud.name = "HUD"
	add_child(hud)
	hud.add_child(joystick_node)

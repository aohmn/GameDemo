extends Node3D

const MAP_MANAGER_SCRIPT: Script = preload("res://scenes/boot/map_manager.gd")
const PLAYER_SCENE_PATH: String = "res://modules/player/scenes/player.tscn"
const JOYSTICK_SCENE_PATH: String = "res://presentation/joystick/joystick.tscn"
const SKY_DOME_SCENE_PATH: String = "res://modules/sky_dome/scenes/sky_dome.tscn"

var _map_manager: Node3D
var _camera: Camera3D
var _player: CharacterBody3D
var _joystick: Node
var _sky_dome: Node3D


func _ready() -> void:
    _create_camera()
    _create_sky_dome()
    _create_map_manager()
    _create_player()
    _create_joystick()


func _process(_delta: float) -> void:
    if _camera == null or _player == null:
        return

    var target := _player.global_position
    _camera.global_position = target + Vector3(0.0, 16.0, 23.0)
    _camera.look_at(target + Vector3(0.0, 0.8, 0.0))


func _create_camera() -> void:
    _camera = Camera3D.new()
    _camera.name = "MainCamera"
    _camera.position = Vector3(0.0, 16.0, 23.0)
    _camera.fov = 55.0
    add_child(_camera)
    _camera.current = true


func _create_sky_dome() -> void:
    if not ResourceLoader.exists(SKY_DOME_SCENE_PATH):
        push_warning("Không tìm thấy SkyDome scene.")
        return

    var resource: Resource = load(SKY_DOME_SCENE_PATH)
    var scene := resource as PackedScene
    if scene == null:
        push_error("SkyDome scene không hợp lệ.")
        return

    var dome_node: Node = scene.instantiate()
    _sky_dome = dome_node as Node3D
    if _sky_dome == null:
        dome_node.free()
        push_error("SkyDome phải có node gốc Node3D.")
        return

    _sky_dome.name = "SkyDome"
    add_child(_sky_dome)

    if _sky_dome.has_method("set_follow_target") and _camera != null:
        _sky_dome.call("set_follow_target", _camera)


func _create_map_manager() -> void:
    _map_manager = MAP_MANAGER_SCRIPT.new() as Node3D
    if _map_manager == null:
        push_error("Không thể khởi tạo MapManager.")
        return

    _map_manager.name = "MapManager"
    add_child(_map_manager)

    var loaded := bool(_map_manager.call("load_map", "harbor_island"))
    if not loaded:
        push_warning("Không thể tải map harbor_island; tiếp tục không có map.")


func _create_player() -> void:
    if not ResourceLoader.exists(PLAYER_SCENE_PATH):
        push_warning("Không tìm thấy Player scene; tiếp tục không có Player.")
        return

    var resource: Resource = load(PLAYER_SCENE_PATH)
    var scene := resource as PackedScene
    if scene == null:
        push_error("Không thể tải Player scene.")
        return

    var player_node: Node = scene.instantiate()
    _player = player_node as CharacterBody3D
    if _player == null:
        player_node.free()
        push_error("Player phải có node gốc CharacterBody3D.")
        return

    _player.name = "Player"
    _player.position = Vector3(-2.0, 0.05, 10.0)
    add_child(_player)


func _create_joystick() -> void:
    if not ResourceLoader.exists(JOYSTICK_SCENE_PATH):
        push_warning("Không tìm thấy Joystick; tiếp tục không có điều khiển cảm ứng.")
        return

    var resource: Resource = load(JOYSTICK_SCENE_PATH)
    var scene := resource as PackedScene
    if scene == null:
        push_error("Joystick scene không hợp lệ.")
        return

    _joystick = scene.instantiate()
    if not _joystick is Control:
        _joystick.free()
        _joystick = null
        push_error("Joystick phải có node gốc Control.")
        return

    var hud := CanvasLayer.new()
    hud.name = "HUD"
    add_child(hud)
    hud.add_child(_joystick)

    if _joystick.has_signal("direction_changed"):
        _joystick.connect(
            "direction_changed",
            _on_joystick_direction_changed
        )


func _on_joystick_direction_changed(direction: Vector2) -> void:
    if _player != null:
        _player.call("set_move_direction", direction)

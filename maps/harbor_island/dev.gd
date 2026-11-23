extends Node3D

const MAP_SCENE: PackedScene = preload("res://maps/harbor_island/map.tscn")
const SKY_DOME_SCENE: PackedScene = preload("res://modules/sky_dome/scenes/sky_dome.tscn")

var _camera: Camera3D
var _orbit_angle: float = 0.0
var _orbit_radius: float = 24.0
var _orbit_height: float = 12.0
var _camera_target: Vector3 = Vector3(0.0, 0.5, 10.0)


func _ready() -> void:
    _create_map()
    _create_sky_dome()
    _create_dev_camera()


func _process(delta: float) -> void:
    if _camera == null:
        return

    # Xoay camera chậm quanh bến cảng và bờ biển để kiểm tra nước từ nhiều góc nhìn
    _orbit_angle += delta * 0.15
    var cam_x := sin(_orbit_angle) * _orbit_radius
    var cam_z := cos(_orbit_angle) * _orbit_radius + 10.0
    _camera.global_position = Vector3(cam_x, _orbit_height, cam_z)
    _camera.look_at(_camera_target)


func _create_map() -> void:
    var map_node: Node = MAP_SCENE.instantiate()
    add_child(map_node)


func _create_sky_dome() -> void:
    var dome_node: Node = SKY_DOME_SCENE.instantiate()
    var dome := dome_node as Node3D
    if dome != null:
        add_child(dome)
        if dome.has_method("set_follow_target") and _camera != null:
            dome.call("set_follow_target", _camera)


func _create_dev_camera() -> void:
    _camera = Camera3D.new()
    _camera.name = "WaterDevCamera"
    _camera.fov = 50.0
    _camera.current = true
    add_child(_camera)

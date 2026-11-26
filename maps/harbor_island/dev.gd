extends Node3D

const MAP_SCENE: PackedScene = preload("res://maps/harbor_island/map.tscn")
const SKY_DOME_SCENE_PATH: String = "res://modules/sky_dome/scenes/sky_dome.tscn"

var _camera: Camera3D
var _orbit_angle: float = 0.0
var _orbit_radius: float = 24.0
var _orbit_height: float = 12.0
var _camera_target: Vector3 = Vector3(0.0, 0.5, 10.0)


func _ready() -> void:
    _create_map()
    _create_dev_camera()
    _create_sky_dome()
    _sync_sun_direction()


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
    map_node.name = "Map"
    add_child(map_node)


func _create_sky_dome() -> void:
    if not ResourceLoader.exists(SKY_DOME_SCENE_PATH):
        return
    var scene := load(SKY_DOME_SCENE_PATH) as PackedScene
    if scene == null:
        return
    var dome_node := scene.instantiate() as Node3D
    if dome_node != null:
        dome_node.name = "SkyDome"
        add_child(dome_node)
        if dome_node.has_method("set_follow_target") and _camera != null:
            dome_node.call("set_follow_target", _camera)


func _create_dev_camera() -> void:
    _camera = Camera3D.new()
    _camera.name = "WaterDevCamera"
    _camera.fov = 50.0
    _camera.current = true
    add_child(_camera)


func _sync_sun_direction() -> void:
    var map_node := get_node_or_null("Map")
    var dome_node := get_node_or_null("SkyDome")
    if map_node != null and map_node.has_method("get_sun_direction"):
        var sun_dir: Vector3 = map_node.call("get_sun_direction")
        if dome_node != null and dome_node.has_method("set_sun_direction"):
            dome_node.call("set_sun_direction", sun_dir)
        if map_node.has_method("get_water_material"):
            var water_mat: ShaderMaterial = map_node.call("get_water_material") as ShaderMaterial
            if water_mat != null:
                water_mat.set_shader_parameter("sun_dir", sun_dir)

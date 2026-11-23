extends Node3D

const SKY_DOME_SCENE: PackedScene = preload("res://modules/sky_dome/scenes/sky_dome.tscn")

var _camera: Camera3D
var _sky_dome: Node3D


func _ready() -> void:
    _create_camera()
    _create_sky_dome()
    _create_ground()
    _create_light()


func _process(delta: float) -> void:
    if _camera != null:
        _camera.rotation.y += delta * 0.2


func _create_camera() -> void:
    _camera = Camera3D.new()
    _camera.name = "DevCamera"
    _camera.position = Vector3(0.0, 2.0, 0.0)
    _camera.current = true
    add_child(_camera)


func _create_sky_dome() -> void:
    var dome_node: Node = SKY_DOME_SCENE.instantiate()
    _sky_dome = dome_node as Node3D
    if _sky_dome == null:
        dome_node.free()
        push_error("SkyDome scene không phải Node3D.")
        return

    add_child(_sky_dome)
    if _sky_dome.has_method("set_follow_target"):
        _sky_dome.call("set_follow_target", _camera)


func _create_ground() -> void:
    var body := StaticBody3D.new()
    body.name = "Ground"

    var mesh_node := MeshInstance3D.new()
    var plane := PlaneMesh.new()
    plane.size = Vector2(40.0, 40.0)
    mesh_node.mesh = plane

    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.35, 0.65, 0.45)
    mesh_node.material_override = mat
    body.add_child(mesh_node)

    add_child(body)


func _create_light() -> void:
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-45.0, -30.0, 0.0)
    add_child(light)

extends Node3D

const SKY_SHADER: Shader = preload("res://modules/sky_dome/assets/sky_dome.gdshader")
const DOME_RADIUS: float = 200.0

var _target: Node3D
var _mesh_instance: MeshInstance3D
var _shader_material: ShaderMaterial


func _ready() -> void:
    _create_dome_mesh()


func _process(_delta: float) -> void:
    if is_instance_valid(_target):
        global_position = _target.global_position


func set_follow_target(target: Node3D) -> void:
    _target = target
    if is_instance_valid(_target):
        global_position = _target.global_position


func get_shader_material() -> ShaderMaterial:
    return _shader_material


func _create_dome_mesh() -> void:
    _mesh_instance = MeshInstance3D.new()
    _mesh_instance.name = "DomeMesh"

    var sphere := SphereMesh.new()
    sphere.radius = DOME_RADIUS
    sphere.height = DOME_RADIUS * 2.0
    sphere.radial_segments = 32
    sphere.rings = 16
    _mesh_instance.mesh = sphere

    _shader_material = ShaderMaterial.new()
    _shader_material.shader = SKY_SHADER
    _mesh_instance.material_override = _shader_material

    # Tắt cast shadow và không nhận ánh sáng để tối ưu hiệu năng
    _mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(_mesh_instance)

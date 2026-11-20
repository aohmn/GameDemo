extends ColorRect
class_name MapShaderController

@export var world_seed: float = 7.0
@export_range(0.01, 0.1, 0.001) var road_width: float = 0.035
@export_range(0.01, 0.08, 0.001) var branch_width: float = 0.022
@export_range(0.005, 0.06, 0.001) var canal_width: float = 0.025
@export_range(8.0, 64.0, 1.0) var detail_scale: float = 24.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _update_shader_parameters()
    get_viewport().size_changed.connect(_update_shader_parameters)

func _update_shader_parameters() -> void:
    var shader_material := material as ShaderMaterial

    if shader_material == null:
        push_warning("MapShaderController: thiếu ShaderMaterial")
        return

    var viewport_size := get_viewport_rect().size

    shader_material.set_shader_parameter("viewport_size", viewport_size)
    shader_material.set_shader_parameter("world_seed", world_seed)
    shader_material.set_shader_parameter("road_width", road_width)
    shader_material.set_shader_parameter("branch_width", branch_width)
    shader_material.set_shader_parameter("canal_width", canal_width)
    shader_material.set_shader_parameter("detail_scale", detail_scale)

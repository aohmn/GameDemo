extends Node3D

const SKY_SHADER: Shader = preload("res://modules/sky_dome/assets/sky_dome.gdshader")
const DOME_RADIUS: float = 200.0

var _target: Node3D
var _mesh_instance: MeshInstance3D
var _shader_material: ShaderMaterial
var _last_synced_hour: float = -1.0


func _ready() -> void:
    _create_dome_mesh()
    _sync_from_clock()


func _process(_delta: float) -> void:
    if is_instance_valid(_target):
        global_position = _target.global_position
    _sync_from_clock()


func _sync_from_clock() -> void:
    var clock: Node = get_node_or_null("/root/GameClock")
    if clock == null:
        return
    var h: float = float(clock.get("current_time"))
    if _last_synced_hour < 0.0 or absf(h - _last_synced_hour) >= 0.02:
        _last_synced_hour = h
        set_time_of_day(h)


func set_time_of_day(hour: float) -> void:
    if _shader_material == null:
        return
    # 6h mọc -> 12h đỉnh -> 18h lặn -> đêm xuống dưới chân trời
    var angle: float = ((hour - 6.0) / 24.0) * TAU
    var sun_y: float = sin(angle)
    var sun_dir := Vector3(-0.37 * cos(angle), sun_y, 0.53).normalized()
    _shader_material.set_shader_parameter("sun_direction", sun_dir)

    var day_w: float = clampf((sun_y + 0.15) / 0.45, 0.0, 1.0)
    var dusk_w: float = clampf(1.0 - absf(sun_y) * 4.0, 0.0, 1.0)
    var top_day := Color(0.12, 0.42, 0.78, 1.0)
    var top_night := Color(0.03, 0.06, 0.16, 1.0)
    var hor_day := Color(0.55, 0.78, 0.92, 1.0)
    var hor_night := Color(0.09, 0.14, 0.28, 1.0)
    var hor_dusk := Color(0.88, 0.52, 0.34, 1.0)
    var hor_col: Color = hor_night.lerp(hor_day, day_w).lerp(hor_dusk, dusk_w * 0.65)
    var cld_col: Color = Color(0.28, 0.32, 0.44, 1.0).lerp(Color(0.98, 0.98, 1.0, 1.0), day_w)
    var gnd_col: Color = Color(0.05, 0.09, 0.16, 1.0).lerp(Color(0.20, 0.52, 0.65, 1.0), day_w)
    _shader_material.set_shader_parameter("sky_top_color", top_night.lerp(top_day, day_w))
    _shader_material.set_shader_parameter("sky_horizon_color", hor_col)
    _shader_material.set_shader_parameter("ground_color", gnd_col)
    _shader_material.set_shader_parameter("cloud_color", cld_col)


func set_follow_target(target: Node3D) -> void:
    _target = target
    if is_instance_valid(_target):
        global_position = _target.global_position


func get_shader_material() -> ShaderMaterial:
    return _shader_material


func set_sun_direction(sun_dir: Vector3) -> void:
    if _shader_material != null:
        _shader_material.set_shader_parameter("sun_direction", sun_dir)


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

extends CharacterBody3D

const PLAYER_SHADER: Shader = preload("res://modules/player/assets/player.gdshader")
const MOVE_SPEED: float = 4.0
const GRAVITY: float = 18.0
const BODY_HEIGHT: float = 1.75
const RESPAWN_POSITION: Vector3 = Vector3(-2.0, 0.05, 10.0)
const FALL_Y_THRESHOLD: float = -2.0

var move_direction: Vector2 = Vector2.ZERO
var visual: MeshInstance3D
var shader_material: ShaderMaterial
var walk_phase: float = 0.0
var current_facing: int = 0
var current_flip: bool = false


func set_move_direction(direction: Vector2) -> void:
    move_direction = direction.limit_length(1.0)


func _ready() -> void:
    _create_collision()
    _create_visual()


func _physics_process(delta: float) -> void:
    # Cơ chế phát hiện rơi khỏi bản đồ: đưa nhân vật về vị trí an toàn trên cầu tàu
    if global_position.y < FALL_Y_THRESHOLD:
        global_position = RESPAWN_POSITION
        velocity = Vector3.ZERO
        return

    var move_vector := Vector3(move_direction.x, 0.0, -move_direction.y)
    move_vector = move_vector.limit_length(1.0)

    velocity.x = move_vector.x * MOVE_SPEED
    velocity.z = move_vector.z * MOVE_SPEED

    if is_on_floor():
        if velocity.y < 0.0:
            velocity.y = 0.0
    else:
        velocity.y -= GRAVITY * delta

    move_and_slide()

    var moving := move_vector.length_squared() > 0.01
    if moving:
        walk_phase += delta * 10.0

    _update_animation(moving)
    _update_billboard()


func _create_collision() -> void:
    var collision := CollisionShape3D.new()
    collision.name = "BodyCollision"

    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.28
    capsule.height = BODY_HEIGHT

    collision.shape = capsule
    collision.position.y = BODY_HEIGHT * 0.5
    add_child(collision)


func _create_visual() -> void:
    visual = MeshInstance3D.new()
    visual.name = "Visual"

    var quad := QuadMesh.new()
    quad.size = Vector2(1.0, BODY_HEIGHT)
    visual.mesh = quad
    visual.position.y = BODY_HEIGHT * 0.5

    shader_material = ShaderMaterial.new()
    shader_material.shader = PLAYER_SHADER
    visual.material_override = shader_material
    add_child(visual)


func _update_animation(moving: bool) -> void:
    if shader_material == null:
        return

    if moving:
        if absf(move_direction.x) > absf(move_direction.y):
            current_facing = 2
            current_flip = move_direction.x > 0.0
        elif move_direction.y > 0.0:
            current_facing = 1
            current_flip = false
        else:
            current_facing = 0
            current_flip = false

    shader_material.set_shader_parameter("walk_phase", walk_phase)
    shader_material.set_shader_parameter("moving", 1.0 if moving else 0.0)
    shader_material.set_shader_parameter("facing", current_facing)
    shader_material.set_shader_parameter("flip_horizontal", current_flip)


func _update_billboard() -> void:
    if visual == null:
        return

    var camera := get_viewport().get_camera_3d()
    if camera == null:
        return

    var camera_right := camera.global_basis.x.normalized()
    var camera_up := camera.global_basis.y.normalized()
    var camera_back := camera_right.cross(camera_up).normalized()

    visual.global_basis = Basis(camera_right, camera_up, camera_back)

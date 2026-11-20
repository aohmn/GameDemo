extends CharacterBody3D
class_name Player3DController

@export var move_speed: float = 5.0
@export var acceleration: float = 18.0
@export var gravity: float = 18.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var joystick: Node = get_node("../HUD/Joystick")

const CAMERA_FOLLOW_OFFSET: Vector3 = Vector3(0.0, 1.5, 0.0)


func _ready() -> void:
	# Camera không kế thừa góc xoay của nhân vật.
	camera_pivot.top_level = true
	camera_pivot.global_rotation = Vector3.ZERO
	camera_pivot.global_position = global_position + CAMERA_FOLLOW_OFFSET


func _physics_process(delta: float) -> void:
	var keyboard_input := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	var touch_input: Vector2 = joystick.get_direction()
	var input_vector := keyboard_input

	if touch_input.length() > keyboard_input.length():
		input_vector = touch_input

	# Camera cố định hướng nên joystick luôn dùng trục thế giới.
	var direction := Vector3(input_vector.x, 0.0, input_vector.y)

	if direction.length() > 0.08:
		direction = direction.normalized()
		look_at(global_position + direction, Vector3.UP)

	var target_velocity := direction * move_speed

	velocity.x = move_toward(
		velocity.x,
		target_velocity.x,
		acceleration * delta
	)

	velocity.z = move_toward(
		velocity.z,
		target_velocity.z,
		acceleration * delta
	)

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif velocity.y < 0.0:
		velocity.y = 0.0

	move_and_slide()

	# Camera chỉ bám vị trí, không xoay theo nhân vật.
	camera_pivot.global_position = global_position + CAMERA_FOLLOW_OFFSET

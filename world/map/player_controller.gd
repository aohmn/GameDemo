extends CharacterBody3D
class_name Player3DController

@export var move_speed: float = 5.0
@export var acceleration: float = 18.0
@export var gravity: float = 18.0
@export var camera_follow_speed: float = 5.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var joystick: Node = get_node("../HUD/Joystick")

var _movement_basis_yaw: float = 0.0
var _was_moving: bool = false


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

	var has_input := input_vector.length() > 0.08

	# Khóa hướng camera tại thời điểm bắt đầu kéo joystick.
	# Camera có thể xoay mà hướng di chuyển không bị lệch theo.
	if has_input and not _was_moving:
		_movement_basis_yaw = camera_pivot.rotation.y

	_was_moving = has_input

	var direction := Vector3(
		input_vector.x,
		0.0,
		input_vector.y
	)

	direction = direction.rotated(
		Vector3.UP,
		_movement_basis_yaw
	)

	if direction.length() > 0.08:
		direction = direction.normalized()

		# Camera tự xoay ra phía sau hướng di chuyển.
		var target_yaw := atan2(
			-direction.x,
			-direction.z
		)

		camera_pivot.rotation.y = lerp_angle(
			camera_pivot.rotation.y,
			target_yaw,
			clampf(camera_follow_speed * delta, 0.0, 1.0)
		)

		# Nhân vật quay mặt theo hướng đang đi.
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

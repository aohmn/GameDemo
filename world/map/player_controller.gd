extends CharacterBody3D
class_name Player3DController

@export var move_speed: float = 5.0
@export var acceleration: float = 18.0
@export var gravity: float = 18.0
@export var camera_sensitivity: float = 0.005

@onready var camera_pivot: Node3D = $CameraPivot
@onready var joystick: Node = get_node("../HUD/Joystick")


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

	var direction := Vector3(
		input_vector.x,
		0.0,
		input_vector.y
	)

	direction = direction.rotated(
		Vector3.UP,
		camera_pivot.rotation.y
	)

	if direction.length() > 0.08:
		direction = direction.normalized()

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

	if direction.length() > 0.08:
		look_at(global_position + direction, Vector3.UP)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		var screen_width := get_viewport().get_visible_rect().size.x

		# Vuốt bên phải màn hình để xoay camera.
		if drag.position.x > screen_width * 0.4:
			camera_pivot.rotation.y -= (
				drag.relative.x * camera_sensitivity
			)

			camera_pivot.rotation.x = clamp(
				camera_pivot.rotation.x
				- drag.relative.y * camera_sensitivity,
				-0.75,
				-0.12
			)

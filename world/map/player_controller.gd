extends CharacterBody3D
class_name Player3DController

signal health_changed(current_health: float, maximum_health: float)

@export var save_id: String = "player"

@export_range(1.0, 1000.0, 1.0) var maximum_health: float = 100.0
@export_range(0.0, 1000.0, 1.0) var current_health: float = 100.0

@export var move_speed: float = 5.0
@export var acceleration: float = 18.0
@export var gravity: float = 18.0
@export var fall_recovery_y: float = -10.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var joystick: Node = get_node("../HUD/Joystick")

const CAMERA_FOLLOW_OFFSET: Vector3 = Vector3(0.0, 1.5, 0.0)


func _ready() -> void:
	add_to_group("save_participant")
	var needs_component := get_node_or_null("Needs")
	if needs_component != null and needs_component.has_signal("health_damage_requested"):
		needs_component.connect("health_damage_requested", apply_damage)
	maximum_health = maxf(1.0, maximum_health)
	current_health = clampf(current_health, 0.0, maximum_health)
	health_changed.emit(current_health, maximum_health)
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

	# Nếu rơi khỏi địa hình, đưa Player về Spawn Point của map hiện tại.
	if global_position.y < fall_recovery_y:
		var map_root := get_parent()
		var spawn_value: Variant = map_root.get("local_spawn_position")

		if spawn_value is Vector3:
			global_position = spawn_value
		else:
			global_position = Vector3(0.0, 0.05, 12.0)

		velocity = Vector3.ZERO
		print("[Player] Recovered after falling.")

	# Camera chỉ bám vị trí, không xoay theo nhân vật.
	camera_pivot.global_position = global_position + CAMERA_FOLLOW_OFFSET


## API sức khỏe tối thiểu của Player; UI chỉ đọc qua signal và thuộc tính.
func apply_damage(amount: float) -> void:
	if amount <= 0.0 or current_health <= 0.0:
		return
	current_health = maxf(0.0, current_health - amount)
	health_changed.emit(current_health, maximum_health)


func restore_health(amount: float) -> void:
	if amount <= 0.0 or current_health >= maximum_health:
		return
	current_health = minf(maximum_health, current_health + amount)
	health_changed.emit(current_health, maximum_health)


func serialize_state() -> Dictionary:
	return {
		"version": 1,
		"health": current_health,
		"position": [global_position.x, global_position.y, global_position.z]
	}


func deserialize_state(data: Dictionary) -> bool:
	if int(data.get("version", -1)) != 1:
		return false
	var health_value: Variant = data.get("health", current_health)
	if typeof(health_value) != TYPE_INT and typeof(health_value) != TYPE_FLOAT:
		return false
	current_health = clampf(float(health_value), 0.0, maximum_health)
	var position_value: Variant = data.get("position", [])
	if position_value is Array and position_value.size() == 3:
		global_position = Vector3(float(position_value[0]), float(position_value[1]), float(position_value[2]))
	velocity = Vector3.ZERO
	health_changed.emit(current_health, maximum_health)
	return true

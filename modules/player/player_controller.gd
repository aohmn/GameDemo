extends CharacterBody3D
class_name Player3DController

signal health_changed(current_health: float, maximum_health: float)

@export var save_id: String = "player"
@export var joystick_path: NodePath = NodePath("../HUD/Joystick")

@export_range(1.0, 1000.0, 1.0) var maximum_health: float = 100.0
@export_range(0.0, 1000.0, 1.0) var current_health: float = 100.0

@export var move_speed: float = 5.0
@export var acceleration: float = 18.0
@export var gravity: float = 18.0
@export var fall_recovery_y: float = -10.0

@onready var camera_pivot: Node3D = $CameraPivot

const CAMERA_FOLLOW_OFFSET: Vector3 = Vector3(0.0, 1.5, 0.0)
const POSITION_EMIT_INTERVAL: float = 0.1

var _touch_input := Vector2.ZERO
var _position_emit_accumulator: float = 0.0
var _recovery_requested := false


func _ready() -> void:
	SaveCoordinator.register_participant(save_id, self)
	add_to_group("player")

	EventBus.subscribe(PlayerEvents.HEALTH_DAMAGE_REQUESTED, _on_health_damage_requested)
	EventBus.subscribe(PlayerEvents.MOVE_INPUT_CHANGED, _on_move_input_changed)
	EventBus.subscribe(PlayerEvents.STATE_SNAPSHOT_REQUESTED, _on_state_snapshot_requested)

	maximum_health = maxf(1.0, maximum_health)
	current_health = clampf(current_health, 0.0, maximum_health)
	_emit_health_changed()

	# Camera không kế thừa góc xoay của nhân vật.
	camera_pivot.top_level = true
	camera_pivot.global_rotation = Vector3.ZERO
	camera_pivot.global_position = global_position + CAMERA_FOLLOW_OFFSET

	_emit_position()


func _exit_tree() -> void:
	if EventBus != null:
		EventBus.unsubscribe(PlayerEvents.HEALTH_DAMAGE_REQUESTED, _on_health_damage_requested)
		EventBus.unsubscribe(PlayerEvents.MOVE_INPUT_CHANGED, _on_move_input_changed)
		EventBus.unsubscribe(PlayerEvents.STATE_SNAPSHOT_REQUESTED, _on_state_snapshot_requested)
	SaveCoordinator.unregister_participant(save_id)


func _physics_process(delta: float) -> void:
	var keyboard_input := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	var input_vector := keyboard_input
	if _touch_input.length() > keyboard_input.length():
		input_vector = _touch_input

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

	# Phần hiển thị tự đăng ký nhận vận tốc; Player không giữ tham chiếu tới Visual.
	EventBus.emit_event(PlayerEvents.MOTION_CHANGED, {
		"velocity": Vector2(velocity.x, velocity.z)
	})

	_position_emit_accumulator += delta
	if _position_emit_accumulator >= POSITION_EMIT_INTERVAL:
		_position_emit_accumulator = 0.0
		_emit_position()

	# Nếu rơi khỏi địa hình, yêu cầu World đưa Player về Spawn Point hiện tại.
	if global_position.y < fall_recovery_y and not _recovery_requested:
		_recovery_requested = true
		EventBus.emit_event(WorldEvents.PLAYER_RECOVERY_REQUESTED, {"player": self})

	# Camera chỉ bám vị trí, không xoay theo nhân vật.
	camera_pivot.global_position = global_position + CAMERA_FOLLOW_OFFSET


## World gọi khi xác nhận Player rơi khỏi địa hình; Player không tự đọc MapController.
func recover_to(spawn_position: Vector3) -> void:
	global_position = spawn_position
	velocity = Vector3.ZERO
	_recovery_requested = false
	_emit_position()


## API sức khỏe tối thiểu của Player; UI chỉ đọc qua signal và sự kiện.
func apply_damage(amount: float) -> void:
	if amount <= 0.0 or current_health <= 0.0:
		return
	current_health = maxf(0.0, current_health - amount)
	_emit_health_changed()


func restore_health(amount: float) -> void:
	if amount <= 0.0 or current_health >= maximum_health:
		return
	current_health = minf(maximum_health, current_health + amount)
	_emit_health_changed()


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
	_recovery_requested = false
	_emit_health_changed()
	_emit_position()
	return true


func _on_health_damage_requested(payload: Dictionary) -> void:
	var amount_value: Variant = payload.get("amount")
	if typeof(amount_value) == TYPE_INT or typeof(amount_value) == TYPE_FLOAT:
		apply_damage(float(amount_value))


func _on_move_input_changed(payload: Dictionary) -> void:
	var direction_value: Variant = payload.get("direction")
	if direction_value is Vector2:
		_touch_input = (direction_value as Vector2).limit_length(1.0)


func _on_state_snapshot_requested(_payload: Dictionary) -> void:
	_emit_health_changed()
	_emit_position()


func _emit_health_changed() -> void:
	health_changed.emit(current_health, maximum_health)
	EventBus.emit_event(PlayerEvents.HEALTH_CHANGED, {
		"current": current_health,
		"maximum": maximum_health
	})


func _emit_position() -> void:
	EventBus.emit_event(WorldEvents.PLAYER_POSITION_CHANGED, {
		"position": global_position
	})

extends Node
class_name PlayerNeeds
## Nhu cầu sinh hoạt của Player. Thời gian chỉ đọc từ GameClock.
## UI và Player không truy cập trực tiếp node này; giao tiếp qua PlayerEvents.

signal needs_changed(hunger: float, thirst: float, energy: float)

const SAVE_VERSION: int = 1
const DEFAULT_VALUE: float = 100.0
const HUNGER_DRAIN_PER_MINUTE: float = 0.025
const THIRST_DRAIN_PER_MINUTE: float = 0.045
const ENERGY_DRAIN_PER_MINUTE: float = 0.018
const REST_ENERGY_PER_MINUTE: float = 0.55

@export var save_id: String = "player_needs"

@export_range(0.0, 100.0, 1.0) var hunger: float = DEFAULT_VALUE
@export_range(0.0, 100.0, 1.0) var thirst: float = DEFAULT_VALUE
@export_range(0.0, 100.0, 1.0) var energy: float = DEFAULT_VALUE

var _last_total_minutes: int = -1


func _ready() -> void:
	SaveCoordinator.register_participant(save_id, self)
	EventBus.subscribe(PlayerEvents.NEEDS_ACTION_REQUESTED, _on_needs_action_requested)
	EventBus.subscribe(PlayerEvents.STATE_SNAPSHOT_REQUESTED, _on_state_snapshot_requested)
	_last_total_minutes = GameClock.get_total_minutes()
	_emit_needs_changed()


func _exit_tree() -> void:
	if EventBus != null:
		EventBus.unsubscribe(PlayerEvents.NEEDS_ACTION_REQUESTED, _on_needs_action_requested)
		EventBus.unsubscribe(PlayerEvents.STATE_SNAPSHOT_REQUESTED, _on_state_snapshot_requested)
	SaveCoordinator.unregister_participant(save_id)


func _process(_delta: float) -> void:
	var current_minutes: int = GameClock.get_total_minutes()
	if _last_total_minutes < 0:
		_last_total_minutes = current_minutes
		return
	var elapsed_minutes: int = maxi(0, current_minutes - _last_total_minutes)
	_last_total_minutes = current_minutes
	if elapsed_minutes <= 0:
		return

	hunger = maxf(0.0, hunger - HUNGER_DRAIN_PER_MINUTE * float(elapsed_minutes))
	thirst = maxf(0.0, thirst - THIRST_DRAIN_PER_MINUTE * float(elapsed_minutes))
	energy = maxf(0.0, energy - ENERGY_DRAIN_PER_MINUTE * float(elapsed_minutes))
	_emit_needs_changed()

	# Đói hoặc khát kiệt sức gây mất máu nhẹ; Player vẫn sở hữu dữ liệu máu.
	if hunger <= 0.0 or thirst <= 0.0:
		_request_health_damage(0.05 * float(elapsed_minutes))


func consume_food(restoration: float = 35.0) -> bool:
	if restoration <= 0.0 or hunger >= 100.0:
		return false
	hunger = minf(100.0, hunger + restoration)
	_emit_needs_changed()
	return true


func drink_water(restoration: float = 40.0) -> bool:
	if restoration <= 0.0 or thirst >= 100.0:
		return false
	thirst = minf(100.0, thirst + restoration)
	_emit_needs_changed()
	return true


func rest(minutes: int = 60) -> bool:
	if minutes <= 0:
		return false
	hunger = maxf(0.0, hunger - HUNGER_DRAIN_PER_MINUTE * float(minutes))
	thirst = maxf(0.0, thirst - THIRST_DRAIN_PER_MINUTE * float(minutes))
	energy = minf(100.0, energy + REST_ENERGY_PER_MINUTE * float(minutes))
	GameClock.advance_minutes(minutes)
	# Cập nhật ngay cả khi GameClock đang pause.
	_last_total_minutes = GameClock.get_total_minutes()
	if hunger <= 0.0 or thirst <= 0.0:
		_request_health_damage(0.05 * float(minutes))
	_emit_needs_changed()
	return true


func get_state() -> Dictionary:
	return {"hunger": hunger, "thirst": thirst, "energy": energy}


func serialize_state() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"hunger": hunger,
		"thirst": thirst,
		"energy": energy
	}


func deserialize_state(data: Dictionary) -> bool:
	if int(data.get("version", -1)) != SAVE_VERSION:
		return false
	if not _is_number(data.get("hunger")) or not _is_number(data.get("thirst")) or not _is_number(data.get("energy")):
		return false
	hunger = clampf(float(data["hunger"]), 0.0, 100.0)
	thirst = clampf(float(data["thirst"]), 0.0, 100.0)
	energy = clampf(float(data["energy"]), 0.0, 100.0)
	_last_total_minutes = GameClock.get_total_minutes()
	_emit_needs_changed()
	return true


func _on_needs_action_requested(payload: Dictionary) -> void:
	var action_value: Variant = payload.get("action")
	if typeof(action_value) != TYPE_STRING and typeof(action_value) != TYPE_STRING_NAME:
		return
	var amount_value: Variant = payload.get("amount", 0.0)
	var amount: float = float(amount_value) if _is_number(amount_value) else 0.0

	match String(action_value):
		"eat":
			consume_food(amount if amount > 0.0 else 35.0)
		"drink":
			drink_water(amount if amount > 0.0 else 40.0)
		"rest":
			rest(int(amount) if amount > 0.0 else 60)
		_:
			push_warning("PlayerNeeds: hành động không hỗ trợ: %s" % str(action_value))


func _on_state_snapshot_requested(_payload: Dictionary) -> void:
	_emit_needs_changed()


func _emit_needs_changed() -> void:
	needs_changed.emit(hunger, thirst, energy)
	EventBus.emit_event(PlayerEvents.NEEDS_CHANGED, {
		"hunger": hunger,
		"thirst": thirst,
		"energy": energy
	})


func _request_health_damage(amount: float) -> void:
	EventBus.emit_event(PlayerEvents.HEALTH_DAMAGE_REQUESTED, {"amount": amount})


static func _is_number(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT

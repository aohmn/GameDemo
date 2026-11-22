extends Node3D
class_name NPCDirector

const NPC_AGENT_SCRIPT: Script = preload("res://modules/npc/npc_agent.gd")
const NPC_PROFILES: Array[Resource] = [
	preload("res://modules/npc/data/lan.tres"),
	preload("res://modules/npc/data/minh.tres")
]

## Cho phép scene kế thừa (ví dụ hồ câu) tắt NPC mà không cần scene map can thiệp.
@export var spawn_enabled: bool = true

var save_id: String = "npc_world"
var _npcs: Array[LifeNPC] = []
var _nearest_npc: LifeNPC
var _interaction_layer: CanvasLayer
var _interaction_button: Button
var _dialogue_panel: PanelContainer
var _dialogue_label: Label
var _simulation_accumulator: float = 0.0
var _position_broadcast_accumulator: float = 0.0
var _last_schedule: Dictionary = {}
var _player_position := Vector3.ZERO
var _has_player_position := false
var _save_registered := false

const SIMULATION_INTERVAL: float = 0.5
const POSITION_BROADCAST_INTERVAL: float = 0.2
const INTERACTION_RANGE: float = 3.2


func _ready() -> void:
	if not spawn_enabled:
		set_process(false)
		return

	_build_npcs()
	_build_interaction_ui()

	EventBus.subscribe(JobEvents.SCHEDULE_CHANGED, _on_schedule_changed)
	EventBus.subscribe(WorldEvents.PLAYER_POSITION_CHANGED, _on_player_position_changed)
	_save_registered = SaveCoordinator.register_participant(save_id, self)

	# Yêu cầu lịch hiện tại thay vì đọc GameClock trực tiếp.
	EventBus.emit_event(JobEvents.SCHEDULE_SNAPSHOT_REQUESTED)
	_broadcast_positions()


func _process(delta: float) -> void:
	_simulation_accumulator += delta
	if _simulation_accumulator >= SIMULATION_INTERVAL:
		_simulation_accumulator = 0.0
		_find_nearest_npc()

	_position_broadcast_accumulator += delta
	if _position_broadcast_accumulator >= POSITION_BROADCAST_INTERVAL:
		_position_broadcast_accumulator = 0.0
		_broadcast_positions()


func _exit_tree() -> void:
	if EventBus != null:
		EventBus.unsubscribe(JobEvents.SCHEDULE_CHANGED, _on_schedule_changed)
		EventBus.unsubscribe(WorldEvents.PLAYER_POSITION_CHANGED, _on_player_position_changed)
	if _save_registered:
		SaveCoordinator.unregister_participant(save_id)
		_save_registered = false


func get_npc_count() -> int:
	return _npcs.size()


func get_npcs() -> Array[LifeNPC]:
	var result: Array[LifeNPC] = []
	for npc: LifeNPC in _npcs:
		if is_instance_valid(npc):
			result.append(npc)
	return result


func serialize_state() -> Dictionary:
	var npc_states: Dictionary = {}
	for npc: LifeNPC in _npcs:
		if is_instance_valid(npc):
			npc_states[npc.npc_id] = npc.serialize_state()
	return {"version": 1, "npcs": npc_states}


func deserialize_state(data: Dictionary) -> bool:
	if int(data.get("version", -1)) != 1:
		return false
	var states: Variant = data.get("npcs", {})
	if not (states is Dictionary):
		return false
	for npc: LifeNPC in _npcs:
		var state: Variant = states.get(npc.npc_id, {})
		if state is Dictionary and not state.is_empty():
			npc.deserialize_state(state)
	# NPC không đọc GameClock; yêu cầu JobSystem phát lại lịch hiện tại.
	EventBus.emit_event(JobEvents.SCHEDULE_SNAPSHOT_REQUESTED)
	return true


func _build_npcs() -> void:
	for profile: Resource in _load_npc_profiles():
		if not (profile is NPCProfile):
			push_warning("NPCDirector: skipped resource that is not an NPCProfile.")
			continue
		var npc_profile := profile as NPCProfile
		if npc_profile.npc_id.is_empty() or npc_profile.display_name.is_empty():
			push_warning("NPCDirector: skipped profile without stable ID/name.")
			continue
		var npc := NPC_AGENT_SCRIPT.new() as LifeNPC
		npc.configure(npc_profile)
		add_child(npc)
		npc.global_position = npc_profile.home_position
		_npcs.append(npc)


func _load_npc_profiles() -> Array[Resource]:
	var profiles: Array[Resource] = []
	for profile: Resource in NPC_PROFILES:
		if profile != null:
			profiles.append(profile)
	return profiles


func _on_schedule_changed(payload: Dictionary) -> void:
	var activity_value: Variant = payload.get("activity")
	if typeof(activity_value) != TYPE_STRING and typeof(activity_value) != TYPE_STRING_NAME:
		push_warning("NPCDirector: schedule thiếu activity hợp lệ.")
		return
	_last_schedule = payload.duplicate(true)
	var activity := StringName(str(activity_value))
	for npc: LifeNPC in _npcs:
		if is_instance_valid(npc):
			npc.apply_schedule(activity)


func _on_player_position_changed(payload: Dictionary) -> void:
	var position_value: Variant = payload.get("position")
	if position_value is Vector3:
		_player_position = position_value
		_has_player_position = true


func _find_nearest_npc() -> void:
	if not _has_player_position:
		return
	var nearest: LifeNPC
	var nearest_distance := INTERACTION_RANGE
	for npc: LifeNPC in _npcs:
		if not is_instance_valid(npc):
			continue
		var distance := _player_position.distance_to(npc.global_position)
		if distance < nearest_distance:
			nearest = npc
			nearest_distance = distance
	_nearest_npc = nearest
	_interaction_button.visible = is_instance_valid(_nearest_npc)
	if not is_instance_valid(_nearest_npc):
		_dialogue_panel.hide()


func _broadcast_positions() -> void:
	var entries: Array[Dictionary] = []
	for npc: LifeNPC in _npcs:
		if is_instance_valid(npc):
			entries.append({
				"id": npc.npc_id,
				"position": npc.global_position
			})
	EventBus.emit_event(WorldEvents.NPC_POSITIONS_CHANGED, {"npcs": entries})


func _build_interaction_ui() -> void:
	_interaction_layer = CanvasLayer.new()
	_interaction_layer.layer = 5
	add_child(_interaction_layer)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_interaction_layer.add_child(root)

	_interaction_button = Button.new()
	_interaction_button.text = "NÓI CHUYỆN"
	_interaction_button.position = Vector2(16.0, 250.0)
	_interaction_button.size = Vector2(180.0, 54.0)
	_interaction_button.visible = false
	_interaction_button.pressed.connect(_on_interact_pressed)
	root.add_child(_interaction_button)

	_dialogue_panel = PanelContainer.new()
	_dialogue_panel.position = Vector2(16.0, 315.0)
	_dialogue_panel.size = Vector2(300.0, 112.0)
	_dialogue_panel.visible = false
	root.add_child(_dialogue_panel)
	_dialogue_label = Label.new()
	_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue_label.text = ""
	_dialogue_panel.add_child(_dialogue_label)


func _on_interact_pressed() -> void:
	if _dialogue_panel.visible:
		_dialogue_panel.hide()
		return
	if not is_instance_valid(_nearest_npc):
		return
	_dialogue_label.text = _nearest_npc.get_dialogue()
	_dialogue_panel.visible = true

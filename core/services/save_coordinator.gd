extends Node
## Điều phối save/load cho GameClock và các node trong group save_participant.

const SAVE_PATH: String = "user://projectgame_save.cfg"
const SAVE_VERSION: int = 1

var _autosave_elapsed: float = 0.0
const AUTOSAVE_INTERVAL: float = 60.0


func _process(delta: float) -> void:
	_autosave_elapsed += delta
	if _autosave_elapsed >= AUTOSAVE_INTERVAL:
		_autosave_elapsed = 0.0
		save_game()


func save_game() -> bool:
	var config := ConfigFile.new()
	config.set_value("meta", "version", SAVE_VERSION)
	config.set_value("clock", "state", GameClock.serialize())

	for participant in get_tree().get_nodes_in_group("save_participant"):
		if not is_instance_valid(participant) or not participant.has_method("serialize_state"):
			continue
		var save_id: String = str(participant.get("save_id"))
		if save_id.is_empty() or save_id == "<null>":
			continue
		config.set_value("participants", save_id, participant.call("serialize_state"))

	var error: Error = config.save(SAVE_PATH)
	if error != OK:
		push_error("SaveCoordinator: không thể lưu game: %s" % error_string(error))
		return false
	return true


func load_game() -> bool:
	var config := ConfigFile.new()
	var error: Error = config.load(SAVE_PATH)
	if error != OK:
		return false
	if int(config.get_value("meta", "version", -1)) != SAVE_VERSION:
		push_warning("SaveCoordinator: phiên bản save không tương thích.")
		return false

	var clock_state: Variant = config.get_value("clock", "state", {})
	if clock_state is Dictionary:
		GameClock.deserialize(clock_state)

	for participant in get_tree().get_nodes_in_group("save_participant"):
		if not is_instance_valid(participant) or not participant.has_method("deserialize_state"):
			continue
		var save_id: String = str(participant.get("save_id"))
		if save_id.is_empty() or save_id == "<null>" or not config.has_section_key("participants", save_id):
			continue
		var state: Variant = config.get_value("participants", save_id)
		if state is Dictionary:
			participant.call("deserialize_state", state)
	return true


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()

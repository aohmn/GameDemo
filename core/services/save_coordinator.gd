extends Node
## Điều phối save/load qua danh sách participant đăng ký độc lập.
## Không quét group, không tham chiếu trực tiếp module gameplay hay GameClock.

const SAVE_PATH: String = "user://projectgame_save.cfg"
const SAVE_VERSION: int = 2
const LEGACY_VERSION: int = 1
const PARTICIPANT_SECTION: String = "participants"

var _autosave_elapsed: float = 0.0
const AUTOSAVE_INTERVAL: float = 60.0

var _participants: Dictionary = {}


func _process(delta: float) -> void:
	_autosave_elapsed += delta
	if _autosave_elapsed >= AUTOSAVE_INTERVAL:
		_autosave_elapsed = 0.0
		save_game()


## Đăng ký một đối tượng có serialize_state()/deserialize_state().
## Mỗi save_id chỉ có một participant; đăng ký lại sẽ thay thế.
func register_participant(save_id: String, participant: Object) -> bool:
	var normalized_id := save_id.strip_edges()
	if normalized_id.is_empty():
		push_warning("SaveCoordinator: save_id rỗng, không đăng ký.")
		return false
	if participant == null:
		push_warning("SaveCoordinator: participant null cho '%s'." % normalized_id)
		return false
	if not participant.has_method("serialize_state") or not participant.has_method("deserialize_state"):
		push_warning("SaveCoordinator: participant '%s' thiếu API serialize/deserialize." % normalized_id)
		return false
	_participants[normalized_id] = participant
	return true


func unregister_participant(save_id: String) -> void:
	_participants.erase(save_id.strip_edges())


func has_participant(save_id: String) -> bool:
	_prune_invalid_participants()
	return _participants.has(save_id.strip_edges())


func get_registered_ids() -> PackedStringArray:
	_prune_invalid_participants()
	var ids := PackedStringArray()
	for save_id: String in _participants.keys():
		ids.append(save_id)
	ids.sort()
	return ids


func save_game() -> bool:
	_prune_invalid_participants()
	var config := ConfigFile.new()
	config.set_value("meta", "version", SAVE_VERSION)

	for save_id: String in _participants.keys():
		var participant: Object = _participants[save_id]
		var state: Variant = participant.call("serialize_state")
		if state is Dictionary:
			config.set_value(PARTICIPANT_SECTION, save_id, state)
		else:
			push_warning("SaveCoordinator: '%s' trả về dữ liệu không phải Dictionary." % save_id)

	var error: Error = config.save(SAVE_PATH)
	if error != OK:
		push_error("SaveCoordinator: không thể lưu game: %s" % error_string(error))
		return false
	return true


func load_game() -> bool:
	_prune_invalid_participants()
	var config := ConfigFile.new()
	var error: Error = config.load(SAVE_PATH)
	if error != OK:
		return false

	var version: int = int(config.get_value("meta", "version", -1))
	if version != SAVE_VERSION and version != LEGACY_VERSION:
		push_warning("SaveCoordinator: phiên bản save không tương thích: %d." % version)
		return false

	# Save v1 lưu GameClock ở section "clock". Chuyển sang participant hiện tại
	# mà không cần SaveCoordinator biết lớp GameClock.
	if version == LEGACY_VERSION:
		var legacy_clock: Variant = config.get_value("clock", "state", {})
		if legacy_clock is Dictionary and not legacy_clock.is_empty():
			var clock_participant: Object = _participants.get("game_clock")
			if clock_participant != null and clock_participant.has_method("deserialize_state"):
				clock_participant.call("deserialize_state", legacy_clock)
			else:
				push_warning("SaveCoordinator: không có participant 'game_clock' để nhận dữ liệu save v1.")

	for save_id: String in _participants.keys():
		if not config.has_section_key(PARTICIPANT_SECTION, save_id):
			continue
		var state: Variant = config.get_value(PARTICIPANT_SECTION, save_id)
		if state is Dictionary:
			var participant: Object = _participants[save_id]
			participant.call("deserialize_state", state)

	return true


func _prune_invalid_participants() -> void:
	for save_id: String in _participants.keys():
		var participant: Variant = _participants[save_id]
		if participant == null or not is_instance_valid(participant):
			_participants.erase(save_id)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()

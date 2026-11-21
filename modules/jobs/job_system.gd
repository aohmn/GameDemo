extends Node
## JobSystem (autoload): cầu nối giữa lịch làm việc và các module khác.
## Đọc thời gian từ GameClock, lấy hoạt động từ JobService và phát
## JobEvents.SCHEDULE_CHANGED. NPC không cần gọi trực tiếp module nào trong số này.

var _current_schedule: Dictionary = {}


func _ready() -> void:
	_current_schedule = _build_schedule(GameClock.get_hour())
	EventBus.subscribe(CoreEvents.HOUR_CHANGED, _on_hour_changed)
	EventBus.subscribe(JobEvents.SCHEDULE_SNAPSHOT_REQUESTED, _on_snapshot_requested)


func _exit_tree() -> void:
	if EventBus != null:
		EventBus.unsubscribe(CoreEvents.HOUR_CHANGED, _on_hour_changed)
		EventBus.unsubscribe(JobEvents.SCHEDULE_SNAPSHOT_REQUESTED, _on_snapshot_requested)


## Trả về bản sao lịch hiện tại để module khác chỉ đọc.
func get_current_schedule() -> Dictionary:
	return _current_schedule.duplicate(true)


func _on_hour_changed(payload: Dictionary) -> void:
	var hour_value: Variant = payload.get("hour")
	if typeof(hour_value) != TYPE_INT and typeof(hour_value) != TYPE_FLOAT:
		return
	_publish(int(hour_value))


func _on_snapshot_requested(_payload: Dictionary) -> void:
	if _current_schedule.is_empty():
		_current_schedule = _build_schedule(GameClock.get_hour())
	EventBus.emit_event(JobEvents.SCHEDULE_CHANGED, _current_schedule.duplicate(true))


func _publish(hour: int) -> void:
	_current_schedule = _build_schedule(hour)
	EventBus.emit_event(JobEvents.SCHEDULE_CHANGED, _current_schedule.duplicate(true))


func _build_schedule(hour: int) -> Dictionary:
	return {
		"hour": hour,
		"activity": JobService.get_activity(hour),
		"shift_start": JobService.get_shift_start(),
		"shift_end": JobService.get_shift_end()
	}

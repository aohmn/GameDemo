extends Node
## EventBus: đường ống sự kiện dùng chung (AGENTS §6).
## Không biết gì về gameplay. Tên sự kiện do module phát tự định nghĩa.
## Handler nhận đúng 1 tham số: payload (Dictionary).

var _handlers: Dictionary = {}


func emit_event(event_name: StringName, payload: Dictionary = {}) -> void:
	if not _handlers.has(event_name):
		return
	var current: Array[Callable] = _handlers[event_name]
	# Duyệt bản sao để handler có thể tự unsubscribe khi đang emit.
	var snapshot: Array[Callable] = []
	snapshot.assign(current)
	for handler: Callable in snapshot:
		if not handler.is_valid():
			unsubscribe(event_name, handler)
			continue
		handler.call(payload)


## Cho phép nơi phát biết có ai đang nghe để chọn fallback (ví dụ đổi scene).
func has_listeners(event_name: StringName) -> bool:
	if not _handlers.has(event_name):
		return false
	var list: Array = _handlers[event_name]
	return not list.is_empty()


func subscribe(event_name: StringName, handler: Callable) -> void:
	if not handler.is_valid():
		push_warning("EventBus.subscribe: handler không hợp lệ cho sự kiện '%s'" % event_name)
		return
	if not _handlers.has(event_name):
		var created: Array[Callable] = []
		_handlers[event_name] = created
	var list: Array[Callable] = _handlers[event_name]
	if list.has(handler):
		return
	list.append(handler)


func unsubscribe(event_name: StringName, handler: Callable) -> void:
	if not _handlers.has(event_name):
		return
	var list: Array[Callable] = _handlers[event_name]
	list.erase(handler)
	if list.is_empty():
		_handlers.erase(event_name)

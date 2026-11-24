extends Node

## Hệ thống phân phối sự kiện toàn cục EventBus (Autoload).
## Quản lý đăng ký Callable độc lập, tự dọn dẹp các Callable khi Object bị giải phóng (freed).

# Lưu trữ danh sách Callable theo event_name: Dictionary[String, Array[Callable]]
var _subscribers: Dictionary = {}


## Đăng ký lắng nghe một sự kiện bằng Callable.
func subscribe(event_name: String, callback: Callable) -> void:
	if not callback.is_valid():
		push_warning("Callable không hợp lệ khi subscribe sự kiện: " + event_name)
		return

	if not _subscribers.has(event_name):
		var list: Array[Callable] = []
		_subscribers[event_name] = list

	var callbacks: Array[Callable] = _subscribers[event_name]
	if not callbacks.has(callback):
		callbacks.append(callback)


## Hủy đăng ký Callable khỏi sự kiện.
func unsubscribe(event_name: String, callback: Callable) -> void:
	if not _subscribers.has(event_name):
		return

	var callbacks: Array[Callable] = _subscribers[event_name]
	callbacks.erase(callback)
	if callbacks.is_empty():
		_subscribers.erase(event_name)


## Phát sự kiện tới tất cả các listener đã đăng ký.
## Tự động bỏ qua và xóa các Callable thuộc về Object đã bị giải phóng (free).
func emit_event(event_name: String, payload: Dictionary = {}) -> void:
	if not _subscribers.has(event_name):
		return

	var callbacks: Array[Callable] = _subscribers[event_name]
	var valid_callbacks: Array[Callable] = []

	for cb in callbacks:
		var target: Object = cb.get_object()
		if target != null and is_instance_valid(target) and cb.is_valid():
			valid_callbacks.append(cb)
			cb.call(payload)

	if valid_callbacks.size() != callbacks.size():
		if valid_callbacks.is_empty():
			_subscribers.erase(event_name)
		else:
			_subscribers[event_name] = valid_callbacks


## Hủy tất cả các listener của một sự kiện hoặc toàn bộ hệ thống.
func clear(event_name: String = "") -> void:
	if event_name.is_empty():
		_subscribers.clear()
	else:
		_subscribers.erase(event_name)

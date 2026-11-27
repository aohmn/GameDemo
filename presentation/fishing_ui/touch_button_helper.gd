extends Node
## Hỗ trợ chạm nhiều ngón (InputEventScreenTouch) cho các nút câu cá,
## giúp vừa giữ joystick vừa bấm Thả/Giật/Kéo/Xả trên Android.

var _entries: Array[Dictionary] = []


func bind_tap(btn: Button, on_tap: Callable) -> void:
	_entries.append({"btn": btn, "mode": "tap", "down": on_tap, "up": Callable(), "touch_idx": -1})


func bind_hold(btn: Button, on_down: Callable, on_up: Callable) -> void:
	_entries.append({"btn": btn, "mode": "hold", "down": on_down, "up": on_up, "touch_idx": -1})


func _input(event: InputEvent) -> void:
	if not (event is InputEventScreenTouch):
		return
	var touch := event as InputEventScreenTouch
	for entry in _entries:
		var btn: Button = entry["btn"] as Button
		if btn == null or not is_instance_valid(btn):
			continue
		if entry["mode"] == "hold" and not touch.pressed and touch.index == int(entry["touch_idx"]):
			entry["touch_idx"] = -1
			var up_cb: Callable = entry["up"] as Callable
			if up_cb.is_valid():
				up_cb.call()
			get_viewport().set_input_as_handled()
			return
		if touch.pressed and btn.is_visible_in_tree() and not btn.disabled:
			if btn.get_global_rect().has_point(touch.position):
				if entry["mode"] == "hold":
					entry["touch_idx"] = touch.index
				var down_cb: Callable = entry["down"] as Callable
				if down_cb.is_valid():
					down_cb.call()
				get_viewport().set_input_as_handled()
				return

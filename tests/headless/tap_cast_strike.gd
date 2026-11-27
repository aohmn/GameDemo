extends SceneTree
var main: Node
var sub: SubViewport
var f := 0
var pos := Vector2.ZERO
var bite_f := -1
var fight := false
func _mouse(p: Vector2, pressed: bool) -> void:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.position = p
	e.global_position = p
	e.pressed = pressed
	sub.push_input(e, true)
func _initialize() -> void:
	sub = SubViewport.new()
	sub.size = Vector2i(1280, 576)
	sub.handle_input_locally = true
	sub.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(sub)
	main = (load("res://scenes/boot/main.tscn") as PackedScene).instantiate()
	sub.add_child(main)
func _physics_process(_d: float) -> bool:
	f += 1
	var ui: Control = main.get("_fishing_ui")
	var api: RefCounted = main.get("_fishing_api")
	var player: Node3D = main.get_node("Player")
	if f == 5: player.global_position = Vector3(-2.0, 0.05, 22.6)
	if f == 40: pos = ui.get("_btn_cast").get_global_rect().get_center(); _mouse(pos, true)
	if f == 46: _mouse(pos, false)
	var st: String = api.call("get_state")
	if f > 50 and st == "BITE" and bite_f < 0:
		bite_f = f
		pos = ui.get("_btn_strike").get_global_rect().get_center()
		_mouse(pos, true)                       # chạm nút GIẬT CẦN, giữ 4 khung (~70 ms)
	if bite_f > 0 and f == bite_f + 4:
		_mouse(pos, false)
	if bite_f > 0 and f == bite_f + 8:
		print("sau chạm GIẬT CẦN (giữ 4 khung): state=", api.call("get_state"))
		quit()
	if f > 3000:
		print("không thấy BITE, state=", st); quit()
	return false

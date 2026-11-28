extends SceneTree
var main: Node
var sub: SubViewport
var f := 0
var tap_pos := Vector2.ZERO
var tap_start := -1
func _mouse(p: Vector2, pressed: bool) -> void:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.position = p
	e.global_position = p
	e.pressed = pressed
	sub.push_input(e, true)
func _tap(c: Control) -> void:
	tap_pos = c.get_global_rect().get_center()
	tap_start = f
	_mouse(tap_pos, true)
func _find_button(root_node: Node, txt: String) -> Button:
	for n in root_node.find_children("*", "Button", true, false):
		if (n as Button).text == txt and (n as Button).is_visible_in_tree():
			return n
	return null
const BackupHelper: Script = preload("res://tests/headless/save_backup_helper.gd")

func _initialize() -> void:
	BackupHelper.backup_user_saves()
	sub = SubViewport.new()
	sub.size = Vector2i(1280, 576)
	sub.handle_input_locally = true
	sub.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(sub)
	main = (load("res://scenes/boot/main.tscn") as PackedScene).instantiate()
	sub.add_child(main)
func _physics_process(_d: float) -> bool:
	f += 1
	if tap_start >= 0 and f == tap_start + 6:
		_mouse(tap_pos, false)
		tap_start = -1
	var inv = main.get("_inventory_api")
	var cult = main.get("_cultivation_api")
	var eco = main.get("_economy_api")
	var iui: Control = main.get("_fishing_inventory_ui")
	var cui: Control = main.get("_cultivation_ui")
	if f == 5:
		for w in [100, 120, 140]: inv.call("add_fish", "fish_ca_chem", w)
		print("HUD tu vi: ", cui.get("_realm_label").text, " | ", cui.get("_exp_label").text, " rect=", cui.get_child(0).get_global_rect())
	if f == 20: _tap(iui.get("_toggle_button"))
	if f == 50:
		var b := _find_button(iui, "Hấp thu")
		print("thấy nút Hấp thu: ", b != null)
		_tap(b)
	if f == 80:
		print("sau Hấp thu(1 con): tu vi=", cult.call("get_total_exp"), " cá còn=", inv.call("get_fish_info", "fish_ca_chem"), " toast='", cui.get("_toast").text, "'")
		print("HUD: ", cui.get("_exp_label").text)
		var bal: int = eco.call("get_balance")
		print("số dư trước bán=", bal)
		_tap(_find_button(iui, "Bán"))
	if f == 110:
		print("sau Bán(1 con): số dư=", eco.call("get_balance"), " cá còn=", inv.call("get_fish_info", "fish_ca_chem"), " toast='", cui.get("_toast").text, "'")
		cult.call("add_exp", 100000, "test")
		print("đủ để đột phá? ", cult.call("can_breakthrough"), " nút hiện=", cui.get("_btn_breakthrough").visible)
	if f == 120: _tap(cui.get("_btn_breakthrough"))
	if f == 150:
		print("sau Đột phá: ", cult.call("get_current_realm_name"), " tầng ", cult.call("get_current_layer"), " | HUD: ", cui.get("_realm_label").text, " | toast='", cui.get("_toast").text, "'")
		BackupHelper.restore_user_saves()
		quit()
	return false

extends SceneTree
var m: Node
var f := 0
func _initialize() -> void:
	m = (load("res://scenes/boot/main.tscn") as PackedScene).instantiate()
	root.add_child(m)
func _physics_process(_d: float) -> bool:
	f += 1
	var player: Node3D = m.get_node("Player")
	var ui: Control = m.get("_fishing_ui")
	var api: RefCounted = m.get("_fishing_api")
	if f == 5: player.global_position = Vector3(4.4, 1.1, -11.2)
	if f > 10 and f < 20: player.call("set_move_direction", Vector2(-1, 0))
	if f == 20: player.call("set_move_direction", Vector2.ZERO)
	if f == 40:
		print("vị trí=", player.global_position, " hướng=", player.call("get_facing_vector"), " nút disabled=", ui.get("_btn_cast").disabled, " text=", ui.get("_btn_cast").text)
		ui.get("_btn_cast").pressed.emit()
	if f == 50:
		print("state=", api.call("get_state"))
		quit()
	return false

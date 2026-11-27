extends SceneTree
var m: Node
var f := 0
var tests := [["đài quan hải: lên bậc", Vector3(14.2, 0.05, 9.0), Vector2(0, 1)], ["ra mép đông", Vector3(10, 0.05, -2), Vector2(1, 0)], ["ra mép tây", Vector3(-10, 0.05, -2), Vector2(-1, 0)], ["ra mép nam (tây cầu)", Vector3(-10, 0.05, 8), Vector2(0, -1)], ["ra mép bậc ao (đông)", Vector3(10, 1.1, -6), Vector2(1, 0)], ["ra mép sân Tiên Các (tây)", Vector3(-6, 2.3, -22), Vector2(-1, 0)]]
var idx := 0
var t0 := 0
func _initialize() -> void:
	m = (load("res://scenes/boot/main.tscn") as PackedScene).instantiate()
	root.add_child(m)
func _physics_process(_d: float) -> bool:
	f += 1
	var p: Node3D = m.get_node("Player")
	if idx >= tests.size():
		quit(); return false
	var t: Array = tests[idx]
	if f == t0 + 5:
		p.global_position = t[1]
	if f > t0 + 8 and f < t0 + 360:
		p.call("set_move_direction", t[2])
	if f == t0 + 360:
		p.call("set_move_direction", Vector2.ZERO)
		print(t[0], ": vị trí cuối=", Vector3(snappedf(p.global_position.x,0.1), snappedf(p.global_position.y,0.1), snappedf(p.global_position.z,0.1)))
		idx += 1
		t0 = f
	return false

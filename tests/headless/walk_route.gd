extends SceneTree
var main: Node
var f := 0
var wp := [Vector2(-2, 7), Vector2(0, 2), Vector2(0, -4), Vector2(0, -8), Vector2(0, -11.2), Vector2(0, -14.5), Vector2(0, -17.6), Vector2(0, -19.6), Vector2(0, -21.5)]
var idx := 0
var log := []
func _initialize() -> void:
	main = (load("res://scenes/boot/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
func _physics_process(_d: float) -> bool:
	f += 1
	var player: Node3D = main.get_node("Player")
	if f < 10: return false
	if idx < wp.size():
		var t: Vector2 = wp[idx]
		var p := Vector2(player.global_position.x, player.global_position.z)
		var d := t - p
		if d.length() < 0.5:
			print("tới waypoint ", idx, " ", t, " y=", snappedf(player.global_position.y, 0.01))
			idx += 1
		else:
			var dir := d.normalized()
			player.call("set_move_direction", Vector2(dir.x, -dir.y))
	else:
		player.call("set_move_direction", Vector2.ZERO)
		print("XONG route, y=", player.global_position.y)
		quit()
	if f > 3000:
		print("KẸT tại waypoint ", idx, " pos=", player.global_position)
		quit()
	return false

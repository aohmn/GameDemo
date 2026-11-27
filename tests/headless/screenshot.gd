extends SceneTree
var main: Node
var f := 0
var shots: Array = []
func _initialize() -> void:
	root.size = Vector2i(1280, 720)
	main = (load("res://scenes/boot/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	var args := OS.get_cmdline_user_args()
	for a in args: shots.append(a)
func _process(_d: float) -> bool:
	f += 1
	var player: Node3D = main.get_node("Player")
	var cam: Camera3D = main.get("_camera")
	if f == 3:
		var spec: String = shots[0]   # "x,z" vị trí người chơi
		var p := spec.split(",")
		player.global_position = Vector3(float(p[0]), float(p[2]) if p.size() > 2 else 0.05, float(p[1]))
	if f == 40:
		var img: Image = root.get_texture().get_image()
		img.save_png(shots[1])
		print("saved ", shots[1], " ", img.get_size())
		quit()
	return false

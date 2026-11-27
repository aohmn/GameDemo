extends SceneTree
var m: Node
var f := 0
func _initialize() -> void:
	m = (load("res://scenes/boot/main.tscn") as PackedScene).instantiate()
	root.add_child(m)
func _physics_process(_d: float) -> bool:
	f += 1
	if f == 15:
		var map: Node = m.get("_map_manager").call("get_current_map")
		var pts := {"cuối cầu → biển": Vector3(-2,0,26), "trên cầu tàu": Vector3(-2,0,16), "giữa ao sen": Vector3(0.0,1,-11.2) + Vector3(2.0,0,0), "lối cầu đá": Vector3(0,1,-11.2), "bờ ao": Vector3(3.9,1,-11.2), "quảng trường": Vector3(0,0,1.5), "biển phía đông": Vector3(25,0,3)}
		for k in pts:
			print(k, ": nước=", map.call("is_water_at", pts[k]), " điểm=", map.call("get_fishing_spot_at", pts[k]))
		quit()
	return false

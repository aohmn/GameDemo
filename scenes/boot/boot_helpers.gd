extends RefCounted
## Helper khởi tạo UI đấu cá và cầu nối dây câu giữa EquipmentAPI và FishingAPI.


static func mount_battle_ui(hud: CanvasLayer, fishing_api: RefCounted) -> void:
	var battle_ui_script: Script = load("res://presentation/fishing_battle_ui/fishing_battle_ui.gd") as Script
	if battle_ui_script != null and hud != null:
		var battle_ui := battle_ui_script.new() as Control
		if battle_ui != null:
			hud.add_child(battle_ui)
			if fishing_api != null and battle_ui.has_method("set_fishing_api"):
				battle_ui.call("set_fishing_api", fishing_api)


static func get_equipped_line(equipment_api: RefCounted) -> Resource:
	if equipment_api == null:
		return null
	var line_id: String = str(equipment_api.call("get_equipped_item_id", "line"))
	if line_id.is_empty():
		return null
	var spec: Resource = equipment_api.call("get_item_spec", line_id) as Resource
	if spec == null:
		return null
	var res: Resource = spec.duplicate()
	var cur_dur: float = float(equipment_api.call("get_item_durability", line_id))
	if "current_durability" in res:
		res.set("current_durability", cur_dur)
	elif "durability" in res:
		res.set("durability", cur_dur)
	return res


static func consume_line_durability(equipment_api: RefCounted, used: float) -> void:
	if equipment_api != null and used > 0.0:
		equipment_api.call("consume_durability", "line", used)


static func setup_sky_and_sun(parent: Node, sky_script: Script, map_manager: Node3D) -> Node:
	var sky: Node = sky_script.new()
	parent.add_child(sky)
	sync_sun_direction(sky, map_manager)
	return sky


static func sync_sun_direction(sky_dome: Node, map_manager: Node3D) -> void:
	if map_manager == null:
		return
	var current_map: Node = map_manager.call("get_current_map") as Node
	if current_map == null or not current_map.has_method("get_sun_direction"):
		return
	var sun_dir: Vector3 = current_map.call("get_sun_direction")
	if sky_dome != null and sky_dome.has_method("set_sun_direction"):
		sky_dome.call("set_sun_direction", sun_dir)
	if current_map.has_method("get_water_material"):
		var water_mat: ShaderMaterial = current_map.call("get_water_material") as ShaderMaterial
		if water_mat != null:
			water_mat.set_shader_parameter("sun_dir", sun_dir)


static func instantiate_ui(hud: CanvasLayer, path: String) -> Control:
	if not ResourceLoader.exists(path):
		return null
	var scene := load(path) as PackedScene
	if scene == null:
		return null
	var ui := scene.instantiate() as Control
	if ui != null and hud != null:
		hud.add_child(ui)
	return ui


static func instantiate_scene(parent: Node, path: String) -> Node:
	if not ResourceLoader.exists(path):
		return null
	var scene := load(path) as PackedScene
	if scene == null:
		return null
	var node := scene.instantiate()
	if node != null and parent != null:
		parent.add_child(node)
	return node

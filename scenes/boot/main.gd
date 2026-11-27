extends Node3D

const MAP_MANAGER_SCRIPT: Script = preload("res://scenes/boot/map_manager.gd")
const SERVICE_COORDINATOR_SCRIPT: Script = preload("res://scenes/boot/service_coordinator.gd")
const UI_ACTION_ROUTER_SCRIPT: Script = preload("res://scenes/boot/ui_action_router.gd")
const CAST_COORDINATOR_SCRIPT: Script = preload("res://scenes/boot/cast_coordinator.gd")

const PLAYER_SCENE_PATH: String = "res://modules/player/scenes/player.tscn"
const JOYSTICK_SCENE_PATH: String = "res://presentation/joystick/joystick.tscn"
const SKY_DOME_SCENE_PATH: String = "res://modules/sky_dome/scenes/sky_dome.tscn"
const INVENTORY_API_PATH: String = "res://modules/inventory/api/inventory_api.gd"
const FISHING_INVENTORY_UI_PATH: String = "res://presentation/fishing_inventory_ui/fishing_inventory_ui.tscn"
const FISHING_UI_PATH: String = "res://presentation/fishing_ui/fishing_ui.tscn"
const FISHING_RIG_PATH: String = "res://presentation/fishing_rig/fishing_rig.tscn"
const ECONOMY_API_PATH: String = "res://modules/economy/api/economy_api.gd"
const SHOP_API_PATH: String = "res://modules/shop/api/shop_api.gd"
const FISHING_API_PATH: String = "res://modules/fishing/api/fishing_api.gd"
const CULTIVATION_API_PATH: String = "res://modules/cultivation/api/cultivation_api.gd"
const EQUIPMENT_API_PATH: String = "res://modules/equipment/api/equipment_api.gd"
const EQUIPMENT_UI_PATH: String = "res://presentation/equipment_ui/equipment_ui.tscn"

var _map_manager: Node3D
var _coordinator: RefCounted
var _camera: Camera3D
var _player: CharacterBody3D
var _joystick: Node
var _sky_dome: Node3D
var _inventory_api: RefCounted
var _economy_api: RefCounted
var _shop_api: RefCounted
var _fishing_api: RefCounted
var _cultivation_api: RefCounted
var _equipment_api: RefCounted
var _cultivation_ui: Control
var _equipment_ui: Control
var _shop_ui: Control
var _ui_router: RefCounted
var _fishing_inventory_ui: Control
var _fishing_ui: Control
var _fishing_rig: Node3D
var _cast_coordinator: RefCounted
var _hud: CanvasLayer


func _ready() -> void:
	_create_camera()
	_create_sky_dome()
	_create_map_manager()
	_sync_sun_direction()
	_create_player()
	_setup_hud()
	_create_joystick()
	_init_services()
	_create_inventory_ui()
	_create_cultivation_ui()
	_create_equipment_ui()
	_shop_ui = _ui_router.call("build_shop_ui", _hud, _shop_api, _economy_api, _cultivation_api) as Control
	_ui_router.call("build_skill_ui", _hud, _fishing_api)
	_create_fishing_ui()
	_create_fishing_rig()

	var eb: Node = get_node_or_null("/root/EventBus")
	if eb != null and eb.has_method("subscribe"):
		eb.call("subscribe", "map_change_requested", Callable(self, "_on_map_change_requested"))


func _on_map_change_requested(payload: Dictionary) -> void:
	var target_id: String = str(payload.get("target_map_id", ""))
	if not target_id.is_empty():
		change_map(target_id)


func change_map(target_map_id: String) -> bool:
	if _map_manager == null:
		return false
	var ok: bool = bool(_map_manager.call("load_map", target_map_id))
	if not ok:
		return false

	_sync_sun_direction()
	if _player != null:
		var spawn_pos: Vector3 = _map_manager.call("get_default_spawn_position", target_map_id) as Vector3
		_player.global_position = spawn_pos
		_player.velocity = Vector3.ZERO

	if _cast_coordinator != null:
		var new_map_node: Node = _map_manager.call("get_current_map") as Node
		_cast_coordinator.call("setup", _player, new_map_node, _fishing_ui, _fishing_rig, _fishing_api)

	return true


func _physics_process(_delta: float) -> void:
	if _cast_coordinator != null:
		_cast_coordinator.call("update")
	if _shop_ui != null and _player != null and _map_manager != null:
		var m: Node = _map_manager.call("get_current_map") as Node
		var near_shop: bool = bool(m.call("is_near_shop", _player.global_position)) if m != null and m.has_method("is_near_shop") else false
		_shop_ui.call("set_near_shop", near_shop)


func _process(delta: float) -> void:
	if _fishing_api != null and _fishing_api.has_method("tick"):
		_fishing_api.call("tick", delta)
	if _camera == null or _player == null:
		return
	var target := _player.global_position
	_camera.global_position = target + Vector3(0.0, 16.0, 23.0)
	_camera.look_at(target + Vector3(0.0, 0.8, 0.0))


func _create_camera() -> void:
	_camera = Camera3D.new()
	_camera.name = "MainCamera"
	_camera.position = Vector3(0.0, 16.0, 23.0)
	_camera.fov = 55.0
	_camera.current = true
	add_child(_camera)


func _create_sky_dome() -> void:
	if not ResourceLoader.exists(SKY_DOME_SCENE_PATH):
		return
	var scene := load(SKY_DOME_SCENE_PATH) as PackedScene
	if scene == null:
		return
	var dome_node := scene.instantiate() as Node3D
	if dome_node != null:
		_sky_dome = dome_node
		_sky_dome.name = "SkyDome"
		add_child(_sky_dome)
		if _sky_dome.has_method("set_follow_target") and _camera != null:
			_sky_dome.call("set_follow_target", _camera)


func _create_map_manager() -> void:
	_map_manager = MAP_MANAGER_SCRIPT.new() as Node3D
	if _map_manager != null:
		_map_manager.name = "MapManager"
		add_child(_map_manager)
		_map_manager.call("load_map", "harbor_island")


func _sync_sun_direction() -> void:
	if _map_manager == null:
		return
	var current_map: Node = _map_manager.call("get_current_map") as Node
	if current_map == null or not current_map.has_method("get_sun_direction"):
		return
	var sun_dir: Vector3 = current_map.call("get_sun_direction")
	if _sky_dome != null and _sky_dome.has_method("set_sun_direction"):
		_sky_dome.call("set_sun_direction", sun_dir)
	if current_map.has_method("get_water_material"):
		var water_mat: ShaderMaterial = current_map.call("get_water_material") as ShaderMaterial
		if water_mat != null:
			water_mat.set_shader_parameter("sun_dir", sun_dir)


func _create_player() -> void:
	if not ResourceLoader.exists(PLAYER_SCENE_PATH):
		return
	var scene := load(PLAYER_SCENE_PATH) as PackedScene
	if scene != null:
		_player = scene.instantiate() as CharacterBody3D
		if _player != null:
			_player.name = "Player"
			_player.position = Vector3(-2.0, 0.05, 10.0)
			add_child(_player)


func _setup_hud() -> void:
	if _hud == null:
		_hud = CanvasLayer.new()
		_hud.name = "HUD"
		add_child(_hud)


func _create_joystick() -> void:
	if not ResourceLoader.exists(JOYSTICK_SCENE_PATH):
		return
	var scene := load(JOYSTICK_SCENE_PATH) as PackedScene
	if scene != null:
		_joystick = scene.instantiate()
		if _joystick is Control:
			_hud.add_child(_joystick)
			if _joystick.has_signal("direction_changed"):
				_joystick.connect("direction_changed", _on_joystick_direction_changed)


func _on_joystick_direction_changed(direction: Vector2) -> void:
	if _player != null:
		_player.call("set_move_direction", direction)


func _init_services() -> void:
	_inventory_api = _load_api(INVENTORY_API_PATH, "load_data")
	_economy_api = _load_api(ECONOMY_API_PATH, "load_data")
	_fishing_api = _load_api(FISHING_API_PATH, "")
	_shop_api = _load_api(SHOP_API_PATH, "load_data")
	_cultivation_api = _load_api(CULTIVATION_API_PATH, "load_save")
	_equipment_api = _load_api(EQUIPMENT_API_PATH, "load_save")
	_coordinator = SERVICE_COORDINATOR_SCRIPT.new()
	_coordinator.call("setup", _inventory_api, _economy_api, _shop_api, _fishing_api)
	if _cultivation_api != null:
		_coordinator.call("set_cultivation_api", _cultivation_api)
		if _fishing_api != null and _fishing_api.has_method("set_realm_provider"):
			_fishing_api.call("set_realm_provider", Callable(_cultivation_api, "get_current_realm_index"))
	if _equipment_api != null:
		_coordinator.call("set_equipment_api", _equipment_api)
		if _fishing_api != null and _fishing_api.has_method("get_all_rods"):
			for rod in (_fishing_api.call("get_all_rods") as Array):
				_equipment_api.call("register_item_spec", rod)
		if _fishing_api != null and _fishing_api.has_method("set_equipment_stats_provider"):
			_fishing_api.call("set_equipment_stats_provider", Callable(_equipment_api, "calculate_total_stats"))
	var eb: Node = get_node_or_null("/root/EventBus")
	if eb != null and eb.has_method("subscribe"):
		eb.call("subscribe", "shop_rod_equipped", Callable(_coordinator, "on_shop_rod_equipped"))
	if _fishing_api != null and _shop_api != null and _shop_api.has_method("get_equipped_rod_id"):
		var eq_rod: String = str(_shop_api.call("get_equipped_rod_id"))
		_fishing_api.call("set_default_rod", eq_rod)


func _load_api(path: String, init_method: String) -> RefCounted:
	if not ResourceLoader.exists(path):
		return null
	var s: Script = load(path) as Script
	if s == null:
		return null
	var api: RefCounted = s.new() as RefCounted
	if api != null and not init_method.is_empty() and api.has_method(init_method):
		api.call(init_method)
	return api


func _create_inventory_ui() -> void:
	if not ResourceLoader.exists(FISHING_INVENTORY_UI_PATH):
		return
	var scene := load(FISHING_INVENTORY_UI_PATH) as PackedScene
	if scene != null:
		_fishing_inventory_ui = scene.instantiate() as Control
		if _fishing_inventory_ui != null:
			_hud.add_child(_fishing_inventory_ui)
			if _inventory_api != null and _fishing_inventory_ui.has_method("set_inventory_api"):
				_fishing_inventory_ui.call("set_inventory_api", _inventory_api)


func _create_cultivation_ui() -> void:
	_ui_router = UI_ACTION_ROUTER_SCRIPT.new()
	_cultivation_ui = _ui_router.call("build", _hud, _fishing_inventory_ui, _coordinator, _economy_api, _cultivation_api) as Control

func _create_equipment_ui() -> void:
	if _equipment_api == null or not ResourceLoader.exists(EQUIPMENT_UI_PATH):
		return
	var scene := load(EQUIPMENT_UI_PATH) as PackedScene
	if scene == null:
		return
	_equipment_ui = scene.instantiate() as Control
	if _equipment_ui == null:
		return
	_hud.add_child(_equipment_ui)
	if _equipment_ui.has_method("setup"):
		_equipment_ui.call("setup", _equipment_api)
	if _ui_router != null:
		_ui_router.call("connect_equipment_ui", _equipment_ui)


func _create_fishing_ui() -> void:
	if not ResourceLoader.exists(FISHING_UI_PATH):
		return
	var scene := load(FISHING_UI_PATH) as PackedScene
	if scene != null:
		_fishing_ui = scene.instantiate() as Control
		if _fishing_ui != null:
			_hud.add_child(_fishing_ui)
			if _fishing_api != null and _fishing_ui.has_method("set_fishing_api"):
				_fishing_ui.call("set_fishing_api", _fishing_api)


func sell_fish(fish_id: String, count: int) -> bool:
	return bool(_coordinator.call("sell_fish", fish_id, count)) if _coordinator != null else false


func buy_shop_item(item_id: String) -> bool:
	return bool(_coordinator.call("buy_shop_item", item_id)) if _coordinator != null else false


func _create_fishing_rig() -> void:
	if _player == null or not ResourceLoader.exists(FISHING_RIG_PATH):
		return
	var scene := load(FISHING_RIG_PATH) as PackedScene
	if scene == null:
		return
	_fishing_rig = scene.instantiate() as Node3D
	if _fishing_rig == null:
		return
	add_child(_fishing_rig)
	_fishing_rig.call("set_anchor", _player)
	_cast_coordinator = CAST_COORDINATOR_SCRIPT.new()
	var map_node: Node = _map_manager.call("get_current_map") as Node
	_cast_coordinator.call("setup", _player, map_node, _fishing_ui, _fishing_rig, _fishing_api)

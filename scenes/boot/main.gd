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
var _cultivation_ui: Control
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
    _create_fishing_ui()
    _create_fishing_rig()

    var eb: Node = get_node_or_null("/root/EventBus")
    if eb != null and eb.has_method("subscribe"):
        eb.call("subscribe", "map_change_requested", Callable(self, "_on_map_change_requested"))


func _on_map_change_requested(payload: Dictionary) -> void:
    var target_id: String = str(payload.get("target_map_id", ""))
    if not target_id.is_empty():
        change_map(target_id)


## Chuyển map an toàn: giữ nguyên Player, Inventory, Cultivation, Economy, Equipment.
func change_map(target_map_id: String) -> bool:
    if _map_manager == null:
        return false

    var ok: bool = bool(_map_manager.call("load_map", target_map_id))
    if not ok:
        return false

    _sync_sun_direction()

    # Cập nhật vị trí xuất hiện của Player nếu có định nghĩa
    if _player != null:
        var spawn_pos: Vector3 = _map_manager.call("get_default_spawn_position", target_map_id) as Vector3
        _player.global_position = spawn_pos
        _player.velocity = Vector3.ZERO

    # Tái kết nối CastCoordinator với bản đồ mới
    if _cast_coordinator != null:
        var new_map_node: Node = _map_manager.call("get_current_map") as Node
        _cast_coordinator.call("setup", _player, new_map_node, _fishing_ui, _fishing_rig, _fishing_api)

    return true



func _physics_process(_delta: float) -> void:
    if _cast_coordinator != null:
        _cast_coordinator.call("update")


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
    add_child(_camera)
    _camera.current = true


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
    if ResourceLoader.exists(INVENTORY_API_PATH):
        var inv_s: Script = load(INVENTORY_API_PATH) as Script
        if inv_s != null:
            _inventory_api = inv_s.new() as RefCounted
            if _inventory_api.has_method("load_data"):
                _inventory_api.call("load_data")

    if ResourceLoader.exists(ECONOMY_API_PATH):
        var eco_s: Script = load(ECONOMY_API_PATH) as Script
        if eco_s != null:
            _economy_api = eco_s.new() as RefCounted
            if _economy_api.has_method("load_data"):
                _economy_api.call("load_data")

    if ResourceLoader.exists(FISHING_API_PATH):
        var fish_s: Script = load(FISHING_API_PATH) as Script
        if fish_s != null:
            _fishing_api = fish_s.new() as RefCounted

    if ResourceLoader.exists(SHOP_API_PATH):
        var shop_s: Script = load(SHOP_API_PATH) as Script
        if shop_s != null:
            _shop_api = shop_s.new() as RefCounted
            if _shop_api.has_method("load_data"):
                _shop_api.call("load_data")

    if ResourceLoader.exists(CULTIVATION_API_PATH):
        var cult_s: Script = load(CULTIVATION_API_PATH) as Script
        if cult_s != null:
            _cultivation_api = cult_s.new() as RefCounted
            if _cultivation_api.has_method("load_save"):
                _cultivation_api.call("load_save")

    # Khởi tạo coordinator kết nối atomic
    _coordinator = SERVICE_COORDINATOR_SCRIPT.new()
    _coordinator.call("setup", _inventory_api, _economy_api, _shop_api, _fishing_api)
    if _cultivation_api != null:
        _coordinator.call("set_cultivation_api", _cultivation_api)
        if _fishing_api != null and _fishing_api.has_method("set_realm_provider"):
            _fishing_api.call("set_realm_provider", Callable(_cultivation_api, "get_current_realm_index"))

    var eb: Node = get_node_or_null("/root/EventBus")
    if eb != null and eb.has_method("subscribe"):
        eb.call("subscribe", "shop_rod_equipped", Callable(_coordinator, "on_shop_rod_equipped"))

    if _fishing_api != null and _shop_api != null and _shop_api.has_method("get_equipped_rod_id"):
        var eq_rod: String = str(_shop_api.call("get_equipped_rod_id"))
        _fishing_api.call("set_default_rod", eq_rod)


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
    if _coordinator != null:
        return bool(_coordinator.call("sell_fish", fish_id, count))
    return false


func buy_shop_item(item_id: String) -> bool:
    if _coordinator != null:
        return bool(_coordinator.call("buy_shop_item", item_id))
    return false


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

extends Control
## Bootstrap: composition root của game.
## - Tạo và giữ SharedMap scene (Player, HUD, Joystick — hệ thống chung độc lập với map).
## - Nối NPCDirector vào shared scene.
## - Chuyển map qua WorldEvents.MAP_CHANGE_REQUESTED (Bootstrap sở hữu vòng đời map).
## Các module không tự gắn cứng vào scene của nhau (AGENTS §5).

const SHARED_SCENE: PackedScene = preload("res://world/map/scenes/shared/shared_map.tscn")
const MAP_SCENE: PackedScene = preload("res://world/map/scenes/hub_map.tscn")

## Presentation là tùy chọn: thiếu sprite thì VisualRoot (3D) vẫn hiển thị.
const SPRITE_SCENE_PATH: String = "res://presentation/player_sprite/player_sprite.tscn"

## NPC là module tùy chọn: thiếu module thì thế giới vẫn chạy, chỉ không có NPC.
const NPC_DIRECTOR_SCRIPT_PATH: String = "res://modules/npc/npc_director.gd"

## Scene world khai báo bằng metadata để Bootstrap biết có tạo NPC hay không.
const NPC_SPAWN_META: StringName = &"npc_spawn_enabled"

var _active_map: Node
var _shared: Node3D


func _ready() -> void:
	var title := get_node_or_null("Title") as Control
	if title != null:
		title.hide()

	# Bootstrap nối các dịch vụ Core vào cơ chế đăng ký save độc lập.
	SaveCoordinator.register_participant(GameClock.SAVE_ID, GameClock)
	_register_economy_participant()

	# World chỉ phát yêu cầu đổi map; Bootstrap sở hữu vòng đời map.
	EventBus.subscribe(WorldEvents.MAP_CHANGE_REQUESTED, _on_map_change_requested)

	_add_shared_systems()
	_show_map(MAP_SCENE)
	SaveCoordinator.call_deferred("load_game")

	print("[Boot] ProjectGame 3D khởi động")
	EventBus.emit_event(CoreEvents.BOOT_COMPLETED)


func _add_shared_systems() -> void:
	# Hệ thống dùng chung (Player, Camera, HUD, Joystick, Minimap) tạo một lần.
	_shared = SHARED_SCENE.instantiate()
	add_child(_shared)


func _exit_tree() -> void:
	if EventBus != null:
		EventBus.unsubscribe(WorldEvents.MAP_CHANGE_REQUESTED, _on_map_change_requested)


## EconomyService là module tùy chọn. Không tham chiếu class/autoload theo tên
## để boot vẫn parse được khi module economy bị gỡ.
func _register_economy_participant() -> void:
	var economy := get_node_or_null("/root/EconomyService")
	if economy == null:
		return
	var economy_script := economy.get_script() as Script
	if economy_script == null:
		push_warning("[Boot] EconomyService thiếu script; bỏ qua đăng ký save.")
		return
	var constants: Dictionary = economy_script.get_script_constant_map()
	var save_id: String = str(constants.get("SAVE_ID", ""))
	if save_id.is_empty():
		push_warning("[Boot] EconomyService thiếu SAVE_ID; bỏ qua đăng ký save.")
		return
	SaveCoordinator.register_participant(save_id, economy)


func _on_map_change_requested(payload: Dictionary) -> void:
	var scene_path: String = str(payload.get("scene_path", ""))
	if scene_path.is_empty():
		push_error("[Boot] MAP_CHANGE_REQUESTED thiếu scene_path.")
		return
	# Đổi map ngoài physics callback để an toàn khi xóa/thêm node.
	call_deferred("_change_map", scene_path)


func _change_map(scene_path: String) -> void:
	if not ResourceLoader.exists(scene_path, "PackedScene"):
		push_error("[Boot] Không tìm thấy scene map: " + scene_path)
		return
	var map_scene := load(scene_path) as PackedScene
	if map_scene == null:
		push_error("[Boot] Không tải được scene map: " + scene_path)
		return
	_show_map(map_scene)


## Dựng map trước khi map vào tree để các node con nhìn thấy nhau ngay trong _ready.
func _show_map(map_scene: PackedScene) -> void:
	var map_instance := map_scene.instantiate()
	if map_instance == null:
		push_error("[Boot] Không instantiate được scene map.")
		return

	_attach_player_visual(_shared)
	_attach_npc_director(map_instance, _shared)

	if _active_map != null and is_instance_valid(_active_map):
		if _active_map.get_parent() == self:
			remove_child(_active_map)
		_active_map.queue_free()
	_active_map = map_instance

	add_child(map_instance)
	move_child(map_instance, 0)


func _attach_player_visual(shared_node: Node) -> void:
	var player := shared_node.get_node_or_null("Player") as Node3D
	if player == null:
		return
	if player.get_node_or_null("Visual") != null:
		return
	if not ResourceLoader.exists(SPRITE_SCENE_PATH, "PackedScene"):
		# Không có presentation: giữ VisualRoot (nhân vật 3D) hiển thị.
		return
	var sprite_scene := load(SPRITE_SCENE_PATH) as PackedScene
	if sprite_scene == null:
		push_warning("[Boot] Không tải được sprite Player; dùng VisualRoot 3D.")
		return
	var visual := sprite_scene.instantiate()
	if visual == null:
		push_warning("[Boot] Không instantiate được sprite Player; dùng VisualRoot 3D.")
		return
	visual.name = "Visual"
	player.add_child(visual)


## NPC độc lập với map: luôn gắn vào SharedMap scene, không tái tạo mỗi lần chuyển map.
func _attach_npc_director(map_instance: Node, shared_node: Node) -> void:
	if shared_node.get_node_or_null("NPCDirector") != null:
		return
	if not ResourceLoader.exists(NPC_DIRECTOR_SCRIPT_PATH, "Script"):
		return
	var npc_script := load(NPC_DIRECTOR_SCRIPT_PATH) as Script
	if npc_script == null:
		push_warning("[Boot] Không tải được NPCDirector; bỏ qua NPC.")
		return
	var director: Node = npc_script.new() as Node
	if director == null:
		push_warning("[Boot] Không tạo được NPCDirector; bỏ qua NPC.")
		return
	director.name = "NPCDirector"
	director.set("spawn_enabled", _is_npc_spawn_enabled(map_instance))

	# Giữ thứ tự cũ: NPCDirector đứng trước HUD trong cây scene.
	var hud := shared_node.get_node_or_null("HUD")
	shared_node.add_child(director)
	if hud != null:
		shared_node.move_child(director, hud.get_index())


func _is_npc_spawn_enabled(map_instance: Node) -> bool:
	if not map_instance.has_meta(NPC_SPAWN_META):
		return true
	return bool(map_instance.get_meta(NPC_SPAWN_META))

extends Control

const MAP_SCENE: PackedScene = preload("res://world/map/scenes/map_root.tscn")


func _ready() -> void:
	var title := get_node_or_null("Title") as Control
	if title != null:
		title.hide()

	# Bootstrap nối các dịch vụ Core vào cơ chế đăng ký save độc lập.
	SaveCoordinator.register_participant(GameClock.SAVE_ID, GameClock)
	SaveCoordinator.register_participant(EconomyService.SAVE_ID, EconomyService)

	var map_instance := MAP_SCENE.instantiate()
	add_child(map_instance)
	move_child(map_instance, 0)
	SaveCoordinator.call_deferred("load_game")

	print("[Boot] ProjectGame 3D khởi động")
	EventBus.emit_event(CoreEvents.BOOT_COMPLETED)

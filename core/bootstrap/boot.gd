extends Control

const MAP_SCENE: PackedScene = preload("res://world/map/scenes/map_root.tscn")


func _ready() -> void:
	var title := get_node_or_null("Title") as Control
	if title != null:
		title.hide()

	var map_instance := MAP_SCENE.instantiate()
	add_child(map_instance)
	move_child(map_instance, 0)

	print("[Boot] ProjectGame 3D khởi động")
	EventBus.emit_event(CoreEvents.BOOT_COMPLETED)

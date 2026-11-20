extends Control

const MAP_SCENE: PackedScene = preload("res://world/map/scenes/map_root.tscn")

func _ready() -> void:
    var map_instance := MAP_SCENE.instantiate()
    add_child(map_instance)
    move_child(map_instance, 0)

    print("[Boot] ProjectGame khởi động")
    EventBus.emit_event(CoreEvents.BOOT_COMPLETED)

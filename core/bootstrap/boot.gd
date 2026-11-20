extends Control


func _ready() -> void:
    print("[Boot] ProjectGame khởi động")
    EventBus.emit_event(CoreEvents.BOOT_COMPLETED)

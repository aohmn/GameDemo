class_name ShopItemSpec
extends Resource

## Định nghĩa vật phẩm trong cửa hàng thiết bị câu cá.

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var price_vnd: int = 0
@export var category: String = "rod" # rod, equipment, bait

# Chỉ số độc lập
@export var rod_id: String = ""
@export var safe_tension_min: float = 30.0
@export var safe_tension_max: float = 70.0
@export var max_tension: float = 100.0
@export var reel_speed: float = 35.0
@export var release_speed: float = 25.0
@export var fatigue_rate: float = 12.0

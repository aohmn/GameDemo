class_name ShopItemSpec
extends Resource

## Định nghĩa vật phẩm trong cửa hàng thiết bị, pháp bảo câu cá.

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var price_spirit_stone: int = 0
@export var category: String = "rod" # rod, equipment, bait
@export var required_realm_level: int = 0

## Lấy giá bán tính theo Linh Thạch (hạ phẩm).
func get_price() -> int:
	return price_spirit_stone

# Chỉ số độc lập
@export var rod_id: String = ""
@export var safe_tension_min: float = 30.0
@export var safe_tension_max: float = 70.0
@export var max_tension: float = 100.0
@export var reel_speed: float = 35.0
@export var release_speed: float = 25.0
@export var fatigue_rate: float = 12.0

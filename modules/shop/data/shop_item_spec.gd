class_name ShopItemSpec
extends Resource

## Định nghĩa vật phẩm trong cửa hàng thiết bị, pháp bảo câu cá.

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var price_spirit_stone: int = 0
@export var price_vnd: int = 0 # Thuộc tính cũ giữ lại để tương thích ngược
@export var category: String = "rod" # rod, equipment, bait
@export var required_realm_level: int = 0

## Lấy giá bán tính theo Linh Thạch (hạ phẩm), ưu tiên price_spirit_stone hoặc fallback sang price_vnd.
func get_price() -> int:
	if price_spirit_stone > 0:
		return price_spirit_stone
	return price_vnd

# Chỉ số độc lập
@export var rod_id: String = ""
@export var safe_tension_min: float = 30.0
@export var safe_tension_max: float = 70.0
@export var max_tension: float = 100.0
@export var reel_speed: float = 35.0
@export var release_speed: float = 25.0
@export var fatigue_rate: float = 12.0

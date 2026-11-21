extends Resource
class_name ShopGood

@export var item_id: String = "item"
@export var display_name: String = "Hàng hóa"
@export_range(0, 2147483647, 1) var price_vnd: int = 0
@export_range(0.0, 100.0, 0.1) var hunger_restore: float = 0.0
@export_range(0.0, 100.0, 0.1) var thirst_restore: float = 0.0

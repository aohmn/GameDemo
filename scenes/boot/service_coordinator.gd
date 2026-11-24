class_name ServiceCoordinator
extends RefCounted

## Điều phối giao dịch atomic giữa các module độc lập (Economy, Inventory, Shop, Fishing).
## Tách biệt khỏi Bootstrap node để giữ số dòng của mỗi script dưới 300 dòng theo luật AGENTS.md.

var _inventory_api: RefCounted
var _economy_api: RefCounted
var _shop_api: RefCounted
var _fishing_api: RefCounted


func setup(inv: RefCounted, eco: RefCounted, shop: RefCounted, fish: RefCounted) -> void:
	_inventory_api = inv
	_economy_api = eco
	_shop_api = shop
	_fishing_api = fish


## Bán cá từ Inventory và cộng tiền vào Economy (atomic).
func sell_fish(fish_id: String, count: int) -> bool:
	if _inventory_api == null or _economy_api == null:
		return false

	var fish_info: Dictionary = _inventory_api.call("get_fish_info", fish_id) as Dictionary
	var available_count: int = int(fish_info.get("count", 0))
	var total_weight: int = int(fish_info.get("total_weight_g", 0))

	if count <= 0 or count > available_count or available_count == 0:
		return false

	var weight_to_sell: int = total_weight if count == available_count else int(roundf(float(total_weight) * (float(count) / float(available_count))))

	var remove_res: Dictionary = _inventory_api.call("remove_fish", fish_id, count) as Dictionary
	if not bool(remove_res.get("success", false)):
		return false

	var actual_weight: int = int(remove_res.get("removed_weight_g", weight_to_sell))
	var sale_res: Dictionary = _economy_api.call("execute_fish_sale", fish_id, count, actual_weight, count) as Dictionary
	if not bool(sale_res.get("success", false)):
		_inventory_api.call("add_fish", fish_id, actual_weight)
		return false

	_inventory_api.call("save")
	_economy_api.call("save")
	return true


## Mua vật phẩm từ Shop sử dụng số dư từ Economy (atomic).
func buy_shop_item(item_id: String) -> bool:
	if _shop_api == null or _economy_api == null:
		return false

	var item: Resource = _shop_api.call("get_item", item_id) as Resource
	if item == null:
		return false

	var price: int = int(item.get("price_vnd"))
	var current_bal: int = int(_economy_api.call("get_balance"))

	if current_bal < price or bool(_shop_api.call("is_owned", item_id)):
		return false

	var deduct_ok: bool = bool(_economy_api.call("deduct_funds", price, "buy_" + item_id))
	if not deduct_ok:
		return false

	var buy_res: Dictionary = _shop_api.call("buy_item", item_id, current_bal) as Dictionary
	if not bool(buy_res.get("success", false)):
		_economy_api.call("add_funds", price, "refund_" + item_id)
		return false

	_economy_api.call("save")
	_shop_api.call("save")
	return true


## Xử lý khi cần câu được trang bị từ Shop.
func on_shop_rod_equipped(payload: Dictionary) -> void:
	var rod_id: String = str(payload.get("rod_id", ""))
	if not rod_id.is_empty() and _fishing_api != null and _fishing_api.has_method("set_default_rod"):
		_fishing_api.call("set_default_rod", rod_id)

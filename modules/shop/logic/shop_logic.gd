class_name ShopLogic
extends RefCounted

## Quản lý danh mục hàng hóa, kiểm tra giao dịch mua đồ và trang bị cần câu.
## Lưu trữ danh sách vật phẩm đã sở hữu và cần câu đang trang bị vào user://shop.cfg bằng ConfigFile.

const SAVE_PATH: String = "user://shop.cfg"
const SECTION_OWNED: String = "owned"
const SECTION_EQUIPPED: String = "equipped"
const SECTION_META: String = "meta"
const SAVE_VERSION: int = 1

var _items: Dictionary = {} # id: Resource (ShopItemSpec)
var _owned_items: Array[String] = ["shop_rod_truc_nhiem"] # Mặc định sở hữu cần trúc
var _equipped_rod_id: String = "rod_truc_nhiem"

var on_item_purchased: Callable
var on_rod_equipped: Callable
var on_purchase_failed: Callable


func register_item(item: Resource) -> void:
	if item != null:
		var item_id: String = str(item.get("id"))
		if not item_id.is_empty():
			_items[item_id] = item


func get_all_items() -> Array[Resource]:
	var list: Array[Resource] = []
	for k in _items.keys():
		list.append(_items[k] as Resource)
	return list


func get_item(item_id: String) -> Resource:
	return _items.get(item_id, null) as Resource


func is_owned(item_id: String) -> bool:
	return _owned_items.has(item_id)


func get_owned_items() -> Array[String]:
	return _owned_items.duplicate()


func get_equipped_rod_id() -> String:
	return _equipped_rod_id


## Thực hiện mua vật phẩm với số dư được cung cấp.
## Trả về Dictionary: { "success": bool, "price": int, "item_id": String, "reason": String }
func buy_item(item_id: String, current_balance: int) -> Dictionary:
	if not _items.has(item_id):
		_fail_purchase(item_id, "Vật phẩm không tồn tại trong cửa hàng")
		return {"success": false, "price": 0, "item_id": item_id, "reason": "item_not_found"}

	if is_owned(item_id):
		_fail_purchase(item_id, "Vật phẩm này đã được sở hữu")
		return {"success": false, "price": 0, "item_id": item_id, "reason": "already_owned"}

	var item: Resource = _items[item_id] as Resource
	var price: int = int(item.get("price_vnd"))

	if current_balance < price:
		_fail_purchase(item_id, "Không đủ tiền để mua vật phẩm này")
		return {"success": false, "price": price, "item_id": item_id, "reason": "insufficient_funds"}

	# Thêm vào danh sách sở hữu
	_owned_items.append(item_id)

	# Nếu là cần câu, lấy rod_id
	var rod_id: String = str(item.get("rod_id"))

	if on_item_purchased.is_valid():
		on_item_purchased.call({
			"item_id": item_id,
			"rod_id": rod_id,
			"price": price,
			"display_name": str(item.get("display_name"))
		})

	return {"success": true, "price": price, "item_id": item_id, "rod_id": rod_id, "reason": "ok"}


## Trang bị cần câu đã sở hữu.
func equip_rod(shop_item_id: String) -> bool:
	if not is_owned(shop_item_id):
		return false

	var item: Resource = _items.get(shop_item_id, null) as Resource
	if item == null:
		return false

	var cat: String = str(item.get("category"))
	if cat != "rod":
		return false

	var r_id: String = str(item.get("rod_id"))
	if r_id.is_empty():
		return false

	_equipped_rod_id = r_id

	if on_rod_equipped.is_valid():
		on_rod_equipped.call({
			"shop_item_id": shop_item_id,
			"rod_id": _equipped_rod_id,
			"item_spec": item
		})
	return true


func _fail_purchase(item_id: String, reason: String) -> void:
	if on_purchase_failed.is_valid():
		on_purchase_failed.call({
			"item_id": item_id,
			"reason": reason
		})


func save_to_disk(custom_path: String = "") -> bool:
	var path: String = SAVE_PATH if custom_path.is_empty() else custom_path
	var config := ConfigFile.new()
	config.set_value(SECTION_META, "version", SAVE_VERSION)
	config.set_value(SECTION_OWNED, "items", _owned_items)
	config.set_value(SECTION_EQUIPPED, "rod_id", _equipped_rod_id)

	var err: Error = config.save(path)
	if err != OK:
		push_error("Lỗi khi lưu shop vào %s: mã %d" % [path, err])
		return false
	return true


func load_from_disk(custom_path: String = "") -> bool:
	var path: String = SAVE_PATH if custom_path.is_empty() else custom_path
	var config := ConfigFile.new()
	var err: Error = config.load(path)
	if err != OK:
		return false

	if config.has_section(SECTION_OWNED):
		var raw_owned: Array = config.get_value(SECTION_OWNED, "items", []) as Array
		var loaded_owned: Array[String] = []
		for item in raw_owned:
			loaded_owned.append(str(item))
		if not loaded_owned.has("shop_rod_truc_nhiem"):
			loaded_owned.append("shop_rod_truc_nhiem")
		_owned_items = loaded_owned

	if config.has_section(SECTION_EQUIPPED):
		_equipped_rod_id = str(config.get_value(SECTION_EQUIPPED, "rod_id", "rod_truc_nhiem"))

	return true

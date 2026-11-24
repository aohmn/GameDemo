class_name ShopAPI
extends RefCounted

## Giao diện lập trình (API) công khai của module cửa hàng (modules/shop/).
## Độc lập hoàn toàn với Economy, Inventory và Fishing; trao đổi thông tin qua EventBus và API do Bootstrap điều phối.

const InventoryEventsContract: Script = preload("res://core/contracts/inventory_events.gd")
const ShopLogicScript: Script = preload("res://modules/shop/logic/shop_logic.gd")

const ROD_EQUIPPED_EVENT: String = "shop_rod_equipped"
const ITEM_PURCHASED_EVENT: String = "shop_item_purchased"
const PURCHASE_FAILED_EVENT: String = "shop_purchase_failed"

var _logic: RefCounted


func _init() -> void:
	_logic = ShopLogicScript.new()
	_setup_callbacks()
	_load_default_items()


## Đăng ký một mặt hàng vào shop.
func register_item(item: Resource) -> void:
	if _logic != null and _logic.has_method("register_item"):
		_logic.call("register_item", item)


## Lấy toàn bộ danh mục mặt hàng.
func get_all_items() -> Array[Resource]:
	if _logic != null and _logic.has_method("get_all_items"):
		return _logic.call("get_all_items") as Array[Resource]
	return []


## Lấy thông tin mặt hàng theo id.
func get_item(item_id: String) -> Resource:
	if _logic != null and _logic.has_method("get_item"):
		return _logic.call("get_item", item_id) as Resource
	return null


## Kiểm tra vật phẩm đã được mua hay chưa.
func is_owned(item_id: String) -> bool:
	if _logic != null and _logic.has_method("is_owned"):
		return bool(_logic.call("is_owned", item_id))
	return false


## Lấy danh sách ID các vật phẩm đã sở hữu.
func get_owned_items() -> Array[String]:
	if _logic != null and _logic.has_method("get_owned_items"):
		return _logic.call("get_owned_items") as Array[String]
	return []


## Lấy rod_id của cần câu đang trang bị.
func get_equipped_rod_id() -> String:
	if _logic != null and _logic.has_method("get_equipped_rod_id"):
		return str(_logic.call("get_equipped_rod_id"))
	return "rod_truc_nhiem"


## Thực hiện mua vật phẩm.
func buy_item(item_id: String, current_balance: int) -> Dictionary:
	if _logic != null and _logic.has_method("buy_item"):
		return _logic.call("buy_item", item_id, current_balance) as Dictionary
	return {"success": false, "price": 0, "reason": "uninitialized"}


## Trang bị cần câu.
func equip_rod(shop_item_id: String) -> bool:
	if _logic != null and _logic.has_method("equip_rod"):
		return bool(_logic.call("equip_rod", shop_item_id))
	return false


## Lưu dữ liệu shop vào đĩa.
func save(custom_path: String = "") -> bool:
	if _logic != null and _logic.has_method("save_to_disk"):
		return bool(_logic.call("save_to_disk", custom_path))
	return false


## Tải dữ liệu shop từ đĩa.
func load_data(custom_path: String = "") -> bool:
	if _logic != null and _logic.has_method("load_from_disk"):
		return bool(_logic.call("load_from_disk", custom_path))
	return false


func _setup_callbacks() -> void:
	if _logic == null:
		return
	_logic.set("on_item_purchased", Callable(self, "_on_logic_item_purchased"))
	_logic.set("on_rod_equipped", Callable(self, "_on_logic_rod_equipped"))
	_logic.set("on_purchase_failed", Callable(self, "_on_logic_purchase_failed"))


func _on_logic_item_purchased(payload: Dictionary) -> void:
	_emit_event(ITEM_PURCHASED_EVENT, payload)
	# Phát sự kiện sang inventory nhận vật phẩm
	_emit_event(InventoryEventsContract.ITEM_ADDED, {
		"item_id": payload.get("item_id", ""),
		"amount": 1,
		"slot_index": 0
	})


func _on_logic_rod_equipped(payload: Dictionary) -> void:
	_emit_event(ROD_EQUIPPED_EVENT, payload)


func _on_logic_purchase_failed(payload: Dictionary) -> void:
	_emit_event(PURCHASE_FAILED_EVENT, payload)


func _emit_event(event_name: String, payload: Dictionary) -> void:
	var main_loop: MainLoop = Engine.get_main_loop()
	if main_loop is SceneTree:
		var st := main_loop as SceneTree
		if st.root != null and st.root.has_node("EventBus"):
			var eb: Node = st.root.get_node("EventBus")
			if eb != null and eb.has_method("emit_event"):
				eb.call("emit_event", event_name, payload)


func _load_default_items() -> void:
	var item_files: Array[String] = [
		"res://modules/shop/data/resources/item_rod_truc_nhiem.tres",
		"res://modules/shop/data/resources/item_rod_carbon_bien_sau.tres"
	]
	for p in item_files:
		if ResourceLoader.exists(p):
			var r: Resource = load(p)
			register_item(r)

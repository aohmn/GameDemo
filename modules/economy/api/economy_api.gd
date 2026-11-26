class_name EconomyAPI
extends RefCounted

## Giao diện lập trình (API) công khai của module kinh tế (modules/economy/).
## Độc lập hoàn toàn với Inventory và Fishing; trao đổi thông tin qua EventBus và API do Bootstrap điều phối.

const EconomyEventsContract: Script = preload("res://core/contracts/economy_events.gd")
const EconomyLogicScript: Script = preload("res://modules/economy/logic/economy_logic.gd")

var _logic: RefCounted


func _init() -> void:
	_logic = EconomyLogicScript.new()
	_setup_callbacks()
	_load_default_price_resources()


## Lấy số dư hiện tại (Linh Thạch hạ phẩm).
func get_balance() -> int:
	if _logic != null and _logic.has_method("get_balance"):
		return int(_logic.call("get_balance"))
	return 0


## Thêm linh thạch vào tài khoản.
func add_funds(amount: int, reason: String = "income") -> void:
	if _logic != null and _logic.has_method("add_funds"):
		_logic.call("add_funds", amount, reason)


## Trừ linh thạch từ tài khoản khi mua vật phẩm (trả về true nếu thành công).
func deduct_funds(amount: int, reason: String = "purchase") -> bool:
	if _logic != null and _logic.has_method("deduct_funds"):
		return bool(_logic.call("deduct_funds", amount, reason))
	return false


## Đăng ký bảng giá bán cá.
func register_price_spec(spec: Resource) -> void:
	if _logic != null and _logic.has_method("register_price_spec"):
		_logic.call("register_price_spec", spec)


## Dự tính giá bán của cá theo fish_id, số lượng và khối lượng.
func calculate_price(fish_id: String, count: int, weight_g: int) -> int:
	if _logic != null and _logic.has_method("calculate_price"):
		return int(_logic.call("calculate_price", fish_id, count, weight_g))
	return 0


## Bán cá với dữ liệu được xác thực từ Inventory (atomic transaction).
func execute_fish_sale(fish_id: String, count: int, weight_g: int, available_count: int) -> Dictionary:
	if _logic != null and _logic.has_method("execute_fish_sale"):
		return _logic.call("execute_fish_sale", fish_id, count, weight_g, available_count) as Dictionary
	return {"success": false, "price": 0, "reason": "uninitialized"}


## Lịch sử giao dịch gần nhất.
func get_history() -> Array[Dictionary]:
	if _logic != null and _logic.has_method("get_history"):
		return _logic.call("get_history") as Array[Dictionary]
	return []


## Lưu số dư vào đĩa.
func save(custom_path: String = "") -> bool:
	if _logic != null and _logic.has_method("save_to_disk"):
		return bool(_logic.call("save_to_disk", custom_path))
	return false


## Tải số dư từ đĩa.
func load_data(custom_path: String = "") -> bool:
	if _logic != null and _logic.has_method("load_from_disk"):
		return bool(_logic.call("load_from_disk", custom_path))
	return false


func _setup_callbacks() -> void:
	if _logic == null:
		return
	_logic.set("on_balance_changed", Callable(self, "_on_balance_changed"))
	_logic.set("on_transaction_completed", Callable(self, "_on_transaction_completed"))
	_logic.set("on_transaction_failed", Callable(self, "_on_transaction_failed"))


func _on_balance_changed(payload: Dictionary) -> void:
	_emit_event(EconomyEventsContract.BALANCE_CHANGED, payload)


func _on_transaction_completed(payload: Dictionary) -> void:
	_emit_event(EconomyEventsContract.TRANSACTION_COMPLETED, payload)


func _on_transaction_failed(payload: Dictionary) -> void:
	_emit_event(EconomyEventsContract.TRANSACTION_FAILED, payload)


func _emit_event(event_name: String, payload: Dictionary) -> void:
	var main_loop: MainLoop = Engine.get_main_loop()
	if main_loop is SceneTree:
		var st := main_loop as SceneTree
		if st.root != null and st.root.has_node("EventBus"):
			var eb: Node = st.root.get_node("EventBus")
			if eb != null and eb.has_method("emit_event"):
				eb.call("emit_event", event_name, payload)


func _load_default_price_resources() -> void:
	var price_files: Array[String] = [
		"res://modules/economy/data/resources/price_ca_com.tres",
		"res://modules/economy/data/resources/price_ca_doi.tres",
		"res://modules/economy/data/resources/price_ca_chem.tres",
		"res://modules/economy/data/resources/price_ca_mu.tres",
		"res://modules/economy/data/resources/price_ca_thu.tres",
		"res://modules/economy/data/resources/price_ca_ngu_dai_duong.tres",
		"res://modules/economy/data/resources/price_ca_chep_linh.tres",
		"res://modules/economy/data/resources/price_ca_tram_ngoc.tres"
	]
	for p in price_files:
		if ResourceLoader.exists(p):
			var r: Resource = load(p)
			register_price_spec(r)

class_name EconomyLogic
extends RefCounted

## Quản lý tài chính, số dư VND, bảng giá và giao dịch bán cá.
## Lưu trữ số dư và lịch sử giao dịch vào user://economy.cfg bằng ConfigFile.

const SAVE_PATH: String = "user://economy.cfg"
const SECTION_WALLET: String = "wallet"
const SECTION_HISTORY: String = "history"
const SECTION_META: String = "meta"
const SAVE_VERSION: int = 1
const MAX_HISTORY: int = 20

var _balance: int = 0
var _price_table: Dictionary = {} # fish_id: Resource (FishPriceSpec)
var _history: Array[Dictionary] = []

var on_balance_changed: Callable
var on_transaction_completed: Callable
var on_transaction_failed: Callable


func get_balance() -> int:
	return _balance


func set_balance(new_balance: int, reason: String = "manual_set") -> void:
	var change: int = new_balance - _balance
	_balance = maxi(0, new_balance)
	if on_balance_changed.is_valid():
		on_balance_changed.call({
			"amount_change": change,
			"new_balance": _balance,
			"reason": reason
		})


func add_funds(amount: int, reason: String = "income") -> void:
	if amount <= 0:
		return
	_balance += amount
	if on_balance_changed.is_valid():
		on_balance_changed.call({
			"amount_change": amount,
			"new_balance": _balance,
			"reason": reason
		})


func deduct_funds(amount: int, reason: String = "purchase") -> bool:
	if amount <= 0:
		return false
	if _balance < amount:
		_fail_transaction("", "Không đủ số dư để thanh toán")
		return false
	_balance -= amount
	if on_balance_changed.is_valid():
		on_balance_changed.call({
			"amount_change": -amount,
			"new_balance": _balance,
			"reason": reason
		})
	return true


func register_price_spec(spec: Resource) -> void:
	if spec != null:
		var f_id: String = str(spec.get("fish_id"))
		if not f_id.is_empty():
			_price_table[f_id] = spec


func get_price_spec(fish_id: String) -> Resource:
	return _price_table.get(fish_id, null) as Resource


## Tính giá bán cho cá: base_price * count + (weight_g / 1000.0) * price_per_kg.
func calculate_price(fish_id: String, count: int, weight_g: int) -> int:
	if not _price_table.has(fish_id) or count <= 0:
		return 0

	var spec: Resource = _price_table[fish_id] as Resource
	var base_p: int = int(spec.get("base_price"))
	var per_kg: int = int(spec.get("price_per_kg"))

	var price_from_base: int = base_p * count
	var price_from_weight: int = int(roundf((float(weight_g) / 1000.0) * float(per_kg)))
	return maxi(0, price_from_base + price_from_weight)


## Thực hiện bán cá với thông tin cá cung cấp từ Inventory.
## Trả về Dictionary: { "success": bool, "price": int, "reason": String }
func execute_fish_sale(fish_id: String, count: int, weight_g: int, available_count: int) -> Dictionary:
	if fish_id.is_empty() or count <= 0:
		_fail_transaction(fish_id, "Số lượng không hợp lệ")
		return {"success": false, "price": 0, "reason": "invalid_count"}

	if count > available_count:
		_fail_transaction(fish_id, "Không đủ cá để bán")
		return {"success": false, "price": 0, "reason": "insufficient_fish"}

	var price: int = calculate_price(fish_id, count, weight_g)
	if price <= 0:
		_fail_transaction(fish_id, "Giá bán bằng 0")
		return {"success": false, "price": 0, "reason": "zero_price"}

	# Thực hiện cộng tiền
	add_funds(price, "sell_fish")

	# Ghi lịch sử giao dịch
	var tx_id: String = "tx_sell_" + str(Time.get_ticks_msec())
	var record: Dictionary = {
		"transaction_id": tx_id,
		"item_id": fish_id,
		"quantity": count,
		"weight_g": weight_g,
		"price": price,
		"timestamp": Time.get_unix_time_from_system()
	}
	_history.append(record)
	if _history.size() > MAX_HISTORY:
		_history.pop_front()

	if on_transaction_completed.is_valid():
		on_transaction_completed.call({
			"transaction_id": tx_id,
			"item_id": fish_id,
			"price": price,
			"quantity": count,
			"weight_g": weight_g
		})

	return {"success": true, "price": price, "reason": "ok"}


func get_history() -> Array[Dictionary]:
	return _history.duplicate()


func _fail_transaction(fish_id: String, reason: String) -> void:
	if on_transaction_failed.is_valid():
		on_transaction_failed.call({
			"item_id": fish_id,
			"required_amount": 0,
			"current_balance": _balance,
			"reason": reason
		})


func save_to_disk(custom_path: String = "") -> bool:
	var path: String = SAVE_PATH if custom_path.is_empty() else custom_path
	var config := ConfigFile.new()
	config.set_value(SECTION_META, "version", SAVE_VERSION)
	config.set_value(SECTION_WALLET, "balance", _balance)

	for i in range(_history.size()):
		var rec: Dictionary = _history[i]
		var prefix: String = "tx_%d_" % i
		config.set_value(SECTION_HISTORY, prefix + "item_id", str(rec.get("item_id", "")))
		config.set_value(SECTION_HISTORY, prefix + "quantity", int(rec.get("quantity", 0)))
		config.set_value(SECTION_HISTORY, prefix + "price", int(rec.get("price", 0)))

	var err: Error = config.save(path)
	if err != OK:
		push_error("Lỗi khi lưu economy vào %s: mã %d" % [path, err])
		return false
	return true


func load_from_disk(custom_path: String = "") -> bool:
	var path: String = SAVE_PATH if custom_path.is_empty() else custom_path
	var config := ConfigFile.new()
	var err: Error = config.load(path)
	if err != OK:
		return false

	_balance = int(config.get_value(SECTION_WALLET, "balance", 0))
	_history.clear()
	if config.has_section(SECTION_HISTORY):
		var keys: PackedStringArray = config.get_section_keys(SECTION_HISTORY)
		var indices: Dictionary = {}
		for k in keys:
			var parts := k.split("_")
			if parts.size() >= 3 and parts[0] == "tx":
				indices[int(parts[1])] = true

		for idx in indices.keys():
			var prefix: String = "tx_%d_" % idx
			var item_id: String = str(config.get_value(SECTION_HISTORY, prefix + "item_id", ""))
			var qty: int = int(config.get_value(SECTION_HISTORY, prefix + "quantity", 0))
			var pr: int = int(config.get_value(SECTION_HISTORY, prefix + "price", 0))
			_history.append({
				"transaction_id": "loaded_" + str(idx),
				"item_id": item_id,
				"quantity": qty,
				"price": pr,
				"weight_g": 0,
				"timestamp": 0
			})

	if on_balance_changed.is_valid():
		on_balance_changed.call({
			"amount_change": 0,
			"new_balance": _balance,
			"reason": "loaded"
		})
	return true

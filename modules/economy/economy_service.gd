extends Node
## Nguồn số dư VND duy nhất của Player. Mọi thay đổi phải qua API này.

signal balance_changed(new_balance_vnd: int)

const SAVE_VERSION: int = 1
const SAVE_ID: String = "player_economy"
const STARTING_BALANCE_VND: int = 250000

var balance_vnd: int = STARTING_BALANCE_VND


func can_afford(amount_vnd: int) -> bool:
	return amount_vnd >= 0 and balance_vnd >= amount_vnd


func add_money(amount_vnd: int) -> bool:
	if amount_vnd <= 0:
		return false
	balance_vnd += amount_vnd
	balance_changed.emit(balance_vnd)
	return true


func spend_money(amount_vnd: int) -> bool:
	if amount_vnd <= 0 or not can_afford(amount_vnd):
		return false
	balance_vnd -= amount_vnd
	balance_changed.emit(balance_vnd)
	return true


func serialize_state() -> Dictionary:
	return {"version": SAVE_VERSION, "balance_vnd": balance_vnd}


func deserialize_state(data: Dictionary) -> bool:
	if int(data.get("version", -1)) != SAVE_VERSION:
		return false
	var amount: Variant = data.get("balance_vnd", -1)
	if typeof(amount) != TYPE_INT or int(amount) < 0:
		return false
	balance_vnd = int(amount)
	balance_changed.emit(balance_vnd)
	return true

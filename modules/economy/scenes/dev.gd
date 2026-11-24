extends Control

## Scene kiểm tra độc lập cho Economy module (modules/economy/).
## Cho phép thử nghiệm cộng/trừ số dư, tính giá, bán cá một phần/toàn bộ và kiểm tra ConfigFile.

const EconomyAPIScript: Script = preload("res://modules/economy/api/economy_api.gd")
const EconomyEventsContract: Script = preload("res://core/contracts/economy_events.gd")

var _api: RefCounted
var _log_label: Label
var _balance_label: Label
var _history_label: Label
var _logs: Array[String] = []

# Mock kho cá giả lập chỉ để test riêng lẻ trong dev scene
var _mock_inventory: Dictionary = {
	"fish_ca_com": {"count": 10, "weight_g": 500},
	"fish_ca_mu": {"count": 2, "weight_g": 3000}
}


func _ready() -> void:
	_setup_ui()
	_api = EconomyAPIScript.new()
	_setup_event_listeners()
	_log("Khởi tạo module Economy dev scene thành công.")
	_refresh_display()


func _setup_ui() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.12, 0.1)
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	add_child(bg)

	var margin := MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var vbox := VBoxContainer.new()
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "KINH TẾ & GIAO DỊCH (ECONOMY) DEV TEST"
	title.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title)

	_balance_label = Label.new()
	_balance_label.text = "Số dư: 0 Linh Thạch"
	_balance_label.add_theme_font_size_override("font_size", 15)
	vbox.add_child(_balance_label)

	var hbox_btns := HBoxContainer.new()
	hbox_btns.add_theme_constant_override("separation", 10)
	vbox.add_child(hbox_btns)

	var btn_sell_1_com := Button.new()
	btn_sell_1_com.text = "Bán 1 Cá Cơm (50g)"
	btn_sell_1_com.pressed.connect(_on_sell_1_com)
	hbox_btns.add_child(btn_sell_1_com)

	var btn_sell_all_mu := Button.new()
	btn_sell_all_mu.text = "Bán hết Cá Mú (2 con/3kg)"
	btn_sell_all_mu.pressed.connect(_on_sell_all_mu)
	hbox_btns.add_child(btn_sell_all_mu)

	var btn_sell_overflow := Button.new()
	btn_sell_overflow.text = "Bán vượt số lượng (Lỗi)"
	btn_sell_overflow.pressed.connect(_on_sell_overflow)
	hbox_btns.add_child(btn_sell_overflow)

	var btn_save := Button.new()
	btn_save.text = "Lưu số dư"
	btn_save.pressed.connect(func(): _api.call("save"); _log("Đã lưu economy.cfg"))
	hbox_btns.add_child(btn_save)

	var btn_load := Button.new()
	btn_load.text = "Tải số dư"
	btn_load.pressed.connect(func(): _api.call("load_data"); _log("Đã tải economy.cfg"); _refresh_display())
	hbox_btns.add_child(btn_load)

	_history_label = Label.new()
	_history_label.text = "Lịch sử: Chưa có giao dịch"
	vbox.add_child(_history_label)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0.0, 160.0)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	_log_label = Label.new()
	_log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scroll.add_child(_log_label)


func _setup_event_listeners() -> void:
	var eb: Node = get_node_or_null("/root/EventBus")
	if eb != null and eb.has_method("subscribe"):
		eb.call("subscribe", EconomyEventsContract.BALANCE_CHANGED, _on_balance_changed_evt)
		eb.call("subscribe", EconomyEventsContract.TRANSACTION_COMPLETED, _on_tx_completed_evt)
		eb.call("subscribe", EconomyEventsContract.TRANSACTION_FAILED, _on_tx_failed_evt)


func _on_sell_1_com() -> void:
	var data: Dictionary = _mock_inventory.get("fish_ca_com", {})
	var count: int = int(data.get("count", 0))
	if count < 1:
		_log("Mock: Không còn cá cơm để bán.")
		return
	var res: Dictionary = _api.call("execute_fish_sale", "fish_ca_com", 1, 50, count) as Dictionary
	if bool(res.get("success", false)):
		data["count"] = count - 1
		data["weight_g"] = int(data.get("weight_g", 0)) - 50
		_log("Bán thành công 1 Cá Cơm: +%d Linh Thạch" % int(res.get("price", 0)))
	else:
		_log("Bán thất bại: %s" % str(res.get("reason", "")))
	_refresh_display()


func _on_sell_all_mu() -> void:
	var data: Dictionary = _mock_inventory.get("fish_ca_mu", {})
	var count: int = int(data.get("count", 0))
	var weight: int = int(data.get("weight_g", 0))
	if count <= 0:
		_log("Mock: Không còn cá mú để bán.")
		return
	var res: Dictionary = _api.call("execute_fish_sale", "fish_ca_mu", count, weight, count) as Dictionary
	if bool(res.get("success", false)):
		data["count"] = 0
		data["weight_g"] = 0
		_log("Bán toàn bộ cá mú thành công: +%d Linh Thạch" % int(res.get("price", 0)))
	else:
		_log("Bán thất bại: %s" % str(res.get("reason", "")))
	_refresh_display()


func _on_sell_overflow() -> void:
	# Thử bán 99 con trong khi chỉ có ít hơn
	var res: Dictionary = _api.call("execute_fish_sale", "fish_ca_com", 99, 4950, 5) as Dictionary
	_log("Kết quả bán 99 con (vượt số lượng): %s (Lý do: %s)" % [
		"Thành công" if bool(res.get("success", false)) else "Bị chặn chính xác",
		str(res.get("reason", ""))
	])


func _on_balance_changed_evt(payload: Dictionary) -> void:
	_log("Event: Số dư đổi %d -> Hiện tại: %d Linh Thạch" % [
		int(payload.get("amount_change", 0)),
		int(payload.get("new_balance", 0))
	])


func _on_tx_completed_evt(payload: Dictionary) -> void:
	_log("Event: Giao dịch %s thành công (+%d Linh Thạch)" % [
		str(payload.get("transaction_id", "")),
		int(payload.get("price", 0))
	])


func _on_tx_failed_evt(payload: Dictionary) -> void:
	_log("Event: Giao dịch thất bại! Lý do: %s" % str(payload.get("reason", "")))


func _refresh_display() -> void:
	if _api == null:
		return
	var bal: int = int(_api.call("get_balance"))
	if _balance_label != null:
		_balance_label.text = "Số dư: %d Linh Thạch" % bal

	var history: Array = _api.call("get_history") as Array
	if _history_label != null:
		if history.is_empty():
			_history_label.text = "Lịch sử: Chưa có giao dịch"
		else:
			var last_tx: Dictionary = history[history.size() - 1] as Dictionary
			_history_label.text = "Lịch sử: Giao dịch gần nhất %s (+%d Linh Thạch cho %d %s)" % [
				str(last_tx.get("transaction_id", "")),
				int(last_tx.get("price", 0)),
				int(last_tx.get("quantity", 0)),
				str(last_tx.get("item_id", ""))
			]


func _log(msg: String) -> void:
	_logs.append(msg)
	if _logs.size() > 15:
		_logs.pop_front()
	if _log_label != null:
		_log_label.text = "\n".join(_logs)

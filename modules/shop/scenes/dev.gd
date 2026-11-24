extends Control

## Scene kiểm tra độc lập cho Shop module (modules/shop/).
## Cho phép thử nghiệm xem danh mục, mua cần câu, kiểm tra thiếu tiền, chặn mua trùng, trang bị cần câu và kiểm tra lưu/tải dữ liệu config.

const ShopAPIScript: Script = preload("res://modules/shop/api/shop_api.gd")
const ShopLogicScript: Script = preload("res://modules/shop/logic/shop_logic.gd")

var _api: RefCounted
var _log_label: Label
var _status_label: Label
var _items_container: VBoxContainer
var _logs: Array[String] = []

# Mock ví tiền để thử độc lập trong scene dev
var _mock_balance: int = 500000


func _ready() -> void:
	_setup_ui()
	_api = ShopAPIScript.new()
	_setup_event_listeners()
	_log("Khởi tạo module Shop dev scene thành công (Mock số dư: %d Linh Thạch)." % _mock_balance)
	_refresh_display()


func _setup_ui() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.09, 0.13)
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
	title.text = "CỬA HÀNG THIẾT BỊ CÂU (SHOP) DEV TEST"
	title.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title)

	_status_label = Label.new()
	_status_label.text = "Số dư: 0 Linh Thạch | Cần đang trang bị: None"
	_status_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(_status_label)

	var hbox_btns := HBoxContainer.new()
	hbox_btns.add_theme_constant_override("separation", 10)
	vbox.add_child(hbox_btns)

	var btn_add_money := Button.new()
	btn_add_money.text = "+ 2,000 Linh Thạch (Nạp thử nghiệm)"
	btn_add_money.pressed.connect(func(): _mock_balance += 2000000; _refresh_display())
	hbox_btns.add_child(btn_add_money)

	var btn_save := Button.new()
	btn_save.text = "Lưu file (Cfg)"
	btn_save.pressed.connect(func(): _api.call("save"); _log("Đã lưu shop.cfg"))
	hbox_btns.add_child(btn_save)

	var btn_load := Button.new()
	btn_load.text = "Tải file (Cfg)"
	btn_load.pressed.connect(func(): _api.call("load_data"); _log("Đã tải shop.cfg"); _refresh_display())
	hbox_btns.add_child(btn_load)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0.0, 160.0)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	_items_container = VBoxContainer.new()
	_items_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_items_container.add_theme_constant_override("separation", 8)
	scroll.add_child(_items_container)

	var scroll_log := ScrollContainer.new()
	scroll_log.custom_minimum_size = Vector2(0.0, 100.0)
	vbox.add_child(scroll_log)

	_log_label = Label.new()
	_log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scroll_log.add_child(_log_label)


func _setup_event_listeners() -> void:
	var eb: Node = get_node_or_null("/root/EventBus")
	if eb != null and eb.has_method("subscribe"):
		eb.call("subscribe", "shop_item_purchased", _on_item_purchased_evt)
		eb.call("subscribe", "shop_rod_equipped", _on_rod_equipped_evt)
		eb.call("subscribe", "shop_purchase_failed", _on_purchase_failed_evt)


func _on_item_purchased_evt(payload: Dictionary) -> void:
	_log("Event: Mua thành công %s (-%d Linh Thạch)" % [str(payload.get("display_name", "")), int(payload.get("price", 0))])


func _on_rod_equipped_evt(payload: Dictionary) -> void:
	_log("Event: Đã trang bị cần câu: %s" % str(payload.get("rod_id", "")))


func _on_purchase_failed_evt(payload: Dictionary) -> void:
	_log("Event: Mua thất bại! Lý do: %s" % str(payload.get("reason", "")))


func _refresh_display() -> void:
	if _api == null:
		return

	var equipped: String = str(_api.call("get_equipped_rod_id"))
	if _status_label != null:
		_status_label.text = "Số dư mock: %d Linh Thạch | Cần đang trang bị: %s" % [_mock_balance, equipped]

	for child in _items_container.get_children():
		child.queue_free()

	var items: Array = _api.call("get_all_items") as Array
	for it in items:
		var item := it as Resource
		if item == null:
			continue
		var item_id: String = str(item.get("id"))
		var d_name: String = str(item.get("display_name"))
		var desc: String = str(item.get("description"))
		var price: int = int(item.call("get_price")) if item.has_method("get_price") else int(item.get("price_vnd"))
		var is_owned: bool = bool(_api.call("is_owned", item_id))
		var r_id: String = str(item.get("rod_id"))
		var is_equipped: bool = (r_id == equipped)

		var row := PanelContainer.new()
		var hbox := HBoxContainer.new()
		row.add_child(hbox)

		var info_vbox := VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(info_vbox)

		var name_lbl := Label.new()
		name_lbl.text = "%s — Giá: %d Linh Thạch" % [d_name, price]
		name_lbl.add_theme_font_size_override("font_size", 14)
		info_vbox.add_child(name_lbl)

		var stats_lbl := Label.new()
		stats_lbl.text = "An toàn: %0.0f-%0.0f | Đứt: %0.0f | Kéo: %0.0f | Xả: %0.0f | Bào mòn: %0.0f/s" % [
			float(item.get("safe_tension_min")),
			float(item.get("safe_tension_max")),
			float(item.get("max_tension")),
			float(item.get("reel_speed")),
			float(item.get("release_speed")),
			float(item.get("fatigue_rate"))
		]
		stats_lbl.add_theme_font_size_override("font_size", 12)
		info_vbox.add_child(stats_lbl)

		var desc_lbl := Label.new()
		desc_lbl.text = desc
		desc_lbl.add_theme_font_size_override("font_size", 11)
		info_vbox.add_child(desc_lbl)

		var btn_action := Button.new()
		if not is_owned:
			btn_action.text = "Mua (%d Linh Thạch)" % price
			btn_action.pressed.connect(func(): _buy_item(item_id, price))
		else:
			if is_equipped:
				btn_action.text = "Đang trang bị"
				btn_action.disabled = true
			else:
				btn_action.text = "Trang bị"
				btn_action.pressed.connect(func(): _equip_item(item_id))

		hbox.add_child(btn_action)
		_items_container.add_child(row)


func _buy_item(item_id: String, price: int) -> void:
	if _mock_balance < price:
		_log("Mock: Không đủ tiền để mua %s (Cần %d, có %d)" % [item_id, price, _mock_balance])
		_api.call("buy_item", item_id, _mock_balance) # Gọi để kiểm tra nhánh thất bại trong logic
		return

	var res: Dictionary = _api.call("buy_item", item_id, _mock_balance) as Dictionary
	if bool(res.get("success", false)):
		_mock_balance -= price
		_log("Giao dịch mua %s thành công!" % item_id)
	else:
		_log("Giao dịch mua thất bại: %s" % str(res.get("reason", "")))
	_refresh_display()


func _equip_item(item_id: String) -> void:
	var ok: bool = bool(_api.call("equip_rod", item_id))
	if ok:
		_log("Trang bị thành công: %s" % item_id)
	else:
		_log("Trang bị thất bại.")
	_refresh_display()


func _log(msg: String) -> void:
	_logs.append(msg)
	if _logs.size() > 15:
		_logs.pop_front()
	if _log_label != null:
		_log_label.text = "\n".join(_logs)

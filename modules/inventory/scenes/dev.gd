extends Control

## Scene kiểm tra độc lập cho module Inventory (modules/inventory/).
## Cho phép mô phỏng sự kiện FISH_CAUGHT, thêm thủ công, lưu/tải user://inventory.cfg.

const InventoryAPIScript: Script = preload("res://modules/inventory/api/inventory_api.gd")
const InventoryEventsContract: Script = preload("res://core/contracts/inventory_events.gd")
const FishingEventsContract: Script = preload("res://core/contracts/fishing_events.gd")

var _api: RefCounted
var _log_label: Label
var _summary_label: Label
var _items_label: Label
var _logs: Array[String] = []


func _ready() -> void:
	_setup_ui()
	_api = InventoryAPIScript.new()
	_setup_event_listeners()
	_log("Khởi tạo module Inventory dev scene thành công.")
	_refresh_display()


func _setup_ui() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.12, 0.15)
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
	title.text = "TÚI ĐỒ (INVENTORY) DEV TEST — modules/inventory"
	title.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title)

	_summary_label = Label.new()
	_summary_label.text = "Tổng số lượng: 0 con | Tổng trọng lượng: 0 g"
	_summary_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(_summary_label)

	var hbox_btns := HBoxContainer.new()
	hbox_btns.add_theme_constant_override("separation", 10)
	vbox.add_child(hbox_btns)

	var btn_simulate_caught := Button.new()
	btn_simulate_caught.text = "Giả lập câu Cá Cơm (+50g)"
	btn_simulate_caught.pressed.connect(_on_simulate_ca_com)
	hbox_btns.add_child(btn_simulate_caught)

	var btn_simulate_mu := Button.new()
	btn_simulate_mu.text = "Giả lập câu Cá Mú (+1200g)"
	btn_simulate_mu.pressed.connect(_on_simulate_ca_mu)
	hbox_btns.add_child(btn_simulate_mu)

	var btn_save := Button.new()
	btn_save.text = "Lưu file (Cfg)"
	btn_save.pressed.connect(_on_btn_save)
	hbox_btns.add_child(btn_save)

	var btn_load := Button.new()
	btn_load.text = "Tải file (Cfg)"
	btn_load.pressed.connect(_on_btn_load)
	hbox_btns.add_child(btn_load)

	var btn_clear := Button.new()
	btn_clear.text = "Xóa túi"
	btn_clear.pressed.connect(_on_btn_clear)
	hbox_btns.add_child(btn_clear)

	_items_label = Label.new()
	_items_label.text = "[Kho cá trống]"
	vbox.add_child(_items_label)

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
		eb.call("subscribe", InventoryEventsContract.ITEM_ADDED, _on_evt_item_added)
		eb.call("subscribe", InventoryEventsContract.INVENTORY_UPDATED, _on_evt_inventory_updated)


func _on_simulate_ca_com() -> void:
	var eb: Node = get_node_or_null("/root/EventBus")
	if eb != null and eb.has_method("emit_event"):
		eb.call("emit_event", FishingEventsContract.FISH_CAUGHT, {
			"fish_id": "fish_ca_com",
			"weight_g": 50,
			"name": "Cá Cơm"
		})
	else:
		# Nếu chạy độc lập không có EventBus singleton
		_api.call("add_fish", "fish_ca_com", 50)


func _on_simulate_ca_mu() -> void:
	var eb: Node = get_node_or_null("/root/EventBus")
	if eb != null and eb.has_method("emit_event"):
		eb.call("emit_event", FishingEventsContract.FISH_CAUGHT, {
			"fish_id": "fish_ca_mu",
			"weight_g": 1200,
			"name": "Cá Mú Đỏ"
		})
	else:
		_api.call("add_fish", "fish_ca_mu", 1200)


func _on_btn_save() -> void:
	var ok: bool = bool(_api.call("save"))
	_log("Đã lưu inventory vào user://inventory.cfg: %s" % ["Thành công" if ok else "Thất bại"])


func _on_btn_load() -> void:
	var ok: bool = bool(_api.call("load_data"))
	_log("Tải dữ liệu từ user://inventory.cfg: %s" % ["Thành công" if ok else "Không tìm thấy/Thất bại"])
	_refresh_display()


func _on_btn_clear() -> void:
	_api.call("clear")
	_log("Đã xóa sạch túi đồ.")
	_refresh_display()


func _on_evt_item_added(payload: Dictionary) -> void:
	_log("Sự kiện ITEM_ADDED: %s (+%dg). Tổng loài: %d con, %d g." % [
		payload.get("item_id", ""),
		payload.get("weight_g", 0),
		payload.get("total_count", 0),
		payload.get("total_weight_g", 0)
	])
	_refresh_display()


func _on_evt_inventory_updated(_payload: Dictionary) -> void:
	_refresh_display()


func _refresh_display() -> void:
	if _api == null:
		return
	var total_c: int = int(_api.call("get_total_fish_count"))
	var total_w: int = int(_api.call("get_total_weight_g"))
	if _summary_label != null:
		_summary_label.text = "Tổng số lượng: %d con | Tổng trọng lượng: %d g (%0.2f kg)" % [
			total_c, total_w, float(total_w) / 1000.0
		]

	var items: Dictionary = _api.call("get_all_items") as Dictionary
	if _items_label != null:
		if items.is_empty():
			_items_label.text = "[Kho cá trống]"
		else:
			var lines: Array[String] = []
			for k in items.keys():
				var info: Dictionary = items[k] as Dictionary
				lines.append("- %s: %d con, %d g" % [k, info.get("count", 0), info.get("total_weight_g", 0)])
			_items_label.text = "\n".join(lines)


func _log(msg: String) -> void:
	_logs.append(msg)
	if _logs.size() > 15:
		_logs.pop_front()
	if _log_label != null:
		_log_label.text = "\n".join(_logs)

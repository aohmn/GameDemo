extends Control

## Giao diện Thương Hội (Shop UI) — mua và đổi cần câu bằng Linh Thạch.
## Presentation thuần: chỉ đọc API hiển thị, nghe EventBus và phát signal về Router/Coordinator.

signal buy_requested(item_id: String)
signal equip_requested(shop_item_id: String)

const EconomyEventsContract: Script = preload("res://core/contracts/economy_events.gd")
const CultivationEventsContract: Script = preload("res://core/contracts/cultivation_events.gd")

var _shop_api: RefCounted
var _economy_api: RefCounted
var _cultivation_api: RefCounted
var _near_shop: bool = false
var _is_open: bool = false

var _open_btn: Button
var _panel: PanelContainer
var _info_label: Label
var _items_vbox: VBoxContainer


func _ready() -> void:
	_setup_ui()
	_connect_events()
	_update_view()


func setup(shop_api: RefCounted, economy_api: RefCounted, cultivation_api: RefCounted = null) -> void:
	_shop_api = shop_api
	_economy_api = economy_api
	_cultivation_api = cultivation_api
	_update_view()


## Chỉ đổi trạng thái nút khi near thay đổi để không hủy trạng thái chạm của Godot.
func set_near_shop(near: bool) -> void:
	if near == _near_shop:
		return
	_near_shop = near
	if _open_btn != null:
		_open_btn.visible = near
	if not near and _is_open:
		set_open(false)


func toggle_open() -> void:
	set_open(not _is_open)


func set_open(open: bool) -> void:
	if open == _is_open:
		return
	_is_open = open
	if _panel != null:
		_panel.visible = _is_open
	if _open_btn != null:
		_open_btn.text = "Đóng Thương Hội" if _is_open else "Thương Hội"
	if _is_open:
		_update_view()


func _setup_ui() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_open_btn = Button.new()
	_open_btn.name = "BtnOpenShop"
	_open_btn.text = "Thương Hội"
	_open_btn.visible = false
	_open_btn.custom_minimum_size = Vector2(110.0, 40.0)
	_open_btn.anchor_left = 1.0
	_open_btn.anchor_top = 0.0
	_open_btn.anchor_right = 1.0
	_open_btn.anchor_bottom = 0.0
	_open_btn.offset_left = -130.0
	_open_btn.offset_top = 102.0
	_open_btn.offset_right = -20.0
	_open_btn.offset_bottom = 142.0
	_open_btn.pressed.connect(toggle_open)
	add_child(_open_btn)

	_panel = PanelContainer.new()
	_panel.name = "ShopPanel"
	_panel.visible = false
	_panel.anchor_left = 0.5
	_panel.anchor_top = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_bottom = 0.5
	_panel.offset_left = -260.0
	_panel.offset_top = -150.0
	_panel.offset_right = 260.0
	_panel.offset_bottom = 150.0

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.08, 0.12, 0.95)
	style.border_color = Color(0.85, 0.70, 0.28, 0.85)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(12.0)
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	_panel.add_child(vbox)

	var header := HBoxContainer.new()
	vbox.add_child(header)

	var title := Label.new()
	title.text = "THƯƠNG HỘI — CẦN CÂU & PHÁP BẢO"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 15)
	header.add_child(title)

	var close_btn := Button.new()
	close_btn.text = " X "
	close_btn.custom_minimum_size = Vector2(36.0, 32.0)
	close_btn.pressed.connect(func() -> void: set_open(false))
	header.add_child(close_btn)

	_info_label = Label.new()
	_info_label.add_theme_font_size_override("font_size", 13)
	_info_label.add_theme_color_override("font_color", Color(0.95, 0.88, 0.55))
	vbox.add_child(_info_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(480.0, 180.0)
	vbox.add_child(scroll)

	_items_vbox = VBoxContainer.new()
	_items_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_items_vbox.add_theme_constant_override("separation", 8)
	scroll.add_child(_items_vbox)


func _connect_events() -> void:
	var eb: Node = get_node_or_null("/root/EventBus")
	if eb == null or not eb.has_method("subscribe"):
		return
	var refresh := func(_p: Dictionary) -> void: _update_view()
	eb.call("subscribe", "shop_item_purchased", refresh)
	eb.call("subscribe", "shop_rod_equipped", refresh)
	eb.call("subscribe", EconomyEventsContract.BALANCE_CHANGED, refresh)
	eb.call("subscribe", CultivationEventsContract.BREAKTHROUGH_SUCCESS, refresh)


func _update_view() -> void:
	if _items_vbox == null:
		return
	for c in _items_vbox.get_children():
		c.queue_free()

	var balance: int = int(_economy_api.call("get_balance")) if _economy_api != null else 0
	var realm: int = int(_cultivation_api.call("get_current_realm_index")) if _cultivation_api != null else 0
	var realm_name: String = str(_cultivation_api.call("get_current_realm_name")) if _cultivation_api != null else "Luyện Thể"
	if _info_label != null:
		_info_label.text = "Linh Thạch: %d | Cảnh giới: %s (Cấp %d)" % [balance, realm_name, realm]

	if _shop_api == null:
		return
	var items: Array = _shop_api.call("get_all_items") as Array
	var equipped_rod: String = str(_shop_api.call("get_equipped_rod_id"))

	for item in items:
		if item == null:
			continue
		_add_item_row(item as Resource, balance, realm, equipped_rod)


func _add_item_row(item: Resource, balance: int, realm: int, equipped_rod: String) -> void:
	var item_id: String = str(item.get("id"))
	var rod_id: String = str(item.get("rod_id"))
	var disp_name: String = str(item.get("display_name"))
	var desc: String = str(item.get("description"))
	var price: int = int(item.call("get_price")) if item.has_method("get_price") else int(item.get("price_spirit_stone"))
	var req_realm: int = int(item.get("required_realm_level")) if "required_realm_level" in item else 0
	var owned: bool = bool(_shop_api.call("is_owned", item_id))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	_items_vbox.add_child(row)

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(left)

	var name_lbl := Label.new()
	var req_text: String = " [Yêu cầu CG %d]" % (req_realm + 1) if req_realm > 0 else ""
	name_lbl.text = "%s — %d Linh Thạch%s" % [disp_name, price, req_text]
	name_lbl.add_theme_font_size_override("font_size", 13)
	left.add_child(name_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = desc
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.75, 0.80, 0.85))
	left.add_child(desc_lbl)

	var btn := Button.new()
	btn.custom_minimum_size = Vector2(150.0, 38.0)
	btn.add_theme_font_size_override("font_size", 12)
	if owned and not rod_id.is_empty() and rod_id == equipped_rod:
		btn.text = "Đang Dùng"
		btn.disabled = true
	elif owned:
		btn.text = "Trang Bị"
		btn.pressed.connect(func() -> void: equip_requested.emit(item_id))
	elif realm < req_realm:
		btn.text = "Thiếu cảnh giới (CG %d)" % req_realm
		btn.disabled = true
	elif balance < price:
		btn.text = "Thiếu Linh Thạch (%d)" % price
		btn.disabled = true
	else:
		btn.text = "Mua (%d LT)" % price
		btn.pressed.connect(func() -> void: buy_requested.emit(item_id))
	row.add_child(btn)

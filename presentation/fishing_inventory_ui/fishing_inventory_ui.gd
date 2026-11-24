extends Control

## Fishing Inventory UI (Túi Cá).
## Hiển thị danh sách cá đã câu được: Tên hiển thị, số lượng và tổng trọng lượng.
## Có trạng thái túi trống khi chưa có cá.
## Chỉ giao tiếp qua API hoặc EventBus của core, hoàn toàn tách biệt khỏi logic lưu trữ hay gameplay.

const InventoryEventsContract: Script = preload("res://core/contracts/inventory_events.gd")
const FishingEventsContract: Script = preload("res://core/contracts/fishing_events.gd")

const FISH_NAMES: Dictionary = {
	"fish_ca_com": "Cá Cơm Biển",
	"fish_ca_doi": "Cá Đối Mục",
	"fish_ca_chem": "Cá Chẽm Bờ",
	"fish_ca_mu": "Cá Mú Đỏ",
	"fish_ca_thu": "Cá Thu Vàng",
	"fish_ca_ngu_dai_duong": "Cá Ngừ Đại Dương"
}

var _inventory_api: RefCounted

# UI Elements
var _panel: PanelContainer
var _title_label: Label
var _summary_label: Label
var _empty_label: Label
var _scroll_container: ScrollContainer
var _fish_list_container: VBoxContainer
var _toggle_button: Button
var _close_button: Button
var _is_open: bool = false


func _ready() -> void:
	_setup_ui()
	_setup_events()
	_update_view()


## Gán Inventory API cho UI đọc dữ liệu.
func set_inventory_api(api: RefCounted) -> void:
	_inventory_api = api
	_update_view()


## Mở hoặc đóng giao diện túi cá.
func toggle_inventory() -> void:
	set_open(not _is_open)


## Đặt trạng thái hiển thị của túi cá.
func set_open(open: bool) -> void:
	_is_open = open
	if _panel != null:
		_panel.visible = _is_open
	if _toggle_button != null:
		_toggle_button.text = "Đóng Túi Cá" if _is_open else "Túi Cá"
	if _is_open:
		_update_view()


func _setup_ui() -> void:
	# Cấu hình kích thước bám theo toàn màn hình
	anchors_preset = Control.PRESET_FULL_RECT
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Nút bấm mở/đóng túi cá góc trên bên phải (thuận tiện bấm trên điện thoại)
	_toggle_button = Button.new()
	_toggle_button.name = "BtnToggleInventory"
	_toggle_button.text = "Túi Cá"
	_toggle_button.custom_minimum_size = Vector2(90.0, 36.0)
	_toggle_button.anchor_left = 1.0
	_toggle_button.anchor_top = 0.0
	_toggle_button.anchor_right = 1.0
	_toggle_button.anchor_bottom = 0.0
	_toggle_button.offset_left = -110.0
	_toggle_button.offset_top = 16.0
	_toggle_button.offset_right = -20.0
	_toggle_button.offset_bottom = 52.0
	_toggle_button.pressed.connect(toggle_inventory)
	add_child(_toggle_button)

	# Bảng điều khiển túi cá (Modal / Popup nằm gọn gàng)
	_panel = PanelContainer.new()
	_panel.name = "InventoryPanel"
	_panel.visible = false
	_panel.anchor_left = 0.5
	_panel.anchor_top = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_bottom = 0.5
	_panel.offset_left = -220.0
	_panel.offset_top = -140.0
	_panel.offset_right = 220.0
	_panel.offset_bottom = 140.0
	add_child(_panel)

	# Stylebox nền tối mờ tinh tế vẽ bằng code phẳng, không dùng texture
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.11, 0.14, 0.95)
	panel_style.border_color = Color(0.25, 0.45, 0.6, 0.8)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(8)
	panel_style.content_margin_left = 16.0
	panel_style.content_margin_top = 12.0
	panel_style.content_margin_right = 16.0
	panel_style.content_margin_bottom = 12.0
	_panel.add_theme_stylebox_override("panel", panel_style)

	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 8)
	_panel.add_child(main_vbox)

	# Header thanh tiêu đề và nút Đóng
	var header_hbox := HBoxContainer.new()
	main_vbox.add_child(header_hbox)

	_title_label = Label.new()
	_title_label.text = "TÚI CÁ CỦA BẠN"
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label.add_theme_font_size_override("font_size", 16)
	header_hbox.add_child(_title_label)

	_close_button = Button.new()
	_close_button.text = " X "
	_close_button.pressed.connect(func(): set_open(false))
	header_hbox.add_child(_close_button)

	# Thanh tổng quan: Tổng số con và tổng trọng lượng
	_summary_label = Label.new()
	_summary_label.text = "Tổng: 0 con | 0 g"
	_summary_label.add_theme_font_size_override("font_size", 13)
	main_vbox.add_child(_summary_label)

	# Vùng cuộn danh sách cá
	_scroll_container = ScrollContainer.new()
	_scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll_container.custom_minimum_size = Vector2(0.0, 140.0)
	main_vbox.add_child(_scroll_container)

	_fish_list_container = VBoxContainer.new()
	_fish_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_fish_list_container.add_theme_constant_override("separation", 6)
	_scroll_container.add_child(_fish_list_container)

	# Nhãn trạng thái túi trống
	_empty_label = Label.new()
	_empty_label.text = "Túi cá hiện đang trống.\nHãy thả cần và thử vận may của bạn!"
	_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_empty_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_empty_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_empty_label.add_theme_font_size_override("font_size", 13)
	_fish_list_container.add_child(_empty_label)


func _setup_events() -> void:
	var eb: Node = get_node_or_null("/root/EventBus")
	if eb != null and eb.has_method("subscribe"):
		eb.call("subscribe", InventoryEventsContract.INVENTORY_UPDATED, _on_inventory_updated)
		eb.call("subscribe", InventoryEventsContract.ITEM_ADDED, _on_item_added)


func _on_inventory_updated(_payload: Dictionary) -> void:
	_update_view()


func _on_item_added(_payload: Dictionary) -> void:
	_update_view()


## Cập nhật toàn bộ nội dung hiển thị trong UI từ Inventory API.
func _update_view() -> void:
	if _fish_list_container == null:
		return

	# Xóa danh sách cũ
	for child in _fish_list_container.get_children():
		child.queue_free()

	var items: Dictionary = {}
	var total_count: int = 0
	var total_weight: int = 0

	if _inventory_api != null:
		if _inventory_api.has_method("get_all_items"):
			items = _inventory_api.call("get_all_items") as Dictionary
		if _inventory_api.has_method("get_total_fish_count"):
			total_count = int(_inventory_api.call("get_total_fish_count"))
		if _inventory_api.has_method("get_total_weight_g"):
			total_weight = int(_inventory_api.call("get_total_weight_g"))

	# Cập nhật tóm tắt
	if _summary_label != null:
		var kg_str: String = "%0.2f kg" % (float(total_weight) / 1000.0)
		_summary_label.text = "Tổng: %d con | %d g (%s)" % [total_count, total_weight, kg_str]

	# Kiểm tra túi trống
	if items.is_empty() or total_count == 0:
		_empty_label = Label.new()
		_empty_label.text = "Túi cá hiện đang trống.\nHãy thả cần và thử vận may của bạn!"
		_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_empty_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_empty_label.custom_minimum_size = Vector2(0.0, 80.0)
		_empty_label.add_theme_font_size_override("font_size", 13)
		_fish_list_container.add_child(_empty_label)
		return

	# Hiển thị từng mục cá trong danh sách
	for fish_id in items.keys():
		var data: Dictionary = items[fish_id] as Dictionary
		var count: int = int(data.get("count", 0))
		var weight_g: int = int(data.get("total_weight_g", 0))
		var display_name: String = str(FISH_NAMES.get(fish_id, fish_id))

		var item_panel := _create_fish_item_row(display_name, count, weight_g)
		_fish_list_container.add_child(item_panel)


func _create_fish_item_row(display_name: String, count: int, weight_g: int) -> Control:
	var row_panel := PanelContainer.new()
	row_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var row_style := StyleBoxFlat.new()
	row_style.bg_color = Color(0.12, 0.16, 0.22, 0.85)
	row_style.border_color = Color(0.2, 0.3, 0.4, 0.5)
	row_style.set_border_width_all(1)
	row_style.set_corner_radius_all(4)
	row_style.content_margin_left = 10.0
	row_style.content_margin_top = 6.0
	row_style.content_margin_right = 10.0
	row_style.content_margin_bottom = 6.0
	row_panel.add_theme_stylebox_override("panel", row_style)

	var hbox := HBoxContainer.new()
	row_panel.add_child(hbox)

	var name_lbl := Label.new()
	name_lbl.text = display_name
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_font_size_override("font_size", 14)
	hbox.add_child(name_lbl)

	var count_lbl := Label.new()
	count_lbl.text = "x%d" % count
	count_lbl.custom_minimum_size = Vector2(50.0, 0.0)
	count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_lbl.add_theme_font_size_override("font_size", 14)
	hbox.add_child(count_lbl)

	var weight_lbl := Label.new()
	var w_str: String = "%d g" % weight_g if weight_g < 1000 else "%0.2f kg" % (float(weight_g) / 1000.0)
	weight_lbl.text = w_str
	weight_lbl.custom_minimum_size = Vector2(70.0, 0.0)
	weight_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	weight_lbl.add_theme_font_size_override("font_size", 14)
	hbox.add_child(weight_lbl)

	return row_panel

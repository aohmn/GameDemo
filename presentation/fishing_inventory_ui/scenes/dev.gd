extends Control

## Scene kiểm tra độc lập cho Fishing Inventory UI (presentation/fishing_inventory_ui/).
## Tích hợp mock inventory hoặc InventoryAPI thực để thử nghiệm tương tác UI trên điện thoại.

const FishingInventoryUIScript: Script = preload("res://presentation/fishing_inventory_ui/fishing_inventory_ui.gd")
const INVENTORY_API_PATH: String = "res://modules/inventory/api/inventory_api.gd"
const InventoryEventsContract: Script = preload("res://core/contracts/inventory_events.gd")
const FishingEventsContract: Script = preload("res://core/contracts/fishing_events.gd")

var _ui: Control
var _inventory_api: RefCounted


func _ready() -> void:
	_setup_mock_environment()


func _setup_mock_environment() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	# Nền môi trường giả lập dev
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.08, 0.12)
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	add_child(bg)

	# Khởi tạo Inventory API độc lập nếu có
	if ResourceLoader.exists(INVENTORY_API_PATH):
		var api_script := load(INVENTORY_API_PATH) as Script
		if api_script != null:
			_inventory_api = api_script.new()

	# Khởi tạo UI
	_ui = FishingInventoryUIScript.new()
	add_child(_ui)
	if _inventory_api != null:
		_ui.call("set_inventory_api", _inventory_api)

	# Thanh nút thử nghiệm dev phía dưới màn hình
	var dev_bar := HBoxContainer.new()
	dev_bar.anchor_top = 1.0
	dev_bar.anchor_bottom = 1.0
	dev_bar.anchor_right = 1.0
	dev_bar.offset_top = -50.0
	dev_bar.offset_left = 20.0
	dev_bar.offset_right = -20.0
	dev_bar.add_theme_constant_override("separation", 10)
	add_child(dev_bar)

	var btn_add_com := Button.new()
	btn_add_com.text = "+ Cá Cơm (45g)"
	btn_add_com.pressed.connect(func(): _add_fish("fish_ca_com", 45))
	dev_bar.add_child(btn_add_com)

	var btn_add_doi := Button.new()
	btn_add_doi.text = "+ Cá Đối (220g)"
	btn_add_doi.pressed.connect(func(): _add_fish("fish_ca_doi", 220))
	dev_bar.add_child(btn_add_doi)

	var btn_add_ngu := Button.new()
	btn_add_ngu.text = "+ Cá Ngừ (18500g)"
	btn_add_ngu.pressed.connect(func(): _add_fish("fish_ca_ngu_dai_duong", 18500))
	dev_bar.add_child(btn_add_ngu)

	var btn_clear := Button.new()
	btn_clear.text = "Xóa rỗng túi"
	btn_clear.pressed.connect(_clear_inventory)
	dev_bar.add_child(btn_clear)

	var btn_toggle := Button.new()
	btn_toggle.text = "Mở/Đóng Túi"
	btn_toggle.pressed.connect(func(): _ui.call("toggle_inventory"))
	dev_bar.add_child(btn_toggle)


func _add_fish(fish_id: String, weight_g: int) -> void:
	var eb: Node = get_node_or_null("/root/EventBus")
	if eb != null and eb.has_method("emit_event"):
		eb.call("emit_event", FishingEventsContract.FISH_CAUGHT, {
			"fish_id": fish_id,
			"weight_g": weight_g,
			"name": fish_id
		})
	elif _inventory_api != null:
		_inventory_api.call("add_fish", fish_id, weight_g)


func _clear_inventory() -> void:
	if _inventory_api != null:
		_inventory_api.call("clear")

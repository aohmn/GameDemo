extends Control

## Scene kiểm thử độc lập cho Equipment UI (presentation/equipment_ui/).
## Nạp động EquipmentAPI nếu có, cho phép thử nghiệm thao tác UI trên điện thoại.

const EquipmentUIScript: Script = preload("res://presentation/equipment_ui/equipment_ui.gd")
const EQUIPMENT_API_PATH: String = "res://modules/equipment/api/equipment_api.gd"

var _ui: Control
var _equipment_api: RefCounted


func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.07, 0.10)
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	add_child(bg)

	if ResourceLoader.exists(EQUIPMENT_API_PATH):
		var api_script := load(EQUIPMENT_API_PATH) as Script
		if api_script != null:
			_equipment_api = api_script.new()

	_ui = EquipmentUIScript.new()
	add_child(_ui)
	if _equipment_api != null:
		_ui.call("setup", _equipment_api)
		_ui.connect("equip_requested", func(s, i): _equipment_api.call("equip_item", s, i, 0))
		_ui.connect("unequip_requested", func(s): _equipment_api.call("unequip_item", s))

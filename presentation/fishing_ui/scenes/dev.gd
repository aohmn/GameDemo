extends Control

## Scene kiểm tra độc lập cho Fishing UI (presentation/fishing_ui/).
## Tích hợp mock FishingAPI để thử nghiệm toàn bộ luồng tương tác:
## Thả cần -> Cắn câu -> Giật cần -> Giằng co lực căng -> Bắt được cá / Đứt dây.

const FishingUIScript: Script = preload("res://presentation/fishing_ui/fishing_ui.gd")
const FishingAPIScript: Script = preload("res://modules/fishing/api/fishing_api.gd")

var _ui: Control
var _fishing_api: RefCounted


func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.08, 0.12)
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	add_child(bg)

	_fishing_api = FishingAPIScript.new(12345)

	_ui = FishingUIScript.new()
	add_child(_ui)
	_ui.call("set_fishing_api", _fishing_api)
	_ui.call("set_near_fishing_spot", true, "spot_cau_tau_ben_cang")

	# Hàng nút test giả lập
	var test_bar := HBoxContainer.new()
	test_bar.position = Vector2(20.0, 100.0)
	test_bar.add_theme_constant_override("separation", 10)
	add_child(test_bar)

	var btn_toggle_spot := Button.new()
	btn_toggle_spot.text = "Bật/Tắt Gần điểm câu"
	var is_near := true
	btn_toggle_spot.pressed.connect(func():
		is_near = not is_near
		_ui.call("set_near_fishing_spot", is_near)
	)
	test_bar.add_child(btn_toggle_spot)


func _process(delta: float) -> void:
	if _fishing_api != null:
		_fishing_api.call("tick", delta)

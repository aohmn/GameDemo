extends Control

## HUD tu vi: cảnh giới, tầng, thanh tu vi và nút Đột phá. Presentation thuần:
## đọc dữ liệu qua CultivationAPI, nghe sự kiện qua EventBus, phát tín hiệu khi người chơi muốn đột phá.

signal breakthrough_requested

const CultivationEventsContract: Script = preload("res://core/contracts/cultivation_events.gd")
const TOAST_SECONDS: float = 3.0

var _api: RefCounted
var _realm_label: Label
var _exp_bar: ProgressBar
var _exp_label: Label
var _btn_breakthrough: Button
var _toast: Label
var _toast_left: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build()
	_connect_events()
	refresh()


func _process(delta: float) -> void:
	if _toast_left > 0.0:
		_toast_left -= delta
		if _toast_left <= 0.0:
			_toast.text = ""


func set_cultivation_api(api: RefCounted) -> void:
	_api = api
	refresh()


## Chỉ gọi khi có sự kiện, không gọi mỗi khung (tránh ẩn/hiện nút liên tục làm chạm không ăn).
func refresh() -> void:
	if _realm_label == null or _api == null:
		return
	var info: Dictionary = _api.call("get_cultivation_info")
	var required: float = maxf(1.0, float(info.get("required_exp", 1)))
	var current: float = float(info.get("layer_exp", 0))
	_realm_label.text = "%s · Tầng %d" % [str(info.get("realm_name", "")), int(info.get("layer", 1))]
	_exp_bar.max_value = required
	_exp_bar.value = minf(current, required)
	_exp_label.text = "Tu vi %d / %d" % [int(current), int(required)]
	_btn_breakthrough.visible = bool(info.get("can_breakthrough", false))


func show_toast(text: String) -> void:
	_toast.text = text
	_toast_left = TOAST_SECONDS


func _build() -> void:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.anchor_left = 0.0
	panel.anchor_top = 0.0
	panel.offset_left = 16.0
	panel.offset_top = 12.0
	panel.custom_minimum_size = Vector2(250.0, 0.0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.10, 0.16, 0.82)
	style.border_color = Color(0.45, 0.75, 0.95, 0.7)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(8.0)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)

	_realm_label = Label.new()
	_realm_label.add_theme_font_size_override("font_size", 15)
	box.add_child(_realm_label)

	_exp_bar = ProgressBar.new()
	_exp_bar.show_percentage = false
	_exp_bar.custom_minimum_size = Vector2(0.0, 10.0)
	_exp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_exp_bar)

	_exp_label = Label.new()
	_exp_label.add_theme_font_size_override("font_size", 12)
	box.add_child(_exp_label)

	_btn_breakthrough = Button.new()
	_btn_breakthrough.text = "ĐỘT PHÁ"
	_btn_breakthrough.custom_minimum_size = Vector2(0.0, 40.0)
	_btn_breakthrough.visible = false
	_btn_breakthrough.pressed.connect(func() -> void: breakthrough_requested.emit())
	box.add_child(_btn_breakthrough)

	_toast = Label.new()
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast.anchor_left = 0.0
	_toast.offset_left = 16.0
	_toast.offset_top = 150.0
	_toast.add_theme_font_size_override("font_size", 14)
	_toast.add_theme_color_override("font_color", Color(1.0, 0.92, 0.55))
	add_child(_toast)


func _connect_events() -> void:
	var eb: Node = get_node_or_null("/root/EventBus")
	if eb == null or not eb.has_method("subscribe"):
		return
	eb.call("subscribe", CultivationEventsContract.EXP_GAINED, _on_exp_gained)
	eb.call("subscribe", CultivationEventsContract.LAYER_UPGRADED, _on_layer_upgraded)
	eb.call("subscribe", CultivationEventsContract.BREAKTHROUGH_SUCCESS, _on_breakthrough_success)
	eb.call("subscribe", CultivationEventsContract.BREAKTHROUGH_FAILED, _on_breakthrough_failed)


func _on_exp_gained(p: Dictionary) -> void:
	refresh()
	show_toast("+%d tu vi" % int(p.get("amount_change", 0)))


func _on_layer_upgraded(p: Dictionary) -> void:
	refresh()
	show_toast("Lên tầng %d - %s" % [int(p.get("new_layer", 1)), str(p.get("realm_name", ""))])


func _on_breakthrough_success(p: Dictionary) -> void:
	refresh()
	show_toast("Đột phá thành công: %s" % str(p.get("new_realm_name", "")))


func _on_breakthrough_failed(p: Dictionary) -> void:
	refresh()
	show_toast(str(p.get("reason", "Đột phá thất bại")))

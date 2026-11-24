extends Control

## Fishing UI điều khiển và tương tác câu cá trên màn hình ngang Android.
## Bố trí các nút Thả cần, Giật cần, Kéo dây, Xả dây gọn gàng góc dưới bên phải.
## Nút Thả cần chỉ kích hoạt khi người chơi đứng gần điểm câu hợp lệ.
## Hiển thị thông báo cắn câu, thanh đo lực căng dây trong vùng an toàn và kết quả bắt cá.
## Thuộc tầng Presentation: chỉ giao tiếp qua EventBus và API, không chứa logic gameplay.

const FishingEventsContract: Script = preload("res://core/contracts/fishing_events.gd")

var _fishing_api: RefCounted
var _is_near_spot: bool = false
var _current_spot_id: String = "spot_cau_tau_ben_cang"

# Trạng thái câu hiện tại
var _state: String = "IDLE"

# UI Nodes
var _container: Control
var _status_label: Label
var _alert_label: Label
var _tension_bar: ProgressBar
var _tension_label: Label
var _result_panel: PanelContainer
var _result_label: Label

# Action Buttons
var _btn_cast: Button
var _btn_strike: Button
var _btn_reel: Button
var _btn_release: Button


func _ready() -> void:
	_setup_ui()
	_setup_events()
	_update_ui_state()


func set_fishing_api(api: RefCounted) -> void:
	_fishing_api = api


func set_near_fishing_spot(near: bool, spot_id: String = "spot_cau_tau_ben_cang") -> void:
	_is_near_spot = near
	_current_spot_id = spot_id
	_update_ui_state()


func _setup_ui() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 1. Bảng đo lực căng và thông báo (nằm ở cạnh trên giữa màn hình, không vướng joystick hay nút túi cá)
	var top_panel := PanelContainer.new()
	top_panel.name = "FishingInfoPanel"
	top_panel.anchor_left = 0.5
	top_panel.anchor_top = 0.0
	top_panel.anchor_right = 0.5
	top_panel.anchor_bottom = 0.0
	top_panel.offset_left = -170.0
	top_panel.offset_top = 16.0
	top_panel.offset_right = 170.0
	top_panel.offset_bottom = 90.0

	var top_style := StyleBoxFlat.new()
	top_style.bg_color = Color(0.08, 0.12, 0.16, 0.88)
	top_style.border_color = Color(0.25, 0.45, 0.6, 0.7)
	top_style.set_border_width_all(1)
	top_style.set_corner_radius_all(6)
	top_style.content_margin_left = 12.0
	top_style.content_margin_top = 8.0
	top_style.content_margin_right = 12.0
	top_style.content_margin_bottom = 8.0
	top_panel.add_theme_stylebox_override("panel", top_style)
	add_child(top_panel)

	var info_vbox := VBoxContainer.new()
	info_vbox.add_theme_constant_override("separation", 4)
	top_panel.add_child(info_vbox)

	_status_label = Label.new()
	_status_label.text = "Trạng thái: Sẵn sàng câu cá"
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", 13)
	info_vbox.add_child(_status_label)

	_alert_label = Label.new()
	_alert_label.text = ""
	_alert_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_alert_label.add_theme_font_size_override("font_size", 13)
	_alert_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	info_vbox.add_child(_alert_label)

	_tension_bar = ProgressBar.new()
	_tension_bar.min_value = 0.0
	_tension_bar.max_value = 100.0
	_tension_bar.value = 40.0
	_tension_bar.show_percentage = false
	_tension_bar.custom_minimum_size = Vector2(0.0, 10.0)
	_tension_bar.visible = false
	info_vbox.add_child(_tension_bar)

	_tension_label = Label.new()
	_tension_label.text = ""
	_tension_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tension_label.add_theme_font_size_override("font_size", 11)
	_tension_label.visible = false
	info_vbox.add_child(_tension_label)

	# 2. Khung nút bấm điều khiển câu cá ở góc dưới bên phải màn hình
	# Không che khuất Joystick (ở góc dưới trái) và Nút Túi Cá (góc trên phải)
	_container = Control.new()
	_container.name = "FishingButtonsCluster"
	_container.anchor_left = 1.0
	_container.anchor_top = 1.0
	_container.anchor_right = 1.0
	_container.anchor_bottom = 1.0
	_container.offset_left = -210.0
	_container.offset_top = -140.0
	_container.offset_right = -20.0
	_container.offset_bottom = -20.0
	add_child(_container)

	# Nút THẢ CẦN (Cast)
	_btn_cast = Button.new()
	_btn_cast.name = "BtnCast"
	_btn_cast.text = "Thả cần"
	_btn_cast.custom_minimum_size = Vector2(90.0, 48.0)
	_btn_cast.position = Vector2(95.0, 65.0)
	_btn_cast.pressed.connect(_on_btn_cast_pressed)
	_container.add_child(_btn_cast)

	# Nút GIẬT CẦN (Strike)
	_btn_strike = Button.new()
	_btn_strike.name = "BtnStrike"
	_btn_strike.text = "Giật cần!"
	_btn_strike.custom_minimum_size = Vector2(90.0, 48.0)
	_btn_strike.position = Vector2(95.0, 65.0)
	_btn_strike.visible = false
	_btn_strike.pressed.connect(_on_btn_strike_pressed)
	_container.add_child(_btn_strike)

	# Nút KÉO DÂY (Reel)
	_btn_reel = Button.new()
	_btn_reel.name = "BtnReel"
	_btn_reel.text = "Kéo dây"
	_btn_reel.custom_minimum_size = Vector2(85.0, 48.0)
	_btn_reel.position = Vector2(105.0, 65.0)
	_btn_reel.visible = false
	_btn_reel.button_down.connect(func(): _set_reeling(true))
	_btn_reel.button_up.connect(func(): _set_reeling(false))
	_container.add_child(_btn_reel)

	# Nút XẢ DÂY (Release)
	_btn_release = Button.new()
	_btn_release.name = "BtnRelease"
	_btn_release.text = "Xả dây"
	_btn_release.custom_minimum_size = Vector2(85.0, 48.0)
	_btn_release.position = Vector2(10.0, 65.0)
	_btn_release.visible = false
	_btn_release.button_down.connect(func(): _set_releasing(true))
	_btn_release.button_up.connect(func(): _set_releasing(false))
	_container.add_child(_btn_release)


func _setup_events() -> void:
	var eb: Node = get_node_or_null("/root/EventBus")
	if eb != null and eb.has_method("subscribe"):
		eb.call("subscribe", FishingEventsContract.STATE_CHANGED, _on_state_changed_evt)
		eb.call("subscribe", FishingEventsContract.FISH_BITING, _on_fish_biting_evt)
		eb.call("subscribe", FishingEventsContract.FIGHT_UPDATE, _on_fight_update_evt)
		eb.call("subscribe", FishingEventsContract.FISH_CAUGHT, _on_fish_caught_evt)
		eb.call("subscribe", FishingEventsContract.FISH_ESCAPED, _on_fish_escaped_evt)


func _update_ui_state() -> void:
	match _state:
		"IDLE", "RESULT":
			_btn_cast.visible = true
			_btn_cast.disabled = not _is_near_spot
			_btn_cast.text = "Thả cần" if _is_near_spot else "Đến gần nước"
			_btn_strike.visible = false
			_btn_reel.visible = false
			_btn_release.visible = false
			_tension_bar.visible = false
			_tension_label.visible = false
			if _state == "IDLE":
				_status_label.text = "Đang ở điểm câu" if _is_near_spot else "Hãy di chuyển ra cầu tàu để câu cá"

		"CASTING", "WAITING":
			_btn_cast.visible = false
			_btn_strike.visible = false
			_btn_reel.visible = false
			_btn_release.visible = false
			_tension_bar.visible = false
			_tension_label.visible = false
			_status_label.text = "Phao đã thả... Đang đợi cá cắn câu"
			_alert_label.text = ""

		"BITE":
			_btn_cast.visible = false
			_btn_strike.visible = true
			_btn_reel.visible = false
			_btn_release.visible = false
			_tension_bar.visible = false
			_tension_label.visible = false
			_status_label.text = "CÁ ĐANG CẮN CÂU!"
			_alert_label.text = "Bấm [Giật cần!] ngay lập tức!"

		"FIGHT":
			_btn_cast.visible = false
			_btn_strike.visible = false
			_btn_reel.visible = true
			_btn_release.visible = true
			_tension_bar.visible = true
			_tension_label.visible = true
			_status_label.text = "Đang giằng co với cá!"


func _on_btn_cast_pressed() -> void:
	if not _is_near_spot:
		return
	if _fishing_api != null and _fishing_api.has_method("cast"):
		_fishing_api.call("cast", _current_spot_id)


func _on_btn_strike_pressed() -> void:
	if _fishing_api != null and _fishing_api.has_method("strike"):
		_fishing_api.call("strike")


func _set_reeling(held: bool) -> void:
	if _fishing_api != null and _fishing_api.has_method("reel"):
		_fishing_api.call("reel", held)


func _set_releasing(held: bool) -> void:
	if _fishing_api != null and _fishing_api.has_method("release"):
		_fishing_api.call("release", held)


func _on_state_changed_evt(payload: Dictionary) -> void:
	_state = str(payload.get("to_state", "IDLE"))
	_update_ui_state()


func _on_fish_biting_evt(payload: Dictionary) -> void:
	_state = "BITE"
	var win_sec: float = float(payload.get("window_seconds", 0.8))
	_alert_label.text = "Cá cắn câu! Giật trong %0.1fs!" % win_sec
	_update_ui_state()


func _on_fight_update_evt(payload: Dictionary) -> void:
	_state = "FIGHT"
	var tension: float = float(payload.get("line_tension", 0.0))
	var s_min: float = float(payload.get("safe_min", 30.0))
	var s_max: float = float(payload.get("safe_max", 70.0))
	var max_t: float = float(payload.get("max_tension", 100.0))
	var strength: float = float(payload.get("fish_strength", 0.0))

	_tension_bar.max_value = max_t
	_tension_bar.value = tension

	var is_safe := (tension >= s_min and tension <= s_max)
	var status_color := "Xanh (An toàn)" if is_safe else "Đỏ (Nguy hiểm)"
	_tension_label.text = "Lực căng: %0.0f/%0.0f [%s] | Sức cá: %0.0f" % [tension, max_t, status_color, strength]
	_alert_label.text = "Giữ lực căng trong khoảng %0.0f - %0.0f" % [s_min, s_max]


func _on_fish_caught_evt(payload: Dictionary) -> void:
	_state = "RESULT"
	var name_str: String = str(payload.get("name", "Cá"))
	var weight: int = int(payload.get("weight_g", 0))
	_status_label.text = "BẮT ĐƯỢC: %s (%d g)!" % [name_str, weight]
	_alert_label.text = "Đã cất vào túi cá. Chúc mừng!"
	_update_ui_state()


func _on_fish_escaped_evt(payload: Dictionary) -> void:
	_state = "RESULT"
	var reason: String = str(payload.get("reason", "unknown"))
	var reason_text := "Cá đã trốn thoát!"
	if reason == "early":
		reason_text = "Giật cần quá sớm!"
	elif reason == "late":
		reason_text = "Cá đã đớp mồi chạy mất (giật trễ)!"
	elif reason == "line_break":
		reason_text = "Lực căng quá lớn làm đứt dây cước!"

	_status_label.text = "THẤT BẠI: " + reason_text
	_alert_label.text = "Hãy thử lại lần sau."
	_update_ui_state()

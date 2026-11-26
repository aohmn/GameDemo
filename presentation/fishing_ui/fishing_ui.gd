extends Control

## Fishing UI — Giao diện câu cá màn hình ngang phong cách Tiên Hiệp Biển Khơi (Genshin x Sea of Thieves).
## Hiển thị đầy đủ: Trạng thái, Lực căng dây, Tiến trình thu phục cá, Độ bền cần/dây, Cảnh báo trực quan.
## Bố cục tối ưu, cụm nút cảm ứng lớn, không che Joystick hay Túi cá. Thuộc tầng Presentation.

const FishingEventsContract: Script = preload("res://core/contracts/fishing_events.gd")
const ThemeUtil: Script = preload("res://presentation/fishing_ui/fishing_ui_theme.gd")

var _fishing_api: RefCounted
var _is_near_spot: bool = false
var _current_spot_id: String = "spot_cau_tau_ben_cang"
var _state: String = "IDLE"

var _badge_label: Label
var _sub_label: Label
var _alert_label: Label
var _tension_bar: ProgressBar
var _tension_txt: Label
var _progress_bar: ProgressBar
var _durability_label: Label

var _btn_cast: Button
var _btn_strike: Button
var _btn_reel: Button
var _btn_release: Button

var _res_popup: PanelContainer
var _res_title: Label
var _res_desc: Label
var _res_timer: float = 0.0


func _ready() -> void:
	_build_ui()
	_connect_events()
	_update_view()


func set_fishing_api(api: RefCounted) -> void:
	_fishing_api = api


func set_near_fishing_spot(near: bool, spot_id: String = "spot_cau_tau_ben_cang") -> void:
	# Bootstrap gọi mỗi khung vật lý: chỉ vẽ lại khi có thay đổi, nếu không nút bị ẩn/hiện liên tục
	# và Godot hủy trạng thái "đang nhấn" nên chạm thật trên điện thoại không bao giờ kích hoạt.
	if near == _is_near_spot and spot_id == _current_spot_id:
		return
	_is_near_spot = near
	_current_spot_id = spot_id
	_update_view()


func _process(delta: float) -> void:
	if _res_popup.visible:
		_res_timer -= delta
		if _res_timer <= 0.0:
			_res_popup.visible = false


func _build_ui() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var top_widgets: Dictionary = ThemeUtil.build_top_panel()
	add_child(top_widgets["panel"])
	_badge_label = top_widgets["badge"]
	_sub_label = top_widgets["sub"]
	_alert_label = top_widgets["alert"]
	_progress_bar = top_widgets["progress"]
	_tension_bar = top_widgets["tension"]
	_tension_txt = top_widgets["tension_text"]
	_durability_label = top_widgets["durability"]

	_build_buttons()
	_build_result_popup()


func _build_buttons() -> void:
	var btn_box := Control.new()
	btn_box.anchor_left = 1.0
	btn_box.anchor_top = 1.0
	btn_box.anchor_right = 1.0
	btn_box.anchor_bottom = 1.0
	btn_box.offset_left = -260.0
	btn_box.offset_top = -140.0
	btn_box.offset_right = -20.0
	btn_box.offset_bottom = -20.0
	add_child(btn_box)

	_btn_cast = ThemeUtil.make_btn("Thả Cần", Vector2(130.0, 52.0), Vector2(110.0, 55.0), Color(0.12, 0.45, 0.40))
	_btn_cast.pressed.connect(func():
		if _is_near_spot and _fishing_api != null and _fishing_api.has_method("cast"):
			_fishing_api.call("cast", _current_spot_id)
	)
	btn_box.add_child(_btn_cast)

	_btn_strike = ThemeUtil.make_btn("GIẬT CẦN!", Vector2(130.0, 52.0), Vector2(110.0, 55.0), Color(0.85, 0.28, 0.18))
	_btn_strike.pressed.connect(func():
		if _fishing_api != null and _fishing_api.has_method("strike"):
			_fishing_api.call("strike")
	)
	btn_box.add_child(_btn_strike)

	_btn_reel = ThemeUtil.make_btn("Kéo Dây", Vector2(110.0, 52.0), Vector2(130.0, 55.0), Color(0.18, 0.45, 0.65))
	_btn_reel.button_down.connect(func(): if _fishing_api != null: _fishing_api.call("reel", true))
	_btn_reel.button_up.connect(func(): if _fishing_api != null: _fishing_api.call("reel", false))
	btn_box.add_child(_btn_reel)

	_btn_release = ThemeUtil.make_btn("Xả Dây", Vector2(110.0, 52.0), Vector2(10.0, 55.0), Color(0.35, 0.35, 0.45))
	_btn_release.button_down.connect(func(): if _fishing_api != null: _fishing_api.call("release", true))
	_btn_release.button_up.connect(func(): if _fishing_api != null: _fishing_api.call("release", false))
	btn_box.add_child(_btn_release)


func _build_result_popup() -> void:
	_res_popup = PanelContainer.new()
	_res_popup.anchor_left = 0.5
	_res_popup.anchor_top = 0.5
	_res_popup.anchor_right = 0.5
	_res_popup.anchor_bottom = 0.5
	_res_popup.offset_left = -160.0
	_res_popup.offset_top = -50.0
	_res_popup.offset_right = 160.0
	_res_popup.offset_bottom = 50.0
	_res_popup.visible = false
	add_child(_res_popup)

	var res_vbox := VBoxContainer.new()
	res_vbox.add_theme_constant_override("separation", 6)
	_res_popup.add_child(res_vbox)

	_res_title = Label.new()
	_res_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_res_title.add_theme_font_size_override("font_size", 16)
	res_vbox.add_child(_res_title)

	_res_desc = Label.new()
	_res_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_res_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_res_desc.custom_minimum_size = Vector2(300.0, 0.0)
	_res_desc.add_theme_font_size_override("font_size", 12)
	res_vbox.add_child(_res_desc)


func _connect_events() -> void:
	var eb: Node = get_node_or_null("/root/EventBus")
	if eb != null and eb.has_method("subscribe"):
		eb.call("subscribe", FishingEventsContract.STATE_CHANGED, func(p: Dictionary): _state = str(p.get("to_state", "IDLE")); _update_view())
		eb.call("subscribe", FishingEventsContract.FISH_BITING, func(p: Dictionary): _state = "BITE"; _alert_label.text = "Cá cắn câu! Giật trong %0.1fs!" % float(p.get("window_seconds", 0.8)); _update_view())
		eb.call("subscribe", FishingEventsContract.FIGHT_UPDATE, _on_fight_update_evt)
		eb.call("subscribe", FishingEventsContract.CAST_DENIED, _on_cast_denied_evt)
		eb.call("subscribe", FishingEventsContract.FISH_CAUGHT, _on_fish_caught_evt)
		eb.call("subscribe", FishingEventsContract.FISH_ESCAPED, _on_fish_escaped_evt)


func _update_view() -> void:
	match _state:
		"IDLE", "CAUGHT", "ESCAPED", "FAILED":
			_set_visible_widgets(false, true)
			_btn_cast.disabled = not _is_near_spot
			_btn_cast.text = "Thả Cần" if _is_near_spot else "Đến Gần Nước"
			_badge_label.text = "SẴN SÀNG"
			if _is_near_spot:
				_sub_label.text = "Điểm câu: Hồ Linh Ngư" if _current_spot_id == "spot_ho_linh_ngu" else "Điểm câu: Cầu Tàu Bến Cảng"
			else:
				_sub_label.text = "Đến gần nước (Cầu tàu hoặc Hồ Linh Ngư) để thả cần"
			_alert_label.text = ""

		"CASTING", "WAITING":
			_set_visible_widgets(false)
			_badge_label.text = "CHỜ ĐỢI"
			_sub_label.text = "Mặt nước đang gợn sóng..."
			_alert_label.text = "Tĩnh tâm chờ linh ngư cắn câu"

		"BITE":
			_set_visible_widgets(false, false, true)
			_badge_label.text = "CẮN CÂU!"
			_sub_label.text = "Phao câu đang bị kéo chìm!"
			_alert_label.text = "BẤM GIẬT CẦN NGAY LẬP TỨC!"

		"FIGHT":
			_set_visible_widgets(true)
			_badge_label.text = "ĐẤU SỨC"
			_sub_label.text = "Giữ lực căng trong vùng an toàn"


func _set_visible_widgets(in_fight: bool, show_cast: bool = false, show_strike: bool = false) -> void:
	_btn_cast.visible = show_cast
	_btn_strike.visible = show_strike
	_btn_reel.visible = in_fight
	_btn_release.visible = in_fight
	_progress_bar.visible = in_fight
	_tension_bar.visible = in_fight
	_tension_txt.visible = in_fight
	_durability_label.visible = in_fight


func _on_fight_update_evt(payload: Dictionary) -> void:
	_state = "FIGHT"
	_set_visible_widgets(true)

	var cur_t: float = float(payload.get("line_tension", 0.0))
	var s_min: float = float(payload.get("safe_min", 30.0))
	var s_max: float = float(payload.get("safe_max", 70.0))
	var max_t: float = float(payload.get("max_tension", 100.0))
	var cur_stam: float = float(payload.get("fish_strength", 0.0))
	var max_stam: float = float(payload.get("fish_max_stamina", 100.0))
	var rod_dur: float = float(payload.get("rod_durability", 100.0))
	var line_dur: float = float(payload.get("line_durability", 100.0))
	var f_mode: int = int(payload.get("fish_mode", 1))

	_tension_bar.max_value = max_t
	_tension_bar.value = cur_t

	var is_safe := (cur_t >= s_min and cur_t <= s_max)
	var t_col := Color(0.2, 0.8, 0.4) if is_safe else (Color(0.9, 0.25, 0.2) if cur_t > s_max else Color(0.85, 0.7, 0.2))
	_tension_bar.add_theme_stylebox_override("fill", ThemeUtil.make_box(t_col, Color.TRANSPARENT, 0, 4))

	var status_text := "Vùng An Toàn" if is_safe else ("QUÁ CĂNG! ĐỨT DÂY!" if cur_t > s_max else "QUÁ CHÙNG! TUỘT LƯỠI!")
	_tension_txt.text = "Lực căng: %0.0f/%0.0f [%s]" % [cur_t, max_t, status_text]
	_durability_label.text = "Cần: %0.0f%% | Dây: %0.0f%%" % [rod_dur, line_dur]

	var progress := clampf((1.0 - (cur_stam / maxf(1.0, max_stam))) * 100.0, 0.0, 100.0)
	_progress_bar.value = progress

	var mode_name := "Bình tĩnh"
	match f_mode:
		0: mode_name = "Cá mệt lả"
		2: mode_name = "CÁ GIÃY BỨT TỐC!"
		3: mode_name = "Cá tạm nghỉ"
	_alert_label.text = "[Thu phục: %0.0f%%] %s" % [progress, mode_name]


func _on_fish_caught_evt(payload: Dictionary) -> void:
	_show_result(
		"THU PHỤC THÀNH CÔNG!",
		"Linh Ngư: %s (%d g)\nChứa %d linh khí - mở Túi, bấm Hấp thu để vào tu vi" % [
			str(payload.get("name", "Linh Ngư")),
			int(payload.get("weight_g", 0)),
			int(payload.get("qi_value", 0))
		],
		Color(0.12, 0.45, 0.40)
	)
	_state = "IDLE"
	_update_view()


func _on_fish_escaped_evt(payload: Dictionary) -> void:
	var r: String = str(payload.get("reason", "unknown"))
	var desc := "Cá đã trốn thoát!"
	if r == "early": desc = "Giật cần quá sớm!"
	elif r == "late": desc = "Cá đớp mồi chạy mất do giật trễ!"
	elif r == "line_break": desc = "Căng quá mức làm đứt dây câu!"
	elif r == "rod_broken": desc = "Cần câu quá tải bị gãy đôi!"
	elif r == "slack": desc = "Dây quá chùng khiến cá tuột lưỡi câu!"

	_show_result("CÂU CÁ THẤT BẠI", desc, Color(0.65, 0.18, 0.15))
	_state = "IDLE"
	_update_view()


func _show_result(title: String, desc: String, bg_col: Color) -> void:
	_res_popup.add_theme_stylebox_override("panel", ThemeUtil.make_box(
		Color(bg_col.r * 0.4, bg_col.g * 0.4, bg_col.b * 0.4, 0.95),
		Color(0.85, 0.70, 0.28), 2, 8
	))
	_res_title.text = title
	_res_desc.text = desc
	_res_popup.visible = true
	_res_timer = 3.0


func _on_cast_denied_evt(p: Dictionary) -> void:
	match str(p.get("reason", "")):
		"spot_realm":
			_alert_label.text = "Cảnh giới chưa đủ để câu ở vùng này (cần cảnh giới %d)" % (int(p.get("required", 0)) + 1)
		"rod_realm":
			_alert_label.text = "Cảnh giới chưa đủ để dùng cần này (cần cảnh giới %d)" % (int(p.get("required", 0)) + 1)
		"no_fish_for_rod":
			_alert_label.text = "Cần câu quá yếu, không có linh ngư nào mắc câu ở đây"
		_:
			_alert_label.text = "Không thể thả cần lúc này"

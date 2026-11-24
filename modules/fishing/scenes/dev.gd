extends Control

## Scene kiểm tra độc lập cho module Fishing.
## Chứa các nút Thả cần, Giật, Kéo, Xả và log trạng thái trực tiếp.

const FishingEventsContract: Script = preload("res://core/contracts/fishing_events.gd")
const FishingAPIScript: Script = preload("res://modules/fishing/api/fishing_api.gd")

var _api: RefCounted
var _log_label: Label
var _status_label: Label
var _gauge_label: Label

var _btn_cast: Button
var _btn_strike: Button
var _btn_reel: Button
var _btn_release: Button
var _btn_cancel: Button

var _logs: Array[String] = []


func _ready() -> void:
	_setup_ui()
	_api = FishingAPIScript.new(12345)
	_setup_event_listeners()
	_log("Khởi tạo module Fishing dev scene thành công (Seed: 12345).")


func _process(delta: float) -> void:
	if _api != null:
		_api.call("tick", delta)
		if _status_label != null:
			var st: String = str(_api.call("get_state"))
			_status_label.text = "Trạng thái: " + st


func _setup_ui() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.12, 0.16)
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
	title.text = "CÂU CÁ DEV TEST — modules/fishing"
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)

	_status_label = Label.new()
	_status_label.text = "Trạng thái: IDLE"
	_status_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(_status_label)

	_gauge_label = Label.new()
	_gauge_label.text = "Lực căng: 0.0 | Sức cá: 0.0"
	_gauge_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(_gauge_label)

	var hbox_btns := HBoxContainer.new()
	hbox_btns.add_theme_constant_override("separation", 10)
	vbox.add_child(hbox_btns)

	_btn_cast = Button.new()
	_btn_cast.text = "Thả cần"
	_btn_cast.pressed.connect(_on_btn_cast_pressed)
	hbox_btns.add_child(_btn_cast)

	_btn_strike = Button.new()
	_btn_strike.text = "Giật cần"
	_btn_strike.pressed.connect(_on_btn_strike_pressed)
	hbox_btns.add_child(_btn_strike)

	_btn_reel = Button.new()
	_btn_reel.text = "Kéo dây"
	_btn_reel.button_down.connect(func(): _api.call("reel", true))
	_btn_reel.button_up.connect(func(): _api.call("reel", false))
	hbox_btns.add_child(_btn_reel)

	_btn_release = Button.new()
	_btn_release.text = "Xả dây"
	_btn_release.button_down.connect(func(): _api.call("release", true))
	_btn_release.button_up.connect(func(): _api.call("release", false))
	hbox_btns.add_child(_btn_release)

	_btn_cancel = Button.new()
	_btn_cancel.text = "Hủy"
	_btn_cancel.pressed.connect(func(): _api.call("cancel"))
	hbox_btns.add_child(_btn_cancel)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0.0, 180.0)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	_log_label = Label.new()
	_log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scroll.add_child(_log_label)


func _setup_event_listeners() -> void:
	var eb: Node = get_node_or_null("/root/EventBus")
	if eb != null and eb.has_method("subscribe"):
		eb.call("subscribe", FishingEventsContract.STATE_CHANGED, _on_evt_state_changed)
		eb.call("subscribe", FishingEventsContract.FISH_BITING, _on_evt_fish_biting)
		eb.call("subscribe", FishingEventsContract.FIGHT_UPDATE, _on_evt_fight_update)
		eb.call("subscribe", FishingEventsContract.FISH_CAUGHT, _on_evt_fish_caught)
		eb.call("subscribe", FishingEventsContract.FISH_ESCAPED, _on_evt_fish_escaped)


func _on_btn_cast_pressed() -> void:
	var ok: bool = bool(_api.call("cast", "spot_cau_tau_ben_cang"))
	if ok:
		_log("Đã quăng câu tại Cầu Tàu Bến Cảng...")


func _on_btn_strike_pressed() -> void:
	var ok: bool = bool(_api.call("strike"))
	if ok:
		_log("Giật cần chuẩn xác! Bắt đầu giằng co...")
	else:
		_log("Giật cần hụt!")


func _on_evt_state_changed(payload: Dictionary) -> void:
	_log("State: %s -> %s" % [payload.get("from_state", ""), payload.get("to_state", "")])


func _on_evt_fish_biting(payload: Dictionary) -> void:
	_log(">> CÁ ĐANG CẮN CÂU! (Thời gian giật: %0.1fs) <<" % [payload.get("window_seconds", 0.8)])


func _on_evt_fight_update(payload: Dictionary) -> void:
	var strength: float = float(payload.get("fish_strength", 0.0))
	var tension: float = float(payload.get("line_tension", 0.0))
	var s_min: float = float(payload.get("safe_min", 30.0))
	var s_max: float = float(payload.get("safe_max", 70.0))
	var max_t: float = float(payload.get("max_tension", 100.0))
	_gauge_label.text = "Lực căng: %0.1f (An toàn: %0.0f-%0.0f | Ngưỡng đứt: %0.0f) | Sức cá: %0.1f" % [tension, s_min, s_max, max_t, strength]


func _on_evt_fish_caught(payload: Dictionary) -> void:
	_log("THÀNH CÔNG: Đã bắt được %s (%d g)!" % [payload.get("name", ""), payload.get("weight_g", 0)])


func _on_evt_fish_escaped(payload: Dictionary) -> void:
	_log("THẤT BẠI: Cá trốn thoát (Lý do: %s)!" % [payload.get("reason", "")])


func _log(msg: String) -> void:
	_logs.append(msg)
	if _logs.size() > 15:
		_logs.pop_front()
	if _log_label != null:
		_log_label.text = "\n".join(_logs)

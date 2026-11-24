extends Control

## Scene kiểm tra độc lập cho module Cultivation.

const CultivationAPIScript: Script = preload("res://modules/cultivation/api/cultivation_api.gd")
const CultivationEventsContract: Script = preload("res://core/contracts/cultivation_events.gd")

var _api: RefCounted
var _info_label: Label
var _log_label: RichTextLabel


func _ready() -> void:
	_api = CultivationAPIScript.new()
	_setup_ui()
	_subscribe_events()
	_update_display()


func _setup_ui() -> void:
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 20
	vbox.offset_top = 20
	vbox.offset_right = -20
	vbox.offset_bottom = -20
	add_child(vbox)

	var title := Label.new()
	title.text = "=== DEV: CULTIVATION MODULE ==="
	vbox.add_child(title)

	_info_label = Label.new()
	vbox.add_child(_info_label)

	var btn_row := HBoxContainer.new()
	vbox.add_child(btn_row)

	var btn_add_100 := Button.new()
	btn_add_100.text = "+100 Tu Vi"
	btn_add_100.pressed.connect(func():
		_api.call("add_exp", 100, "dev_test")
		_update_display()
	)
	btn_row.add_child(btn_add_100)

	var btn_add_1000 := Button.new()
	btn_add_1000.text = "+1,000 Tu Vi"
	btn_add_1000.pressed.connect(func():
		_api.call("add_exp", 1000, "dev_test")
		_update_display()
	)
	btn_row.add_child(btn_add_1000)

	var btn_breakthrough := Button.new()
	btn_breakthrough.text = "Đột Phá Cảnh Giới"
	btn_breakthrough.pressed.connect(func():
		var res: Dictionary = _api.call("breakthrough") as Dictionary
		_log("Kết quả đột phá: %s (Lý do: %s)" % [str(res.get("success")), str(res.get("reason"))])
		_update_display()
	)
	btn_row.add_child(btn_breakthrough)

	var btn_save := Button.new()
	btn_save.text = "Lưu (save)"
	btn_save.pressed.connect(func():
		_api.call("save")
		_log("Đã lưu cultivation vào disk.")
	)
	btn_row.add_child(btn_save)

	var btn_load := Button.new()
	btn_load.text = "Tải (load)"
	btn_load.pressed.connect(func():
		_api.call("load_save")
		_log("Đã nạp cultivation từ disk.")
		_update_display()
	)
	btn_row.add_child(btn_load)

	_log_label = RichTextLabel.new()
	_log_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_log_label)


func _subscribe_events() -> void:
	var ml: MainLoop = Engine.get_main_loop()
	if ml is SceneTree:
		var st := ml as SceneTree
		if st.root != null and st.root.has_node("EventBus"):
			var eb: Node = st.root.get_node("EventBus")
			eb.call("subscribe", CultivationEventsContract.EXP_GAINED, Callable(self, "_on_exp_evt"))
			eb.call("subscribe", CultivationEventsContract.LAYER_UPGRADED, Callable(self, "_on_layer_evt"))
			eb.call("subscribe", CultivationEventsContract.BREAKTHROUGH_SUCCESS, Callable(self, "_on_bt_ok_evt"))
			eb.call("subscribe", CultivationEventsContract.BREAKTHROUGH_FAILED, Callable(self, "_on_bt_fail_evt"))


func _update_display() -> void:
	if _info_label == null or _api == null:
		return
	var info: Dictionary = _api.call("get_cultivation_info") as Dictionary
	_info_label.text = "Cảnh giới: %s (Cấp %d) | Tầng: %d/9 | Tu vi: %d/%d (Tổng: %d) | Đủ đk đột phá: %s" % [
		str(info.get("realm_name", "")),
		int(info.get("realm_index", 0)),
		int(info.get("layer", 1)),
		int(info.get("layer_exp", 0)),
		int(info.get("required_exp", 0)),
		int(info.get("total_exp", 0)),
		str(info.get("can_breakthrough", false))
	]


func _on_exp_evt(payload: Dictionary) -> void:
	_log("[Event] Tu vi +%d (Hiện tại: %d, Tổng: %d)" % [int(payload.get("amount_change", 0)), int(payload.get("current_exp", 0)), int(payload.get("total_exp", 0))])


func _on_layer_evt(payload: Dictionary) -> void:
	_log("[Event] Thăng tầng! %s Tầng %d -> Tầng %d" % [str(payload.get("realm_name", "")), int(payload.get("old_layer", 0)), int(payload.get("new_layer", 0))])


func _on_bt_ok_evt(payload: Dictionary) -> void:
	_log("[Event] ĐỘT PHÁ THÀNH CÔNG! Đắc đạo tiến vào: %s" % str(payload.get("new_realm_name", "")))


func _on_bt_fail_evt(payload: Dictionary) -> void:
	_log("[Event] Đột phá thất bại: %s" % str(payload.get("reason", "")))


func _log(msg: String) -> void:
	if _log_label != null:
		_log_label.append_text(msg + "\n")

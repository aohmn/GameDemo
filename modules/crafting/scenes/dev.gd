extends Control

## Scene kiểm tra độc lập cho module Crafting.

const CraftingAPIScript: Script = preload("res://modules/crafting/api/crafting_api.gd")
const CraftingEventsContract: Script = preload("res://core/contracts/crafting_events.gd")

var _api: RefCounted
var _info_label: Label
var _log_label: RichTextLabel


func _ready() -> void:
	_api = CraftingAPIScript.new()
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
	title.text = "=== DEV: CRAFTING MODULE ==="
	vbox.add_child(title)

	_info_label = Label.new()
	vbox.add_child(_info_label)

	var btn_row := HBoxContainer.new()
	vbox.add_child(btn_row)

	var btn_craft_truc := Button.new()
	btn_craft_truc.text = "Chế Cần Trúc (Tức thì)"
	btn_craft_truc.pressed.connect(func():
		var res: Dictionary = _api.call("start_craft", "recipe_rod_truc_nhiem", 0) as Dictionary
		_log("Bắt đầu chế cần trúc: %s" % str(res))
		_update_display()
	)
	btn_row.add_child(btn_craft_truc)

	var btn_craft_carbon := Button.new()
	btn_craft_carbon.text = "Chế Cần Carbon (2s)"
	btn_craft_carbon.pressed.connect(func():
		var res: Dictionary = _api.call("start_craft", "recipe_rod_carbon_bien_sau", 1) as Dictionary
		_log("Bắt đầu chế cần carbon: %s" % str(res))
		_update_display()
	)
	btn_row.add_child(btn_craft_carbon)

	var btn_cancel := Button.new()
	btn_cancel.text = "Hủy Chế Tạo"
	btn_cancel.pressed.connect(func():
		var res: Dictionary = _api.call("cancel_craft") as Dictionary
		_log("Hủy chế tạo: %s" % str(res))
		_update_display()
	)
	btn_row.add_child(btn_cancel)

	_log_label = RichTextLabel.new()
	_log_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_log_label)


func _process(delta: float) -> void:
	if _api != null:
		var p_res: Dictionary = _api.call("process_craft", delta) as Dictionary
		if bool(p_res.get("finished", false)):
			_log("Tiến trình chế tạo %s hoàn tất!" % str(p_res.get("recipe_id")))
			_update_display()


func _subscribe_events() -> void:
	var ml: MainLoop = Engine.get_main_loop()
	if ml is SceneTree:
		var st := ml as SceneTree
		if st.root != null and st.root.has_node("EventBus"):
			var eb: Node = st.root.get_node("EventBus")
			eb.call("subscribe", CraftingEventsContract.CRAFT_STARTED, Callable(self, "_on_c_started"))
			eb.call("subscribe", CraftingEventsContract.CRAFT_COMPLETED, Callable(self, "_on_c_completed"))
			eb.call("subscribe", CraftingEventsContract.CRAFT_CANCELLED, Callable(self, "_on_c_cancelled"))
			eb.call("subscribe", CraftingEventsContract.CRAFT_FAILED, Callable(self, "_on_c_failed"))


func _update_display() -> void:
	if _info_label == null or _api == null:
		return
	var active: Dictionary = _api.call("get_active_craft_info") as Dictionary
	if active.is_empty():
		_info_label.text = "Trạng thái lò luyện: Rảnh rỗi"
	else:
		_info_label.text = "Đang chế tạo: %s | Còn lại: %.1fs" % [
			str(active.get("recipe_id")),
			float(active.get("remaining_time", 0.0))
		]


func _on_c_started(payload: Dictionary) -> void:
	_log("[Event] Bắt đầu chế tạo %s (thời gian: %.1fs)" % [str(payload.get("recipe_id")), float(payload.get("duration", 0.0))])


func _on_c_completed(payload: Dictionary) -> void:
	_log("[Event] Chế tạo hoàn tất! Nhận: %s x%d" % [str(payload.get("output_item_id")), int(payload.get("output_count", 1))])


func _on_c_cancelled(payload: Dictionary) -> void:
	_log("[Event] Đã hủy chế tạo %s" % str(payload.get("recipe_id")))


func _on_c_failed(payload: Dictionary) -> void:
	_log("[Event] Chế tạo thất bại: %s (Lý do: %s)" % [str(payload.get("recipe_id")), str(payload.get("reason"))])


func _log(msg: String) -> void:
	if _log_label != null:
		_log_label.append_text(msg + "\n")

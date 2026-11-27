extends Control

## Scene kiểm tra độc lập cho module Equipment.

const EquipmentAPIScript: Script = preload("res://modules/equipment/api/equipment_api.gd")
const EquipmentItemSpecScript: Script = preload("res://modules/equipment/data/equipment_item_spec.gd")
const EquipmentEventsContract: Script = preload("res://core/contracts/equipment_events.gd")

var _api: RefCounted
var _info_label: Label
var _log_label: RichTextLabel


func _ready() -> void:
	_api = EquipmentAPIScript.new()
	_register_dev_rods()
	_setup_ui()
	_subscribe_events()
	_update_display()


func _register_dev_rods() -> void:
	for entry in [
		{"id": "rod_truc_nhiem", "name": "Cần Trúc (Dev)", "tension": 0.0, "fatigue": 0.0},
		{"id": "rod_carbon_bien_sau", "name": "Cần Carbon (Dev)", "tension": 25.0, "fatigue": 6.0},
	]:
		var spec: Resource = EquipmentItemSpecScript.new()
		spec.set("id", entry["id"])
		spec.set("display_name", entry["name"])
		spec.set("slot_type", "rod")
		spec.set("max_tension_bonus", entry["tension"])
		spec.set("fatigue_rate_bonus", entry["fatigue"])
		_api.call("register_item_spec", spec)


func _setup_ui() -> void:
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 20
	vbox.offset_top = 20
	vbox.offset_right = -20
	vbox.offset_bottom = -20
	add_child(vbox)

	var title := Label.new()
	title.text = "=== DEV: EQUIPMENT MODULE ==="
	vbox.add_child(title)

	_info_label = Label.new()
	vbox.add_child(_info_label)

	var btn_row := HBoxContainer.new()
	vbox.add_child(btn_row)

	var btn_equip_carbon := Button.new()
	btn_equip_carbon.text = "Trang bị Cần Carbon"
	btn_equip_carbon.pressed.connect(func():
		var ok: bool = _api.call("equip_item", "rod", "rod_carbon_bien_sau", 0)
		_log("Trang bị Cần Carbon: %s" % ["Thành công" if ok else "Thất bại"])
		_update_display()
	)
	btn_row.add_child(btn_equip_carbon)

	var btn_equip_truc := Button.new()
	btn_equip_truc.text = "Trang bị Cần Trúc"
	btn_equip_truc.pressed.connect(func():
		var ok: bool = _api.call("equip_item", "rod", "rod_truc_nhiem", 0)
		_log("Trang bị Cần Trúc: %s" % ["Thành công" if ok else "Thất bại"])
		_update_display()
	)
	btn_row.add_child(btn_equip_truc)

	var btn_unequip := Button.new()
	btn_unequip.text = "Tháo Cần"
	btn_unequip.pressed.connect(func():
		var ok: bool = _api.call("unequip_item", "rod")
		_log("Tháo Cần: %s" % ["Thành công" if ok else "Thất bại"])
		_update_display()
	)
	btn_row.add_child(btn_unequip)

	var btn_save := Button.new()
	btn_save.text = "Lưu"
	btn_save.pressed.connect(func():
		_api.call("save")
		_log("Đã lưu equipment vào disk.")
	)
	btn_row.add_child(btn_save)

	var btn_load := Button.new()
	btn_load.text = "Tải"
	btn_load.pressed.connect(func():
		_api.call("load_save")
		_log("Đã nạp equipment từ disk.")
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
			eb.call("subscribe", EquipmentEventsContract.ITEM_EQUIPPED, Callable(self, "_on_eq_evt"))
			eb.call("subscribe", EquipmentEventsContract.ITEM_UNEQUIPPED, Callable(self, "_on_uneq_evt"))
			eb.call("subscribe", EquipmentEventsContract.STATS_UPDATED, Callable(self, "_on_stats_evt"))


func _update_display() -> void:
	if _info_label == null or _api == null:
		return
	var eq: Dictionary = _api.call("get_all_equipped") as Dictionary
	var stats: Dictionary = _api.call("calculate_total_stats") as Dictionary
	_info_label.text = "Cần câu: %s | Dây: %s | Mồi: %s | Bảo vật 1: %s | Bảo vật 2: %s\nChỉ số: Rod ID = %s" % [
		str(eq.get("rod", "")), str(eq.get("line", "")), str(eq.get("bait", "")),
		str(eq.get("relic_1", "")), str(eq.get("relic_2", "")), str(stats.get("rod_id", ""))
	]


func _on_eq_evt(payload: Dictionary) -> void:
	_log("[Event] Đã trang bị %s vào ô %s" % [str(payload.get("item_id")), str(payload.get("slot"))])


func _on_uneq_evt(payload: Dictionary) -> void:
	_log("[Event] Đã tháo %s khỏi ô %s" % [str(payload.get("item_id")), str(payload.get("slot"))])


func _on_stats_evt(_payload: Dictionary) -> void:
	_log("[Event] Chỉ số trang bị tổng hợp đã được cập nhật.")


func _log(msg: String) -> void:
	if _log_label != null:
		_log_label.append_text(msg + "\n")

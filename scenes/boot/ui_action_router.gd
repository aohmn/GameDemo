extends RefCounted

## Nhận hành động từ UI (hấp thu, bán, đột phá) và chuyển tới ServiceCoordinator / Cultivation.
## Bootstrap nối tín hiệu UI vào đây; UI không biết logic nghiệp vụ.

const CULTIVATION_UI_PATH: String = "res://presentation/cultivation_ui/cultivation_ui.tscn"
const SHOP_UI_PATH: String = "res://presentation/shop_ui/shop_ui.tscn"
const SKILL_UI_PATH: String = "res://presentation/fishing_skill_ui/fishing_skill_ui.tscn"

var _coordinator: RefCounted
var _economy_api: RefCounted
var _cultivation_api: RefCounted
var _cultivation_ui: Control


## Tạo HUD tu vi (nếu có Cultivation), nối tín hiệu UI vào router. Trả về HUD tu vi hoặc null.
func build(hud: Node, inventory_ui: Control, coordinator: RefCounted, economy_api: RefCounted, cultivation_api: RefCounted) -> Control:
	_coordinator = coordinator
	_economy_api = economy_api
	_cultivation_api = cultivation_api
	if cultivation_api != null and ResourceLoader.exists(CULTIVATION_UI_PATH):
		var scene := load(CULTIVATION_UI_PATH) as PackedScene
		if scene != null:
			_cultivation_ui = scene.instantiate() as Control
	if _cultivation_ui != null:
		hud.add_child(_cultivation_ui)
		_cultivation_ui.call("set_cultivation_api", cultivation_api)
	_connect(_cultivation_ui, "breakthrough_requested", on_breakthrough_requested)
	_connect(inventory_ui, "fish_action_requested", on_fish_action_requested)
	return _cultivation_ui


func _connect(ui: Control, signal_name: String, handler: Callable) -> void:
	if ui != null and ui.has_signal(signal_name):
		ui.connect(signal_name, handler)


func on_fish_action_requested(action: String, fish_id: String, count: int) -> void:
	if _coordinator == null:
		return
	if action == "absorb":
		var res: Dictionary = _coordinator.call("absorb_fish_qi", fish_id, count)
		if not bool(res.get("success", false)):
			_toast(_absorb_fail_text(str(res.get("reason", ""))))
	elif action == "sell":
		var before: int = _balance()
		if bool(_coordinator.call("sell_fish", fish_id, count)):
			_toast("Đã bán %d con, +%d Linh Thạch" % [count, _balance() - before])
		else:
			_toast("Không bán được loại cá này")


func on_breakthrough_requested() -> void:
	if _cultivation_api == null:
		return
	_cultivation_api.call("breakthrough")
	_cultivation_api.call("save")


func connect_equipment_ui(eq_ui: Control) -> void:
	_connect(eq_ui, "equip_requested", on_equip_requested)
	_connect(eq_ui, "unequip_requested", on_unequip_requested)


## Tạo Shop UI (nếu có ShopAPI), nối tín hiệu mua và đổi cần. Trả về Shop UI hoặc null.
func build_shop_ui(hud: Node, shop_api: RefCounted, economy_api: RefCounted, cultivation_api: RefCounted) -> Control:
	if shop_api == null or not ResourceLoader.exists(SHOP_UI_PATH):
		return null
	var scene := load(SHOP_UI_PATH) as PackedScene
	if scene == null:
		return null
	var shop_ui := scene.instantiate() as Control
	if shop_ui == null:
		return null
	hud.add_child(shop_ui)
	if shop_ui.has_method("setup"):
		shop_ui.call("setup", shop_api, economy_api, cultivation_api)
	_connect(shop_ui, "buy_requested", on_shop_buy_requested)
	_connect(shop_ui, "equip_requested", on_shop_equip_requested)
	return shop_ui


## Tạo UI nhỏ xem 5 kỹ năng câu cá và điểm cảnh giới. Trả về Control hoặc null.
func build_skill_ui(hud: Node, fishing_api: RefCounted) -> Control:
	if fishing_api == null or not ResourceLoader.exists(SKILL_UI_PATH):
		return null
	var scene := load(SKILL_UI_PATH) as PackedScene
	if scene == null:
		return null
	var ui := scene.instantiate() as Control
	if ui != null:
		hud.add_child(ui)
		if ui.has_method("setup"):
			ui.call("setup", fishing_api)
	return ui


func on_shop_buy_requested(item_id: String) -> void:
	if _coordinator == null:
		return
	var ok: bool = bool(_coordinator.call("buy_shop_item", item_id))
	if ok:
		_toast("Mua pháp bảo thành công!")
	else:
		_toast("Không thể mua: thiếu Linh Thạch hoặc chưa đủ cảnh giới")


func on_shop_equip_requested(shop_item_id: String) -> void:
	if _coordinator == null:
		return
	if bool(_coordinator.call("equip_shop_rod", shop_item_id)):
		_toast("Đã đổi cần câu!")
	else:
		_toast("Không thể đổi cần câu này")


func on_equip_requested(slot: String, item_id: String) -> void:
	if _coordinator == null:
		return
	var realm: int = int(_cultivation_api.call("get_current_realm_index")) if _cultivation_api != null else 0
	var ok: bool = bool(_coordinator.call("equip_item_from_inventory", slot, item_id, realm))
	if ok:
		_toast("Đã trang bị pháp bảo thành công")
	else:
		_toast("Không thể trang bị: chưa đủ cảnh giới hoặc chưa sở hữu")


func on_unequip_requested(slot: String) -> void:
	if _coordinator == null:
		return
	var ok: bool = bool(_coordinator.call("unequip_item", slot))
	if ok:
		_toast("Đã tháo pháp bảo")


func _balance() -> int:
	return int(_economy_api.call("get_balance")) if _economy_api != null else 0


func _toast(text: String) -> void:
	if _cultivation_ui != null:
		_cultivation_ui.call("show_toast", text)


func _absorb_fail_text(reason: String) -> String:
	match reason:
		"no_spirit_qi":
			return "Loại cá này không chứa linh khí"
		"insufficient_fish":
			return "Không đủ cá để hấp thu"
	return "Không thể hấp thu"

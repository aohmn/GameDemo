class_name EquipmentLogic
extends RefCounted

## Quản lý các vị trí trang bị pháp bảo, kiểm tra điều kiện và tính toán chỉ số tổng hợp.
## Lưu trữ trạng thái trang bị vào user://equipment.cfg bằng ConfigFile.

const SAVE_PATH: String = "user://equipment.cfg"
const SECTION_SLOTS: String = "slots"
const SECTION_META: String = "meta"
const SAVE_VERSION: int = 1

# Các vị trí trang bị được hỗ trợ
const SLOTS: Array[String] = ["rod", "line", "bait", "relic_1", "relic_2"]

# Lưu trữ ID vật phẩm đang trang bị ở mỗi slot: slot_name -> item_id
var _equipped_slots: Dictionary = {
	"rod": "rod_truc_nhiem",
	"line": "",
	"bait": "",
	"relic_1": "",
	"relic_2": ""
}

# Bảng spec đã đăng ký: item_id -> EquipmentItemSpec hoặc RodSpec
var _item_specs: Dictionary = {}
var _item_levels: Dictionary = {}      # item_id -> int
var _item_durability: Dictionary = {}  # item_id -> float

var on_item_equipped: Callable
var on_item_unequipped: Callable
var on_stats_updated: Callable


func _init() -> void:
	_load_default_specs()


func _load_default_specs() -> void:
	var paths: Array[String] = [
		"res://modules/equipment/data/resources/line_cuoc_bach_lien.tres",
		"res://modules/equipment/data/resources/bait_linh_trung.tres",
		"res://modules/equipment/data/resources/relic_dinh_hai_chau.tres"
	]
	for p in paths:
		if ResourceLoader.exists(p):
			var res: Resource = load(p) as Resource
			if res != null:
				var spec_id: String = str(res.get("id"))
				if not spec_id.is_empty():
					_item_specs[spec_id] = res


func register_item_spec(spec: Resource) -> void:
	if spec != null:
		var spec_id: String = str(spec.get("id"))
		if not spec_id.is_empty():
			_item_specs[spec_id] = spec


func get_item_spec(item_id: String) -> Resource:
	return _item_specs.get(item_id, null) as Resource


func get_equipped_item_id(slot: String) -> String:
	return str(_equipped_slots.get(slot, ""))


func get_all_equipped() -> Dictionary:
	return _equipped_slots.duplicate()


## Kiểm tra điều kiện trang bị với cảnh giới người chơi.
func can_equip(item_id: String, slot: String, current_realm_level: int = 0) -> bool:
	if item_id.is_empty() or not SLOTS.has(slot):
		return false

	# Kiểm tra vật phẩm có đang bị trang bị ở slot khác không (không cho trùng lắp)
	for s in _equipped_slots.keys():
		if s != slot and str(_equipped_slots[s]) == item_id:
			return false

	var spec: Resource = get_item_spec(item_id)
	if spec != null and spec.has_method("get"):
		var item_slot: String = str(spec.get("slot_type")) if "slot_type" in spec else "rod"
		if slot.begins_with("relic"):
			if item_slot != "relic" and item_slot != slot:
				return false
		elif item_slot != slot:
			return false
		var req_realm: int = int(spec.get("required_realm_level"))
		if current_realm_level < req_realm:
			return false

	return true


## Trang bị vật phẩm vào một slot.
func equip_item(slot: String, item_id: String, current_realm_level: int = 0) -> bool:
	if not can_equip(item_id, slot, current_realm_level):
		return false

	var old_id: String = str(_equipped_slots.get(slot, ""))
	_equipped_slots[slot] = item_id

	if on_item_equipped.is_valid():
		on_item_equipped.call({
			"slot": slot,
			"item_id": item_id,
			"old_item_id": old_id
		})

	_notify_stats_updated()
	return true


## Tháo vật phẩm khỏi một slot.
func unequip_item(slot: String) -> bool:
	if not SLOTS.has(slot):
		return false
	var current_id: String = str(_equipped_slots.get(slot, ""))
	if current_id.is_empty():
		return false

	_equipped_slots[slot] = ""
	if on_item_unequipped.is_valid():
		on_item_unequipped.call({
			"slot": slot,
			"item_id": current_id
		})

	_notify_stats_updated()
	return true


## Tính toán chỉ số tổng hợp từ toàn bộ pháp bảo đang trang bị.
func calculate_total_stats() -> Dictionary:
	var stats: Dictionary = {
		"rod_id": str(_equipped_slots.get("rod", "rod_truc_nhiem")),
		"total_pull_force_bonus": 0.0,
		"total_max_tension_bonus": 0.0,
		"total_control_power_bonus": 0.0,
		"total_spirit_sensing": 0.0,
		"total_rare_fish_rate": 0.0,
		"total_qi_absorption_bonus": 0.0,
		"total_fatigue_rate_bonus": 0.0,
	}

	for s in SLOTS:
		var item_id: String = str(_equipped_slots.get(s, ""))
		if item_id.is_empty():
			continue
		var spec: Resource = get_item_spec(item_id)
		if spec == null:
			continue
		if get_item_durability(item_id) <= 0.0:
			continue
		var mult: float = 1.0 + float(get_item_level(item_id) - 1) * 0.15

		stats["total_pull_force_bonus"] += (float(spec.get("pull_force_bonus")) if "pull_force_bonus" in spec else 0.0) * mult
		stats["total_max_tension_bonus"] += (float(spec.get("max_tension_bonus")) if "max_tension_bonus" in spec else 0.0) * mult
		stats["total_control_power_bonus"] += (float(spec.get("control_power_bonus")) if "control_power_bonus" in spec else 0.0) * mult
		stats["total_spirit_sensing"] += (float(spec.get("spirit_sensing")) if "spirit_sensing" in spec else 0.0) * mult
		stats["total_rare_fish_rate"] += (float(spec.get("rare_fish_rate_bonus")) if "rare_fish_rate_bonus" in spec else 0.0) * mult
		stats["total_qi_absorption_bonus"] += (float(spec.get("qi_absorption_bonus")) if "qi_absorption_bonus" in spec else 0.0) * mult
		stats["total_fatigue_rate_bonus"] += (float(spec.get("fatigue_rate_bonus")) if "fatigue_rate_bonus" in spec else 0.0) * mult

	return stats


func get_item_level(item_id: String) -> int:
	return maxi(1, int(_item_levels.get(item_id, 1)))


func get_item_durability(item_id: String) -> float:
	if _item_durability.has(item_id):
		return float(_item_durability[item_id])
	var spec: Resource = get_item_spec(item_id)
	if spec != null and "durability" in spec:
		return float(spec.get("durability"))
	return 100.0


func get_upgrade_cost(item_id: String) -> int:
	return get_item_level(item_id) * 50


func upgrade_item(item_id: String) -> bool:
	if item_id.is_empty() or get_item_spec(item_id) == null:
		return false
	var lvl: int = get_item_level(item_id)
	if lvl >= 5:
		return false
	_item_levels[item_id] = lvl + 1
	_notify_stats_updated()
	return true


func consume_durability(slot: String, amount: float) -> void:
	var item_id: String = str(_equipped_slots.get(slot, ""))
	if item_id.is_empty() or amount <= 0.0:
		return
	var cur: float = get_item_durability(item_id)
	_item_durability[item_id] = maxf(0.0, cur - amount)
	if _item_durability[item_id] <= 0.0:
		_notify_stats_updated()


func repair_item(item_id: String) -> bool:
	var spec: Resource = get_item_spec(item_id)
	if spec == null:
		return false
	var max_d: float = float(spec.get("durability")) if "durability" in spec else 100.0
	_item_durability[item_id] = max_d
	_notify_stats_updated()
	return true


func _notify_stats_updated() -> void:
	if on_stats_updated.is_valid():
		on_stats_updated.call(calculate_total_stats())


func save_to_disk(custom_path: String = "") -> bool:
	var path: String = SAVE_PATH if custom_path.is_empty() else custom_path
	var config := ConfigFile.new()
	config.set_value(SECTION_META, "version", SAVE_VERSION)

	for s in SLOTS:
		config.set_value(SECTION_SLOTS, s, str(_equipped_slots.get(s, "")))
	for k in _item_levels.keys():
		config.set_value("levels", str(k), int(_item_levels[k]))
	for k in _item_durability.keys():
		config.set_value("durability", str(k), float(_item_durability[k]))

	var err: Error = config.save(path)
	if err != OK:
		push_error("Lỗi khi lưu equipment vào %s: mã lỗi %d" % [path, err])
		return false
	return true


func load_from_disk(custom_path: String = "") -> bool:
	var path: String = SAVE_PATH if custom_path.is_empty() else custom_path
	var config := ConfigFile.new()
	var err: Error = config.load(path)
	if err != OK:
		# Tương thích: nếu chưa có save equipment.cfg, kiểm tra user://shop.cfg để nạp rod đã trang bị cũ
		_load_compat_from_shop()
		return false

	var save_ver: int = int(config.get_value(SECTION_META, "version", 0))
	if save_ver <= 0 or save_ver > SAVE_VERSION:
		push_warning("Equipment: Phiên bản save không hỗ trợ (%d)" % save_ver)
		return false

	for s in SLOTS:
		_equipped_slots[s] = str(config.get_value(SECTION_SLOTS, s, ""))
	if config.has_section("levels"):
		for k in config.get_section_keys("levels"):
			_item_levels[str(k)] = maxi(1, int(config.get_value("levels", k, 1)))
	if config.has_section("durability"):
		for k in config.get_section_keys("durability"):
			_item_durability[str(k)] = maxf(0.0, float(config.get_value("durability", k, 100.0)))

	if str(_equipped_slots.get("rod", "")).is_empty():
		_equipped_slots["rod"] = "rod_truc_nhiem"

	_notify_stats_updated()
	return true


func _load_compat_from_shop() -> void:
	var shop_cfg := ConfigFile.new()
	if shop_cfg.load("user://shop.cfg") == OK:
		var old_rod: String = str(shop_cfg.get_value("equipped", "rod_id", "rod_truc_nhiem"))
		_equipped_slots["rod"] = old_rod
		_notify_stats_updated()

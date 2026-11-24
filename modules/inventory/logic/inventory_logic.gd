class_name InventoryLogic
extends RefCounted

## Quản lý kho đồ đa năng và lưu trữ cá / vật phẩm tu tiên (modules/inventory/).
## Lưu trữ trạng thái vào user://inventory.cfg bằng ConfigFile.

const SAVE_PATH: String = "user://inventory.cfg"
const SECTION_ITEMS: String = "items"
const SECTION_META: String = "meta"
const SAVE_VERSION: int = 2

# Giới hạn dung lượng kho (số loại vật phẩm tối đa lưu trữ đồng thời)
var max_slots: int = 100

# _items cấu trúc theo item_id:
# {
#   "count": int,
#   "total_weight_g": int,
#   "category": int,     # 0: Cá, 1: Nguyên liệu, 2: Pháp bảo, 3: Tiêu hao, 4: Khác
#   "tier": int,         # 0: Phàm, 1: Linh, 2: Huyền...
#   "is_stackable": bool,
#   "max_stack": int
# }
var _items: Dictionary = {}

var on_inventory_updated: Callable


func add_fish(fish_id: String, weight_g: int) -> void:
	if fish_id.is_empty():
		return
	add_item(fish_id, 1, weight_g, 0, 0, true, 999)


func add_item(item_id: String, count: int = 1, weight_g: int = 0, category: int = 0, tier: int = 0, is_stackable: bool = true, max_stack: int = 999) -> bool:
	if item_id.is_empty() or count <= 0:
		return false

	if not _items.has(item_id):
		if _items.size() >= max_slots:
			push_warning("Kho đồ đã đầy (%d/%d loại vật phẩm)" % [_items.size(), max_slots])
			return false
		_items[item_id] = {
			"count": 0,
			"total_weight_g": 0,
			"category": category,
			"tier": tier,
			"is_stackable": is_stackable,
			"max_stack": max_stack
		}

	var entry: Dictionary = _items[item_id] as Dictionary
	var cur_count: int = int(entry.get("count", 0))
	var m_stack: int = int(entry.get("max_stack", max_stack))

	if is_stackable and m_stack > 0 and (cur_count + count) > m_stack:
		count = maxi(0, m_stack - cur_count)
		if count == 0:
			return false

	entry["count"] = cur_count + count
	entry["total_weight_g"] = int(entry.get("total_weight_g", 0)) + maxi(0, weight_g)

	if on_inventory_updated.is_valid():
		on_inventory_updated.call(get_all_items())
	return true


func remove_fish(fish_id: String, count: int) -> Dictionary:
	return remove_item(fish_id, count)


func remove_item(item_id: String, count: int) -> Dictionary:
	if not _items.has(item_id) or count <= 0:
		return {"success": false, "removed_count": 0, "removed_weight_g": 0}

	var entry: Dictionary = _items[item_id] as Dictionary
	var cur_count: int = int(entry.get("count", 0))
	if count > cur_count:
		return {"success": false, "removed_count": 0, "removed_weight_g": 0}

	var cur_weight: int = int(entry.get("total_weight_g", 0))
	var removed_weight: int = 0

	if count == cur_count:
		removed_weight = cur_weight
		_items.erase(item_id)
	else:
		removed_weight = cur_weight if cur_count == 0 else int(roundf(float(cur_weight) * (float(count) / float(cur_count))))
		removed_weight = clampi(removed_weight, 0, cur_weight)
		entry["count"] = cur_count - count
		entry["total_weight_g"] = cur_weight - removed_weight

	if on_inventory_updated.is_valid():
		on_inventory_updated.call(get_all_items())

	return {
		"success": true,
		"removed_count": count,
		"removed_weight_g": removed_weight
	}


func restore_fish(fish_id: String, count: int, weight_g: int) -> bool:
	if fish_id.is_empty() or count <= 0 or weight_g < 0:
		return false
	if not _items.has(fish_id):
		if _items.size() >= max_slots:
			return false
		_items[fish_id] = {
			"count": 0,
			"total_weight_g": 0,
			"category": 0,
			"tier": 0,
			"is_stackable": true,
			"max_stack": 999
		}
	var entry: Dictionary = _items[fish_id] as Dictionary
	entry["count"] = int(entry.get("count", 0)) + count
	entry["total_weight_g"] = int(entry.get("total_weight_g", 0)) + weight_g
	if on_inventory_updated.is_valid():
		on_inventory_updated.call(get_all_items())
	return true


func has_item(item_id: String, min_count: int = 1) -> bool:
	if not _items.has(item_id):
		return false
	var entry: Dictionary = _items[item_id] as Dictionary
	return int(entry.get("count", 0)) >= min_count


func get_item_count(item_id: String) -> int:
	if _items.has(item_id):
		var entry: Dictionary = _items[item_id] as Dictionary
		return int(entry.get("count", 0))
	return 0


func get_fish_info(fish_id: String) -> Dictionary:
	return get_item_info(fish_id)


func get_item_info(item_id: String) -> Dictionary:
	if _items.has(item_id):
		return (_items[item_id] as Dictionary).duplicate()
	return {"count": 0, "total_weight_g": 0, "category": 0, "tier": 0}


func get_all_items() -> Dictionary:
	var result: Dictionary = {}
	for k in _items.keys():
		var val: Dictionary = _items[k] as Dictionary
		result[k] = val.duplicate()
	return result


func get_items_by_category(category: int) -> Dictionary:
	var result: Dictionary = {}
	for k in _items.keys():
		var val: Dictionary = _items[k] as Dictionary
		if int(val.get("category", 0)) == category:
			result[k] = val.duplicate()
	return result


func get_total_fish_count() -> int:
	var total: int = 0
	for k in _items.keys():
		var val: Dictionary = _items[k] as Dictionary
		if int(val.get("category", 0)) == 0:
			total += int(val.get("count", 0))
	return total


func get_total_weight_g() -> int:
	var total: int = 0
	for k in _items.keys():
		var val: Dictionary = _items[k] as Dictionary
		if int(val.get("category", 0)) == 0:
			total += int(val.get("total_weight_g", 0))
	return total


func clear() -> void:
	_items.clear()
	if on_inventory_updated.is_valid():
		on_inventory_updated.call({})


func save_to_disk(custom_path: String = "") -> bool:
	var path: String = SAVE_PATH if custom_path.is_empty() else custom_path
	var config := ConfigFile.new()
	config.set_value(SECTION_META, "version", SAVE_VERSION)

	for item_id in _items.keys():
		var entry: Dictionary = _items[item_id] as Dictionary
		config.set_value(SECTION_ITEMS, item_id + "_count", int(entry.get("count", 0)))
		config.set_value(SECTION_ITEMS, item_id + "_weight", int(entry.get("total_weight_g", 0)))
		config.set_value(SECTION_ITEMS, item_id + "_category", int(entry.get("category", 0)))
		config.set_value(SECTION_ITEMS, item_id + "_tier", int(entry.get("tier", 0)))

	var err: Error = config.save(path)
	if err != OK:
		push_error("Lỗi khi lưu inventory vào %s: mã lỗi %d" % [path, err])
		return false
	return true


func load_from_disk(custom_path: String = "") -> bool:
	var path: String = SAVE_PATH if custom_path.is_empty() else custom_path
	var config := ConfigFile.new()
	var err: Error = config.load(path)
	if err != OK:
		return false

	_items.clear()
	if config.has_section(SECTION_ITEMS):
		var keys: PackedStringArray = config.get_section_keys(SECTION_ITEMS)
		for k in keys:
			if k.ends_with("_count"):
				var item_id: String = k.trim_suffix("_count")
				var c: int = int(config.get_value(SECTION_ITEMS, k, 0))
				var w: int = int(config.get_value(SECTION_ITEMS, item_id + "_weight", 0))
				var cat: int = int(config.get_value(SECTION_ITEMS, item_id + "_category", 0))
				var tr: int = int(config.get_value(SECTION_ITEMS, item_id + "_tier", 0))
				if c > 0:
					_items[item_id] = {
						"count": c,
						"total_weight_g": w,
						"category": cat,
						"tier": tr,
						"is_stackable": true,
						"max_stack": 999
					}

	if on_inventory_updated.is_valid():
		on_inventory_updated.call(get_all_items())
	return true

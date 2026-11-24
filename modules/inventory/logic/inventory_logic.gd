class_name InventoryLogic
extends RefCounted

## Logic quản lý dữ liệu kho đồ / túi cá của người chơi.
## Lưu trữ cá đã câu: fish_id, số lượng (count) và tổng khối lượng (total_weight_g).
## Hỗ trợ lưu và tải dữ liệu bằng ConfigFile tại user://inventory.cfg.

const SAVE_PATH: String = "user://inventory.cfg"
const SECTION_ITEMS: String = "items"
const SECTION_META: String = "meta"
const SAVE_VERSION: int = 1

# Danh sách cá lưu trữ: Dictionary[fish_id: String, Dictionary]
# Cấu trúc mỗi phần tử: { "count": int, "total_weight_g": int }
var _items: Dictionary = {}

var on_item_added: Callable
var on_inventory_updated: Callable


## Thêm cá vào túi đồ theo fish_id và trọng lượng thu được.
func add_fish(fish_id: String, weight_g: int) -> void:
	if fish_id.is_empty():
		return

	if not _items.has(fish_id):
		_items[fish_id] = {
			"count": 0,
			"total_weight_g": 0
		}

	var entry: Dictionary = _items[fish_id]
	var current_count: int = int(entry.get("count", 0)) + 1
	var current_weight: int = int(entry.get("total_weight_g", 0)) + weight_g

	entry["count"] = current_count
	entry["total_weight_g"] = current_weight

	if on_item_added.is_valid():
		on_item_added.call({
			"item_id": fish_id,
			"amount": 1,
			"weight_g": weight_g,
			"total_count": current_count,
			"total_weight_g": current_weight
		})

	if on_inventory_updated.is_valid():
		on_inventory_updated.call(get_all_items())


## Trừ cá khỏi túi đồ (dùng khi bán hoặc tiêu hao).
## Trả về Dictionary kết quả: { "success": bool, "removed_count": int, "removed_weight_g": int }
func remove_fish(fish_id: String, count: int) -> Dictionary:
	if fish_id.is_empty() or count <= 0:
		return {"success": false, "removed_count": 0, "removed_weight_g": 0}

	if not _items.has(fish_id):
		return {"success": false, "removed_count": 0, "removed_weight_g": 0}

	var entry: Dictionary = _items[fish_id] as Dictionary
	var current_count: int = int(entry.get("count", 0))
	var current_weight: int = int(entry.get("total_weight_g", 0))

	if count > current_count:
		return {"success": false, "removed_count": 0, "removed_weight_g": 0}

	var removed_weight: int = 0
	if count == current_count:
		removed_weight = current_weight
		_items.erase(fish_id)
	else:
		# Khối lượng trừ theo tỷ lệ trung bình
		removed_weight = int(roundf(float(current_weight) * (float(count) / float(current_count))))
		removed_weight = clampi(removed_weight, 1, current_weight)
		entry["count"] = current_count - count
		entry["total_weight_g"] = current_weight - removed_weight

	if on_inventory_updated.is_valid():
		on_inventory_updated.call(get_all_items())

	return {
		"success": true,
		"removed_count": count,
		"removed_weight_g": removed_weight
	}


## Lấy thông tin của một loài cá trong túi đồ.
func get_fish_info(fish_id: String) -> Dictionary:
	if _items.has(fish_id):
		return (_items[fish_id] as Dictionary).duplicate()
	return {
		"count": 0,
		"total_weight_g": 0
	}


## Lấy toàn bộ danh sách cá hiện có trong túi đồ.
func get_all_items() -> Dictionary:
	var result: Dictionary = {}
	for k in _items.keys():
		var val: Dictionary = _items[k] as Dictionary
		result[k] = val.duplicate()
	return result


## Tổng số lượng cá trong túi đồ.
func get_total_fish_count() -> int:
	var total: int = 0
	for k in _items.keys():
		var val: Dictionary = _items[k] as Dictionary
		total += int(val.get("count", 0))
	return total


## Tổng khối lượng tất cả cá trong túi đồ (gam).
func get_total_weight_g() -> int:
	var total_w: int = 0
	for k in _items.keys():
		var val: Dictionary = _items[k] as Dictionary
		total_w += int(val.get("total_weight_g", 0))
	return total_w


## Xóa toàn bộ vật phẩm trong kho đồ.
func clear() -> void:
	_items.clear()
	if on_inventory_updated.is_valid():
		on_inventory_updated.call({})


## Lưu dữ liệu túi đồ vào user://inventory.cfg bằng ConfigFile.
func save_to_disk(custom_path: String = "") -> bool:
	var path: String = SAVE_PATH if custom_path.is_empty() else custom_path
	var config := ConfigFile.new()

	config.set_value(SECTION_META, "version", SAVE_VERSION)

	for fish_id in _items.keys():
		var entry: Dictionary = _items[fish_id] as Dictionary
		config.set_value(SECTION_ITEMS, fish_id + "_count", int(entry.get("count", 0)))
		config.set_value(SECTION_ITEMS, fish_id + "_weight", int(entry.get("total_weight_g", 0)))

	var err: Error = config.save(path)
	if err != OK:
		push_error("Lỗi khi lưu inventory vào %s: mã lỗi %d" % [path, err])
		return false
	return true


## Tải dữ liệu túi đồ từ user://inventory.cfg bằng ConfigFile.
func load_from_disk(custom_path: String = "") -> bool:
	var path: String = SAVE_PATH if custom_path.is_empty() else custom_path
	var config := ConfigFile.new()
	var err: Error = config.load(path)
	if err != OK:
		# Nếu file chưa tồn tại, bắt đầu với túi đồ trống
		return false

	var loaded_items: Dictionary = {}
	if config.has_section(SECTION_ITEMS):
		var keys: PackedStringArray = config.get_section_keys(SECTION_ITEMS)
		for key in keys:
			if key.ends_with("_count"):
				var fish_id: String = key.trim_suffix("_count")
				var count: int = int(config.get_value(SECTION_ITEMS, key, 0))
				var weight: int = int(config.get_value(SECTION_ITEMS, fish_id + "_weight", 0))
				loaded_items[fish_id] = {
					"count": count,
					"total_weight_g": weight
				}

	_items = loaded_items
	if on_inventory_updated.is_valid():
		on_inventory_updated.call(get_all_items())
	return true

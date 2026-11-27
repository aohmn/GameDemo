class_name CraftingLogic
extends RefCounted

## Quản lý danh mục công thức, kiểm tra điều kiện và tiến trình chế tạo (modules/crafting/).
## Lưu trữ trạng thái mở khóa công thức vào user://crafting.cfg bằng ConfigFile.

const SAVE_PATH: String = "user://crafting.cfg"
const SECTION_UNLOCKED: String = "unlocked_recipes"
const SECTION_META: String = "meta"
const SAVE_VERSION: int = 1

var _recipes: Dictionary = {}          # recipe_id -> Resource (RecipeSpec)
var _unlocked_recipe_ids: Dictionary = {} # recipe_id -> bool

# Quản lý hàng đợi chế tạo theo thời gian (nếu có craft_duration)
var _active_craft: Dictionary = {}     # { "recipe_id": String, "remaining_time": float, "total_time": float }

var on_craft_started: Callable
var on_craft_completed: Callable
var on_craft_cancelled: Callable
var on_craft_failed: Callable


func _init() -> void:
	_load_default_recipes()


func _load_default_recipes() -> void:
	var paths: Array[String] = [
		"res://modules/crafting/data/resources/recipe_rod_truc_nhiem.tres",
		"res://modules/crafting/data/resources/recipe_rod_carbon_bien_sau.tres"
	]
	for p in paths:
		if ResourceLoader.exists(p):
			var r: Resource = load(p) as Resource
			if r != null:
				register_recipe(r)


func register_recipe(spec: Resource) -> void:
	if spec != null:
		var r_id: String = str(spec.get("id"))
		if not r_id.is_empty():
			_recipes[r_id] = spec
			var is_default: bool = bool(spec.get("is_unlocked_by_default")) if "is_unlocked_by_default" in spec else true
			if is_default:
				_unlocked_recipe_ids[r_id] = true


func get_recipe(recipe_id: String) -> Resource:
	return _recipes.get(recipe_id, null) as Resource


func get_all_recipes() -> Dictionary:
	return _recipes.duplicate()


func is_recipe_unlocked(recipe_id: String) -> bool:
	return bool(_unlocked_recipe_ids.get(recipe_id, false))


func unlock_recipe(recipe_id: String) -> bool:
	if _recipes.has(recipe_id):
		_unlocked_recipe_ids[recipe_id] = true
		return true
	return false


## Kiểm tra điều kiện chế tạo với cảnh giới tu vi của người chơi.
func can_craft_recipe(recipe_id: String, current_realm_level: int = 0) -> Dictionary:
	if not _recipes.has(recipe_id):
		return {"can_craft": false, "reason": "recipe_not_found"}

	if not is_recipe_unlocked(recipe_id):
		return {"can_craft": false, "reason": "recipe_locked"}

	var spec: Resource = _recipes[recipe_id] as Resource
	var req_realm: int = int(spec.get("required_realm_level")) if "required_realm_level" in spec else 0
	if current_realm_level < req_realm:
		return {"can_craft": false, "reason": "insufficient_realm"}

	if not _active_craft.is_empty():
		return {"can_craft": false, "reason": "busy_crafting"}

	return {"can_craft": true, "reason": "ok"}


## Bắt đầu chế tạo (nếu craft_duration > 0 thì chuyển sang active craft, ngược lại hoàn thành tức thì).
func start_craft(recipe_id: String, current_realm_level: int = 0) -> Dictionary:
	var check: Dictionary = can_craft_recipe(recipe_id, current_realm_level)
	if not bool(check.get("can_craft", false)):
		var r: String = str(check.get("reason", "failed"))
		if on_craft_failed.is_valid():
			on_craft_failed.call({"recipe_id": recipe_id, "reason": r})
		return {"success": false, "completed_now": false, "reason": r}

	var spec: Resource = _recipes[recipe_id] as Resource
	var duration: float = float(spec.get("craft_duration")) if "craft_duration" in spec else 0.0
	var out_id: String = str(spec.get("output_item_id"))
	var out_count: int = int(spec.get("output_count")) if "output_count" in spec else 1

	if duration <= 0.0:
		# Chế tạo tức thì
		if on_craft_completed.is_valid():
			on_craft_completed.call({
				"recipe_id": recipe_id,
				"output_item_id": out_id,
				"output_count": out_count
			})
		return {
			"success": true,
			"completed_now": true,
			"output_item_id": out_id,
			"output_count": out_count,
			"reason": "ok"
		}

	# Đưa vào tiến trình chế tạo theo thời gian
	_active_craft = {
		"recipe_id": recipe_id,
		"remaining_time": duration,
		"total_time": duration,
		"output_item_id": out_id,
		"output_count": out_count
	}

	if on_craft_started.is_valid():
		on_craft_started.call({
			"recipe_id": recipe_id,
			"output_item_id": out_id,
			"duration": duration
		})

	return {
		"success": true,
		"completed_now": false,
		"output_item_id": out_id,
		"output_count": out_count,
		"reason": "crafting_started"
	}


## Cập nhật tiến trình chế tạo theo thời gian delta.
func process_craft(delta: float) -> Dictionary:
	if _active_craft.is_empty():
		return {"is_active": false, "finished": false}

	var rem: float = float(_active_craft.get("remaining_time", 0.0)) - delta
	_active_craft["remaining_time"] = rem

	if rem <= 0.0:
		var r_id: String = str(_active_craft.get("recipe_id"))
		var out_id: String = str(_active_craft.get("output_item_id"))
		var out_c: int = int(_active_craft.get("output_count", 1))
		_active_craft.clear()

		if on_craft_completed.is_valid():
			on_craft_completed.call({
				"recipe_id": r_id,
				"output_item_id": out_id,
				"output_count": out_c
			})
		return {
			"is_active": false,
			"finished": true,
			"recipe_id": r_id,
			"output_item_id": out_id,
			"output_count": out_c
		}

	return {
		"is_active": true,
		"finished": false,
		"remaining_time": rem,
		"recipe_id": str(_active_craft.get("recipe_id"))
	}


## Hủy tiến trình chế tạo đang chạy.
func cancel_craft() -> Dictionary:
	if _active_craft.is_empty():
		return {"success": false, "reason": "no_active_craft"}

	var r_id: String = str(_active_craft.get("recipe_id"))
	_active_craft.clear()

	if on_craft_cancelled.is_valid():
		on_craft_cancelled.call({"recipe_id": r_id, "reason": "user_cancelled"})

	return {"success": true, "recipe_id": r_id, "reason": "cancelled"}


func get_active_craft_info() -> Dictionary:
	return _active_craft.duplicate()


func save_to_disk(custom_path: String = "") -> bool:
	var path: String = SAVE_PATH if custom_path.is_empty() else custom_path
	var config := ConfigFile.new()
	config.set_value(SECTION_META, "version", SAVE_VERSION)

	for r_id in _unlocked_recipe_ids.keys():
		config.set_value(SECTION_UNLOCKED, r_id, bool(_unlocked_recipe_ids[r_id]))

	var err: Error = config.save(path)
	if err != OK:
		push_error("Lỗi khi lưu crafting vào %s: mã lỗi %d" % [path, err])
		return false
	return true


func load_from_disk(custom_path: String = "") -> bool:
	var path: String = SAVE_PATH if custom_path.is_empty() else custom_path
	var config := ConfigFile.new()
	var err: Error = config.load(path)
	if err != OK:
		return false

	var save_ver: int = int(config.get_value(SECTION_META, "version", 0))
	if save_ver <= 0 or save_ver > SAVE_VERSION:
		push_warning("Crafting: Phiên bản save không hỗ trợ (%d)" % save_ver)
		return false

	if config.has_section(SECTION_UNLOCKED):
		var keys: PackedStringArray = config.get_section_keys(SECTION_UNLOCKED)
		for k in keys:
			_unlocked_recipe_ids[k] = bool(config.get_value(SECTION_UNLOCKED, k, false))
	return true

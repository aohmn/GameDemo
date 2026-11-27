class_name ServiceCoordinator
extends RefCounted

## Điều phối giao dịch atomic giữa các module độc lập (Economy, Inventory, Shop, Fishing).
## Tách biệt khỏi Bootstrap node để giữ số dòng của mỗi script dưới 300 dòng theo luật AGENTS.md.

var _inventory_api: RefCounted
var _economy_api: RefCounted
var _shop_api: RefCounted
var _fishing_api: RefCounted
var _cultivation_api: RefCounted
var _equipment_api: RefCounted
var _crafting_api: RefCounted
var _fish_specs: Dictionary = {} # fish_id: Resource (FishSpec)


func setup(inv: RefCounted, eco: RefCounted, shop: RefCounted, fish: RefCounted, cult: RefCounted = null, eq: RefCounted = null, craft: RefCounted = null) -> void:
	_inventory_api = inv
	_economy_api = eco
	_shop_api = shop
	_fishing_api = fish
	_cultivation_api = cult
	_equipment_api = eq
	_crafting_api = craft
	_load_default_fish_specs()


func set_cultivation_api(cult: RefCounted) -> void:
	_cultivation_api = cult

func set_equipment_api(eq: RefCounted) -> void:
	_equipment_api = eq

func set_crafting_api(craft: RefCounted) -> void:
	_crafting_api = craft


func _load_default_fish_specs() -> void:
	var paths: Array[String] = [
		"res://modules/fishing/data/resources/fish_ca_com.tres",
		"res://modules/fishing/data/resources/fish_ca_doi.tres",
		"res://modules/fishing/data/resources/fish_ca_chem.tres",
		"res://modules/fishing/data/resources/fish_ca_mu.tres",
		"res://modules/fishing/data/resources/fish_ca_thu.tres",
		"res://modules/fishing/data/resources/fish_ca_ngu_dai_duong.tres",
		"res://modules/fishing/data/resources/fish_ca_chep_linh.tres",
		"res://modules/fishing/data/resources/fish_ca_tram_ngoc.tres",
		"res://modules/fishing/data/resources/fish_ca_den_long.tres",
		"res://modules/fishing/data/resources/fish_ca_nguyet_anh.tres",
	]
	for p in paths:
		if ResourceLoader.exists(p):
			var spec: Resource = load(p) as Resource
			if spec != null:
				var f_id: String = str(spec.get("id"))
				if not f_id.is_empty():
					_fish_specs[f_id] = spec


func register_fish_spec(spec: Resource) -> void:
	if spec != null:
		var f_id: String = str(spec.get("id"))
		if not f_id.is_empty():
			_fish_specs[f_id] = spec

func get_fish_spec(fish_id: String) -> Resource:
	return _fish_specs.get(fish_id, null) as Resource


## Hấp thu linh khí từ cá trong Inventory để chuyển hóa thành tu vi (atomic transaction).
## Trả về Dictionary: { "success": bool, "absorbed_count": int, "exp_gained": int, "reason": String }
func absorb_fish_qi(fish_id: String, count: int) -> Dictionary:
	if _inventory_api == null or _cultivation_api == null:
		return {"success": false, "absorbed_count": 0, "exp_gained": 0, "reason": "uninitialized"}

	if fish_id.is_empty() or count <= 0:
		return {"success": false, "absorbed_count": 0, "exp_gained": 0, "reason": "invalid_parameters"}

	var fish_info: Dictionary = _inventory_api.call("get_fish_info", fish_id) as Dictionary
	var available_count: int = int(fish_info.get("count", 0))
	var total_weight: int = int(fish_info.get("total_weight_g", 0))

	if available_count <= 0 or count > available_count:
		return {"success": false, "absorbed_count": 0, "exp_gained": 0, "reason": "insufficient_fish"}

	var spec: Resource = get_fish_spec(fish_id)
	if spec == null:
		return {"success": false, "absorbed_count": 0, "exp_gained": 0, "reason": "spec_not_found"}

	var spirit_qi_per_fish: int = int(spec.get("spirit_qi"))
	if spirit_qi_per_fish <= 0:
		return {"success": false, "absorbed_count": 0, "exp_gained": 0, "reason": "no_spirit_qi"}

	var weight_to_remove: int = total_weight if count == available_count else int(roundf(float(total_weight) * (float(count) / float(available_count))))

	# 1. Trừ cá khỏi Inventory
	var remove_res: Dictionary = _inventory_api.call("remove_fish", fish_id, count) as Dictionary
	if not bool(remove_res.get("success", false)):
		return {"success": false, "absorbed_count": 0, "exp_gained": 0, "reason": "remove_failed"}

	var actual_weight: int = int(remove_res.get("removed_weight_g", weight_to_remove))
	var total_exp_gained: int = spirit_qi_per_fish * count
	# Áp dụng bonus hấp thu từ pháp bảo
	if _equipment_api != null and _equipment_api.has_method("calculate_total_stats"):
		var eq_stats: Dictionary = _equipment_api.call("calculate_total_stats") as Dictionary
		var qi_bonus: float = float(eq_stats.get("total_qi_absorption_bonus", 0.0))
		if qi_bonus > 0.0:
			total_exp_gained = int(roundf(float(total_exp_gained) * (1.0 + qi_bonus / 100.0)))

	# 2. Cộng tu vi vào Cultivation
	_cultivation_api.call("add_exp", total_exp_gained, "absorb_" + fish_id)

	# 3. Lưu dữ liệu an toàn
	_inventory_api.call("save")
	_cultivation_api.call("save")

	return {
		"success": true,
		"absorbed_count": count,
		"exp_gained": total_exp_gained,
		"reason": "ok"
	}



## Bán cá từ Inventory và cộng tiền vào Economy (atomic).
func sell_fish(fish_id: String, count: int) -> bool:
	if _inventory_api == null or _economy_api == null:
		return false

	var fish_info: Dictionary = _inventory_api.call("get_fish_info", fish_id) as Dictionary
	var available_count: int = int(fish_info.get("count", 0))
	var total_weight: int = int(fish_info.get("total_weight_g", 0))

	if count <= 0 or count > available_count or available_count == 0:
		return false

	var weight_to_sell: int = total_weight if count == available_count else int(roundf(float(total_weight) * (float(count) / float(available_count))))

	var remove_res: Dictionary = _inventory_api.call("remove_fish", fish_id, count) as Dictionary
	if not bool(remove_res.get("success", false)):
		return false

	var actual_weight: int = int(remove_res.get("removed_weight_g", weight_to_sell))
	var sale_res: Dictionary = _economy_api.call("execute_fish_sale", fish_id, count, actual_weight, count) as Dictionary
	if not bool(sale_res.get("success", false)):
		var restore_ok: bool = bool(_inventory_api.call("restore_fish", fish_id, count, actual_weight))
		if not restore_ok:
			push_error("sell_fish rollback: restore_fish thất bại cho %s x%d (%dg)" % [fish_id, count, actual_weight])
		return false

	_inventory_api.call("save")
	_economy_api.call("save")
	return true


## Mua vật phẩm từ Shop sử dụng số dư từ Economy (atomic) và kiểm tra cảnh giới.
func buy_shop_item(item_id: String) -> bool:
	if _shop_api == null or _economy_api == null:
		return false

	var item: Resource = _shop_api.call("get_item", item_id) as Resource
	if item == null:
		return false

	var current_realm: int = int(_cultivation_api.call("get_current_realm_index")) if _cultivation_api != null and _cultivation_api.has_method("get_current_realm_index") else 0
	var req_realm: int = int(item.get("required_realm_level")) if "required_realm_level" in item else 0
	if current_realm < req_realm:
		return false

	var price: int = int(item.call("get_price")) if item.has_method("get_price") else int(item.get("price_vnd"))
	var current_bal: int = int(_economy_api.call("get_balance"))

	if current_bal < price or bool(_shop_api.call("is_owned", item_id)):
		return false

	var deduct_ok: bool = bool(_economy_api.call("deduct_funds", price, "buy_" + item_id))
	if not deduct_ok:
		return false

	var buy_res: Dictionary = _shop_api.call("buy_item", item_id, current_bal, current_realm) as Dictionary
	if not bool(buy_res.get("success", false)):
		_economy_api.call("add_funds", price, "refund_" + item_id)
		return false

	_economy_api.call("save")
	_shop_api.call("save")
	return true


## Trang bị cần câu đã mua từ Shop và đồng bộ lưu trữ.
func equip_shop_rod(shop_item_id: String) -> bool:
	if _shop_api == null:
		return false
	var ok: bool = bool(_shop_api.call("equip_rod", shop_item_id))
	if ok:
		_shop_api.call("save")
		if _equipment_api != null:
			_equipment_api.call("save")
	return ok


## Xử lý khi cần câu được trang bị từ Shop hoặc Equipment module.
func on_shop_rod_equipped(payload: Dictionary) -> void:
	var rod_id: String = str(payload.get("rod_id", ""))
	if rod_id.is_empty():
		rod_id = str(payload.get("item_id", ""))
	if not rod_id.is_empty() and _fishing_api != null and _fishing_api.has_method("set_default_rod"):
		_fishing_api.call("set_default_rod", rod_id)
	if not rod_id.is_empty() and _equipment_api != null and _equipment_api.has_method("equip_item"):
		_equipment_api.call("equip_item", "rod", rod_id)


## Trang bị pháp bảo từ kho đồ vào vị trí trang bị (kiểm tra sở hữu và đồng bộ).
func equip_item_from_inventory(slot: String, item_id: String, realm_level: int = 0) -> bool:
	if _equipment_api == null:
		return false
	if _inventory_api != null and _inventory_api.has_method("has_item"):
		# Nếu là cần câu mặc định rod_truc_nhiem thì luôn cho phép, các món khác kiểm tra trong kho hoặc shop
		if item_id != "rod_truc_nhiem" and not bool(_inventory_api.call("has_item", item_id)):
			if _shop_api != null and not bool(_shop_api.call("is_owned", item_id)):
				return false

	var ok: bool = bool(_equipment_api.call("equip_item", slot, item_id, realm_level))
	if ok and slot == "rod":
		_sync_rod(item_id)
	if ok:
		_equipment_api.call("save")
	return ok


func _sync_rod(rod_id: String) -> void:
	if _fishing_api != null and _fishing_api.has_method("set_default_rod"):
		_fishing_api.call("set_default_rod", rod_id)
	if _shop_api != null and _shop_api.has_method("equip_rod"):
		_shop_api.call("equip_rod", rod_id)
		_shop_api.call("save")

## Tháo trang bị khỏi vị trí slot.
func unequip_item(slot: String) -> bool:
	if _equipment_api == null:
		return false
	var ok: bool = bool(_equipment_api.call("unequip_item", slot))
	if ok and slot == "rod":
		_sync_rod("rod_truc_nhiem")
	if ok:
		_equipment_api.call("save")
	return ok


## Thực hiện chế tạo vật phẩm (Atomic transaction giữa Crafting, Inventory và Cultivation).
## Trả về Dictionary: { "success": bool, "recipe_id": String, "reason": String }
func execute_craft(recipe_id: String) -> Dictionary:
	if _crafting_api == null or _inventory_api == null:
		return {"success": false, "recipe_id": recipe_id, "reason": "uninitialized"}

	var recipe: Resource = _crafting_api.call("get_recipe", recipe_id) as Resource
	if recipe == null:
		return {"success": false, "recipe_id": recipe_id, "reason": "recipe_not_found"}

	# 1. Kiểm tra cảnh giới từ Cultivation
	var current_realm: int = 0
	if _cultivation_api != null and _cultivation_api.has_method("get_current_realm_index"):
		current_realm = int(_cultivation_api.call("get_current_realm_index"))

	var check_res: Dictionary = _crafting_api.call("can_craft_recipe", recipe_id, current_realm) as Dictionary
	if not bool(check_res.get("can_craft", false)):
		return {"success": false, "recipe_id": recipe_id, "reason": str(check_res.get("reason"))}

	# 2. Kiểm tra đủ nguyên liệu trong Inventory
	var ingredients: Array = recipe.get("ingredients") as Array
	for ing in ingredients:
		var item_id: String = str(ing.get("item_id", ""))
		var count: int = int(ing.get("count", 1))
		if not bool(_inventory_api.call("has_item", item_id, count)):
			return {"success": false, "recipe_id": recipe_id, "reason": "insufficient_ingredient_" + item_id}

	# 3. Trừ nguyên liệu (lưu lại danh sách đã trừ để rollback nếu có lỗi)
	var deducted: Array[Dictionary] = []
	for ing in ingredients:
		var item_id: String = str(ing.get("item_id", ""))
		var count: int = int(ing.get("count", 1))
		var rem_res: Dictionary = _inventory_api.call("remove_item", item_id, count) as Dictionary
		if not bool(rem_res.get("success", false)):
			# Rollback toàn bộ nguyên liệu đã trừ trước đó
			for d in deducted:
				_inventory_api.call("add_item", str(d["item_id"]), int(d["count"]))
			return {"success": false, "recipe_id": recipe_id, "reason": "deduct_failed"}
		deducted.append({"item_id": item_id, "count": count})

	# 4. Kích hoạt Crafting
	var craft_res: Dictionary = _crafting_api.call("start_craft", recipe_id, current_realm) as Dictionary
	if not bool(craft_res.get("success", false)):
		# Rollback hoàn nguyên nguyên liệu
		for d in deducted:
			_inventory_api.call("add_item", str(d["item_id"]), int(d["count"]))
		return {"success": false, "recipe_id": recipe_id, "reason": "craft_start_failed"}

	# Nếu chế tạo tức thì, nhận ngay thành phẩm vào Inventory
	if bool(craft_res.get("completed_now", false)):
		var out_id: String = str(craft_res.get("output_item_id"))
		var out_c: int = int(craft_res.get("output_count", 1))
		_inventory_api.call("add_item", out_id, out_c)

	_inventory_api.call("save")
	_crafting_api.call("save")

	return {"success": true, "recipe_id": recipe_id, "reason": "ok"}


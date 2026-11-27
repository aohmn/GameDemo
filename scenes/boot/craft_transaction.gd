extends RefCounted
## Giao dịch chế tạo atomic giữa Crafting, Inventory và Cultivation.


static func execute_craft(crafting_api: RefCounted, inventory_api: RefCounted, cultivation_api: RefCounted, recipe_id: String) -> Dictionary:
	if crafting_api == null or inventory_api == null:
		return {"success": false, "recipe_id": recipe_id, "reason": "uninitialized"}
	var recipe: Resource = crafting_api.call("get_recipe", recipe_id) as Resource
	if recipe == null:
		return {"success": false, "recipe_id": recipe_id, "reason": "recipe_not_found"}

	var current_realm: int = 0
	if cultivation_api != null and cultivation_api.has_method("get_current_realm_index"):
		current_realm = int(cultivation_api.call("get_current_realm_index"))

	var check_res: Dictionary = crafting_api.call("can_craft_recipe", recipe_id, current_realm) as Dictionary
	if not bool(check_res.get("can_craft", false)):
		return {"success": false, "recipe_id": recipe_id, "reason": str(check_res.get("reason"))}

	var ingredients: Array = recipe.get("ingredients") as Array
	for ing in ingredients:
		var item_id: String = str(ing.get("item_id", ""))
		var count: int = int(ing.get("count", 1))
		if not bool(inventory_api.call("has_item", item_id, count)):
			return {"success": false, "recipe_id": recipe_id, "reason": "insufficient_ingredient_" + item_id}

	var deducted: Array[Dictionary] = []
	for ing in ingredients:
		var item_id: String = str(ing.get("item_id", ""))
		var count: int = int(ing.get("count", 1))
		var rem_res: Dictionary = inventory_api.call("remove_item", item_id, count) as Dictionary
		if not bool(rem_res.get("success", false)):
			for d in deducted:
				inventory_api.call("add_item", str(d["item_id"]), int(d["count"]))
			return {"success": false, "recipe_id": recipe_id, "reason": "deduct_failed"}
		deducted.append({"item_id": item_id, "count": count})

	var craft_res: Dictionary = crafting_api.call("start_craft", recipe_id, current_realm) as Dictionary
	if not bool(craft_res.get("success", false)):
		for d in deducted:
			inventory_api.call("add_item", str(d["item_id"]), int(d["count"]))
		return {"success": false, "recipe_id": recipe_id, "reason": "craft_start_failed"}

	if bool(craft_res.get("completed_now", false)):
		inventory_api.call("add_item", str(craft_res.get("output_item_id")), int(craft_res.get("output_count", 1)))

	inventory_api.call("save")
	crafting_api.call("save")
	return {"success": true, "recipe_id": recipe_id, "reason": "ok"}

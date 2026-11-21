extends RefCounted
class_name ShopService

const GOODS: Array[Resource] = [
	preload("res://modules/shops/data/water_bottle.tres"),
	preload("res://modules/shops/data/bread.tres")
]

static func get_goods() -> Array[ShopGood]:
	var goods: Array[ShopGood] = []
	for resource: Resource in GOODS:
		if resource is ShopGood:
			var good := resource as ShopGood
			if not good.item_id.is_empty() and good.price_vnd >= 0:
				goods.append(good)
	return goods

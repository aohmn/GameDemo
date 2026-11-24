class_name EquipmentEvents
extends RefCounted

## Hợp đồng sự kiện trang bị và pháp bảo (Equipment).

## Trang bị vật phẩm vào một vị trí thành công.
## Payload: { "slot": String, "item_id": String, "spec_id": String }
const ITEM_EQUIPPED: String = "equipment_item_equipped"

## Tháo trang bị khỏi một vị trí thành công.
## Payload: { "slot": String, "item_id": String }
const ITEM_UNEQUIPPED: String = "equipment_item_unequipped"

## Chỉ số trang bị tổng hợp thay đổi.
## Payload: { "stats": Dictionary }
const STATS_UPDATED: String = "equipment_stats_updated"

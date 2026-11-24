class_name InventoryEvents
extends RefCounted

## Hợp đồng sự kiện túi đồ và kho lưu trữ vật phẩm.

## Vật phẩm được thêm vào kho đồ của người chơi.
## Payload: { "item_id": String, "amount": int, "slot_index": int }
const ITEM_ADDED: String = "inventory_item_added"

## Vật phẩm được tiêu hao hoặc loại bỏ khỏi túi đồ.
## Payload: { "item_id": String, "amount": int, "slot_index": int }
const ITEM_REMOVED: String = "inventory_item_removed"

## Dữ liệu túi đồ được đồng bộ hóa hoặc tải lại toàn bộ.
## Payload: { "slots": Array, "capacity": int }
const INVENTORY_UPDATED: String = "inventory_updated"

## Túi đồ đầy, không thể nhận thêm vật phẩm.
## Payload: { "item_id": String, "attempted_amount": int }
const INVENTORY_FULL: String = "inventory_full"

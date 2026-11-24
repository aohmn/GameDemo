class_name CraftingEvents
extends RefCounted

## Hợp đồng sự kiện chế tạo vật phẩm (Crafting).

## Bắt đầu quá trình chế tạo.
## Payload: { "recipe_id": String, "output_item_id": String, "duration": float }
const CRAFT_STARTED: String = "crafting_craft_started"

## Chế tạo hoàn tất thành công.
## Payload: { "recipe_id": String, "output_item_id": String, "output_count": int }
const CRAFT_COMPLETED: String = "crafting_craft_completed"

## Quá trình chế tạo bị hủy bỏ hoặc hoàn nguyên nguyên liệu.
## Payload: { "recipe_id": String, "reason": String }
const CRAFT_CANCELLED: String = "crafting_craft_cancelled"

## Chế tạo thất bại (thiếu nguyên liệu, chưa đủ cảnh giới...).
## Payload: { "recipe_id": String, "reason": String }
const CRAFT_FAILED: String = "crafting_craft_failed"

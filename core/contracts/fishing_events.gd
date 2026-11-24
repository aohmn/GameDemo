class_name FishingEvents
extends RefCounted

## Hợp đồng sự kiện tính năng câu cá.

## Người chơi bắt đầu quăng câu.
## Payload: { "player_id": String, "rod_id": String, "position": Vector3 }
const CAST_STARTED: String = "fishing_cast_started"

## Cá cắn câu, bắt đầu minigame giật cần.
## Payload: { "player_id": String, "fish_id": String, "difficulty": float }
const FISH_BITING: String = "fishing_fish_biting"

## Câu cá thành công và thu hoạch được sinh vật biển.
## Payload: { "player_id": String, "fish_id": String, "weight": float, "quality": int }
const FISH_CAUGHT: String = "fishing_fish_caught"

## Lưỡi câu bị đứt hoặc cá trốn thoát.
## Payload: { "player_id": String, "reason": String }
const FISH_ESCAPED: String = "fishing_fish_escaped"

class_name FishingEvents
extends RefCounted

## Hợp đồng sự kiện tính năng câu cá.

## Người chơi bắt đầu quăng câu.
## Payload: { "spot_id": String, "rod_id": String }
const CAST_STARTED: String = "fishing_cast_started"

## Trạng thái máy câu cá thay đổi (IDLE, CASTING, WAITING, BITE, FIGHT, CAUGHT, ESCAPED, FAILED)
## Payload: { "from_state": String, "to_state": String }
const STATE_CHANGED: String = "fishing_state_changed"

## Cá cắn câu, bắt đầu cửa sổ giật cần (strike window).
## Payload: { "spot_id": String, "fish_id": String, "window_seconds": float }
const FISH_BITING: String = "fishing_fish_biting"

## Cập nhật thông số giằng co giữa người chơi và cá.
## Payload: { "fish_strength": float, "line_tension": float, "safe_min": float, "safe_max": float, "max_tension": float, "fish_max_stamina": float, "line_durability": float, "rod_durability": float, "fish_mode": int }
const FIGHT_UPDATE: String = "fishing_fight_update"

## Câu cá thành công và thu hoạch được sinh vật biển.
## Payload: { "fish_id": String, "weight_g": int, "name": String, "tier": int, "qi_value": int }
const FISH_CAUGHT: String = "fishing_fish_caught"

## Lưỡi câu bị đứt hoặc cá trốn thoát (early, late, line_break, cancel).
## Payload: { "reason": String }
const FISH_ESCAPED: String = "fishing_fish_escaped"

class_name MapEvents
extends RefCounted

## Hợp đồng sự kiện hệ thống bản đồ (Multi-map).

## Yêu cầu chuyển bản đồ.
## Payload: { "target_map_id": String, "spawn_pos": Vector3 }
const MAP_CHANGE_REQUESTED: String = "map_change_requested"

## Bản đồ đã được thay đổi và nạp thành công.
## Payload: { "old_map_id": String, "new_map_id": String, "spawn_pos": Vector3 }
const MAP_CHANGED: String = "map_changed"

## Bản đồ mới được mở khóa.
## Payload: { "map_id": String }
const MAP_UNLOCKED: String = "map_unlocked"

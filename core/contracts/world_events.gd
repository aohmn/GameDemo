class_name WorldEvents
extends RefCounted
## Hợp đồng dữ liệu không gian giữa World, Player, NPC và bản đồ.
## Các module không đọc trực tiếp vị trí của nhau; chúng trao đổi qua EventBus.

## Player phát vị trí thế giới.
## Payload: { "position": Vector3 }
const PLAYER_POSITION_CHANGED: StringName = &"world_player_position_changed"

## NPC Director phát danh sách vị trí NPC đang hoạt động.
## Payload: { "npcs": Array[Dictionary] } với mỗi phần tử
## { "id": String, "position": Vector3 }
const NPC_POSITIONS_CHANGED: StringName = &"world_npc_positions_changed"

## Yêu cầu tìm tuyến đường. Dùng request_id để ghép kết quả.
## Payload: { "request_id": int, "start": Vector3, "destination": Vector3 }
const ROUTE_REQUESTED: StringName = &"world_route_requested"

## Kết quả tìm tuyến đường.
## Payload: { "request_id": int, "route": PackedVector3Array, "destination": Vector3 }
const ROUTE_READY: StringName = &"world_route_ready"

## Player rơi khỏi địa hình và cần World đưa về spawn hợp lệ.
## Payload: { "player": Node3D }
const PLAYER_RECOVERY_REQUESTED: StringName = &"world_player_recovery_requested"

## Map hiện tại yêu cầu đổi sang scene world khác. Bootstrap sở hữu vòng đời
## map và chịu trách nhiệm gắn lại Presentation/NPC cho map mới.
## Payload: { "scene_path": String }
const MAP_CHANGE_REQUESTED: StringName = &"world_map_change_requested"

## Khi Player đi vào cửa của một tòa nhà bất kỳ.
## Payload: { "building_id": String }
const BUILDING_DOOR_ENTERED: StringName = &"world_building_door_entered"

## Khi Map dựng xong toàn bộ các công trình.
## Payload: { "buildings": Dictionary } với mỗi entry là id -> door_point (Vector3)
const BUILDINGS_READY: StringName = &"world_buildings_ready"

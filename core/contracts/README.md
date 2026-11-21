# core/contracts

## Mục đích
Chứa hợp đồng sự kiện dùng chung giữa các module độc lập. Chỉ khai báo tên
sự kiện và cấu trúc payload; không chứa logic gameplay.

## Cấu trúc
- `player_events.gd` — class `PlayerEvents`.
- `world_events.gd` — class `WorldEvents`.

Quy ước EventBus: tên snake_case, payload là `Dictionary`, handler nhận
đúng một tham số `payload`.

## PlayerEvents

| Hằng | Hướng | Payload |
|---|---|---|
| `MOVE_INPUT_CHANGED` | Joystick → Player | `{ "direction": Vector2 }` |
| `MOTION_CHANGED` | Player → Visual/Sprite | `{ "velocity": Vector2 }` |
| `NEEDS_CHANGED` | Needs → HUD | `{ "hunger": float, "thirst": float, "energy": float }` |
| `NEEDS_ACTION_REQUESTED` | HUD → Needs | `{ "action": String, "amount": float }` |
| `HEALTH_CHANGED` | Player → HUD | `{ "current": float, "maximum": float }` |
| `HEALTH_DAMAGE_REQUESTED` | Needs → Player | `{ "amount": float }` |
| `STATE_SNAPSHOT_REQUESTED` | UI → Player/Needs | `{}` |

`STATE_SNAPSHOT_REQUESTED` cho phép UI mới khởi tạo nhận lại trạng thái
hiện tại mà không cần đọc node nội bộ của Player hoặc Needs.

## WorldEvents

| Hằng | Hướng | Payload |
|---|---|---|
| `PLAYER_POSITION_CHANGED` | Player → Minimap/NPC | `{ "position": Vector3 }` |
| `NPC_POSITIONS_CHANGED` | NPCDirector → Minimap | `{ "npcs": Array[Dictionary] }` |
| `ROUTE_REQUESTED` | NPC/Minimap → WorldNavigation | `{ "request_id": int, "start": Vector3, "destination": Vector3 }` |
| `ROUTE_READY` | WorldNavigation → người yêu cầu | `{ "request_id": int, "route": PackedVector3Array, "destination": Vector3 }` |
| `PLAYER_RECOVERY_REQUESTED` | Player → MapController | `{ "player": Node3D }` |

`request_id` phải lớn hơn 0 và được dùng để bỏ qua kết quả không khớp.
`NPC_POSITIONS_CHANGED` thay thế toàn bộ danh sách NPC đang hoạt động.

## Dependencies
Không phụ thuộc module gameplay. Chỉ dùng kiểu dữ liệu built-in của Godot.

## Kiểm tra
`gdparse`/`gdlint` cho các file trong thư mục này. Kiểm tra runtime trên
Godot Android là bước riêng, chưa thực hiện trong đợt tách module.

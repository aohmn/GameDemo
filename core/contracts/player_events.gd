class_name PlayerEvents
extends RefCounted
## Hợp đồng sự kiện giữa Player, Needs, HUD, Joystick và phần hiển thị.
## Chỉ chứa tên sự kiện; payload là Dictionary theo quy ước EventBus.

## Joystick phát hướng điều khiển đã chuẩn hóa.
## Payload: { "direction": Vector2 }
const MOVE_INPUT_CHANGED: StringName = &"player_move_input_changed"

## Player phát vận tốc mặt phẳng cho phần hiển thị.
## Payload: { "velocity": Vector2 } với x = trục X, y = trục Z.
const MOTION_CHANGED: StringName = &"player_motion_changed"

## Needs phát trạng thái nhu cầu hiện tại.
## Payload: { "hunger": float, "thirst": float, "energy": float }
const NEEDS_CHANGED: StringName = &"player_needs_changed"

## UI yêu cầu Needs thực hiện hành động.
## Payload: { "action": String, "amount": float }
const NEEDS_ACTION_REQUESTED: StringName = &"player_needs_action_requested"

## Player phát trạng thái sức khỏe.
## Payload: { "current": float, "maximum": float }
const HEALTH_CHANGED: StringName = &"player_health_changed"

## Needs yêu cầu Player trừ máu khi đói/khát kiệt sức.
## Payload: { "amount": float }
const HEALTH_DAMAGE_REQUESTED: StringName = &"player_health_damage_requested"

## Yêu cầu Player và Needs phát lại trạng thái hiện tại cho UI mới khởi tạo.
## Payload: rỗng.
const STATE_SNAPSHOT_REQUESTED: StringName = &"player_state_snapshot_requested"

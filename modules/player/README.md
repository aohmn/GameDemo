# Player

Module quản lý Player 3D: nhân vật, vận tốc, sức khỏe và phản hồi điều khiển.
Dữ liệu máu đăng ký participant độc lập qua `SaveCoordinator`.

## Mục đích

- `Player3DController` (extends `CharacterBody3D`): chủ vị chuyển động vật lý
  (`move_and_slide`), tăng tốc theo `acceleration`, hồi máu khi rơi
  (`fall_recovery_y`).
- Nhận hướng đi qua `PlayerEvents.MOVE_INPUT_CHANGED` (bởi Joystick).
- API: `apply_damage()`, `restore_health()`, `recover_to(spawn_position)`,
  `serialize_state()`/`deserialize_state()`.
- Joystick: `@export var joystick_path: NodePath` gán trong
  `world/map/scenes/map_root.tscn` (node Joystick con trực tiếp của HUD);
  Joystick phát hướng điều khiển, Player không giữ tham chiếu.

## API công khai

- `apply_damage(amount: float) -> void`
- `restore_health(amount: float) -> void`
- `recover_to(spawn_position: Vector3) -> void`: phục hồi khi rơi khỏi địa hình.
- `serialize_state() -> Dictionary`, `deserialize_state(data: Dictionary) -> bool`.
- Signal `health_changed(current_health, maximum_health)`.

## Event (qua EventBus; tên tại `core/contracts/player_events.gd` / `world_events.gd`)

- Phát: `PlayerEvents.HEALTH_CHANGED`, `PlayerEvents.MOTION_CHANGED`
  (payload `velocity` Vector2: x = X thế giới, y = Z),
  `PlayerEvents.HEALTH_DAMAGE_REQUESTED`, `PlayerEvents.STATE_SNAPSHOT_REQUESTED`.
- Phát `WorldEvents.PLAYER_POSITION_CHANGED` (payload `position` Vector3).
- Nhận: `PlayerEvents.MOVE_INPUT_CHANGED` (payload `direction` Vector2),
  `PlayerEvents.HEALTH_DAMAGE_REQUESTED` (payload `amount`),
  `PlayerEvents.STATE_SNAPSHOT_REQUESTED`.
- World gọi `recover_to()` khi rơi ngoài địa hình qua
  `WorldEvents.PLAYER_RECOVERY_REQUESTED`; Player không đọc `MapController`.

## Phụ thuộc

- `PlayerEvents`, `WorldEvents`, `SaveCoordinator`, `EventBus`. Không đọc
  trực tiếp Needs/Visual/Joystick.

## Kiểm tra

- `gdparse modules/player/player_controller.gd` — không error.
- Di chuyển nhân vật: tốc độ tăng dần theo `acceleration`, di chuyển trên mặt phẳng.
- Gọi `apply_damage()`/`restore_health()` từ debugger: thanh máu cập nhật.

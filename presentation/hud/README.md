# HUD

Presentation layer cho HUD Player: thanh sức khỏe, nhu cầu, nút ĂN/UỐNG/NGHỈ và
Joystick cảm ứng. Chỉ nhận sự kiện qua EventBus — không chứa logic gameplay,
không đọc node Player/Needs/Visual.

## Mục đích

- Hiển thị: avatar hình học, thanh sức khỏe + text (ví dụ "100 / 100"), thanh đói/
  khát/năng lượng, giờ + thứ trong tuần.
- Nút ĂN/UỐNG/NGHỈ ở góc trái trên, gửi `PlayerEvents.NEEDS_ACTION_REQUESTED`.
- Joystick: nhận `InputEventScreenTouch`/`InputEventScreenDrag` trên mặt phẳng,
  phát hướng điều khiển (`PlayerEvents.MOVE_INPUT_CHANGED`), vẽ thanh hướng.

## API công khai

- `PlayerHUD`: thiết lập nút được tạo trong `_create_action_buttons()`.
- `VirtualJoystick`: `get_direction() -> Vector2`, `is_active() -> bool`.

## Event (qua EventBus; tên tại `core/contracts/player_events.gd` / `core/events/core_events.gd`)

- Nhận `PlayerEvents.HEALTH_CHANGED` (payload `current`, `maximum`).
- Nhận `PlayerEvents.NEEDS_CHANGED` (payload `hunger`, `thirst`, `energy`).
- Nhận `CoreEvents.HOUR_CHANGED` (payload `hour`, `minute`, `weekday`).
- Phát `PlayerEvents.NEEDS_ACTION_REQUESTED` (payload `action`, `amount`).
- Khi khởi tạo: phát `PlayerEvents.STATE_SNAPSHOT_REQUESTED` và
  `CoreEvents.TIME_SNAPSHOT_REQUESTED` để các module phát lại trạng thái.

## Phụ thuộc

- `PlayerEvents`, `CoreEvents`, `EventBus`; UI primitives (Control, Button,
  ThemeDB). Không phụ thuộc module gameplay.

## Kiểm tra

- `gdparse presentation/hud/player_hud.gd presentation/hud/virtual_joystick.gd`
  — không error.
- Chạy map: Player có node con `Joystick` và `PlayerHUD` hiển thị avatar/máu/
  nhu cầu/giờ đúng vị trí góc trái.
- Đưa ngón vào Joystick: Player di chuyển theo hướng tương ứng (hành vi như trước).
- Đồng bộ giờ: Tua GameClock → HUD giờ cập nhật.

# core/events

## Mục đích
EventBus: đường ống phát/nhận sự kiện giữa các module độc lập. Dùng cho thông báo
và thay đổi trạng thái. Yêu cầu cần kết quả trực tiếp thì dùng API module (AGENTS §5).

## Cấu trúc
- `event_bus.gd`: autoload `EventBus`.
- `core_events.gd`: class `CoreEvents`, chỉ chứa tên sự kiện nền tảng của Core.
- Hợp đồng sự kiện dùng chung nằm ở `core/contracts/`: `PlayerEvents`, `WorldEvents`.
- Module gameplay tự khai báo hợp đồng riêng, ví dụ `modules/jobs/job_events.gd`.

## API công khai
- `emit_event(event_name: StringName, payload: Dictionary = {}) -> void`
- `subscribe(event_name: StringName, handler: Callable) -> void`
- `unsubscribe(event_name: StringName, handler: Callable) -> void`

Handler nhận đúng 1 tham số: `payload` (Dictionary).
`subscribe` không đăng ký trùng cùng một Callable. Handler không còn hợp lệ bị dọn khi emit.
An toàn khi handler tự unsubscribe lúc đang emit.
Node phải unsubscribe trong `_exit_tree()` nếu có thể bị giải phóng.

## Quy ước đặt tên sự kiện
snake_case, thì quá khứ, payload là Dictionary. Ví dụ: `boot_completed`.
Tên sự kiện gameplay nằm trong module/hợp đồng sở hữu, không thêm tùy tiện vào `core_events.gd`.

## Event hiện có

### CoreEvents
- `BOOT_COMPLETED`: phát từ `boot.gd` sau khi thế giới khởi tạo.
- `HOUR_CHANGED`: GameClock phát khi giờ đổi; cũng là phản hồi cho yêu cầu snapshot thời gian.
- `DAY_CHANGED`: GameClock phát khi sang ngày mới.
- `TIME_SNAPSHOT_REQUESTED`: UI phát để GameClock trả lại `HOUR_CHANGED` với giờ hiện tại.

### PlayerEvents
- `MOVE_INPUT_CHANGED`, `MOTION_CHANGED`, `NEEDS_CHANGED`, `NEEDS_ACTION_REQUESTED`,
  `HEALTH_CHANGED`, `HEALTH_DAMAGE_REQUESTED`, `STATE_SNAPSHOT_REQUESTED`.

### WorldEvents
- `PLAYER_POSITION_CHANGED`, `NPC_POSITIONS_CHANGED`, `ROUTE_REQUESTED`,
  `ROUTE_READY`, `PLAYER_RECOVERY_REQUESTED`.

### JobEvents
- `SCHEDULE_CHANGED`, `SCHEDULE_SNAPSHOT_REQUESTED`.

Chi tiết payload: xem `core/contracts/README.md` và `modules/jobs/README.md`.

## Dependencies
Chỉ phụ thuộc kiểu built-in của Godot. Không phụ thuộc module gameplay.

## Kiểm tra
Đã kiểm tra cú pháp bằng `gdparse`. Chạy game trên Godot Android để xác nhận
không có lỗi runtime khi subscribe/unsubscribe; chưa thực hiện trong đợt này.

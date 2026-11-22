# Needs

Module quản lý nhu cầu sinh hoạt của Player: đói (`hunger`), khát (`thirst`)
và năng lượng (`energy`). Thời gian chỉ đọc từ `GameClock`; module không tự
tạo đồng hồ.

## Mục đích

- Dữ liệu: `hunger`, `thirst`, `energy` — float, 0–100, export_range.
- Tiêu hao theo số phút tăng trong `GameClock` (`_process`):
  - đói −0.025/phút, khát −0.045/phút, năng lượng −0.018/phút;
  - khi đói/khát bằng 0: Player trừ máu nhẹ (`PlayerEvents.HEALTH_DAMAGE_REQUESTED`).
- `rest(minutes)`: hồi năng lượng +0.55/phút và tua `GameClock`.

## API công khai

- `consume_food(restoration: float = 35.0) -> bool`: hồi đói.
- `drink_water(restoration: float = 40.0) -> bool`: hồi khát.
- `rest(minutes: int = 60) -> bool`: hồi năng lượng và tua GameClock.
- `get_state() -> Dictionary`: đọc trạng thái hiện tại.
- `serialize_state()` / `deserialize_state()`: tích hợp SaveCoordinator qua
  đăng ký participant (`save_id = "player_needs"`).

## Event (qua EventBus; tên tại `core/contracts/player_events.gd`)

- Phát `PlayerEvents.NEEDS_CHANGED` (payload: `hunger`, `thirst`, `energy`) cho HUD.
- Nhận `PlayerEvents.NEEDS_ACTION_REQUESTED` từ HUD (`eat`, `drink`, `rest`).
- Nhận `PlayerEvents.STATE_SNAPSHOT_REQUESTED` để phát lại trạng thái cho UI mới.
- Phát `PlayerEvents.HEALTH_DAMAGE_REQUESTED` (payload: `amount`) khi kiệt sức.
- Signal nội bộ: `needs_changed(hunger, thirst, energy)`.

## Phụ thuộc

- `GameClock` (chỉ đọc), `PlayerEvents`, `EventBus`, `SaveCoordinator`.
- Không gọi module gameplay khác; Player/HUD không đọc trực tiếp node Needs.

## Kiểm tra

- `gdparse modules/needs/player_needs.gd` — không error.
- Chuyển map sang `fishing_lake_map.tscn` và quay về `map_root.tscn`: HUD tiếp tục hiển thị và nhu cầu vẫn tăng/giảm đều như trước.
- Tương tác UI: Nút ĂN/UỐNG/NGHỈ của HUD gửi `NEEDS_ACTION_REQUESTED`; Needs phản hồi `NEEDS_CHANGED`.

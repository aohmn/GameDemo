# core/services

## Mục đích
Các dịch vụ nền tảng dùng chung. Hiện có: GameClock và SaveCoordinator.

## GameClock (autoload "GameClock")
Nguồn thời gian duy nhất. Không module nào được tự tạo đồng hồ riêng.
Thời gian là số nguyên phút. Ngày 0 là Thứ Hai, bắt đầu 06:00.

### API công khai
- get_total_minutes() -> int
- get_day_index() -> int (bắt đầu từ 0)
- get_hour() -> int, get_minute() -> int
- get_weekday() -> GameClock.Weekday
- advance_minutes(minutes: int) -> void (bỏ qua nếu <= 0)
- set_paused(paused: bool), is_paused() -> bool
- set_speed(minutes_per_real_second: float), get_speed() -> float (giới hạn 0..600)
- serialize() -> Dictionary, deserialize(data: Dictionary) -> bool
- serialize_state() -> Dictionary, deserialize_state(data: Dictionary) -> bool
  (API participant cho SaveCoordinator; gọi lại serialize/deserialize)
- hằng `SAVE_ID = "game_clock"`

### Event (qua EventBus, tên trong CoreEvents)
- hour_changed, day_changed. Payload: total_minutes, day_index, hour, minute, weekday, elapsed_minutes.
- Mỗi lần advance_minutes phát tối đa 1 event mỗi loại, dù tua qua nhiều giờ.
- `time_snapshot_requested` → GameClock phát `hour_changed` với giờ hiện tại để UI mới khởi tạo đồng bộ.

### Dependencies
EventBus, CoreEvents. Không tự đăng ký save; Bootstrap đăng ký với SaveCoordinator.

### Kiểm tra
Chưa có test tự động (thư mục tests/ đã gỡ). Đã kiểm tra cú pháp bằng `gdparse`; chưa chạy Godot Android.

## SaveCoordinator (autoload "SaveCoordinator")
Điều phối lưu/tải qua danh sách participant đăng ký độc lập. Không quét group,
không tham chiếu trực tiếp GameClock hay module gameplay.

### API công khai
- `register_participant(save_id: String, participant: Object) -> bool`
- `unregister_participant(save_id: String) -> void`
- `has_participant(save_id: String) -> bool`
- `get_registered_ids() -> PackedStringArray`
- `save_game() -> bool`: lưu file `user://projectgame_save.cfg`.
- `load_game() -> bool`: kiểm tra version và khôi phục trạng thái.

Participant phải có `serialize_state() -> Dictionary` và
`deserialize_state(data: Dictionary) -> bool`. Mỗi `save_id` chỉ có một
participant; đăng ký lại sẽ thay thế. Participant được dọn khỏi danh sách khi
node đã bị giải phóng.

### Người đăng ký hiện tại
- `boot.gd`: GameClock (`game_clock`); EconomyService (`player_economy`) chỉ
  khi autoload `/root/EconomyService` tồn tại.
- `Player3DController`: `player`.
- `PlayerNeeds`: `player_needs`.
- `NPCDirector`: `npc_world` (chỉ đăng ký khi `spawn_enabled`). Bootstrap tạo
  node này nếu `modules/npc/npc_director.gd` tồn tại.

### Save version
- Version hiện tại: 2, dữ liệu nằm trong section `participants`.
- Version 1 được đọc để tương thích: section `clock` cũ được chuyển cho
  participant `game_clock` nếu đã đăng ký.
- Tự lưu mỗi 60 giây thực và khi ứng dụng pause/đóng.

## Trạng thái và giới hạn đã biết
- Chưa có tháng, năm, mùa.
- `GameClock.deserialize()` chưa phát event khi nạp dữ liệu; UI nhận cập nhật
  qua event thời gian kế tiếp hoặc yêu cầu snapshot.
- Tốc độ mặc định 1 phút game / 1 giây thật chỉ là giá trị tạm, chưa cân bằng.
- Chưa chạy thử save/load trên Godot Android.
- SaveCoordinator không biết module nào đăng ký. Khi module bị gỡ (economy,
  npc), participant tương ứng chỉ đơn giản không xuất hiện trong save.
- Bootstrap đăng ký EconomyService qua `get_node_or_null()` và kiểm tra null,
  nên `boot.gd` không lỗi compile khi thiếu module economy.

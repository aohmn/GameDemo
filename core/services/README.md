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

### Event (qua EventBus, tên trong CoreEvents)
- hour_changed, day_changed. Payload: total_minutes, day_index, hour, minute, weekday, elapsed_minutes.
- Mỗi lần advance_minutes phát tối đa 1 event mỗi loại, dù tua qua nhiều giờ.

### Dependencies
EventBus, CoreEvents.

### Kiểm tra
Chưa có test tự động (thư mục tests/ đã gỡ). Kiểm tra thủ công trên Godot Android.

### SaveCoordinator (autoload "SaveCoordinator")
Điều phối lưu/tải GameClock và các node trong group `save_participant`.

- `save_game() -> bool`: lưu file `user://projectgame_save.cfg`.
- `load_game() -> bool`: kiểm tra version và khôi phục trạng thái.
- Node tham gia phải có `save_id`, `serialize_state()` và `deserialize_state(data)`.
- Tự lưu mỗi 60 giây thực và khi ứng dụng pause/đóng.

## Trạng thái và giới hạn đã biết
- Chưa có tháng, năm, mùa.
- `GameClock.deserialize()` chưa phát event khi nạp dữ liệu.
- Tốc độ mặc định 1 phút game / 1 giây thật chỉ là giá trị tạm, chưa cân bằng.

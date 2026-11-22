# Jobs

Module cung cấp khung lịch làm việc chung và cầu nối sự kiện cho NPC.

## Thành phần
- `job_service.gd`: `JobService` (RefCounted, static) — dữ liệu lịch thuần.
- `job_system.gd`: autoload `JobSystem` — đọc `GameClock` + `JobService` và
  phát lịch qua EventBus.
- `JobEvents` không còn nằm trong module này. Hợp đồng sự kiện dùng chung
  được đặt tại `core/contracts/job_events.gd` để module khác (ví dụ NPC)
  không phải tham chiếu thư mục `modules/jobs`.

## API công khai
- `JobService.get_activity(hour: int) -> StringName`: `work` (07–17),
  `shopping` (17–19), ngược lại `home`.
- `JobService.get_shift_start() -> int` (7), `get_shift_end() -> int` (17).
- `JobSystem.get_current_schedule() -> Dictionary`: bản sao lịch hiện tại.

## Sự kiện (EventBus)
- `JobEvents.SCHEDULE_CHANGED` — `JobSystem` phát khi giờ đổi hoặc khi có yêu
  cầu snapshot. Payload:
  `{ "hour": int, "activity": StringName, "shift_start": int, "shift_end": int }`.
- `JobEvents.SCHEDULE_SNAPSHOT_REQUESTED` — module khác (ví dụ NPC mới khởi tạo
  hoặc vừa tải save) phát để `JobSystem` trả lại `SCHEDULE_CHANGED` với lịch
  hiện tại.

## Vai trò của JobSystem
`JobSystem` là autoload đứng giữa `GameClock`, `JobService` và các module tiêu
thụ lịch. Nhờ đó NPC không cần đọc `GameClock` hay gọi `JobService` trực tiếp;
module chỉ subscribe `SCHEDULE_CHANGED`.

Thứ tự autoload trong `project.godot`: `EventBus`, `GameClock`, `JobSystem`,
`WorldNavigation`, `SaveCoordinator`, `EconomyService` — `JobSystem` khởi tạo
sau `GameClock` để đọc được giờ ban đầu.

## Phụ thuộc
- `GameClock` (autoload), `EventBus`, `CoreEvents`.
- `JobEvents` từ `core/contracts/job_events.gd`.
- Không phụ thuộc module NPC hay bất kỳ module gameplay nào. Module khác chỉ
  cần `core/contracts/job_events.gd`, không cần import thư mục `modules/jobs`.

## Giới hạn
Chưa có tuyển dụng Player, chấm công, tính lương hoặc hợp đồng lao động.
Chưa có lịch theo thứ trong tuần, ngày nghỉ hay sự kiện.

## Kiểm tra
- `gdparse` cho các file `.gd` (đã chạy, không lỗi cú pháp).
- Import headless Godot 4.7 + boot 150 frame: `SCHEDULE_CHANGED` được phát,
  không `Parse Error`.
- Xóa tạm `modules/jobs/`, import + boot: chỉ còn lỗi thiếu autoload `JobSystem`
  (đúng dự kiến); scene world và NPC vẫn chạy.
- Mở Godot Android, tua giờ và xác nhận `SCHEDULE_CHANGED` được phát; NPC cập
  nhật hoạt động tương ứng.

class_name JobEvents
extends RefCounted
## Hợp đồng sự kiện của module Jobs.
## NPC nhận lịch sinh hoạt qua EventBus, không gọi JobService hay GameClock.

## JobSystem phát lịch hiện tại khi giờ trong game thay đổi.
## Payload: { "hour": int, "activity": StringName,
##            "shift_start": int, "shift_end": int }
const SCHEDULE_CHANGED: StringName = &"job_schedule_changed"

## Module cần lịch hiện tại (ví dụ NPC mới khởi tạo hoặc vừa tải save)
## phát yêu cầu này. JobSystem trả lời bằng SCHEDULE_CHANGED.
const SCHEDULE_SNAPSHOT_REQUESTED: StringName = &"job_schedule_snapshot_requested"

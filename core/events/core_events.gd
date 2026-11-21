class_name CoreEvents
extends RefCounted
## Tên sự kiện nền tảng của Core. Sự kiện gameplay do từng module tự định nghĩa.

const BOOT_COMPLETED: StringName = &"boot_completed"
const HOUR_CHANGED: StringName = &"hour_changed"
const DAY_CHANGED: StringName = &"day_changed"
## UI mới khởi tạo yêu cầu GameClock phát lại giờ hiện tại qua HOUR_CHANGED.
const TIME_SNAPSHOT_REQUESTED: StringName = &"time_snapshot_requested"

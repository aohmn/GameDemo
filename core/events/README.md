# core/events

## Mục đích
EventBus: đường ống phát/nhận sự kiện giữa các module độc lập. Dùng cho thông báo
và thay đổi trạng thái. Yêu cầu cần kết quả trực tiếp thì dùng API module (AGENTS §5).

## Cấu trúc
- event_bus.gd: autoload "EventBus".
- core_events.gd: class CoreEvents, chỉ chứa tên sự kiện nền tảng của Core.

## API công khai
- emit_event(event_name: StringName, payload: Dictionary = {}) -> void
- subscribe(event_name: StringName, handler: Callable) -> void
- unsubscribe(event_name: StringName, handler: Callable) -> void

Handler nhận đúng 1 tham số: payload (Dictionary).
subscribe không đăng ký trùng cùng một Callable. Handler không còn hợp lệ bị dọn khi emit.
An toàn khi handler tự unsubscribe lúc đang emit.

## Quy ước đặt tên sự kiện
snake_case, thì quá khứ, payload là Dictionary. Ví dụ: boot_completed.
Module gameplay tự khai báo hằng tên sự kiện trong module của mình, không thêm vào core_events.gd.

## Event hiện có
- boot_completed (CoreEvents.BOOT_COMPLETED): phát từ boot.gd sau khi khởi động.

## Dependencies
Không phụ thuộc module nào.

## Kiểm tra
Chạy game, Output có dòng "[Boot] ProjectGame khởi động" và không có lỗi đỏ.

## Trạng thái
Mới có khung. Chưa có unit test. Chưa có module nào subscribe.

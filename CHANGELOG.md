# CHANGELOG

## Giai đoạn 0: khung khởi động

- Thiết lập Boot scene làm màn hình khởi động.
- Thêm Bootstrap script với log khởi động.
- Thiết lập tên ProjectGame.
- Thiết lập màn hình ngang Android.
- Chưa triển khai gameplay hoặc module khác.

- Giai đoạn 0: thêm EventBus (autoload, generic event) và CoreEvents.BOOT_COMPLETED; boot.gd phát boot_completed.

- Giai đoạn 0: thêm GameClock (autoload, thời gian số nguyên phút, hour_changed/day_changed, serialize/deserialize) và scene tự kiểm tra tests/game_clock_selftest.tscn.

## Phase 1: Shader Map Prototype

- Thêm map nền procedural bằng CanvasItem shader, không dùng texture.
- Thêm địa hình, đường chính, đường nhánh và kênh nước.
- Thêm MapShaderController quản lý tham số shader và viewport.
- Boot khởi tạo map làm nền, giữ EventBus và UI hiện có.

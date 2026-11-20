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

## Phase 2: 3D Third-person Map Prototype

- Thay map CanvasItem 2D bằng scene môi trường Node3D.
- Tạo đường giao thông, vỉa hè, kênh nước, nhà phố và cây bằng Primitive Mesh.
- Thêm Player CharacterBody3D với trọng lực và va chạm.
- Thêm camera third-person dùng SpringArm3D.
- Thêm joystick cảm ứng và thao tác vuốt để xoay camera.
- Giữ shader map 2D cũ làm prototype tham khảo, không còn dùng trong scene chính.
- Chưa xác nhận runtime trên Godot Android.

# Shader Map Prototype — Phase 1

## Mục đích
Map nền procedural render bằng CanvasItem shader, không sử dụng texture.

## Thành phần
- Địa hình procedural nhiều lớp noise.
- Mảng màu cỏ và đất.
- Đường chính uốn cong.
- Đường nhánh.
- Kênh nước uốn cong và bờ kênh.
- ShaderMaterial có seed và thông số độ rộng.
- Controller tự cập nhật kích thước viewport.

## Cấu trúc
- map_controller.gd: quản lý tham số shader.
- shaders/terrain_map.gdshader: render map procedural.
- scenes/map_root.tscn: scene bản đồ.

## Dependencies
Godot 4.x, GL Compatibility.
Không phụ thuộc gameplay module.

## Tích hợp
Boot khởi tạo map làm lớp nền, giữ UI và EventBus.

## Kiểm tra
Mở project trong Godot Android, chạy game, kiểm tra map,
đường và kênh nước. Chưa xác nhận runtime cho tới khi chạy thử.

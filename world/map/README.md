# 3D Map — Third-person Prototype

## Mục đích
Thay thế map CanvasItem 2D bằng môi trường 3D góc nhìn thứ ba,
tối ưu bước đầu cho Godot Android.

## Thành phần
- MapRoot: scene môi trường 3D.
- Map3DController: tạo địa hình phẳng, đường, ngã tư, kênh nước,
  nhà phố và cây bằng Primitive Mesh.
- Player3DController: CharacterBody3D, trọng lực, va chạm,
  di chuyển theo hướng camera.
- VirtualJoystick: joystick cảm ứng bên trái màn hình.
- SpringArm3D + Camera3D: camera theo sau nhân vật.

## Điều khiển
- Chạm/kéo joystick bên trái: di chuyển.
- Vuốt bên phải màn hình: xoay camera.
- Phím điều hướng ui_left/ui_right/ui_up/ui_down:
  điều khiển khi có bàn phím.

## Đồ họa
- Dựng bằng Mesh và StandardMaterial3D.
- Không dùng texture.
- Map shader CanvasItem cũ được giữ lại làm tài liệu prototype,
  không còn được tham chiếu bởi map_root.tscn.

## Dependencies
Godot 4.x, GL Compatibility, EventBus và CoreEvents từ dự án.

## Giới hạn prototype
- Địa hình hiện là mặt phẳng.
- Nhà và cây là mô hình low-poly cơ bản.
- Kênh nước hiện là hình học tĩnh.
- Chưa có giao thông, NPC, hệ thống tương tác hoặc lưu vị trí.
- Chưa tối ưu LOD và streaming khu vực.

## Kiểm tra
Mở project bằng Godot Android và chạy scene khởi động.
Kiểm tra nhân vật đứng trên mặt đất, di chuyển bằng joystick,
xoay camera bằng thao tác vuốt và va chạm với nhà.
Chỉ xác nhận hoàn thành sau khi chạy thử thực tế.

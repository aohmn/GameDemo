# 3D Map — Top-down Angled Prototype

## Mục đích
Môi trường 3D góc nhìn từ trên xuống, nghiêng nhẹ,
tối ưu cho thao tác cảm ứng trên Android.

## Thành phần
- MapRoot: scene môi trường 3D.
- Map3DController: tạo địa hình và vật thể bằng Primitive Mesh.
- Player3DController: di chuyển, trọng lực, va chạm và điều khiển camera.
- VirtualJoystick: joystick cảm ứng bên trái màn hình.
- SpringArm3D + Camera3D: camera top-down nghiêng, tự xoay theo hướng đi.

## Điều khiển
- Kéo joystick bên trái: di chuyển nhân vật.
- Camera tự xoay mượt ra phía sau hướng di chuyển.
- Thả joystick: camera giữ nguyên hướng.
- Lần kéo tiếp theo sử dụng hướng camera hiện tại làm chuẩn.
- Không cần vuốt màn hình để xoay camera.

## Camera
- Góc nghiêng: 55 độ.
- Khoảng cách SpringArm: 8 đơn vị.
- Camera theo hướng di chuyển bằng lerp_angle.
- Hướng tham chiếu di chuyển được khóa khi bắt đầu điều khiển,
  tránh hiện tượng nhân vật chạy vòng khi camera đang xoay.

## Đồ họa
- Dựng bằng Mesh và StandardMaterial3D.
- Không sử dụng texture.

## Dependencies
Godot 4.x, GL Compatibility, EventBus và GameClock.

## Kiểm tra
Mở project bằng Godot Android và chạy scene khởi động.
Kiểm tra:
1. Camera nhìn từ trên xuống và vẫn thấy nhân vật.
2. Kéo joystick lên, xuống, trái, phải.
3. Camera tự xoay theo hướng di chuyển.
4. Nhân vật không chạy vòng khi camera xoay.
5. Thả joystick, camera giữ hướng.
6. Kéo joystick lần nữa, hướng di chuyển vẫn chính xác.

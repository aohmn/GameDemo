# 3D Map — Fixed Angled Camera Prototype

## Mục đích
Môi trường 3D góc nhìn từ trên xuống, nghiêng 55 độ.
Camera cố định hướng nhìn và bám theo vị trí nhân vật.

## Thành phần
- MapRoot: scene môi trường 3D.
- Map3DController: tạo địa hình và vật thể bằng Primitive Mesh.
- Player3DController: di chuyển, trọng lực, va chạm và cập nhật camera.
- VirtualJoystick: joystick cảm ứng bên trái màn hình.
- SpringArm3D + Camera3D: camera nghiêng cố định.

## Điều khiển
- Kéo joystick bên trái để di chuyển.
- Nhân vật quay mặt theo hướng đang di chuyển.
- Camera giữ nguyên góc nhìn, chỉ theo sau vị trí nhân vật.
- Không có thao tác vuốt để xoay camera.

## Camera
- Góc nghiêng SpringArm3D: 55 độ.
- Khoảng cách SpringArm: 8 đơn vị.
- CameraPivot sử dụng top_level để không kế thừa góc xoay của Player.
- Camera giữ rotation toàn cục bằng 0 độ.
- Joystick sử dụng hệ trục thế giới cố định.

## Đồ họa
- Dựng bằng Mesh và StandardMaterial3D.
- Không sử dụng texture.

## Kiểm tra
1. Chạy scene khởi động trên Godot Android.
2. Kéo joystick lên, xuống, trái, phải.
3. Xác nhận nhân vật quay mặt theo hướng đi.
4. Xác nhận camera không xoay khi nhân vật đổi hướng.
5. Xác nhận camera chỉ bám theo vị trí nhân vật.

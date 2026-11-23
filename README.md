# GameDemo

Dự án game 2D HD: môi trường map 3D, nhân vật và vật thể 2D.

## Công nghệ

- Godot 4.x, GDScript có kiểu.
- Ưu tiên Android.
- Đồ họa map bằng mesh và shader, không dùng texture ảnh.

## Khởi động

Scene chính: `scenes/boot/main.tscn`.

Bootstrap tạo Camera, tải map `vietnam_street`, tạo Player và tải Joystick tùy chọn. Joystick gửi hướng điều khiển tới Player qua API của Player.

## Cấu trúc

- `core/`: hệ thống nền dùng chung.
- `modules/player/`: nhân vật, vật lý và hiển thị shader.
- `scenes/boot/`: Bootstrap, nơi kết nối các module.
- `maps/vietnam_street/`: map phố Việt Nam.
- `presentation/joystick/`: điều khiển cảm ứng.

## Kiểm tra

- Player độc lập: `modules/player/scenes/dev.tscn`.
- Joystick độc lập: `presentation/joystick/scenes/dev.tscn`.
- Chạy game chính bằng Godot Android.

# Player Module

Nhân vật CharacterBody3D với hiển thị cartoon 2D từ shader SDF, không sử dụng texture.

## API
- `set_move_direction(Vector2)`: hướng điều khiển.
- X âm: trái, X dương: phải.
- Y dương: lên, Y âm: xuống.

## Cấu trúc
- api/: thông tin API module
- logic/: chuyển động và vật lý
- data/: dữ liệu cấu hình (dành cho mở rộng)
- scenes/: scene chính và scene test
- assets/: shader
- tests/: dành cho test mở rộng

## Kiểm thử
Mở `scenes/dev.tscn` để kiểm tra hình ảnh và vật lý cơ bản.
Scene dev hiện chưa có joystick.

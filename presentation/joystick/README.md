# Joystick

Joystick ảo độc lập dành cho điều khiển cảm ứng trên Android.

## Chức năng

- Nhận cảm ứng màn hình và thao tác chuột để kiểm tra.
- Hỗ trợ một điểm chạm điều khiển tại một thời điểm.
- Vẽ nền và cần joystick bằng draw API, không dùng texture.
- Có deadzone để tránh tín hiệu trôi khi không chủ động điều khiển.
- Trả hướng điều khiển trong khoảng -1 đến 1.

## API

- `get_direction() -> Vector2`: lấy hướng hiện tại.
- `direction_changed(direction: Vector2)`: phát khi hướng thay đổi.

Trục X: trái âm, phải dương.
Trục Y: lên âm? Không. Hướng lên là dương, hướng xuống là âm.

## Kiểm tra

Mở scene `scenes/dev.tscn` để thử riêng joystick.

## Giới hạn

Module chỉ cung cấp hướng điều khiển. Chưa điều khiển Player vì dự án chưa có Player.
Bootstrap tải module tùy chọn; nếu không có module thì game vẫn khởi động.

# Module Presentation: Joystick Đấu Cá (`presentation/fishing_joystick`)

Joystick cảm ứng riêng bên phải màn hình cho pha giằng co (`FIGHT`).

## Cơ chế
- **Kéo trái/phải**: Tạo lực điều hướng cần câu (`steer_changed(steer_x: float)` trong `[-1.0, 1.0]`), gọi `FishingAPI.set_rod_steer()`.
- **Nhấp rồi nhả nhanh**: Phát xung giật cần (`twitch_triggered()`).
- **Trả về tâm**: Dừng tác động (`steer_x = 0.0`).
- **Bảo vệ chạm**: Có deadzone (`0.14`), giới hạn biên, pointer capture theo `touch.index`, hỗ trợ safe area.
- Không chứa thao tác hay nút thu/nhả dây.

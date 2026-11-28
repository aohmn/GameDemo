# Module Presentation: Camera Dưới Nước (`presentation/underwater_cam`)

Hiển thị góc nhìn camera phụ dưới nước bằng `SubViewport` + `Camera3D` độc lập khi người chơi đang ở trạng thái giằng co (`FIGHT`).

## Thành phần
- `underwater_cam_panel.gd`: Panel nổi responsive, lắng nghe `EventBus` (`STATE_CHANGED`, `FIGHT_UPDATE`, `FISH_CAUGHT`, `FISH_ESCAPED`).
- `underwater_fish_scene.gd` & `underwater_fish_shader.gdshader`: Cá 3D dựng hoàn toàn bằng Mesh + Shader (không texture), có chuyển động uốn thân/đuôi theo tốc độ và hướng bơi.
- `underwater_line.gd`: Dây câu 3D và lưỡi câu nối từ mặt nước tới miệng cá, đổi màu theo lực căng.
- `underwater_environment.gd`: Môi trường nước xanh lam, sương mù, ánh sáng và bọt khí nổi.
- `scenes/dev.tscn`: Scene chạy thử độc lập với dữ liệu giả lập.

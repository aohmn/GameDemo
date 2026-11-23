# GameDemo

Dự án game phiêu lưu khám phá và mô phỏng câu cá thư giãn theo phong cách 2D HD (Map 3D, nhân vật 2D billboard shader SDF).

## Thể loại & Lối chơi

- Game phiêu lưu khám phá kết hợp câu cá thư giãn.
- Khám phá các hòn đảo, bến cảng và vùng biển rộng lớn.
- Câu cá, sưu tập sinh vật biển đa dạng, giao thương và nâng cấp trang thiết bị.
- Mỗi bản đồ câu cá là một module độc lập, dùng chung dữ liệu người chơi.

## Công nghệ & Đồ họa

- Godot 4.x, GDScript có kiểu (static typing).
- Ưu tiên trải nghiệm mượt mà trên Android (màn ngang, Joystick cảm ứng).
- Map 3D dựng bằng mesh và vật liệu màu/shader, nhân vật 2D shader SDF, hoàn toàn không dùng texture ảnh hay sampler2D.

## Khởi động

Scene chính: `scenes/boot/main.tscn`.

Bootstrap khởi tạo Camera bám theo nhân vật, nạp MapManager để tải map đảo bến cảng nhiệt đới, sinh Player và kết nối Joystick cảm ứng.

## Cấu trúc dự án

- `core/`: hệ thống nền, hợp đồng và sự kiện dùng chung.
- `modules/player/`: nhân vật, chuyển động vật lý, animation shader SDF và hướng nhìn.
- `modules/sky_dome/`: vòm trời procedural 3D nhiệt đới (gradient, mặt trời, mây procedural không texture).
- `maps/harbor_island/`: map đảo bến cảng nhiệt đới (~50 × 50m) với bãi biển, cầu tàu, vịnh kín, núi đá và rặng dừa.
- `presentation/joystick/`: điều khiển cảm ứng đa điểm độc lập.
- `scenes/boot/`: Bootstrap và MapManager kết nối các thành phần.
- `docs/`: tài liệu phong cách đồ họa và quyết định kiến trúc (`docs/decisions/`).

## Kiểm tra

- Sky Dome độc lập: `modules/sky_dome/scenes/dev.tscn`.
- Player độc lập: `modules/player/scenes/dev.tscn`.
- Joystick độc lập: `presentation/joystick/scenes/dev.tscn`.
- Chạy toàn bộ game bằng Godot Android qua scene khởi động `scenes/boot/main.tscn`.

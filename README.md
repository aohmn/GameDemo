# GameDemo

Dự án game 2D HD: môi trường map 3D, nhân vật và vật thể 2D.

## Công nghệ

- Godot 4.x, GDScript có kiểu.
- Ưu tiên Android.
- Đồ họa map bằng mesh và shader, không dùng texture ảnh.

## Khởi động

Scene chính: `scenes/boot/main.tscn`

Bootstrap tạo camera và MapManager. Map đầu tiên được tải là `vietnam_street`.

## Cấu trúc hiện tại

- `scenes/boot/`: khởi động và quản lý vòng đời map.
- `maps/vietnam_street/`: map phố Việt Nam đầu tiên.

## Chuyển map

MapManager nhận ID map qua hàm `load_map(map_id)`. Các map được đăng ký trong `MAP_SCENES`.

## Phát triển

Đọc `AGENTS.md` trước khi thay đổi dự án. Chạy và kiểm tra bằng Godot Android.

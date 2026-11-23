# Bootstrap

Bootstrap là điểm khởi động và nơi duy nhất kết nối các hệ thống cấp cao.

## Trách nhiệm

- `main.tscn`: scene khởi động của game.
- `main.gd`: tạo camera và khởi tạo MapManager.
- `map_manager.gd`: đăng ký, tải và giải phóng map.

## Chuyển map

Gọi `load_map(map_id)` trên MapManager.

MapManager chỉ giữ một map hoạt động tại một thời điểm. Map mới phải có node gốc `Node3D`.

Khi thêm map mới, đăng ký ID và PackedScene trong `MAP_SCENES` của `map_manager.gd`.

Không để map tự tải hoặc quản lý map khác.

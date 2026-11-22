# 0002 — Tách Player/Needs/HUD/Visual khỏi world/map

- Ngày: 2026-11-22
- Trạng thái: Chưa xác nhận trên Godot Android (mức 2).
- Liên quan: AGENTS §5, §9, §10; `docs/architecture/module_dependency_survey.md`.

## Quyết định

Tách thành mô-đun riêng theo kiến trúc module + Presentation:

- `modules/needs/player_needs.gd` (class `PlayerNeeds`) — Nhu cầu đói/khát/năng lượng.
- `modules/player/player_controller.gd` (class `Player3DController`) — chủ vị CharacterBody3D.
- `presentation/hud/player_hud.gd` (class `PlayerHUD`) + `presentation/hud/virtual_joystick.gd` — HUD và Joystick.
- `presentation/player_visual/player_visual.gd` (class `PlayerVisual`) — nhân vật 3D dự phòng.

Không thay đổi hành vi, không đổi tên class_name, không đụng minimap/đường/kênh.

## Hệ quả

- `world/map/` chỉ còn: `map_controller.gd`, `minimap.gd`, `shaders/`, `scenes/`, `README.md`.
  `world/map/characters/` đã xóa.
- Đường dẫn script trong `world/map/scenes/map_root.tscn` cập nhật sang
  `res://modules/needs/player_needs.gd`, `res://modules/player/player_controller.gd`,
  `res://presentation/hud/player_hud.gd`, `res://presentation/hud/virtual_joystick.gd`,
  `res://presentation/player_visual/player_visual.gd`.
- Giao tiếp giữa các thành phần chỉ qua sự kiện `PlayerEvents`/`CoreEvents`/`WorldEvents`
  (`core/contracts`, `core/events`), không qua tham chiếu node nội bộ.
- Player đã thêm `@export var joystick_path: NodePath`; `map_root.tscn` gán
  `joystick_path = NodePath("../HUD/Joystick")`. Lưu ý: không còn
  `get_node("../HUD/Joystick")` trong code — Joystick nhận hướng điều khiển qua
  `PlayerEvents.MOVE_INPUT_CHANGED`, nên export là điểm gắn kết thay thế.

## Mức kiểm tra sau (§11)

- Mức 2: `gdparse` không error, `grep` không còn tham chiếu cũ, cấu trúc file đúng.
- Chưa kiểm tra: boot 200 frame và ảnh chụp trên Godot Android.
- Chưa chạy xóa từng thư mục modules/needs, presentation/hud, presentation/player_visual
  (chỉ mô phỏng bằng `mv` + grep không tham chiếu còn lại).

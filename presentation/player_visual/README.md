# Player Visual

Nhân vật 3D dự phòng của Player: dựng đầu, tóc, thân, tay, chân, bàn tay và giày
bằng `CapsuleMesh`, `SphereMesh`, `CylinderMesh` (không dùng texture hoặc ảnh).

## Mục đích

- `PlayerVisual` (extends `Node3D`): dựng nhân vật stylized bán thực tế; chuyển động
  tay/chân procedural theo vận tốc nhận qua `PlayerEvents.MOTION_CHANGED`; vật liệu
  `StandardMaterial3D` dùng màu albedo, roughness cao, không metallic.

## Tích hợp

- `world/map/scenes/map_root.tscn` gắn script lên node `Player/VisualRoot`.
- `PlayerVisual` tự subscribe `PlayerEvents.MOTION_CHANGED`; `PlayerController`
  không giữ tham chiếu tới node này.
- Nếu node Player có sibling tên `Visual` (sprite HD-2D do Bootstrap gắn lúc chạy),
  `VisualRoot` tự ẩn và tắt xử lý; không bị xóa, dùng làm dự phòng.
  `CollisionShape3D` của Player giữ nguyên.

## Event

- Nhận `PlayerEvents.MOTION_CHANGED` (payload `velocity` Vector2). Không phát event.

## Kiểm tra

- `gdparse presentation/player_visual/player_visual.gd` — không error.
- Chạy map không có sprite: Player/VisualRoot hiển thị với 15 mesh con; di chuyển,
  tay/chân động theo vận tốc.

## Giới hạn

Chưa phải mô hình người giải phẫu chi tiết. Chưa có rig xương, facial animation
hoặc quần áo mô phỏng.

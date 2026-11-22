# Player Character Visual

## Mục đích

Hiển thị nhân vật người chơi bằng hình học 3D dựng từ primitive mesh, không dùng texture hoặc ảnh.

## Thành phần

- `player_visual.gd`: tạo đầu, tóc, thân, tay, chân, bàn tay và giày bằng CapsuleMesh, SphereMesh và CylinderMesh.
- Chuyển động tay/chân procedural theo vận tốc nhận qua `PlayerEvents.MOTION_CHANGED`.
- Vật liệu StandardMaterial3D dùng màu albedo, roughness cao và không metallic.

## Tích hợp

`world/map/scenes/map_root.tscn` gắn script lên node `Player/VisualRoot`.
`PlayerVisual` tự subscribe `PlayerEvents.MOTION_CHANGED`; `PlayerController`
không giữ tham chiếu tới node này.

Nếu node Player có sibling tên `Visual` (sprite HD-2D), `VisualRoot` tự ẩn và
tắt xử lý; không bị xóa, dùng làm dự phòng. CollisionShape3D của Player giữ
nguyên, độc lập với hình dáng hiển thị.

## Giới hạn

Đây là nhân vật 3D stylized bán thực tế dựng bằng primitive, chưa phải mô hình người giải phẫu chi tiết. Chưa có rig xương, facial animation hoặc quần áo mô phỏng.

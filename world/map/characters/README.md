# Player Character Visual

## Mục đích

Hiển thị nhân vật người chơi bằng hình học 3D dựng từ primitive mesh, không dùng texture hoặc ảnh.

## Thành phần

- `player_visual.gd`: tạo đầu, tóc, thân, tay, chân, bàn tay và giày bằng CapsuleMesh, SphereMesh và CylinderMesh.
- Chuyển động tay/chân procedural theo vận tốc của `CharacterBody3D`.
- Vật liệu StandardMaterial3D dùng màu albedo, roughness cao và không metallic.

## Tích hợp

`world/map/scenes/map_root.tscn` gắn script lên node `Player/VisualRoot`. CollisionShape3D của Player được giữ nguyên, độc lập với hình dáng hiển thị.

## Giới hạn

Đây là nhân vật 3D stylized bán thực tế dựng bằng primitive, chưa phải mô hình người giải phẫu chi tiết. Chưa có rig xương, facial animation hoặc quần áo mô phỏng.

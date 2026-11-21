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

# Player Needs

Module quản lý đói, khát và năng lượng của Player. Dữ liệu thời gian lấy duy
nhất từ `GameClock`; module không tự tạo đồng hồ.

## API công khai

- `consume_food(restoration: float = 35.0) -> bool`: hồi đói.
- `drink_water(restoration: float = 40.0) -> bool`: hồi khát.
- `rest(minutes: int = 60) -> bool`: hồi năng lượng và tua GameClock.
- `get_state() -> Dictionary`: đọc trạng thái hiện tại.
- `serialize_state()` / `deserialize_state()`: tích hợp SaveCoordinator qua
  đăng ký participant (`save_id = "player_needs"`).
- Signal `needs_changed(hunger, thirst, energy)`.

## Giao tiếp

- Phát `PlayerEvents.NEEDS_CHANGED` cho HUD.
- Nhận `PlayerEvents.NEEDS_ACTION_REQUESTED` từ HUD (`eat`, `drink`, `rest`).
- Nhận `PlayerEvents.STATE_SNAPSHOT_REQUESTED` để phát lại trạng thái cho UI mới.
- Yêu cầu Player trừ máu qua `PlayerEvents.HEALTH_DAMAGE_REQUESTED`.

UI và Player không truy cập trực tiếp node Needs.

Giá trị nằm trong khoảng 0–100. Khi đói hoặc khát bằng 0, Player mất máu nhẹ;
Player vẫn sở hữu API và dữ liệu sức khỏe.

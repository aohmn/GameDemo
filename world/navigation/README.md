# Navigation Foundation

## Purpose
Cung cấp truy vấn tuyến đường trên đồ thị đường cho prototype thế giới mở.
Module chạy dưới dạng autoload `WorldNavigation` và **chỉ giao tiếp qua
EventBus**; không module nào tham chiếu trực tiếp script này.

## Public API (event-based)
- Nhận `WorldEvents.ROUTE_REQUESTED`:
  `{ "request_id": int, "start": Vector3, "destination": Vector3 }`.
- Phát `WorldEvents.ROUTE_READY`:
  `{ "request_id": int, "route": PackedVector3Array, "destination": Vector3 }`.

`request_id` phải lớn hơn 0 và được người yêu cầu dùng để bỏ qua kết quả không
khớp (NPC và Minimap có thể cùng yêu cầu). Route rỗng nghĩa là không tìm thấy
đường.

## Dependencies
- `EventBus`, `core/contracts/world_events.gd` (`WorldEvents`).
- Built-in `AStar2D`.
- Không preload/không gọi trực tiếp module NPC, Minimap hay Player.

## Current graph
Đồ thị dùng các trục đường hiện có:
- X: -65, 0, 65
- Z: -90, -12, 70

Tuyến luôn đi qua các giao lộ của đồ thị. Đoạn tiếp cận tới đích chỉ được thêm
sau khi đã có tuyến hợp lệ, nên lỗi pathfinding không bị biến thành đi thẳng.

## Limitations
- Đây là nền tảng tuyến đường, chưa phải local avoidance đầy đủ.
- Start và destination được snap về giao lộ gần nhất.
- Chưa mô hình đường một chiều, giao thông, đóng đường, vỉa hè, lối vào nhà hay
  tránh vật cản cục bộ.
- Tọa độ đồ thị phải cập nhật khi bố trí đường của map thay đổi.

## Verification
- `gdparse` (đã chạy, không lỗi cú pháp).
- Mở Godot Android, chạy `map_root.tscn`:
  - Tua lịch NPC và quan sát NPC đi theo các điểm giao lộ.
  - Mở bản đồ lớn, chạm một vị trí và xác nhận preview tuyến xuất hiện.
- Chưa xác nhận runtime trên Godot Android.

## Tích hợp
- NPC: `LifeNPC` phát `ROUTE_REQUESTED` khi đổi điểm đến và nhận `ROUTE_READY`.
- Minimap: `WorldMinimap` phát `ROUTE_REQUESTED` khi chọn waypoint và vẽ
  `ROUTE_READY` tương ứng.

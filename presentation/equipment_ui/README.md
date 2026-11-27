# Equipment UI — ProjectGame

Module giao diện người dùng cho hệ thống Pháp Bảo & Trang Bị (`presentation/equipment_ui/`).
Chỉ phụ thuộc vào `core/contracts/equipment_events.gd` và phát tín hiệu cho Bootstrap.

## Tính năng
- Nút bấm mở/đóng "Trang Bị" góc trên bên phải màn hình.
- Bảng điều khiển modal phong cách tiên hiệp cổ phong (không texture).
- Quản lý 5 vị trí trang bị: Cần Câu, Dây Cước, Mồi Câu, Bảo Vật 1, Bảo Vật 2.
- Hiển thị chỉ số tổng hợp thời gian thực: Lực kéo, Chịu tải dây, Khống chế, Hấp thu tu vi.
- Tự động đồng bộ với `EquipmentAPI` và `ServiceCoordinator`.

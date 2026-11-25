# Fishing Inventory UI

Giao diện hiển thị túi cá của người chơi (`presentation/fishing_inventory_ui/`).
Thuộc tầng Presentation: chỉ giao tiếp qua API của `modules/inventory` hoặc lắng nghe sự kiện từ `core/EventBus`, không chứa logic gameplay hay logic lưu trữ dữ liệu.

## Chức năng
- Nút bấm `Túi Cá` ở góc trên màn hình hỗ trợ bật/tắt nhanh giao diện modal túi cá trên thiết bị di động.
- Hiển thị danh sách cá đã câu được:
  - Tên tiếng Việt hiển thị (ví dụ: Cá Cơm Biển, Cá Đối Mục, Cá Mú Đỏ...).
  - Số lượng cá câu được (`xN`).
  - Khối lượng của từng loài (gam hoặc kg).
- Thanh tổng quan hiển thị tổng số lượng cá và tổng trọng lượng cả túi.
- Trạng thái túi trống thân thiện khi người chơi chưa bắt được con cá nào.
- Tự động cập nhật nội dung hiển thị thời gian thực khi có sự kiện `inventory_updated` hoặc `inventory_item_added`.

## Phong cách đồ họa
- Hoàn toàn vẽ bằng UI phẳng (`StyleBoxFlat`), không dùng ảnh texture bên ngoài.
- Nền xanh đen mờ hiện đại, viền sắc nét, tương thích kích thước màn hình ngang Android.

## Kiểm tra độc lập
- Mở scene `presentation/fishing_inventory_ui/scenes/dev.tscn` để kiểm tra trực tiếp giao diện trên Godot hoặc thiết bị.
- Scene dev tích hợp sẵn các nút giả lập câu cá để kiểm tra việc cập nhật danh sách và trạng thái túi trống.

## Hành động trên cá
- Mỗi dòng cá có nút Hấp thu và Bán. Nút "Số lượng" ở tiêu đề đổi giữa 1 con và Tất cả.
- Tín hiệu `fish_action_requested(action, fish_id, count)` với `action` là `absorb` hoặc `sell`; Bootstrap (`scenes/boot/ui_action_router.gd`) xử lý, UI không chứa logic.

# Kế hoạch phát triển Module Inventory (ROADMAP)

## Giai đoạn 1: Cơ bản (Hiện tại - Bước 2)
- [x] Tạo module độc lập `modules/inventory/` chỉ phụ thuộc `core/`.
- [x] Lưu trữ cá đã câu theo `fish_id`, số lượng `count` và tổng khối lượng `total_weight_g`.
- [x] Lắng nghe sự kiện `FISH_CAUGHT` từ `FishingEvents` qua EventBus.
- [x] Cơ chế lưu và tải file định dạng ConfigFile tại `user://inventory.cfg`.
- [x] Scene chạy thử độc lập `scenes/dev.tscn`.
- [x] Tích hợp nạp tùy chọn tại Bootstrap (`scenes/boot/main.gd`).

## Giai đoạn 2: Kho Đồ Tu Tiên Đa Năng (TASK 05 - Đã hoàn thành)
- [x] Tạo `ItemSpec` Resource phân loại 5 nhóm: Cá, Nguyên liệu, Pháp bảo, Tiêu hao, Khác.
- [x] Hỗ trợ phẩm cấp vật phẩm: Phàm, Linh, Huyền, Địa, Thiên, Thánh.
- [x] Thêm hàm `add_item()`, `remove_item()`, `has_item()`, `get_item_count()`.
- [x] Kiểm tra giới hạn kho chứa (`max_slots = 100`) và giới hạn xếp chồng `max_stack`.
- [x] Hỗ trợ lọc theo loại qua `get_items_by_category()`.
- [x] Nâng cấp lưu trữ ConfigFile version 2, tương thích ngược hoàn hảo với save version 1.
- [x] Đảm bảo tương thích 100% với bán cá (`Economy`), mua cần (`Shop`) và hấp thu linh khí (`Cultivation`).

## Giai đoạn 3: Tính Năng Kho Nâng Cao (Kế hoạch tương lai)
- [ ] Mở rộng sức chứa kho thông qua Túi Càn Khôn / Nhẫn Trữ Vật.
- [ ] Cơ chế sử dụng đan dược / bùa chú trực tiếp từ kho đồ.
- [ ] Sắp xếp kho đồ tự động theo phẩm cấp và nhóm vật phẩm.

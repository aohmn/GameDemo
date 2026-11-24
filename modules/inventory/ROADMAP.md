# Kế hoạch phát triển Module Inventory (ROADMAP)

## Giai đoạn 1: Cơ bản (Hiện tại - Bước 2)
- [x] Tạo module độc lập `modules/inventory/` chỉ phụ thuộc `core/`.
- [x] Lưu trữ cá đã câu theo `fish_id`, số lượng `count` và tổng khối lượng `total_weight_g`.
- [x] Lắng nghe sự kiện `FISH_CAUGHT` từ `FishingEvents` qua EventBus.
- [x] Cơ chế lưu và tải file định dạng ConfigFile tại `user://inventory.cfg`.
- [x] Scene chạy thử độc lập `scenes/dev.tscn`.
- [x] Tích hợp nạp tùy chọn tại Bootstrap (`scenes/boot/main.gd`).

## Giai đoạn 2: Giới hạn sức chứa và phân loại kho (Tương lai)
- [ ] Bổ sung giới hạn tải trọng tối đa của túi đồ (Weight Capacity) theo cấp độ túi.
- [ ] Phát sự kiện `INVENTORY_FULL` khi trọng lượng vượt quá sức chứa.
- [ ] Phân loại ngăn chứa đồ: Ngăn chứa sinh vật biển / Ngăn chứa mồi câu / Dụng cụ câu.

## Giai đoạn 3: Tích hợp kinh tế và bán cá (Tương lai)
- [ ] Giao tiếp với Module Economy (thương lái bến cảng) để bán cá lấy tiền VND.
- [ ] Hỗ trợ bán toàn bộ hoặc bán theo từng loài cá.
- [ ] Trừ cá và phát sự kiện `ITEM_REMOVED` khi giao dịch hoàn tất atomic.

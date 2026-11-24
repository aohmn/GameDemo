# Roadmap Module Equipment

## Giai đoạn 1: Nền tảng Trang Bị & Pháp Bảo (TASK 06 - Đã hoàn thành)
- [x] Tạo `EquipmentItemSpec` Resource hỗ trợ 8 phẩm cấp và 5 vị trí trang bị.
- [x] Quản lý trang bị / tháo trang bị cho 5 slot: cần câu, dây câu, mồi câu, bảo vật 1, bảo vật 2.
- [x] Kiểm tra điều kiện cảnh giới (`required_realm_level`) và chặn trang bị trùng món.
- [x] Tính toán chỉ số tổng hợp qua `calculate_total_stats()`.
- [x] Lưu và tải dữ liệu an toàn `user://equipment.cfg`, tương thích ngược với cần câu từ Shop.
- [x] Điều phối đồng bộ sang Fishing API qua `ServiceCoordinator`.
- [x] Scene dev chạy độc lập `scenes/dev.tscn`.

## Giai đoạn 2: Nâng Cấp Pháp Bảo & Hiệu Ứng Chuyên Sâu (Kế hoạch tương lai)
- [ ] Cơ chế tiêu hao độ bền và sửa chữa pháp bảo bằng linh thạch.
- [ ] Khảm nạm ngọc thạch, khắc phù văn gia hộ pháp bảo.
- [ ] Hiệu ứng kích hoạt bị động khi giằng co với Tiên ngư / Thần ngư.

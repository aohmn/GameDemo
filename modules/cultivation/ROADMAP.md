# Roadmap Module Cultivation

## Giai đoạn 1: Nền tảng Tu Luyện (TASK 03 - Đã hoàn thành)
- [x] Tạo dữ liệu 12 cảnh giới tu tiên qua Resource `RealmSpec` và 12 file `.tres`.
- [x] Mỗi cảnh giới chuẩn 9 tầng, ngưỡng tu vi phân tầng rõ ràng.
- [x] Quản lý tu vi, tự động thăng tầng 1->9, chặn tự động đột phá đại cảnh giới.
- [x] API kiểm tra điều kiện và thực hiện đột phá.
- [x] Lưu trữ an toàn bằng ConfigFile `user://cultivation.cfg`.
- [x] Scene dev chạy độc lập `scenes/dev.tscn`.

## Giai đoạn 2: Tích hợp Gameplay Tu Tiên
- [x] Nhận tu vi khi hấp thu Linh Ngư trong túi đồ qua `ServiceCoordinator.absorb_fish_qi()` (TASK 04).
- [ ] Thiên kiếp lôi kiếp khi đột phá từ Kim Đan / Độ Kiếp trở lên.
- [ ] Đan dược hỗ trợ đột phá và gia tăng tỷ lệ thành công.
- [ ] Kỹ năng tu chân gia tăng tốc độ tích lũy tu vi.

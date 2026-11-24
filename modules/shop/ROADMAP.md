# Kế hoạch phát triển Module Shop (ROADMAP)

## Giai đoạn 1: Cơ bản (Hiện tại - Bước 5)
- [x] Tạo module độc lập `modules/shop/` chỉ phụ thuộc `core/`.
- [x] Quản lý danh mục cần câu bằng Resource `.tres` (`ShopItemSpec`) với đầy đủ tên, mô tả, giá VND và chỉ số chuẩn xác.
- [x] Kiểm tra mua vật phẩm: chặn thiếu tiền, chặn mua trùng, phát sự kiện khi mua thành công.
- [x] Cơ chế trang bị cần câu đã sở hữu và đồng bộ thông số sang Fishing API qua Bootstrap.
- [x] Lưu và tải dữ liệu vật phẩm đã sở hữu và cần câu trang bị tại `user://shop.cfg`.
- [x] Giao dịch atomic giữa Shop và Economy điều phối tại Bootstrap.
- [x] Scene chạy thử độc lập `scenes/dev.tscn`.

## Giai đoạn 2: Bổ sung mồi câu và phụ kiện (Tương lai)
- [ ] Bán mồi câu tiêu hao (trùng biển, tép bạc, mồi giả spinner).
- [ ] Bán phụ kiện hỗ trợ: Phao dạ quang câu đêm, dây cước gia cường, giỏ đựng cá tăng sức chứa.

## Giai đoạn 3: Giao diện Shop UI hoàn chỉnh (Tương lai)
- [ ] Xây dựng Presentation Shop UI với bố cục thẻ vật phẩm trực quan cho mobile.
- [ ] Hiển thị thông số so sánh trực quan giữa cần câu đang cầm và cần câu trong cửa hàng.

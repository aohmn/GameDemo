# Kế hoạch phát triển Module Economy (ROADMAP)

## Giai đoạn 1: Cơ bản (Hiện tại - Bước 4)
- [x] Tạo module độc lập `modules/economy/` chỉ phụ thuộc `core/`.
- [x] Quản lý số dư VND bằng số nguyên `int`.
- [x] Bảng giá bán cá theo `fish_id` bằng Resource `.tres` (`FishPriceSpec`).
- [x] Tính giá theo số lượng và khối lượng cá.
- [x] Cơ chế bán cá an toàn không vượt số lượng, ghi nhận lịch sử giao dịch.
- [x] Phát sự kiện `BALANCE_CHANGED`, `TRANSACTION_COMPLETED`, `TRANSACTION_FAILED` qua EventBus.
- [x] Lưu và tải dữ liệu bằng ConfigFile tại `user://economy.cfg`.
- [x] Điều phối giao dịch atomic tại Bootstrap giữa Inventory và Economy.
- [x] Scene chạy thử độc lập `scenes/dev.tscn`.

## Giai đoạn 2: Cửa hàng & Mua bán vật phẩm (Tương lai)
- [ ] Xây dựng hệ thống cửa hàng ngư cụ tại bến cảng (Cửa hàng ông Ba).
- [ ] Mua mồi câu các loại (trùng biển, tép, cá con).
- [ ] Giao diện thương nhân (Merchant UI) tương tác trực quan.

## Giai đoạn 3: Nâng cấp thiết bị câu cá (Tương lai)
- [ ] Cơ chế nâng cấp cần câu (tăng ngưỡng đứt dây, tốc độ kéo/xả).
- [ ] Nâng cấp thuyền hoặc mở khóa bến tàu mới bằng tiền VND.

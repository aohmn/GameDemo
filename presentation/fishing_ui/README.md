# Fishing UI

Giao diện điều khiển tương tác câu cá trên màn hình ngang Android (`presentation/fishing_ui/`).
Thiết kế theo phong cách mỹ thuật **Genshin Impact x Sea of Thieves** (tiên hiệp biển khơi, bảng màu Bạch Ngọc, Ngọc Bích Biển, Linh Kim, Cát Nắng Vàng).
Thuộc tầng Presentation: chỉ giao tiếp qua `FishingAPI` và nhận sự kiện từ `core/EventBus`, không chứa logic gameplay.

## Bố cục & Trải nghiệm người dùng
- **Thanh thông tin & Lực căng trung tâm (Top Center)**:
  - Bảng HUD ngọc bích viền hoàng kim, bố trí cạnh trên màn hình (y = 10px), không che khuất Joystick hay nút Túi Cá.
  - Huy hiệu trạng thái linh hoạt (`SẴN SÀNG`, `CHỜ ĐỢI`, `CẮN CÂU!`, `ĐẤU SỨC`).
  - Thanh tiến trình thu phục cá (`ProgressBar`) hiển thị tỷ lệ cá bị bào mòn thể lực.
  - Thanh lực căng cước câu đa sắc: Xanh (Vùng an toàn), Vàng (Quá chùng), Đỏ (Quá căng nguy hiểm).
  - Nhãn hiển thị độ bền thực tế của Cần câu và Dây câu theo thời gian thực.
  - Phản hồi hành vi cá tức thời: Cá mệt lả, bứt tốc giãy mạnh hay tạm nghỉ.
- **Cụm nút điều khiển cảm ứng lớn (Bottom Right)**:
  - Tối ưu kích thước cảm ứng ngón tay cái (>48px) trên điện thoại Android màn ngang:
    - **Nút Thả Cần**: Tự động kích hoạt khi đứng gần mặt nước hợp lệ.
    - **Nút Giật Cần**: Nút màu đỏ nổi bật xuất hiện ngay khi cá cắn câu.
    - **Nút Kéo Dây / Xả Dây**: Chạm giữ mượt mà khi đấu sức với cá.
- **Popup kết quả**:
  - Thông báo rõ ràng khi bắt thành công (tên linh ngư, trọng lượng, linh khí) hoặc lý do thất bại (giật sớm, giật trễ, đứt dây, gãy cần, tuột lưỡi).

## Kiểm tra độc lập
- Mở scene `presentation/fishing_ui/scenes/dev.tscn` để chạy thử riêng biệt quy trình câu cá đầy đủ.

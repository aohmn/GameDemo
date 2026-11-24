# Fishing UI

Giao diện điều khiển tương tác câu cá trên màn hình ngang Android (`presentation/fishing_ui/`).
Thuộc tầng Presentation: chỉ giao tiếp qua `FishingAPI` và nhận sự kiện từ `core/EventBus`, không chứa logic gameplay.

## Bố cục & Trải nghiệm người dùng
- **Thanh thông tin & Lực căng (Top Center)**:
  - Nằm ở cạnh trên chính giữa màn hình (y = 16px), không che khuất Joystick (góc dưới trái) và Nút Túi Cá (góc trên phải).
  - Hiển thị trạng thái hiện tại (Đang đợi, Cá cắn câu, Giằng co, Bắt được cá / Thất bại).
  - Thanh đo lực căng `ProgressBar` và nhãn cảnh báo vùng an toàn khi bước vào giai đoạn giằng co (`FIGHT`).
- **Cụm nút điều khiển câu cá (Bottom Right)**:
  - Nằm ở góc dưới bên phải màn hình:
    - **Nút Thả cần**: Chỉ sáng và bấm được khi người chơi đứng gần điểm câu hợp lệ (như cầu tàu). Khi ở xa sẽ mờ đi và đổi chữ thành "Đến gần nước".
    - **Nút Giật cần**: Xuất hiện tức thì khi cá cắn câu trong cửa sổ thời gian (0.8s).
    - **Nút Kéo dây / Xả dây**: Xuất hiện khi giằng co, hỗ trợ chạm giữ (`button_down` / `button_up`) chính xác trên màn hình cảm ứng điện thoại.

## Kiểm tra độc lập
- Mở scene `presentation/fishing_ui/scenes/dev.tscn` để chạy thử riêng biệt quy trình câu cá đầy đủ.

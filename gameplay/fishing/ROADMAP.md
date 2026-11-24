# Lộ Trình Phát Triển Gameplay Fishing (`gameplay/fishing/`)

## 1. Đã Hoàn Thành (TASK 11)
- [x] Kiến trúc phân tầng độc lập (`core/`, `fish/`, `battle/`, `equipment/`, `skills/`, `rewards/`).
- [x] Máy trạng thái FSM 8 trạng thái hoàn chỉnh với cơ chế chống nhảy cóc trạng thái.
- [x] Tách biệt toàn bộ công thức toán học vào `fishing_calculator.gd`.
- [x] Dữ liệu sinh học & tu vi cá `FishData` (sức mạnh, thể lực, tốc độ bơi, độ lì, phẩm cấp, linh khí).
- [x] Trí tuệ hành vi cá `FishAI` với các trạng thái giãy bứt tốc (RUSH), nhử chùng dây (REST) và mệt mỏi (TIRED).
- [x] Hệ thống đấu sức `FishingBattle` và quản lý lực căng `TensionSystem` (đứt dây khi vượt max, tuột lưỡi khi chùng dây).
- [x] Hệ thống trang bị mở rộng: Cần câu (`FishingRod`), Dây câu (`FishingLine`), Mồi câu (`BaitSystem`).
- [x] Khung định hướng 5 kỹ năng câu cá tu đạo (`FishingSkill`: Linh Nhãn, Thính Thủy, Ngự Câu, Tỏa Ngư, Thu Linh).
- [x] Scene kiểm thử độc lập `dev.tscn` và `dev.gd` xác thực toàn bộ các trường hợp thắng/thua/đứt dây/chùng dây.
- [x] Tích hợp với `modules/fishing/api/fishing_api.gd` và `EventBus`.

## 2. Phần Chưa Triển Khai (Dự Kiến Tương Lai)
- [ ] Giao diện kỹ năng tu đạo trên HUD khi thi triển (ví dụ: kích hoạt Linh Nhãn thấy hào quang cá dưới nước).
- [ ] Cây kỹ năng câu cá chuyên sâu gắn liền với cảnh giới đột phá của Cultivation.
- [ ] Hao mòn độ bền cần câu và dây câu vĩnh viễn cần tu sửa tại Lò Chế Tạo.
- [ ] Đấu trùm thủy quái / Linh ngư cổ đại với cơ chế QTE kết hợp ngự khí phi kiếm.

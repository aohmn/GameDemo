# Gameplay Fishing Module (`gameplay/fishing/`)

Module gameplay trung tâm của GameDemo: quản lý toàn diện quy trình câu cá tu tiên từ chuẩn bị trang bị, mồi câu, quăng câu, phát hiện cắn câu, đấu sức giằng co đến thu phục cá hoặc cá trốn thoát.

---

## 1. Kiến Trúc & Cấu Trúc Thư Mục
Tuân thủ kiến trúc module độc lập và AGENTS.md (mỗi file ≤ 300 dòng, không texture, không phụ thuộc chéo gameplay khác, chỉ giao tiếp qua `core/contracts/fishing_events.gd` và `EventBus`).

```
gameplay/fishing/
├── README.md                      # Tài liệu kiến trúc và API
├── ROADMAP.md                     # Lộ trình tính năng đã làm và hướng phát triển
├── fishing_controller.gd          # Bộ điều khiển trung tâm FSM và quản lý phiên câu
├── dev.tscn                       # Scene kiểm thử độc lập module
├── dev.gd                         # Kịch bản kiểm thử luồng FSM, đứt dây, trốn thoát
├── core/
│   ├── fishing_state.gd           # 8 trạng thái hữu hạn và ma trận chuyển đổi hợp lệ
│   ├── fishing_data.gd            # Dữ liệu phiên câu cá, thông số lực căng và độ bền
│   └── fishing_calculator.gd      # Phép tính toán học: lực căng, hao mòn, độ mỏi cá
├── fish/
│   ├── fish_data.gd               # Dữ liệu sinh học & linh khí cá (sức mạnh, thể lực, độ lì...)
│   ├── fish_ai.gd                 # Trí tuệ hành vi cá (bứt tốc Rush, nghỉ ngơi Rest, mệt mỏi)
│   └── fish_spawner.gd            # Điều phối tỷ lệ cá cắn câu theo SpotSpec và Mồi
├── battle/
│   ├── fishing_battle.gd          # Điều phối vòng lặp đấu sức giằng co thời gian thực
│   └── tension_system.gd          # Quản lý lực căng, ngưỡng an toàn, đứt dây và chùng dây
├── equipment/
│   ├── fishing_rod.gd             # Thông số cần câu: lực chịu tải, tốc độ thu/xả, độ dẻo
│   ├── fishing_line.gd            # Thông số dây câu: độ bền, độ giãn, giảm chấn xung lực
│   └── bait_system.gd             # Quản lý mồi câu: thu hút phẩm cấp cá, giảm thời gian chờ
├── skills/
│   └── fishing_skill.gd           # 5 kỹ năng câu cá tu đạo (Linh Nhãn, Thính Thủy, Ngự Câu...)
└── rewards/
    └── fishing_reward.gd          # Đóng gói phần thưởng cá và linh khí gửi sang EventBus
```

---

## 2. Máy Trạng Thái Hữu Hạn (8 Trạng Thái FSM)
Tuân thủ quy tắc chống nhảy cóc trạng thái:
1. **IDLE**: Chưa câu, sẵn sàng nhận lệnh quăng cần.
2. **CASTING**: Quăng câu, chuẩn bị dữ liệu và xác định cá mục tiêu.
3. **WAITING**: Phao nổi trên mặt nước, đếm ngược thời gian chờ cá cắn.
4. **BITE**: Cá cắn câu, kích hoạt cửa sổ giật cần (Strike Window 0.85s).
5. **FIGHTING**: Đấu sức giằng co thời gian thực giữa người chơi và cá.
6. **CAUGHT**: Thu phục cá thành công khi thể lực cá cạn về 0.
7. **ESCAPED**: Cá trốn thoát (giật trễ, tuột lưỡi do chùng dây quá 3.5s).
8. **FAILED**: Thất bại (đứt dây khi lực căng vượt `max_tension`, gãy cần, giật quá sớm).

---

## 3. Cơ Chế Đấu Sức (Battle & Tension System)
- **Lực căng (`Tension`)**: Thay đổi theo lực thu dây của người chơi (`reel`), xả dây (`release`), và lực kéo biến thiên của cá (`FishAI`).
- **Vùng an toàn (`Safe Zone`)**: Nằm giữa `safe_min` và `safe_max`. Khi giữ lực căng trong vùng này, cá bị tiêu hao thể lực nhanh nhất.
- **Phản kháng theo đợt**: AI cá liên tục đổi trạng thái giữa *RUSH* (bứt tốc giãy mạnh), *NORMAL* (kéo nhịp nhàng) và *REST* (tạm dừng kéo khiến dây dễ bị chùng).
- **Điều chỉnh thời gian thực**: Hỗ trợ `set_pull_strength_factor` (0.5 đến 1.5) để người chơi kiểm soát lực kéo linh hoạt.

---

## 4. Tích Hợp Hệ Thống
- Khi thu phục cá thành công (`CAUGHT`), controller phát payload qua `on_fish_caught`:
  `{ "fish_id": String, "name": String, "tier": int, "rarity": int, "weight_g": int, "qi_value": int }`
- `modules/fishing/api/fishing_api.gd` chuyển tiếp payload vào `EventBus` (`fishing_fish_caught`).
- `Inventory` tiếp nhận để lưu trữ cá vào túi đồ.
- `Cultivation` có thể tiếp nhận qua ServiceCoordinator để hấp thu tu vi linh khí.

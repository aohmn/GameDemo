# Equipment Module — ProjectGame

Module quản lý hệ thống trang bị, pháp bảo câu cá (cần câu, dây câu, mồi câu, bảo vật hỗ trợ) (`modules/equipment/`).
Chỉ phụ thuộc vào `core/` (EventBus và contracts), hoàn toàn độc lập với Fishing, Inventory, Economy hay Cultivation.

## Cấu trúc module
```
modules/equipment/
├── README.md
├── ROADMAP.md
├── api/
│   └── equipment_api.gd           # API công khai kết nối EventBus
├── logic/
│   └── equipment_logic.gd         # Logic quản lý slot, tính chỉ số, ConfigFile I/O
├── data/
│   └── equipment_item_spec.gd     # Resource script EquipmentItemSpec (phẩm cấp, vị trí, chỉ số)
└── scenes/
    ├── dev.gd                     # Scene dev độc lập
    └── dev.tscn
```

## 1. 5 Vị trí trang bị pháp bảo
- `rod`: Cần câu (pháp bảo chủ lực).
- `line`: Dây câu (pháp bảo chịu lực, độ bền).
- `bait`: Mồi câu (tăng tỷ lệ linh ngư, cảm nhận linh khí).
- `relic_1`: Bảo vật hỗ trợ 1 (phù văn, ngọc thạch).
- `relic_2`: Bảo vật hỗ trợ 2.

## 2. Phẩm cấp pháp bảo
Định nghĩa qua `enum ArtifactTier` trong `EquipmentItemSpec`:
- `PHAM` (0), `LINH` (1), `HUYEN` (2), `DIA` (3), `THIEN` (4), `THANH` (5), `TIEN` (6), `THAN` (7).

## 3. Thuộc tính & Chỉ số tổng hợp
- Lực kéo gia tăng (`pull_force_bonus`).
- Độ chịu lực / đứt dây (`max_tension_bonus`).
- Khống chế cá (`control_power_bonus`).
- Cảm nhận linh khí (`spirit_sensing`).
- Tỷ lệ cá hiếm (`rare_fish_rate_bonus`).
- Hiệu quả hấp thu tu vi (`qi_absorption_bonus`).
- Yêu cầu cảnh giới (`required_realm_level`).
- Hàm `calculate_total_stats() -> Dictionary`: Tính toán tổng hợp mọi chỉ số từ các pháp bảo đang trang bị.

## 4. Tương thích & Đồng bộ
- Đồng bộ cần câu sang `FishingAPI` thông qua `ServiceCoordinator` tại Bootstrap.
- Lưu trữ trạng thái trang bị vào `user://equipment.cfg`. Nếu file chưa tồn tại, tự động đọc tương thích từ `user://shop.cfg` để bảo lưu cần câu đang trang bị của người chơi.
- Không cho phép trang bị trùng lặp 1 vật phẩm vào nhiều vị trí.

## 5. Chạy thử độc lập
- Scene `scenes/dev.tscn` cung cấp giao diện trực quan độc lập để thử nghiệm trang bị cần trúc/carbon, tháo cần, lưu, tải và hiển thị log sự kiện.

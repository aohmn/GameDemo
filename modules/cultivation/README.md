# Cultivation Module — ProjectGame

Module quản lý hệ thống tu luyện, cảnh giới, tầng bậc và đột phá đại cảnh giới (`modules/cultivation/`).
Chỉ phụ thuộc vào `core/` (EventBus và contracts), hoàn toàn độc lập với Fishing, Inventory, Economy hay Shop.

## Cấu trúc module
```
modules/cultivation/
├── README.md
├── ROADMAP.md
├── api/
│   └── cultivation_api.gd         # API công khai kết nối EventBus
├── logic/
│   └── cultivation_logic.gd       # Quản lý cảnh giới, tích lũy tu vi, đột phá, ConfigFile I/O
├── data/
│   ├── realm_spec.gd              # Resource script RealmSpec
│   └── resources/
│       ├── realm_luyen_the.tres   # 1. Luyện Thể (9 tầng)
│       ├── realm_tu_khi.tres      # 2. Tụ Khí (9 tầng)
│       ├── realm_khai_mach.tres   # 3. Khai Mạch (9 tầng)
│       ├── realm_truc_co.tres     # 4. Trúc Cơ (9 tầng)
│       ├── realm_kim_dan.tres     # 5. Kim Đan (9 tầng)
│       ├── realm_nguyen_anh.tres  # 6. Nguyên Anh (9 tầng)
│       ├── realm_hoa_than.tres    # 7. Hóa Thần (9 tầng)
│       ├── realm_luyen_hu.tres    # 8. Luyện Hư (9 tầng)
│       ├── realm_hop_the.tres     # 9. Hợp Thể (9 tầng)
│       ├── realm_dai_thua.tres    # 10. Đại Thừa (9 tầng)
│       ├── realm_do_kiep.tres     # 11. Độ Kiếp (9 tầng)
│       └── realm_chan_tien.tres   # 12. Chân Tiên (9 tầng)
└── scenes/
    ├── dev.gd                     # Scene dev độc lập
    └── dev.tscn
```

## 1. 12 Đại Cảnh Giới
Mỗi cảnh giới gồm 9 tầng, định nghĩa bằng Resource `.tres` (`RealmSpec`):
- `realm_index`: Thứ tự cảnh giới từ 0 (Luyện Thể) đến 11 (Chân Tiên).
- `max_layer`: Số tầng (9).
- `layer_exp_requirements`: Mảng 9 phần tử lưu trữ ngưỡng tu vi cần thiết của từng tầng.
- `base_breakthrough_chance`: Tỷ lệ đột phá cơ sở.

## 2. Quản lý Tu Vi & Đột Phá
- **Tích lũy Tu Vi**:
  - `add_exp(amount: int, reason: String)`: Cộng dồn tu vi.
  - Tự động thăng tầng từ tầng 1 đến tầng 9 khi đủ tu vi yêu cầu của tầng.
  - Khi ở tầng 9, tu vi dừng lại ở mức viên mãn để chờ lệnh đột phá của người chơi.
- **Đột Phá Đại Cảnh Giới**:
  - `can_breakthrough() -> bool`: Kiểm tra điều kiện (phải đạt tầng 9 viên mãn và chưa phải cảnh giới tối cao).
  - `breakthrough() -> Dictionary`: Tiến hành đột phá lên cảnh giới kế tiếp, reset tầng về 1 và tu vi tầng về 0. Không làm mất tu vi nếu thất bại.

## 3. Kết Nối Câu Cá & Hấp Thu Linh Khí (TASK 04)
- **Độc lập kiến trúc**: `Cultivation` và `Fishing` không phụ thuộc trực tiếp vào nhau.
- **Dịch vụ điều phối**: `ServiceCoordinator` (`scenes/boot/service_coordinator.gd`) kết nối `InventoryAPI` và `CultivationAPI`:
  - `absorb_fish_qi(fish_id, count)`:
    - Kiểm tra số lượng cá hợp lệ trong túi đồ (`Inventory`).
    - Lấy chỉ số linh khí `spirit_qi` từ `FishSpec`.
    - Trừ cá khỏi `Inventory` -> Cộng tu vi `exp_gained = spirit_qi * count` vào `Cultivation`.
    - Lưu dữ liệu an toàn (`inventory.save()`, `cultivation.save()`).
    - Đảm bảo tính toàn vẹn: nếu thiếu cá hoặc tham số sai, hủy giao dịch và không làm mất cá hay tu vi.

## 4. Lưu trữ ConfigFile
- Đường dẫn: `user://cultivation.cfg`.
- Lưu trữ: `realm_index`, `layer`, `layer_exp`, `total_exp` và `version = 1`.
- Tự động kiểm tra giới hạn (`clampi`) khi tải dữ liệu để đảm bảo an toàn.

## 4. Chạy thử độc lập
- Scene `scenes/dev.tscn` cung cấp giao diện thử nghiệm độc lập: nạp tu vi (+100, +1000), nút Đột phá, Lưu/Tải file và màn hình log sự kiện.

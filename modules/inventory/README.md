# Inventory Module — ProjectGame

Module quản lý túi đồ và kho lưu trữ cá câu được (`modules/inventory/`).
Chỉ phụ thuộc vào `core/` (EventBus và contracts), hoàn toàn độc lập với Fishing module hay bất kỳ module gameplay nào khác.

## Cấu trúc module
```
modules/inventory/
├── README.md
├── ROADMAP.md
├── api/
│   └── inventory_api.gd           # API công khai kết nối EventBus
├── logic/
│   └── inventory_logic.gd         # Logic lưu trữ cá, tính tổng, ConfigFile I/O
└── scenes/
    ├── dev.gd                     # Điều khiển scene thử nghiệm độc lập
    └── dev.tscn                   # Scene dev giao diện kiểm tra
```

## 1. Lưu trữ cá câu được
- **Khóa (Key)**: `fish_id` (ví dụ: `fish_ca_com`, `fish_ca_mu`, ...).
- **Thuộc tính**:
  - `count`: Số lượng con đã câu được (số nguyên `int`).
  - `total_weight_g`: Tổng khối lượng cá thuộc loài này (gam, số nguyên `int`).
- Tính toán tổng quan:
  - `get_total_fish_count()`: Tổng số lượng mọi loài cá trong túi đồ.
  - `get_total_weight_g()`: Tổng khối lượng tất cả cá trong túi đồ.

## 2. Giao tiếp qua EventBus (Không phụ thuộc trực tiếp module khác)
- **Lắng nghe sự kiện**: `fishing_fish_caught` (`FishingEventsContract.FISH_CAUGHT`) từ `core/contracts/fishing_events.gd`.
  - Nhận payload `{ "fish_id": String, "weight_g": int, ... }` và tự động cộng dồn vào kho cá.
- **Phát sự kiện**:
  - `inventory_item_added`: Khi một con cá mới được đưa vào túi đồ.
  - `inventory_updated`: Khi toàn bộ túi đồ có sự thay đổi (thêm cá, xóa túi, tải dữ liệu).

## 3. Lưu và tải dữ liệu bằng ConfigFile
- Đường dẫn file lưu trữ: `user://inventory.cfg`.
- Định dạng INI/ConfigFile:
  - Section `[meta]`: Lưu `version = 1`.
  - Section `[items]`: Lưu theo cặp `fish_id_count` và `fish_id_weight`.

## 4. Chạy thử độc lập
- Scene `scenes/dev.tscn` cung cấp giao diện trực quan độc lập với các nút bấm giả lập sự kiện `FISH_CAUGHT`, nút Lưu file, Tải file, Xóa túi và màn hình hiển thị danh sách chi tiết kèm log sự kiện.

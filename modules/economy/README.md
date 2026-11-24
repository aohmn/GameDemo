# Economy Module — ProjectGame

Module quản lý kinh tế, số dư tiền tệ VND, bảng giá sinh vật biển và lịch sử giao dịch (`modules/economy/`).
Chỉ phụ thuộc vào `core/` (EventBus và contracts), hoàn toàn độc lập với `modules/inventory/` và `modules/fishing/`.

## Cấu trúc module
```
modules/economy/
├── README.md
├── ROADMAP.md
├── api/
│   └── economy_api.gd             # API công khai kết nối EventBus
├── logic/
│   └── economy_logic.gd           # Quản lý số dư VND, tính giá, lịch sử, ConfigFile I/O
├── data/
│   ├── fish_price_spec.gd         # Resource script FishPriceSpec
│   └── resources/
│       ├── price_ca_com.tres
│       ├── price_ca_doi.tres
│       ├── price_ca_chem.tres
│       ├── price_ca_mu.tres
│       ├── price_ca_thu.tres
│       └── price_ca_ngu_dai_duong.tres
└── scenes/
    ├── dev.gd                     # Điều khiển scene thử nghiệm độc lập
    └── dev.tscn                   # Scene dev giao diện kiểm tra
```

## 1. Quản lý số dư VND
- Đơn vị tiền tệ: **VND** (số nguyên `int`).
- Lưu trữ bằng ConfigFile tại `user://economy.cfg`:
  - Section `[wallet]`: Lưu `balance`.
  - Section `[history]`: Lưu lịch sử các giao dịch gần nhất.
  - Section `[meta]`: Lưu phiên bản lưu trữ `version = 1`.

## 2. Bảng giá (.tres)
- Dữ liệu giá được lưu bằng các tài nguyên có kiểu `FishPriceSpec` (`.tres`):
  - `fish_id`: Mã định danh loài cá.
  - `display_name`: Tên tiếng Việt có dấu.
  - `base_price`: Giá cơ bản mỗi con.
  - `price_per_kg`: Giá theo khối lượng (VND/kg).
- Công thức tính giá:
  `Giá = (base_price * số_lượng) + round((khối_lượng_gam / 1000.0) * price_per_kg)`

## 3. Giao dịch an toàn & Nguyên tắc độc lập
- Module Economy **không** import hay truy cập trực tiếp dữ liệu của module Inventory.
- Việc kết nối giao dịch bán cá được điều phối tại **Bootstrap** (`scenes/boot/main.gd`) theo mô hình atomic:
  - Kiểm tra điều kiện đủ số lượng cá trong kho.
  - Trừ cá từ Inventory.
  - Cộng tiền trong Economy và ghi lịch sử.
  - Nếu xảy ra lỗi ở bất kỳ bước nào -> Hoàn tác ngay lập tức.
- Phát sự kiện qua `EventBus`:
  - `economy_balance_changed`: Biến động số dư.
  - `economy_transaction_completed`: Giao dịch thành công.
  - `economy_transaction_failed`: Giao dịch thất bại kèm lý do.

## 4. Chạy thử độc lập
- Mở scene `modules/economy/scenes/dev.tscn` để thử nghiệm bán 1 phần, bán toàn bộ, chặn bán vượt số lượng và kiểm tra lưu/tải dữ liệu `user://economy.cfg`.

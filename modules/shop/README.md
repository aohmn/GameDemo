# Shop Module — ProjectGame

Module quản lý cửa hàng thiết bị, danh mục cần câu, mua bán trang bị và đồng bộ trang bị (`modules/shop/`).
Chỉ phụ thuộc vào `core/` (EventBus và contracts), hoàn toàn độc lập với `modules/economy/`, `modules/inventory/` và `modules/fishing/`.

## Cấu trúc module
```
modules/shop/
├── README.md
├── ROADMAP.md
├── api/
│   └── shop_api.gd                # API công khai kết nối EventBus
├── logic/
│   └── shop_logic.gd              # Quản lý danh mục, kiểm tra mua, trang bị, ConfigFile I/O
├── data/
│   ├── shop_item_spec.gd          # Resource script ShopItemSpec
│   └── resources/
│       ├── item_rod_truc_nhiem.tres
│       └── item_rod_carbon_bien_sau.tres
└── scenes/
    ├── dev.gd                     # Điều khiển scene thử nghiệm độc lập
    └── dev.tscn                   # Scene dev giao diện kiểm tra
```

## 1. Danh mục hàng hóa (.tres)
- Dữ liệu vật phẩm lưu bằng Resource có kiểu `ShopItemSpec`:
  - `id`: Mã định danh vật phẩm shop (vd: `shop_rod_truc_nhiem`, `shop_rod_carbon_bien_sau`).
  - `display_name`: Tên tiếng Việt có dấu.
  - `description`: Mô tả trang bị / pháp bảo.
  - `price_spirit_stone`: Giá bán bằng Linh Thạch (hạ phẩm).
  - `category`: Phân loại (`rod`, `equipment`, `bait`).
  - Chỉ số cần câu chuẩn xác tương ứng với hệ thống mô phỏng: `safe_tension_min`, `safe_tension_max`, `max_tension`, `reel_speed`, `release_speed`, `fatigue_rate`.

## 2. Quản lý mua và trang bị
- **Kiểm tra giao dịch mua**:
  - Không cho mua nếu số dư Linh Thạch từ Economy không đủ.
  - Chặn mua trùng nếu đã sở hữu vật phẩm (`already_owned`).
  - Khi mua thành công: tự động thêm vào danh sách sở hữu và phát sự kiện `ITEM_ADDED` để `Inventory` nhận vật phẩm.
- **Trang bị cần câu**:
  - Cho phép người chơi kích hoạt trang bị cần câu đã sở hữu qua `equip_rod()`.
  - Phát sự kiện `shop_rod_equipped` để Bootstrap đồng bộ sang `FishingAPI.set_default_rod()`.

## 3. Lưu trữ ConfigFile
- Lưu trữ danh sách vật phẩm đã sở hữu và ID cần câu đang trang bị tại `user://shop.cfg`.
- Mặc định người chơi luôn sở hữu cần câu khởi đầu `shop_rod_truc_nhiem`.

## 4. Giao dịch an toàn & Nguyên tắc độc lập
- Module Shop không phụ thuộc hay import trực tiếp module Economy, Inventory hay Fishing.
- Mọi giao dịch trừ tiền (Economy) và mua vật phẩm (Shop) được điều phối atomic tại **Bootstrap** (`scenes/boot/service_coordinator.gd`).
- Chạy thử riêng biệt qua `modules/shop/scenes/dev.tscn`.

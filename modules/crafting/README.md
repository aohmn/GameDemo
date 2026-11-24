# Crafting Module — ProjectGame

Module quản lý công thức chế tạo, rèn đúc pháp bảo và điều phối luyện chế vật phẩm (`modules/crafting/`).
Chỉ phụ thuộc vào `core/` (EventBus và contracts), hoàn toàn độc lập với Fishing, Inventory, Equipment hay Cultivation.

## Cấu trúc module
```
modules/crafting/
├── README.md
├── ROADMAP.md
├── api/
│   └── crafting_api.gd            # API công khai kết nối EventBus
├── logic/
│   └── crafting_logic.gd          # Quản lý công thức, hàng đợi, ConfigFile I/O
├── data/
│   ├── recipe_spec.gd             # Resource script RecipeSpec
│   └── resources/
│       ├── recipe_rod_truc_nhiem.tres       # Chế cần trúc (Phàm, tức thì)
│       └── recipe_rod_carbon_bien_sau.tres  # Rèn cần carbon (Linh, 2.0s)
└── scenes/
    ├── dev.gd                     # Scene dev độc lập
    └── dev.tscn
```

## 1. Dữ liệu công thức chế tạo (RecipeSpec)
- Dữ liệu định nghĩa bằng Resource `.tres` (`RecipeSpec`):
  - `id`: Mã công thức duy nhất.
  - `display_name`, `description`: Tên hiển thị và mô tả.
  - `category`: Nhóm chế tạo (`rod`, `line`, `bait`, `relic`, `material`, `consumable`).
  - `output_item_id`, `output_count`: Vật phẩm đầu ra và số lượng nhận được.
  - `ingredients`: Danh sách nguyên liệu tiêu hao (`item_id` và `count`).
  - `required_realm_level`: Cảnh giới yêu cầu (0: Luyện Thể, 1: Tụ Khí...).
  - `craft_duration`: Thời gian chế tạo (giây, 0.0 là tức thì).

## 2. Quy trình chế tạo an toàn (Atomic Transaction)
- Thực thi thông qua `ServiceCoordinator.execute_craft(recipe_id)`:
  1. Kiểm tra công thức mở khóa và cảnh giới từ `CultivationAPI`.
  2. Kiểm tra đủ nguyên liệu trong `InventoryAPI`.
  3. Trừ nguyên liệu với cơ chế rollback: nếu xảy ra lỗi bất kỳ ở các bước sau, tự động hoàn trả đầy đủ 100% nguyên liệu vào kho đồ.
  4. Nhận thành phẩm và lưu trữ an toàn.

## 3. Lưu trữ ConfigFile
- Đường dẫn: `user://crafting.cfg`.
- Section `[unlocked_recipes]`: Lưu trạng thái các công thức đã mở khóa.

## 4. Chạy thử độc lập
- Scene `scenes/dev.tscn` cung cấp giao diện trực quan độc lập để thử nghiệm chế tạo tức thì, chế tạo theo thời gian, hủy chế tạo và xem cập nhật log sự kiện thời gian thực.

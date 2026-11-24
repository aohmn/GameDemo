# Inventory Module — ProjectGame

Module quản lý kho đồ đa năng và lưu trữ cá / vật phẩm tu tiên (`modules/inventory/`).
Chỉ phụ thuộc vào `core/` (EventBus và contracts), hoàn toàn độc lập với Fishing, Economy, Shop hay Cultivation.

## Cấu trúc module
```
modules/inventory/
├── README.md
├── ROADMAP.md
├── api/
│   └── inventory_api.gd           # API công khai kết nối EventBus
├── logic/
│   └── inventory_logic.gd         # Logic kho đồ đa năng, xếp chồng, ConfigFile I/O
├── data/
│   └── item_spec.gd               # Resource script ItemSpec (phẩm cấp, phân nhóm)
└── scenes/
    ├── dev.gd                     # Điều khiển scene thử nghiệm độc lập
    └── dev.tscn                   # Scene dev giao diện kiểm tra
```

## 1. Phân loại & Phẩm cấp vật phẩm
- **Resource ItemSpec** (`modules/inventory/data/item_spec.gd`):
  - Phân loại (`ItemCategory`): `CA` (0), `NGUYEN_LIEU` (1), `PHAP_BAO` (2), `TIEU_HAO` (3), `KHAC` (4).
  - Phẩm cấp (`ItemTier`): `PHAM` (0), `LINH` (1), `HUYEN` (2), `DIA` (3), `THIEN` (4), `THANH` (5).
  - Đặc tính: `is_stackable` (xếp chồng), `max_stack_size` (giới hạn chồng, mặc định 999), `base_value` (giá trị cơ sở Linh Thạch).

## 2. Quản lý kho đồ & Thao tác API
- **Thêm / Lấy vật phẩm**:
  - `add_item(item_id, count, weight_g, category, tier, is_stackable, max_stack) -> bool`: Thêm vật phẩm đa năng, kiểm tra giới hạn ô chứa (`max_slots = 100`) và giới hạn xếp chồng.
  - `add_fish(fish_id, weight_g)`: Wrapper tương thích ngược cho hệ thống câu cá (tự động phân loại `CA`).
  - `remove_item(item_id, count) -> Dictionary`: Trừ số lượng vật phẩm.
  - `remove_fish(fish_id, count) -> Dictionary`: Trừ cá và khối lượng tương ứng (phục vụ bán cá / hấp thu).
  - `restore_fish(fish_id, count, weight_g) -> bool`: Khôi phục cá khi rollback giao dịch thất bại.
- **Truy vấn & Lọc**:
  - `has_item(item_id, min_count) -> bool`: Kiểm tra tồn tại và số lượng.
  - `get_item_count(item_id) -> int`: Số lượng vật phẩm trong kho.
  - `get_items_by_category(category) -> Dictionary`: Lọc vật phẩm theo nhóm.
  - `get_fish_info(fish_id) -> Dictionary`: Thông tin số lượng & khối lượng cá.
  - `get_total_fish_count()`, `get_total_weight_g()`: Tổng số lượng và khối lượng cá (giữ tương thích 100% với UI và ServiceCoordinator).

## 3. Giao tiếp qua EventBus (Không phụ thuộc trực tiếp module khác)
- **Lắng nghe sự kiện**: `fishing_fish_caught` (`FishingEventsContract.FISH_CAUGHT`) tự động thêm cá vào kho.
- **Phát sự kiện**:
  - `inventory_item_added`: Khi vật phẩm/cá mới được đưa vào kho.
  - `inventory_item_removed`: Khi vật phẩm bị lấy ra khỏi kho.
  - `inventory_updated`: Khi toàn bộ kho đồ có thay đổi.

## 4. Lưu và tải dữ liệu bằng ConfigFile
- Đường dẫn file: `user://inventory.cfg`.
- Phiên bản: `version = 2` (tự động nhận diện và đọc tương thích với cấu trúc version 1 cũ).

## 5. Chạy thử độc lập
- Scene `scenes/dev.tscn` cung cấp giao diện trực quan độc lập với các nút bấm thử nghiệm thêm/xóa/lưu/tải kho.

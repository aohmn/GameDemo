class_name ItemSpec
extends Resource

## Resource định nghĩa vật phẩm chuẩn hóa trong thế giới tu tiên (modules/inventory/).

# 1. Phân loại nhóm vật phẩm:
# - CA: Cá / linh ngư các phẩm cấp
# - NGUYEN_LIEU: Linh thảo, khoáng thạch, linh tài
# - PHAP_BAO: Cần câu, dây câu, phao, bảo vật
# - TIEU_HAO: Đan dược, phù chú, mồi câu
# - KHAC: Vật phẩm nhiệm vụ, lệnh bài, đồ đặc biệt
enum ItemCategory {
	CA = 0,
	NGUYEN_LIEU = 1,
	PHAP_BAO = 2,
	TIEU_HAO = 3,
	KHAC = 4,
}

# 2. Phẩm cấp vật phẩm:
# 0: Phàm, 1: Linh, 2: Huyền / Yêu, 3: Địa / Tiên, 4: Thiên / Thần, 5: Thánh / Thái Cổ
enum ItemTier {
	PHAM = 0,
	LINH = 1,
	HUYEN = 2,
	DIA = 3,
	THIEN = 4,
	THANH = 5,
}

# 3. Thuộc tính định danh & Hiển thị
@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var category: ItemCategory = ItemCategory.CA
@export var tier: ItemTier = ItemTier.PHAM

# 4. Thuộc tính kinh tế & Xếp chồng
@export var base_value: int = 0               # Giá trị giao dịch cơ sở bằng Linh Thạch
@export var is_stackable: bool = true         # Có thể xếp chồng hay không
@export var max_stack_size: int = 999         # Giới hạn số lượng trong một ô xếp chồng

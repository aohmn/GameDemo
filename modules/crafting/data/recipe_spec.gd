class_name RecipeSpec
extends Resource

## Resource định nghĩa công thức chế tạo vật phẩm / pháp bảo tu tiên (modules/crafting/).

# 1. Định danh & Hiển thị
@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var category: String = "rod" # rod, line, bait, relic, material, consumable

# 2. Đầu ra thành phẩm
@export var output_item_id: String = ""
@export var output_count: int = 1

# 3. Yêu cầu nguyên liệu (Array[Dictionary]):
# Mỗi phần tử gồm:
# - "item_id": String (Mã vật phẩm nguyên liệu trong Inventory)
# - "count": int (Số lượng cần tiêu hao)
@export var ingredients: Array[Dictionary] = []

# 4. Điều kiện chế tạo & Thời gian
@export var required_realm_level: int = 0      # Cảnh giới yêu cầu (0: Luyện Thể)
@export var is_unlocked_by_default: bool = true # Mở khóa mặc định hay cần bí kíp
@export var craft_duration: float = 0.0        # Thời gian chế tạo (giây, 0.0 là tức thì)

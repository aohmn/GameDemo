class_name SpotSpec
extends Resource

## Định nghĩa thông số của một điểm câu / vùng nước câu cá tu tiên.

# 1. Định danh & Hiển thị
@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""

# 2. Vùng nước & Phân loại môi trường
@export var water_type: String = "bien"        # Loại vùng nước: bien, song, ho, linh_tuyen, dam_lay, han_dam
@export var danger_level: int = 0             # Cấp độ nguy hiểm của vùng nước (0: An toàn)
@export var required_realm_level: int = 0     # Cảnh giới tối thiểu để vào câu (0: Luyện Thể)

# 3. Điều kiện thời gian & Thiên tượng
@export var min_wait_time: float = 2.0
@export var max_wait_time: float = 5.0
@export var time_condition: String = "tat_ca"  # tat_ca, ngay, dem, hoang_hon, binh_minh
@export var weather_condition: String = "tat_ca" # tat_ca, nang, mua, sam_set, linh_trieu, nhat_thuc

# 4. Bảng cá theo tỷ lệ xuất hiện (Array[Dictionary]):
# Key quy chuẩn:
# - "fish": FishSpec (Resource)
# - "weight": int (tỷ trọng ngẫu nhiên)
@export var fish_table: Array[Dictionary] = []

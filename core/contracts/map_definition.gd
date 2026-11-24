class_name MapDefinition
extends Resource

## Resource định nghĩa cấu hình và thông số đặc tính của một bản đồ câu cá tu tiên.

# 1. Định danh & Hiển thị
@export var map_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var scene_path: String = ""                 # Đường dẫn file scene map.tscn
@export var default_spawn_position: Vector3 = Vector3(-2.0, 0.05, 10.0)

# 2. Điều kiện mở khóa & Tu vi
@export var is_unlocked_by_default: bool = true
@export var required_realm_level: int = 0           # Cảnh giới tu vi yêu cầu (0: Luyện Thể)

# 3. Môi trường & Đặc trưng tu tiên
@export var water_type: String = "bien"             # bien, song, ho, linh_tuyen, dam_lay...
@export var spiritual_energy_density: float = 1.0   # Nồng độ linh khí của bản đồ (ảnh hưởng câu cá)
@export var danger_level: int = 0                   # Cấp độ nguy hiểm

# 4. Các tuyến kết nối sang bản đồ khác (Array[MapConnection])
@export var connections: Array[Resource] = []

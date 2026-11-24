class_name MapConnection
extends Resource

## Định nghĩa liên kết / lối đi giữa 2 bản đồ (cổng truyền tống, bến đò, tiên thuyền...).

@export var target_map_id: String = ""              # ID bản đồ đích đến
@export var display_name: String = ""               # Tên tuyến hành trình hiển thị
@export var spawn_position: Vector3 = Vector3.ZERO  # Tọa độ xuất hiện tại bản đồ đích
@export var required_realm_level: int = 0           # Cảnh giới tối thiểu để đi qua (0: Luyện Thể)
@export var fee_spirit_stone: int = 0               # Phí di chuyển bằng Linh Thạch
@export var is_unlocked: bool = true                # Trạng thái mở khóa của tuyến kết nối

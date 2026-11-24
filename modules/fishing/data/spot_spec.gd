class_name SpotSpec
extends Resource

## Định nghĩa thông số của một điểm câu cá.

@export var id: String = ""
@export var display_name: String = ""
@export var min_wait_time: float = 2.0
@export var max_wait_time: float = 5.0

# Bảng cá theo tỷ lệ xuất hiện: Array[Dictionary] với các key:
# "fish": FishSpec, "weight": int
@export var fish_table: Array[Dictionary] = []

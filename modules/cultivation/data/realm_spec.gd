class_name RealmSpec
extends Resource

## Định nghĩa thông số đặc tính của một đại cảnh giới tu tiên.

@export var realm_index: int = 0                  # Chỉ số thứ tự cảnh giới (0 đến 11)
@export var id: String = ""                       # ID định danh: realm_luyen_the, realm_tu_khi...
@export var display_name: String = ""             # Tên hiển thị tiếng Việt có dấu
@export var description: String = ""              # Mô tả cảnh giới
@export var max_layer: int = 9                    # Số tầng trong cảnh giới (chuẩn 9 tầng)

## Ngưỡng tu vi cần tích lũy để đột phá qua từng tầng (mảng 9 phần tử, ứng với tầng 1->9)
## Giá trị này là tu vi cần nạp trong tầng hiện tại để lên tầng kế tiếp (hoặc chạm ngưỡng đột phá ở tầng 9)
@export var layer_exp_requirements: Array[int] = [
	100, 150, 220, 320, 460, 650, 900, 1250, 1700
]

## Tỷ lệ đột phá cơ bản lên cảnh giới kế tiếp (0.0 đến 1.0)
@export var base_breakthrough_chance: float = 1.0

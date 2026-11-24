class_name FishSpec
extends Resource

## Định nghĩa thông số đặc tính của một loài cá.

@export var id: String = ""
@export var display_name: String = ""
@export var min_weight_g: int = 100
@export var max_weight_g: int = 500
@export var strength: float = 30.0 # Sức khỏe của cá trong giằng co (0 về 0 thì bắt được)
@export var rarity: int = 1 # 1: Phổ biến, 2: Hiếm, 3: Rất hiếm, 4: Huyền thoại
@export var pull_force: float = 18.0 # Lực cá kéo làm tăng line_tension khi giãy

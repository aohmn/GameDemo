class_name RodSpec
extends Resource

## Định nghĩa thông số của cần câu và dây cước.

@export var id: String = ""
@export var display_name: String = ""
@export var safe_tension_min: float = 30.0 # Ngưỡng lực căng tối thiểu của vùng an toàn
@export var safe_tension_max: float = 70.0 # Ngưỡng lực căng tối đa của vùng an toàn
@export var max_tension: float = 100.0     # Ngưỡng đứt dây nếu vượt qua
@export var reel_speed: float = 35.0      # Tốc độ kéo dây tăng tension
@export var release_speed: float = 25.0   # Tốc độ xả dây giảm tension
@export var fatigue_rate: float = 12.0    # Tốc độ bào mòn sức cá mỗi giây khi tension ở vùng an toàn

class_name RodSpec
extends Resource

## Định nghĩa thông số của cần câu / pháp bảo câu cá trong thế giới tu tiên.

# 1. Định danh & Hiển thị
@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""

# 2. Phẩm cấp pháp bảo:
# 0: Phàm, 1: Linh, 2: Huyền, 3: Địa, 4: Thiên, 5: Thánh, 6: Tiên, 7: Thần
enum ArtifactTier {
	PHAM = 0,
	LINH = 1,
	HUYEN = 2,
	DIA = 3,
	THIEN = 4,
	THANH = 5,
	TIEN = 6,
	THAN = 7,
}
@export var tier: ArtifactTier = ArtifactTier.PHAM

# 3. Độ bền & Điều kiện tu vi
@export var max_durability: int = 100          # Độ bền tối đa
@export var current_durability: int = 100      # Độ bền hiện tại
@export var required_realm_level: int = 0      # Cấp cảnh giới yêu cầu để sử dụng (0: Luyện Thể)

# 4. Cơ chế lực kéo & Điều khiển (tương thích gameplay)
@export var safe_tension_min: float = 30.0     # Ngưỡng lực căng tối thiểu của vùng an toàn
@export var safe_tension_max: float = 70.0     # Ngưỡng lực căng tối đa của vùng an toàn
@export var max_tension: float = 100.0         # Ngưỡng đứt dây / vỡ pháp bảo nếu vượt qua
@export var reel_speed: float = 35.0          # Tốc độ kéo dây tăng tension
@export var release_speed: float = 25.0       # Tốc độ xả dây giảm tension
@export var fatigue_rate: float = 12.0        # Tốc độ bào mòn sức cá mỗi giây khi tension ở vùng an toàn
@export var control_power: float = 1.0        # Hệ số hỗ trợ kiểm soát, giảm rung lắc của dây

# 5. Thuộc tính pháp bảo đặc biệt
@export var special_effect: String = ""       # Hiệu ứng đặc biệt (ví dụ: ngự_lực, định_thủy, hấp_linh)

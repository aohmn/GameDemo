class_name EquipmentItemSpec
extends Resource

## Resource định nghĩa thuộc tính và chỉ số của pháp bảo trang bị (modules/equipment/).

# 1. Phẩm cấp pháp bảo tu tiên:
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

# 2. Vị trí trang bị:
# rod: Cần câu, line: Dây câu, bait: Mồi câu, relic_1: Bảo vật 1, relic_2: Bảo vật 2
@export var slot_type: String = "rod"

# 3. Định danh & Phẩm cấp
@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var tier: ArtifactTier = ArtifactTier.PHAM
@export var required_realm_level: int = 0      # Cảnh giới yêu cầu (0: Luyện Thể)

# 4. Thuộc tính & Chỉ số trang bị
@export var pull_force_bonus: float = 0.0      # Lực kéo gia tăng
@export var max_tension_bonus: float = 0.0     # Độ chịu lực / ngưỡng đứt dây gia tăng
@export var durability: int = 100              # Độ bền tối đa
@export var control_power_bonus: float = 0.0   # Khả năng khống chế cá / giảm rung giật
@export var spirit_sensing: float = 0.0        # Cảm nhận linh khí (giúp phát hiện cá)
@export var rare_fish_rate_bonus: float = 0.0  # Tỷ lệ phát hiện cá hiếm tăng thêm (%)
@export var qi_absorption_bonus: float = 0.0   # Hiệu quả hấp thu linh khí (%)
@export var fatigue_rate_bonus: float = 0.0    # Tốc độ bào mòn sức cá gia tăng

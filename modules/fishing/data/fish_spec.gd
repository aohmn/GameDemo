class_name FishSpec
extends Resource

## Định nghĩa thông số đặc tính của một loài cá / linh ngư trong thế giới tu tiên.

# 1. Định danh & Hiển thị
@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""

# 2. Phẩm cấp linh ngư:
# 0: Phàm ngư, 1: Linh ngư, 2: Yêu ngư, 3: Tiên ngư, 4: Thần ngư, 5: Thái Cổ
enum FishTier {
	PHAM_NGU = 0,
	LINH_NGU = 1,
	YEU_NGU = 2,
	TIEN_NGU = 3,
	THAN_NGU = 4,
	THAI_CO = 5,
}
@export var tier: FishTier = FishTier.PHAM_NGU

# 3. Thuộc tính tu tiên & Kinh tế
@export var spirit_qi: int = 0             # Linh khí người chơi nhận được khi thu phục/hấp thu
@export var base_value: int = 0            # Giá trị trao đổi cơ bản (linh thạch)
@export var element: String = "thuy"       # Thuộc tính nguyên tố: kim, moc, thuy, hoa, tho, phong, loi, quang, am

# 4. Đặc tính thể chất & Gameplay câu cá (tương thích hiện tại)
@export var min_weight_g: int = 100
@export var max_weight_g: int = 500
@export var strength: float = 30.0         # Sức bền của cá trong giằng co (về 0 thì bắt được)
@export var rarity: int = 1                # 1: Phổ biến, 2: Hiếm, 3: Rất hiếm, 4: Huyền thoại
@export var pull_force: float = 18.0       # Lực cá kéo làm tăng line_tension khi giãy

# 5. Điều kiện môi trường & Thiên tượng (mở rộng)
@export var habitat_water_type: String = "bien" # Vùng nước: bien, song, ho, dam_lay, han_bang, linh_tuyen
@export var weather_condition: String = "tat_ca" # Thoi tiet: tat_ca, mua, gio, bao, linh_trieu, trang_tron

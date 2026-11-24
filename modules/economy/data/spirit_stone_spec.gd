class_name SpiritStoneSpec
extends Resource

## Định nghĩa phẩm cấp và thông số của Linh Thạch trong thế giới tu tiên.

enum StoneTier {
	HA_PHAM = 0,     # Hạ phẩm linh thạch (đơn vị giao dịch phổ thông cơ sở)
	TRUNG_PHAM = 1,  # Trung phẩm linh thạch
	THUONG_PHAM = 2, # Thượng phẩm linh thạch
	CUC_PHAM = 3,    # Cực phẩm linh thạch
}

@export var tier: StoneTier = StoneTier.HA_PHAM
@export var id: String = "spirit_stone_ha_pham"
@export var display_name: String = "Hạ Phẩm Linh Thạch"
@export var description: String = "Linh thạch hạ phẩm chứa đựng linh khí thiên địa tinh thuần, là tiền tệ giao thương phổ biến nhất giới tu chân."

## BuildingSpec: Đặc tả công trình/nhà trong MapLayout.
extends Resource
class_name BuildingSpec

@export var id: String = ""
@export var type: String = "residential"
@export var lot_id: String = ""
@export var floors: int = 1
@export var color: Color = Color(0.8, 0.8, 0.8)
@export var sign_text: String = ""
## Điểm cửa nằm ngoài tường, trên vỉa hè.
@export var door_point: Vector3 = Vector3.ZERO

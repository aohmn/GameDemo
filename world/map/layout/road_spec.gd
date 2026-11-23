## RoadSpec: Đặc tả đoạn đường trong MapLayout.
extends Resource
class_name RoadSpec

@export var id: String = ""
## Loại đường: "main" (phố chính), "alley" (hẻm), "plaza" (quảng trường).
@export var kind: String = "main"
@export var start_point: Vector2 = Vector2.ZERO
@export var end_point: Vector2 = Vector2.ZERO
@export var width: float = 7.0

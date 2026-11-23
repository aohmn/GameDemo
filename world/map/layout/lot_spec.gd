## LotSpec: Đặc tả lô đất trong MapLayout.
extends Resource
class_name LotSpec

@export var id: String = ""
@export var rect: Rect2 = Rect2()
## Hướng mặt tiền tiếp giáp đường: "north", "south", "east", "west".
@export var facing: String = "east"

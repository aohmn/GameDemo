## DestinationData: điểm đến khi chuyển map. Thêm điểm đến = thêm file .tres.
extends Resource
class_name DestinationData

@export var id: String = ""
@export var display_name: String = ""
@export var scene_path: String = ""
@export var spawn_id: String = ""
@export var unlocked: bool = true
## CHUA dung — dat san cho tuong lai
@export_range(0, 2147483647, 1) var travel_cost_vnd: int = 0
## CHUA dung — dat san cho tuong lai
@export_range(0, 1440, 1) var travel_minutes: int = 0

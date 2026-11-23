extends Resource
class_name NPCProfile

@export var npc_id: String = "npc"
@export var display_name: String = "Người dân"
@export_range(1, 120, 1) var age: int = 25
@export var occupation: String = "Người dân"
@export var personality: String = "Thân thiện"
@export var home_building_id: String = ""
@export var workplace_building_id: String = ""
@export var shop_building_id: String = ""
@export_range(0, 2147483647, 1) var cash_vnd: int = 50000

extends Resource
class_name NPCProfile

@export var npc_id: String = "npc"
@export var display_name: String = "Người dân"
@export_range(1, 120, 1) var age: int = 25
@export var occupation: String = "Người dân"
@export var personality: String = "Thân thiện"
@export var home_position: Vector3 = Vector3.ZERO
@export var workplace_position: Vector3 = Vector3.ZERO
@export var shop_position: Vector3 = Vector3.ZERO
@export_range(0, 2147483647, 1) var cash_vnd: int = 50000

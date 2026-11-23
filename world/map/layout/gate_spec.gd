## GateSpec: Đặc tả cổng chuyển map trong MapLayout.
extends Resource
class_name GateSpec

@export var id: String = ""
@export var name: String = ""
@export var position: Vector3 = Vector3.ZERO
@export var size: Vector3 = Vector3(5.0, 3.0, 5.0)
@export var sign_text: String = ""
@export var dest_scene: String = ""
@export var dest_spawn: String = ""

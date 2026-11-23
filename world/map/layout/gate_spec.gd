## GateSpec: Dac ta cong chuyen map trong MapLayout.
extends Resource
class_name GateSpec

@export var id: String = ""
@export var name: String = ""
@export var position: Vector3 = Vector3.ZERO
@export var size: Vector3 = Vector3(5.0, 3.0, 5.0)
@export var sign_text: String = ""
## Ho tro N diem den: moi id tuong ung voi mot file DestinationData .tres
## (world/map/data/dest_<id>.tres). Khi danh sach co 1 phan tu, hien 1 hang.
@export var destination_ids: Array[String] = []
## Giu lai de tuong thich nguoc voi cac map chua co destination_ids
@export var dest_scene: String = ""
@export var dest_spawn: String = ""

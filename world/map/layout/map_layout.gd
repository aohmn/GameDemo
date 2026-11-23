## MapLayout: Bố cục tổng thể của một bản đồ.
extends Resource
class_name MapLayout

@export var bounds: Rect2 = Rect2(-55, -60, 110, 120)
@export var roads: Array[RoadSpec] = []
@export var lots: Array[LotSpec] = []
@export var buildings: Array[BuildingSpec] = []
@export var gates: Array[GateSpec] = []

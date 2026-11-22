## FishingLakeMapArea — Hồ câu: nội dung hồ cá, bến câu, cây quanh hồ,
## lối chuyển về bản đồ trung tâm. Hồ câu không có đường vỉa hè.
extends MapArea
class_name FishingLakeMapArea

## Nền hồ câu — tái sử dụng từ map_controller (cũ).
const LAKE_GROUND_SPECS: Array[Dictionary] = [
	{
		"name": "GroundNorth",
		"size": Vector3(100.0, 0.5, 31.0),
		"position": Vector3(0.0, -0.25, -34.5),
		"color": Color(0.29, 0.48, 0.23),
	},
	{
		"name": "GroundSouth",
		"size": Vector3(100.0, 0.5, 43.0),
		"position": Vector3(0.0, -0.25, 28.5),
		"color": Color(0.29, 0.48, 0.23),
	},
	{
		"name": "GroundWest",
		"size": Vector3(34.0, 0.5, 100.0),
		"position": Vector3(-33.0, -0.25, 0.0),
		"color": Color(0.29, 0.48, 0.23),
	},
	{
		"name": "GroundEast",
		"size": Vector3(34.0, 0.5, 100.0),
		"position": Vector3(33.0, -0.25, 0.0),
		"color": Color(0.29, 0.48, 0.23),
	},
]


func get_entry_point() -> Vector3:
	return Vector3(0.0, 0.05, 22.0)


func get_spawn_points() -> Dictionary:
	return {
		"lake_entry": Vector3(0.0, 0.05, 22.0),
		"from_hub": Vector3(0.0, 0.05, 37.5),
	}


func build_content() -> void:
	GroundBuilder.build(LAKE_GROUND_SPECS, self)
	ObjectBuilder.build_fishing_lake(self)
	TransitionBuilder.build([
		{
			"name": "ToHub",
			"position": Vector3(0.0, 1.0, 43.0),
			"size": Vector3(5.0, 3.0, 5.0),
			"sign_text": "Khu dân cư",
			"dest_scene": "res://world/map/scenes/hub_map.tscn",
			"dest_spawn": "from_lake",
		},
	], self, Callable(self, "_on_transition_entered"))

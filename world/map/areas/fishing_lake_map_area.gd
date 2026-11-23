## FishingLakeMapArea — Ho cau: noi dung ho ca, ben cau, cay quanh ho,
## loi chuyen ve ban do trung tam. Ho cau khong co duong via he.
extends MapArea
class_name FishingLakeMapArea

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
			"gate_id": "gate_to_hub",
			"name": "ToHub",
			"position": Vector3(0.0, 1.0, 43.0),
			"size": Vector3(5.0, 3.0, 5.0),
			"sign_text": "Khu Dan Cu",
			"destinations": [
				{
					"id": "dest_khu_dan_cu",
					"display_name": "Khu Dan Cu",
					"scene_path": "res://world/map/scenes/hub_map.tscn",
					"spawn_id": "from_lake",
					"unlocked": true,
				}
			],
		},
	], self)

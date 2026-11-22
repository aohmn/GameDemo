## HubMapArea — bản đồ trung tâm (khu dân cư), 40×40m.
## Chỉ: nền + đường chính + đường dọc (RoadSpine) + lối chuyển sang Hồ câu.
## Không có nhà, cây hay công trình khác.
extends MapArea
class_name HubMapArea


func get_entry_point() -> Vector3:
	return Vector3(0.0, 0.05, -8.0)


func get_spawn_points() -> Dictionary:
	return {"hub_entry": Vector3(0.0, 0.05, -8.0)}


func get_road_points() -> Array[Vector2]:
	return [
		Vector2(0.0, -10.25), Vector2(0.0, -7.75),
		Vector2(0.0, -8.0), Vector2(0.0, 2.0),
		Vector2(0.0, 12.0), Vector2(0.0, 18.0),
	]


func build_content() -> void:
	GroundBuilder.build([
		{
			"name": "HubGround",
			"size": Vector3(40.0, 0.5, 40.0),
			"position": Vector3(0.0, -0.25, 0.0),
			"color": Color(0.6, 0.58, 0.5),
		}
	], self)

	RoadBuilder.build([
		{
			"name": "RoadMain",
			"size": Vector3(36.0, 0.10, 2.5),
			"position": Vector3(0.0, -0.05, -9.0),
			"color": Color(0.2, 0.19, 0.18),
		},
		{
			"name": "RoadSpine",
			"size": Vector3(2.5, 0.10, 26.0),
			"position": Vector3(0.0, -0.05, 5.0),
			"color": Color(0.2, 0.19, 0.18),
		},
	], self)

	TransitionBuilder.build([
		{
			"name": "ToLake",
			"position": Vector3(0.0, 1.0, 4.0),
			"size": Vector3(5.0, 3.0, 5.0),
			"sign_text": "Hồ câu",
			"dest_scene": "res://world/map/scenes/fishing_lake_map.tscn",
		},
	], self, Callable(self, "_on_transition_entered"))

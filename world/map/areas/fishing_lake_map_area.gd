## FishingLakeMapArea — Hồ câu: nội dung hồ cá, bến câu, cây quanh hồ,
## lối chuyển về bản đồ trung tâm. Hồ câu không có đường vỉa hè.
extends MapArea
class_name FishingLakeMapArea


func get_entry_point() -> Vector3:
	return Vector3(0.0, 0.05, 22.0)


func get_spawn_points() -> Dictionary:
	return {"lake_entry": Vector3(0.0, 0.05, 22.0)}


func build_content() -> void:
	ObjectBuilder.build_fishing_lake(self)
	TransitionBuilder.build([
		{
			"name": "ToHub",
			"position": Vector3(0.0, 1.0, 43.0),
			"size": Vector3(5.0, 3.0, 5.0),
			"sign_text": "Khu dân cư",
			"dest_scene": "res://world/map/scenes/hub_map.tscn",
		},
	], self, Callable(self, "_on_transition_entered"))

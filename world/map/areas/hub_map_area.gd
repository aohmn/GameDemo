## HubMapArea — bản đồ trung tâm (khu dân cư), kích thước ~110m (x) x 120m (z).
## Bố cục kiểu PHỐ CHÍNH + HẺM CỤT, dựng hoàn toàn dựa trên dữ liệu MapLayout.
## Cung cấp: map_bounds, get_road_points(), get_buildings() (id -> door_point).
extends MapArea
class_name HubMapArea

const HUB_LAYOUT_PATH: String = "res://world/map/data/hub_layout.tres"

var _layout_res: MapLayout = null


func _get_layout() -> MapLayout:
	if _layout_res == null:
		var res: Resource = load(HUB_LAYOUT_PATH)
		if res is MapLayout:
			_layout_res = res
	return _layout_res


func _init() -> void:
	var layout := _get_layout()
	if layout != null:
		map_bounds = layout.bounds
	else:
		map_bounds = Rect2(-55.0, -60.0, 110.0, 120.0)


func get_entry_point() -> Vector3:
	return Vector3(0.0, 0.08, -8.0)


func get_spawn_points() -> Dictionary:
	return {
		"hub_entry": Vector3(0.0, 0.08, -8.0),
		"from_lake": Vector3(0.0, 0.08, 41.0),
	}


func get_road_points() -> Array[Vector2]:
	# Đồ thị waypoints dẫn đường theo phố chính và 3 nhánh hẻm
	return [
		# Phố chính (z từ -45 đến 45)
		Vector2(0.0, -45.0),
		Vector2(0.0, -30.0),
		Vector2(0.0, -15.0),
		Vector2(0.0, 0.0),
		Vector2(0.0, 15.0),
		Vector2(0.0, 30.0),
		Vector2(0.0, 45.0),
		# Hẻm 1 (z = -30, rẽ tây x < 0)
		Vector2(-10.0, -30.0),
		Vector2(-20.0, -30.0),
		Vector2(-27.0, -30.0),
		# Hẻm 2 (z = 0, rẽ đông x > 0)
		Vector2(10.0, 0.0),
		Vector2(20.0, 0.0),
		Vector2(27.0, 0.0),
		# Hẻm 3 (z = 30, rẽ tây x < 0)
		Vector2(-10.0, 30.0),
		Vector2(-20.0, 30.0),
		Vector2(-27.0, 30.0),
	]


func get_buildings() -> Dictionary:
	var result: Dictionary = {}
	var layout := _get_layout()
	if layout != null:
		var lots_dict: Dictionary = {}
		for lot: LotSpec in layout.lots:
			lots_dict[lot.id] = lot
		for building: BuildingSpec in layout.buildings:
			var lot: LotSpec = lots_dict.get(building.lot_id, null)
			var bld_pos := building.door_point
			var bld_size := Vector2(8.0, 8.0)
			if lot != null:
				bld_pos = Vector3(lot.rect.position.x + lot.rect.size.x * 0.5, 0.12, lot.rect.position.y + lot.rect.size.y * 0.5)
				bld_size = lot.rect.size
			result[building.id] = {
				"door_point": building.door_point,
				"type": building.type,
				"sign_text": building.sign_text,
				"position": bld_pos,
				"size": bld_size,
			}
	return result


func build_content() -> void:
	var layout := _get_layout()
	if layout == null:
		push_error("[HubMapArea] Thiếu dữ liệu hub_layout.tres!")
		return

	map_bounds = layout.bounds

	# 1. Dựng nền, lòng đường, vỉa hè, gờ lề và vạch kẻ từ MapLayout
	RoadBuilder.build_from_layout(layout, self)

	# 2. Dựng các tòa nhà kiến trúc chức năng từ MapLayout
	BuildingBuilder.build_from_layout(layout, self)

	# 3. Dung cong chuyen map tu layout.gates
	for gate: GateSpec in layout.gates:
		var gate_spec: Array[Dictionary] = [_gate_to_spec(gate)]
		TransitionBuilder.build(gate_spec, self)


## Chuyen GateSpec thanh spec Dictionary cho TransitionBuilder.
## Tai DestinationData tu file .tres tuong ung voi moi destination_id.
func _gate_to_spec(gate: GateSpec) -> Dictionary:
	var destinations: Array[Dictionary] = []
	for dest_id: String in gate.destination_ids:
		var path: String = "res://world/map/data/" + dest_id + ".tres"
		if ResourceLoader.exists(path, "Resource"):
			var res: Resource = load(path)
			if res is DestinationData:
				var d: DestinationData = res as DestinationData
				destinations.append({
					"id": d.id,
					"display_name": d.display_name,
					"scene_path": d.scene_path,
					"spawn_id": d.spawn_id,
					"unlocked": d.unlocked,
				})
		else:
			push_warning("[HubMapArea] Khong tim thay destination: " + path)
	# Fallback: neu chua co destination_ids, dung dest_scene/dest_spawn cu
	if destinations.is_empty() and not gate.dest_scene.is_empty():
		destinations.append({
			"id": gate.id + "_default",
			"display_name": gate.sign_text,
			"scene_path": gate.dest_scene,
			"spawn_id": gate.dest_spawn,
			"unlocked": true,
		})
	return {
		"gate_id": gate.id,
		"name": gate.name,
		"position": gate.position,
		"size": gate.size,
		"sign_text": gate.sign_text,
		"destinations": destinations,
	}

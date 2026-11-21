extends Node
## WorldNavigation (autoload): cung cấp tuyến đường qua EventBus.
## Module khác không tham chiếu trực tiếp script này; chúng phát
## WorldEvents.ROUTE_REQUESTED và nhận WorldEvents.ROUTE_READY.
##
## Đồ thị đường hiện tại dựa trên các trục đường của Map3DController.
## Tuyến đường luôn đi qua các giao lộ của đồ thị; không có fallback
## di chuyển thẳng khi không tìm thấy đường.

const ROAD_X: Array[float] = [-65.0, 0.0, 65.0]
const ROAD_Z: Array[float] = [-90.0, -12.0, 70.0]
const ROAD_POINT_HEIGHT: float = 0.15


func _ready() -> void:
	EventBus.subscribe(WorldEvents.ROUTE_REQUESTED, _on_route_requested)


func _exit_tree() -> void:
	if EventBus != null:
		EventBus.unsubscribe(WorldEvents.ROUTE_REQUESTED, _on_route_requested)


func _on_route_requested(payload: Dictionary) -> void:
	var request_id_value: Variant = payload.get("request_id", 0)
	var start_value: Variant = payload.get("start")
	var destination_value: Variant = payload.get("destination")

	if typeof(request_id_value) != TYPE_INT and typeof(request_id_value) != TYPE_FLOAT:
		push_warning("WorldNavigation: request_id không hợp lệ.")
		return
	if not (start_value is Vector3) or not (destination_value is Vector3):
		push_warning("WorldNavigation: start hoặc destination không phải Vector3.")
		return

	var request_id: int = int(request_id_value)
	if request_id <= 0:
		push_warning("WorldNavigation: request_id phải lớn hơn 0.")
		return

	var destination := destination_value as Vector3
	var route: PackedVector3Array = _compute_route(start_value as Vector3, destination)

	EventBus.emit_event(WorldEvents.ROUTE_READY, {
		"request_id": request_id,
		"route": route,
		"destination": destination
	})


static func _compute_route(
	start_position: Vector3,
	destination: Vector3
) -> PackedVector3Array:
	var graph := AStar2D.new()

	for row in range(ROAD_Z.size()):
		for column in range(ROAD_X.size()):
			var point_id := row * ROAD_X.size() + column
			var point := Vector2(ROAD_X[column], ROAD_Z[row])
			graph.add_point(point_id, point)

	for row in range(ROAD_Z.size()):
		for column in range(ROAD_X.size() - 1):
			var left_id := row * ROAD_X.size() + column
			graph.connect_points(left_id, left_id + 1)

	for row in range(ROAD_Z.size() - 1):
		for column in range(ROAD_X.size()):
			var upper_id := row * ROAD_X.size() + column
			var lower_id := upper_id + ROAD_X.size()
			graph.connect_points(upper_id, lower_id)

	var start_id := _find_nearest_intersection(start_position)
	var destination_id := _find_nearest_intersection(destination)
	if start_id < 0 or destination_id < 0:
		return PackedVector3Array()

	var id_path: PackedInt64Array = graph.get_id_path(start_id, destination_id)
	if id_path.is_empty():
		return PackedVector3Array()

	var route := PackedVector3Array()
	for point_id in id_path:
		var road_point: Vector2 = graph.get_point_position(point_id)
		route.append(Vector3(road_point.x, ROAD_POINT_HEIGHT, road_point.y))

	# Đoạn tiếp cận cuối từ giao lộ gần nhất tới đích. Chỉ thêm khi đã có
	# tuyến đường hợp lệ, để không biến lỗi pathfinding thành đi thẳng.
	if route.is_empty():
		return route
	var last_point: Vector3 = route[route.size() - 1]
	var flat_destination := Vector3(destination.x, ROAD_POINT_HEIGHT, destination.z)
	if last_point.distance_to(flat_destination) > 0.05:
		route.append(flat_destination)

	return route


static func _find_nearest_intersection(position: Vector3) -> int:
	var nearest_id := -1
	var nearest_distance := INF

	for row in range(ROAD_Z.size()):
		for column in range(ROAD_X.size()):
			var point_id := row * ROAD_X.size() + column
			var road_point := Vector2(ROAD_X[column], ROAD_Z[row])
			var distance := Vector2(position.x, position.z).distance_squared_to(road_point)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_id = point_id

	return nearest_id

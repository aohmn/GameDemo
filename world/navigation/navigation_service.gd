extends Node
## WorldNavigation (autoload): cung cấp tuyến đường qua EventBus.
## Đồ thị đường được nắm theo khu vực: MapArea gọi `set_graph()` với road
## points của map hiện tại (`MapArea.get_road_points()`).
## Hồ câu: đồ thị rỗng → không tìm được tuyến.

const ROAD_POINT_HEIGHT: float = 0.15

var _points: Array[Vector2] = []
var _width: float = 2.5


func _ready() -> void:
	EventBus.subscribe(WorldEvents.ROUTE_REQUESTED, _on_route_requested)


func _exit_tree() -> void:
	if EventBus != null:
		EventBus.unsubscribe(WorldEvents.ROUTE_REQUESTED, _on_route_requested)


## Thiết lập đồ thị đường cho khu vực hiện tại (gọi từ MapArea).
func set_graph(points: Array[Vector2], width: float = 2.5) -> void:
	if _points == points and is_equal_approx(_width, width):
		return
	_points = points.duplicate()
	_width = width


func get_road_points() -> Array[Vector2]:
	return _points.duplicate()


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
	var route := _compute_route(start_value as Vector3, destination)

	EventBus.emit_event(WorldEvents.ROUTE_READY, {
		"request_id": request_id,
		"route": route,
		"destination": destination
	})


func _compute_route(start_position: Vector3, destination: Vector3) -> PackedVector3Array:
	var graph := AStar2D.new()

	for i in range(_points.size()):
		graph.add_point(i, _points[i])
	for i in range(_points.size()):
		for j in range(i + 1, _points.size()):
			if _points[i].distance_to(_points[j]) <= _width * 4.0:
				graph.connect_points(i, j)

	var start_id := _find_nearest_point(start_position)
	var destination_id := _find_nearest_point(destination)
	if start_id < 0 or destination_id < 0:
		return PackedVector3Array()

	var id_path: PackedInt64Array = graph.get_id_path(start_id, destination_id)
	if id_path.is_empty():
		return PackedVector3Array()

	var route := PackedVector3Array()
	for point_id in id_path:
		var road_point: Vector2 = graph.get_point_position(point_id)
		route.append(Vector3(road_point.x, ROAD_POINT_HEIGHT, road_point.y))

	# Đoạn tiếp cận tới đích chỉ thêm khi đã có tuyến hợp lệ, để không biến
	# lỗi pathfinding thành đi thẳng.
	if route.is_empty():
		return route
	var last_point: Vector3 = route[route.size() - 1]
	var flat_destination := Vector3(destination.x, ROAD_POINT_HEIGHT, destination.z)
	if last_point.distance_to(flat_destination) > 0.05:
		route.append(flat_destination)

	return route


func _find_nearest_point(position: Vector3) -> int:
	var nearest_id := -1
	var nearest_distance := INF

	for i in range(_points.size()):
		var road_point := _points[i]
		var distance := Vector2(position.x, position.z).distance_squared_to(road_point)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_id = i

	return nearest_id

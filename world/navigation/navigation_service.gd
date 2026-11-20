extends RefCounted
class_name NavigationService

# Road graph foundation for the current prototype map.
# Coordinates match the existing roads in Map3DController.

const ROAD_X: Array[float] = [-65.0, 0.0, 65.0]
const ROAD_Z: Array[float] = [-90.0, -12.0, 70.0]


static func find_route(
    start_position: Vector3,
    destination: Vector3
) -> PackedVector3Array:
    var graph := AStar2D.new()

    # Create intersections.
    for row in range(ROAD_Z.size()):
        for column in range(ROAD_X.size()):
            var point_id := row * ROAD_X.size() + column
            var point := Vector2(
                ROAD_X[column],
                ROAD_Z[row]
            )
            graph.add_point(point_id, point)

    # Connect intersections along existing road axes.
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

    var id_path: PackedInt64Array = graph.get_id_path(
        start_id,
        destination_id
    )

    if id_path.is_empty():
        return PackedVector3Array()

    var route := PackedVector3Array()

    for point_id in id_path:
        var road_point: Vector2 = graph.get_point_position(point_id)
        route.append(Vector3(road_point.x, 0.15, road_point.y))

    return route


static func _find_nearest_intersection(position: Vector3) -> int:
    var nearest_id := -1
    var nearest_distance := INF

    for row in range(ROAD_Z.size()):
        for column in range(ROAD_X.size()):
            var point_id := row * ROAD_X.size() + column
            var road_point := Vector2(
                ROAD_X[column],
                ROAD_Z[row]
            )
            var distance := Vector2(
                position.x,
                position.z
            ).distance_squared_to(road_point)

            if distance < nearest_distance:
                nearest_distance = distance
                nearest_id = point_id

    return nearest_id

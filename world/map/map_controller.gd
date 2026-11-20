extends Node3D
class_name Map3DController

const WORLD_SIZE := 100.0

func _ready() -> void:
    _build_environment()
    _build_ground()
    _build_roads()
    _build_canal()
    _build_buildings()
    _build_trees()
    print("[Map3D] World created")


func _build_environment() -> void:
    var world_environment := WorldEnvironment.new()
    var environment_data := Environment.new()
    environment_data.background_mode = Environment.BG_COLOR
    environment_data.background_color = Color(0.52, 0.72, 0.86)
    environment_data.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment_data.ambient_light_color = Color(0.78, 0.82, 0.88)
    environment_data.ambient_light_energy = 0.65
    world_environment.environment = environment_data
    add_child(world_environment)

    var sunlight := DirectionalLight3D.new()
    sunlight.rotation_degrees = Vector3(-52.0, -32.0, 0.0)
    sunlight.light_energy = 1.15
    sunlight.shadow_enabled = true
    add_child(sunlight)


func _build_ground() -> void:
    _add_box(
        "Ground",
        Vector3(WORLD_SIZE, 0.5, WORLD_SIZE),
        Vector3(0.0, -0.25, 0.0),
        Color(0.29, 0.48, 0.23)
    )

    var ground_body := StaticBody3D.new()
    ground_body.name = "GroundCollision"

    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(WORLD_SIZE, 0.5, WORLD_SIZE)
    collision.shape = shape
    collision.position.y = -0.25

    ground_body.add_child(collision)
    add_child(ground_body)


func _build_roads() -> void:
    # Lề đường
    _add_box(
        "RoadShoulderMain",
        Vector3(11.0, 0.12, WORLD_SIZE),
        Vector3(0.0, 0.02, 0.0),
        Color(0.48, 0.43, 0.34)
    )

    # Đường chính
    _add_box(
        "MainRoad",
        Vector3(8.0, 0.10, WORLD_SIZE),
        Vector3(0.0, 0.09, 0.0),
        Color(0.17, 0.19, 0.20)
    )

    # Đường giao cắt
    _add_box(
        "CrossRoad",
        Vector3(WORLD_SIZE, 0.10, 8.0),
        Vector3(0.0, 0.10, -12.0),
        Color(0.17, 0.19, 0.20)
    )

    # Vạch đứt giữa đường
    for index in range(-16, 17, 3):
        _add_box(
            "RoadMarking",
            Vector3(0.16, 0.025, 1.5),
            Vector3(0.0, 0.16, float(index) * 2.5),
            Color(0.90, 0.87, 0.72)
        )

    # Vỉa hè
    _add_box(
        "SidewalkLeft",
        Vector3(1.5, 0.20, WORLD_SIZE),
        Vector3(-5.8, 0.10, 0.0),
        Color(0.57, 0.55, 0.47)
    )
    _add_box(
        "SidewalkRight",
        Vector3(1.5, 0.20, WORLD_SIZE),
        Vector3(5.8, 0.10, 0.0),
        Color(0.57, 0.55, 0.47)
    )


func _build_canal() -> void:
    # Bờ kênh
    _add_box(
        "CanalBankLeft",
        Vector3(1.2, 0.45, WORLD_SIZE),
        Vector3(21.8, 0.20, 0.0),
        Color(0.43, 0.48, 0.31)
    )
    _add_box(
        "CanalBankRight",
        Vector3(1.2, 0.45, WORLD_SIZE),
        Vector3(28.2, 0.20, 0.0),
        Color(0.43, 0.48, 0.31)
    )

    # Mặt nước
    _add_box(
        "CanalWater",
        Vector3(5.2, 0.12, WORLD_SIZE),
        Vector3(25.0, -0.08, 0.0),
        Color(0.08, 0.34, 0.48)
    )


func _build_buildings() -> void:
    var wall_colors: Array[Color] = [
        Color(0.78, 0.65, 0.48),
        Color(0.76, 0.75, 0.63),
        Color(0.72, 0.49, 0.37),
        Color(0.67, 0.72, 0.65),
        Color(0.82, 0.76, 0.62)
    ]

    for index in range(6):
        var z_position := -34.0 + float(index) * 13.0
        var wall_color: Color = wall_colors[index % wall_colors.size()]

        _build_house(
            Vector3(-13.0, 0.0, z_position),
            wall_color
        )
        _build_house(
            Vector3(13.0, 0.0, z_position),
            wall_color.darkened(0.08)
        )


func _build_house(world_position: Vector3, wall_color: Color) -> void:
    var house := StaticBody3D.new()
    house.name = "VietnameseHouse"
    house.position = world_position
    add_child(house)

    var body := _make_box_node(
        "HouseBody",
        Vector3(5.0, 3.0, 6.0),
        Vector3(0.0, 1.5, 0.0),
        wall_color
    )
    house.add_child(body)

    var collision := CollisionShape3D.new()
    var collision_shape := BoxShape3D.new()
    collision_shape.size = Vector3(5.0, 3.0, 6.0)
    collision.shape = collision_shape
    collision.position.y = 1.5
    house.add_child(collision)

    var roof := _make_box_node(
        "FlatRoof",
        Vector3(5.4, 0.35, 6.4),
        Vector3(0.0, 3.15, 0.0),
        Color(0.35, 0.27, 0.23)
    )
    house.add_child(roof)

    var front_direction := 1.0
    if world_position.x > 0.0:
        front_direction = -1.0

    var door := _make_box_node(
        "FrontDoor",
        Vector3(0.08, 1.8, 0.9),
        Vector3(front_direction * 2.54, 0.9, 0.0),
        Color(0.30, 0.19, 0.12)
    )
    house.add_child(door)

    for window_index in range(2):
        var window_z := -1.45 + float(window_index) * 2.9
        var window := _make_box_node(
            "FrontWindow",
            Vector3(0.08, 0.75, 1.0),
            Vector3(front_direction * 2.55, 2.0, window_z),
            Color(0.20, 0.48, 0.59)
        )
        house.add_child(window)


func _build_trees() -> void:
    for index in range(12):
        var z_position := -35.0 + float(index) * 6.0
        _build_tree(Vector3(-8.0, 0.0, z_position))
        _build_tree(Vector3(8.0, 0.0, z_position))


func _build_tree(world_position: Vector3) -> void:
    var tree := Node3D.new()
    tree.name = "LowPolyTree"
    tree.position = world_position
    add_child(tree)

    var trunk := CylinderMesh.new()
    trunk.top_radius = 0.16
    trunk.bottom_radius = 0.24
    trunk.height = 2.0

    var trunk_node := MeshInstance3D.new()
    trunk_node.mesh = trunk
    trunk_node.position.y = 1.0
    trunk_node.material_override = _make_material(
        Color(0.31, 0.20, 0.12)
    )
    tree.add_child(trunk_node)

    var crown := SphereMesh.new()
    crown.radius = 1.0
    crown.height = 2.0
    crown.radial_segments = 8
    crown.rings = 4

    var crown_node := MeshInstance3D.new()
    crown_node.mesh = crown
    crown_node.position.y = 2.5
    crown_node.material_override = _make_material(
        Color(0.17, 0.39, 0.17)
    )
    tree.add_child(crown_node)


func _add_box(
    object_name: String,
    box_size: Vector3,
    world_position: Vector3,
    color: Color
) -> void:
    add_child(
        _make_box_node(
            object_name,
            box_size,
            world_position,
            color
        )
    )


func _make_box_node(
    object_name: String,
    box_size: Vector3,
    local_position: Vector3,
    color: Color
) -> MeshInstance3D:
    var mesh := BoxMesh.new()
    mesh.size = box_size

    var instance := MeshInstance3D.new()
    instance.name = object_name
    instance.mesh = mesh
    instance.position = local_position
    instance.material_override = _make_material(color)
    return instance


func _make_material(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.9
    return material

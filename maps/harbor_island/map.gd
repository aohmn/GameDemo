extends Node3D

const WATER_COLOR: Color = Color(0.18, 0.62, 0.78, 0.85)
const SAND_COLOR: Color = Color(0.92, 0.84, 0.62)
const GRASS_COLOR: Color = Color(0.38, 0.72, 0.32)
const CLIFF_COLOR: Color = Color(0.48, 0.44, 0.40)
const WOOD_COLOR: Color = Color(0.55, 0.38, 0.24)
const WOOD_DARK: Color = Color(0.40, 0.26, 0.16)
const ROOF_COLOR: Color = Color(0.82, 0.45, 0.28)
const LEAF_COLOR: Color = Color(0.24, 0.58, 0.22)


func _ready() -> void:
    _make_environment()
    _make_ocean()
    _make_island_terrain()
    _make_mountains()
    _make_pier_and_harbor()
    _make_harbor_structures()
    _make_tropical_trees()
    _make_island_boundaries()


func _make_environment() -> void:
    var env := WorldEnvironment.new()
    var settings := Environment.new()
    settings.background_mode = Environment.BG_SKY
    settings.sky = Sky.new()
    settings.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    settings.ambient_light_energy = 0.85
    env.environment = settings
    add_child(env)

    var sun := DirectionalLight3D.new()
    sun.name = "TropicalSun"
    sun.rotation_degrees = Vector3(-50.0, -35.0, 0.0)
    sun.light_color = Color(1.0, 0.96, 0.88)
    sun.light_energy = 1.3
    sun.shadow_enabled = true
    add_child(sun)


func _make_ocean() -> void:
    var water_mesh := PlaneMesh.new()
    water_mesh.size = Vector2(80.0, 80.0)

    var water_mat := StandardMaterial3D.new()
    water_mat.albedo_color = WATER_COLOR
    water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    water_mat.roughness = 0.15
    water_mat.metallic = 0.1

    var water_node := MeshInstance3D.new()
    water_node.name = "OceanSurface"
    water_node.mesh = water_mesh
    water_node.position = Vector3(0.0, -0.15, 0.0)
    water_node.material_override = water_mat
    add_child(water_node)

    # Đáy biển sâu - không dùng collider để tránh làm sàn đi bộ ảo dưới nước
    var seabed_pos := Vector3(0.0, -4.0, 0.0)
    var seabed_size := Vector3(80.0, 1.0, 80.0)
    _box("Seabed", seabed_pos, seabed_size, Color(0.12, 0.35, 0.42))


func _make_island_terrain() -> void:
    var beach_pos := Vector3(0.0, -0.2, 4.0)
    var beach_size := Vector3(44.0, 0.4, 38.0)
    _box("SandyBeach", beach_pos, beach_size, SAND_COLOR)
    _add_box_collider("BeachCollision", beach_pos, beach_size)

    var plateaus: Array[Dictionary] = [
        {"name": "PlateauCenter", "pos": Vector3(0.0, 0.01, 7.0), "size": Vector3(32.0, 0.02, 22.0)},
        {"name": "PlateauNorth", "pos": Vector3(0.0, 0.01, -6.0), "size": Vector3(22.0, 0.02, 14.0)},
        {"name": "PlateauWest", "pos": Vector3(-12.0, 0.01, 3.0), "size": Vector3(14.0, 0.02, 18.0)},
        {"name": "PlateauEast", "pos": Vector3(12.0, 0.01, 3.0), "size": Vector3(14.0, 0.02, 18.0)},
    ]
    for p in plateaus:
        _box(p["name"], p["pos"], p["size"], GRASS_COLOR)


func _make_mountains() -> void:
    # Núi đá tự nhiên bao quanh vịnh, cửa biển chính Bắc (-6.5 <= X <= 6.5) hoàn toàn thông thoáng
    var cliffs: Array[Dictionary] = [
        {"pos": Vector3(-18.0, 3.0, -4.0), "r_top": 2.5, "r_bot": 6.5, "h": 6.0},
        {"pos": Vector3(-16.0, 4.5, -12.0), "r_top": 2.0, "r_bot": 7.0, "h": 9.0},
        {"pos": Vector3(-12.5, 5.0, -18.5), "r_top": 1.5, "r_bot": 5.5, "h": 10.0},
        {"pos": Vector3(-20.0, 2.5, 6.0), "r_top": 3.0, "r_bot": 6.0, "h": 5.0},
        {"pos": Vector3(18.0, 3.0, -4.0), "r_top": 2.5, "r_bot": 6.5, "h": 6.0},
        {"pos": Vector3(16.0, 4.5, -12.0), "r_top": 2.0, "r_bot": 7.0, "h": 9.0},
        {"pos": Vector3(12.5, 5.0, -18.5), "r_top": 1.5, "r_bot": 5.5, "h": 10.0},
        {"pos": Vector3(20.0, 2.5, 6.0), "r_top": 3.0, "r_bot": 6.0, "h": 5.0},
    ]

    var idx := 0
    for c in cliffs:
        idx += 1
        var cyl := CylinderMesh.new()
        cyl.top_radius = c["r_top"]
        cyl.bottom_radius = c["r_bot"]
        cyl.height = c["h"]
        var name_str := "Cliff_" + str(idx)
        _mesh(name_str, cyl, c["pos"], CLIFF_COLOR)

        var body := StaticBody3D.new()
        body.name = name_str + "Col"
        body.position = c["pos"]
        var col := CollisionShape3D.new()
        var shape := CylinderShape3D.new()
        shape.radius = c["r_bot"] * 0.85
        shape.height = c["h"]
        col.shape = shape
        body.add_child(col)
        add_child(body)


func _make_pier_and_harbor() -> void:
    # Cầu tàu vươn từ bờ cát (mặt trên y = 0.05)
    var main_pier_pos := Vector3(-2.0, -0.05, 16.5)
    var main_pier_size := Vector3(4.5, 0.2, 13.0)
    _box("MainPierPlanks", main_pier_pos, main_pier_size, WOOD_COLOR)
    _add_box_collider("MainPierCol", main_pier_pos, main_pier_size)

    # Dốc thoai thoải nối bãi cát (y=0.0) lên cầu tàu (y=0.05)
    var ramp_pos := Vector3(-2.0, -0.02, 9.5)
    var ramp_size := Vector3(4.5, 0.08, 1.2)
    _box("PierRamp", ramp_pos, ramp_size, WOOD_COLOR)
    _add_box_collider("PierRampCol", ramp_pos, ramp_size)

    # Cầu tàu ngang chữ T bến đỗ thuyền
    var t_pier_pos := Vector3(-6.5, -0.05, 22.0)
    var t_pier_size := Vector3(8.0, 0.2, 3.5)
    _box("TPierPlanks", t_pier_pos, t_pier_size, WOOD_COLOR)
    _add_box_collider("TPierCol", t_pier_pos, t_pier_size)

    # Cọc gỗ cầu tàu
    var post_positions: Array[Vector3] = [
        Vector3(-4.0, -0.4, 11.0), Vector3(0.0, -0.4, 11.0),
        Vector3(-4.0, -0.4, 16.5), Vector3(0.0, -0.4, 16.5),
        Vector3(-4.0, -0.4, 22.0), Vector3(0.0, -0.4, 22.0),
        Vector3(-8.0, -0.4, 22.0), Vector3(-10.5, -0.4, 22.0),
    ]
    for p in post_positions:
        var post := CylinderMesh.new()
        post.top_radius = 0.16
        post.bottom_radius = 0.18
        post.height = 1.4
        _mesh("PierPost", post, p, WOOD_DARK)

    # Thuyền gỗ neo đậu bên ngoài cầu tàu (không đè lên lối đi cầu tàu)
    _boat("DockedBoat1", Vector3(-6.5, 0.05, 25.5), Vector3(2.2, 0.8, 3.2), 0.0)
    _boat("DockedBoat2", Vector3(3.5, 0.05, 17.5), Vector3(2.0, 0.75, 3.8), -15.0)


func _boat(b_name: String, pos: Vector3, size: Vector3, rot_y: float) -> void:
    var hull := BoxMesh.new()
    hull.size = size
    var node := MeshInstance3D.new()
    node.name = b_name
    node.mesh = hull
    node.position = pos
    node.rotation_degrees.y = rot_y
    node.material_override = _mat(WOOD_COLOR)
    add_child(node)

    var body := StaticBody3D.new()
    body.name = b_name + "Col"
    body.position = pos
    body.rotation_degrees.y = rot_y
    var col := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = size
    col.shape = shape
    body.add_child(col)
    add_child(body)


func _make_harbor_structures() -> void:
    _building("FisheryWarehouse", Vector3(6.5, 1.4, 8.5), Vector3(6.0, 2.8, 5.0), WOOD_DARK, ROOF_COLOR)
    _building("BaitHut", Vector3(-9.0, 1.1, 7.0), Vector3(4.0, 2.2, 4.0), WOOD_COLOR, Color(0.28, 0.55, 0.65))

    var crates: Array[Vector3] = [
        Vector3(2.5, 0.35, 10.5), Vector3(3.5, 0.35, 10.5),
        Vector3(3.0, 1.05, 10.5), Vector3(-5.0, 0.35, 9.5)
    ]
    var idx := 0
    for cr in crates:
        idx += 1
        var sz := Vector3(0.7, 0.7, 0.7)
        _box("Crate_" + str(idx), cr, sz, WOOD_COLOR)
        _add_box_collider("CrateCol_" + str(idx), cr, sz)


func _building(b_name: String, pos: Vector3, size: Vector3, wall_color: Color, roof_color: Color) -> void:
    _box(b_name + "Wall", pos, size, wall_color)
    _add_box_collider(b_name + "Col", pos, size)

    var roof := PrismMesh.new()
    roof.size = Vector3(size.x + 0.6, 1.3, size.z + 0.6)
    _mesh(b_name + "Roof", roof, pos + Vector3(0.0, size.y * 0.5 + 0.65, 0.0), roof_color)


func _make_tropical_trees() -> void:
    var tree_locs: Array[Vector3] = [
        Vector3(-14.0, 0.0, 12.0),
        Vector3(-11.0, 0.0, 15.0),
        Vector3(12.0, 0.0, 13.0),
        Vector3(15.0, 0.0, 7.0),
        Vector3(7.5, 0.0, -2.0),
        Vector3(-7.5, 0.0, -2.0),
        Vector3(0.0, 0.0, -10.0),
    ]

    var t_idx := 0
    for loc in tree_locs:
        t_idx += 1
        var trunk := CylinderMesh.new()
        trunk.top_radius = 0.14
        trunk.bottom_radius = 0.22
        trunk.height = 2.4
        _mesh("PalmTrunk_" + str(t_idx), trunk, loc + Vector3(0.0, 1.2, 0.0), WOOD_DARK)

        var crown := SphereMesh.new()
        crown.radius = 1.15
        crown.height = 1.3
        _mesh("PalmCrown_" + str(t_idx), crown, loc + Vector3(0.0, 2.5, 0.0), LEAF_COLOR)

        var body := StaticBody3D.new()
        body.name = "TreeCol_" + str(t_idx)
        body.position = loc + Vector3(0.0, 1.2, 0.0)
        var col := CollisionShape3D.new()
        var shape := CylinderShape3D.new()
        shape.radius = 0.25
        shape.height = 2.4
        col.shape = shape
        body.add_child(col)
        add_child(body)


func _make_island_boundaries() -> void:
    # Ranh giới ngăn Player rơi khỏi mép đảo và mép nước.
    # Player có collision_mask mặc định = 1, va chạm vững chắc với tất cả collider này.
    var wall_h := 3.0
    var bounds: Array[Dictionary] = [
        # Mép ngoài phía Tây và Đông
        {"name": "BoundWest", "pos": Vector3(-23.0, 1.5, 3.0), "size": Vector3(1.0, wall_h, 40.0)},
        {"name": "BoundEast", "pos": Vector3(23.0, 1.5, 3.0), "size": Vector3(1.0, wall_h, 40.0)},
        # Mép bờ Nam (khu mặt nước hai bên cầu tàu)
        {"name": "BoundSouthLeft", "pos": Vector3(-16.0, 1.5, 23.5), "size": Vector3(14.0, wall_h, 1.0)},
        {"name": "BoundSouthRight", "pos": Vector3(11.0, 1.5, 23.5), "size": Vector3(24.0, wall_h, 1.0)},
        # Lan can bảo vệ hai bên lối đi cầu tàu chính (chừa lối đi thông thoáng ở giữa: -4.25 < x < 0.25)
        {"name": "BoundMainPierWest", "pos": Vector3(-4.35, 1.5, 16.5), "size": Vector3(0.2, wall_h, 11.0)},
        {"name": "BoundMainPierEast", "pos": Vector3(0.35, 1.5, 16.5), "size": Vector3(0.2, wall_h, 13.0)},
        # Lan can bảo vệ cầu tàu T (không chắn lối giao cắt từ cầu tàu chính rẽ sang)
        {"name": "BoundPierTNorth", "pos": Vector3(-7.5, 1.5, 20.15), "size": Vector3(6.0, wall_h, 0.3)},
        {"name": "BoundPierTSouth", "pos": Vector3(-6.5, 1.5, 23.85), "size": Vector3(8.0, wall_h, 0.3)},
        {"name": "BoundPierTWest", "pos": Vector3(-10.6, 1.5, 22.0), "size": Vector3(0.3, wall_h, 3.6)},
        # Mép bờ cát phía Bắc hai bên cửa biển (chừa cửa biển -6.5 <= X <= 6.5 hoàn toàn thông thoáng)
        {"name": "BoundCoastNorthL", "pos": Vector3(-9.75, 1.5, -15.5), "size": Vector3(6.5, wall_h, 1.0)},
        {"name": "BoundCoastNorthR", "pos": Vector3(9.75, 1.5, -15.5), "size": Vector3(6.5, wall_h, 1.0)},
    ]
    for b in bounds:
        _add_box_collider(b["name"], b["pos"], b["size"])


func _add_box_collider(node_name: String, pos: Vector3, size: Vector3) -> void:
    var body := StaticBody3D.new()
    body.name = node_name
    body.position = pos

    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = size
    collision.shape = shape

    body.add_child(collision)
    add_child(body)


func _box(node_name: String, pos: Vector3, size: Vector3, color: Color) -> void:
    var mesh := BoxMesh.new()
    mesh.size = size
    _mesh(node_name, mesh, pos, color)


func _mesh(node_name: String, mesh: Mesh, pos: Vector3, color: Color) -> void:
    var node := MeshInstance3D.new()
    node.name = node_name
    node.mesh = mesh
    node.position = pos
    node.material_override = _mat(color)
    add_child(node)


func _mat(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.85
    return material

extends Node3D

const PLAYER_SCENE: PackedScene = preload("res://modules/player/scenes/player.tscn")


func _ready() -> void:
    _create_floor()
    _create_player()
    _create_camera()
    _create_light()


func _create_floor() -> void:
    var body := StaticBody3D.new()
    body.name = "TestFloor"

    var mesh_instance := MeshInstance3D.new()
    var box_mesh := BoxMesh.new()
    box_mesh.size = Vector3(12.0, 0.2, 12.0)
    mesh_instance.mesh = box_mesh
    body.add_child(mesh_instance)

    var collision := CollisionShape3D.new()
    var box_shape := BoxShape3D.new()
    box_shape.size = box_mesh.size
    collision.shape = box_shape
    body.add_child(collision)

    body.position.y = -0.1
    add_child(body)


func _create_player() -> void:
    var player_node: Node = PLAYER_SCENE.instantiate()
    var player := player_node as CharacterBody3D
    if player == null:
        player_node.free()
        push_error("Player scene không phải CharacterBody3D.")
        return

    player.position.y = 0.05
    add_child(player)


func _create_camera() -> void:
    var camera := Camera3D.new()
    add_child(camera)
    camera.look_at_from_position(Vector3(0.0, 4.0, 7.0), Vector3.ZERO)
    camera.current = true


func _create_light() -> void:
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-45.0, -30.0, 0.0)
    add_child(light)

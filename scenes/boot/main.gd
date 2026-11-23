extends Node3D

const MAP: PackedScene = preload("res://maps/vietnam_street/map.tscn")

func _ready() -> void:
	var map_node: Node3D = MAP.instantiate()
	add_child(map_node)

	var camera := Camera3D.new()
	camera.name = "MainCamera"
	camera.position = Vector3(0.0, 16.0, 23.0)
	camera.fov = 55.0
	add_child(camera)
	camera.look_at(Vector3.ZERO)
	camera.current = true

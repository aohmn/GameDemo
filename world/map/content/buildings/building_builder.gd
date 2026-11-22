## Building: nhà dân cư (dựng từ primitive mesh, không texture).
## Tái sử dụng logic _build_house từ map_controller (cũ).
extends RefCounted
class_name BuildingBuilder

static func build_buildings(specs: Array[Dictionary], parent: Node3D) -> void:
	for i in range(specs.size()):
		var spec: Dictionary = specs[i]
		_build_house(parent, spec["position"], spec["wall_color"])


static func _build_house(parent: Node3D, world_position: Vector3, wall_color: Color) -> void:
	var house := StaticBody3D.new()
	house.name = "VietnameseHouse"
	house.position = world_position
	parent.add_child(house)

	house.add_child(
		_make_box_node("HouseBody", Vector3(5.0, 3.0, 6.0), Vector3(0.0, 1.5, 0.0), wall_color)
	)

	var collision := CollisionShape3D.new()
	var collision_shape := BoxShape3D.new()
	collision_shape.size = Vector3(5.0, 3.0, 6.0)
	collision.shape = collision_shape
	collision.position.y = 1.5
	house.add_child(collision)

	house.add_child(
		_make_box_node("FlatRoof", Vector3(5.4, 0.35, 6.4), Vector3(0.0, 3.15, 0.0), Color(0.35, 0.27, 0.23))
	)

	var front_direction := 1.0
	if world_position.x > 0.0:
		front_direction = -1.0

	house.add_child(
		_make_box_node("FrontDoor", Vector3(0.08, 1.8, 0.9), Vector3(front_direction * 2.54, 0.9, 0.0), Color(0.30, 0.19, 0.12))
	)

	for index in range(2):
		var window_z := -1.45 + float(index) * 2.9
		house.add_child(
			_make_box_node("FrontWindow", Vector3(0.08, 0.75, 1.0), Vector3(front_direction * 2.55, 2.0, window_z), Color(0.20, 0.48, 0.59))
		)


static func _make_box_node(object_name: String, box_size: Vector3, local_position: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = box_size
	var instance := MeshInstance3D.new()
	instance.name = object_name
	instance.mesh = mesh
	instance.position = local_position
	instance.material_override = _make_material(color)
	return instance


static func _make_material(color: Color) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = preload("res://world/map/shaders/procedural_surface.gdshader")
	material.set_shader_parameter("base_color", color)
	material.set_shader_parameter("roughness_value", 0.88)
	material.set_shader_parameter("surface_detail", 0.018)
	return material

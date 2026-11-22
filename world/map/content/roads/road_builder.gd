## Road (vỉa hè): đường vuông góc + collision. Tái sử dụng từ map_controller (cũ).
extends RefCounted
class_name RoadBuilder

static func build(specs: Array[Dictionary], parent: Node3D) -> void:
	for i in range(specs.size()):
		var spec: Dictionary = specs[i]
		var body := StaticBody3D.new()
		body.name = spec["name"]
		body.position = spec["position"]

		var mesh := _make_box_node(spec["name"] + "Mesh", spec["size"], Vector3.ZERO, spec["color"])
		body.add_child(mesh)

		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = spec["size"]
		collision.shape = shape
		body.add_child(collision)
		parent.add_child(body)


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

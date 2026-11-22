## Objects: vật thể hồ câu (LakeWater, LakeBanks, DirtPath, FishingDock, cây quanh hồ).
## Tái sử dụng từ map_controller (cũ) — cắt bỏ logic Residential.
extends RefCounted
class_name ObjectBuilder

static func build_fishing_lake(parent: Node3D) -> void:
	# Mặt hồ.
	_box(parent, "LakeWater", Vector3(31.0, 0.12, 25.0), Vector3(0.0, -0.12, -6.0), Color(0.06, 0.32, 0.47))

	# Bờ hồ.
	_box(parent, "LakeBankNorth", Vector3(35.0, 0.35, 1.5), Vector3(0.0, 0.12, -19.5), Color(0.48, 0.43, 0.29))
	_box(parent, "LakeBankSouth", Vector3(35.0, 0.35, 1.5), Vector3(0.0, 0.12, 7.5), Color(0.48, 0.43, 0.29))
	_box(parent, "LakeBankWest", Vector3(1.5, 0.35, 27.0), Vector3(-16.5, 0.12, -6.0), Color(0.48, 0.43, 0.29))
	_box(parent, "LakeBankEast", Vector3(1.5, 0.35, 27.0), Vector3(16.5, 0.12, -6.0), Color(0.48, 0.43, 0.29))

	# Đường đất từ Spawn Point đến bến câu.
	_box(parent, "DirtPath", Vector3(4.0, 0.08, 15.0), Vector3(0.0, 0.04, 14.0), Color(0.52, 0.39, 0.24))

	# Bến câu có va chạm để nhân vật đi lên được.
	_static_box(parent, "FishingDock", Vector3(3.5, 0.35, 12.0), Vector3(0.0, 0.25, 0.0), Color(0.39, 0.25, 0.14))

	# Cây quanh hồ.
	TreeBuilder.build_tree(parent, Vector3(-23.0, 0.0, -24.0))
	TreeBuilder.build_tree(parent, Vector3(-30.0, 0.0, -8.0))
	TreeBuilder.build_tree(parent, Vector3(-23.0, 0.0, 12.0))
	TreeBuilder.build_tree(parent, Vector3(23.0, 0.0, -24.0))
	TreeBuilder.build_tree(parent, Vector3(30.0, 0.0, -8.0))
	TreeBuilder.build_tree(parent, Vector3(23.0, 0.0, 12.0))
	TreeBuilder.build_tree(parent, Vector3(-10.0, 0.0, 30.0))
	TreeBuilder.build_tree(parent, Vector3(10.0, 0.0, 30.0))


static func _box(parent: Node3D, object_name: String, box_size: Vector3, world_position: Vector3, color: Color) -> void:
	var piece := MeshInstance3D.new()
	piece.name = object_name
	var mesh := BoxMesh.new()
	mesh.size = box_size
	piece.mesh = mesh
	piece.position = world_position
	piece.material_override = _make_material(color)
	parent.add_child(piece)


static func _static_box(parent: Node3D, object_name: String, box_size: Vector3, world_position: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.name = object_name
	body.position = world_position

	var mesh := _box_node(object_name + "Mesh", box_size, Vector3.ZERO, color)
	body.add_child(mesh)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = box_size
	collision.shape = shape
	body.add_child(collision)
	parent.add_child(body)


static func _box_node(object_name: String, box_size: Vector3, local_position: Vector3, color: Color) -> MeshInstance3D:
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

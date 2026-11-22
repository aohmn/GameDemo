## Ground: nền đất + collision. Tái sử dụng từ map_controller (cũ).
extends RefCounted
class_name GroundBuilder

const SURFACE_SHADER: Shader = preload("res://world/map/shaders/procedural_surface.gdshader")

static func build(specs: Array[Dictionary], parent: Node3D) -> void:
	for i in range(specs.size()):
		var spec: Dictionary = specs[i]
		var piece := MeshInstance3D.new()
		piece.name = spec["name"]
		var mesh := BoxMesh.new()
		mesh.size = spec["size"]
		piece.mesh = mesh
		piece.position = spec["position"]
		piece.material_override = _make_material(spec["color"])
		parent.add_child(piece)

		var body := StaticBody3D.new()
		body.name = spec["name"] + "Collision"
		var shape := BoxShape3D.new()
		shape.size = spec["size"]
		body.position = spec["position"]
		var collision := CollisionShape3D.new()
		collision.shape = shape
		body.add_child(collision)
		parent.add_child(body)


static func _make_material(color: Color) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = SURFACE_SHADER
	material.set_shader_parameter("base_color", color)
	material.set_shader_parameter("roughness_value", 0.88)
	material.set_shader_parameter("surface_detail", 0.018)
	return material

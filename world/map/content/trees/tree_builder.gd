## Tree: cây cối (trunk + crown, dựng từ primitive mesh, không texture).
## Tái sử dụng từ map_controller (cũ).
extends RefCounted
class_name TreeBuilder

static var _trunk_mesh: CylinderMesh = null
static var _crown_mesh: SphereMesh = null


static func build_tree(parent: Node3D, world_position: Vector3) -> void:
	var tree := Node3D.new()
	tree.name = "LowPolyTree"
	tree.position = world_position
	parent.add_child(tree)

	if _trunk_mesh == null:
		_trunk_mesh = CylinderMesh.new()
		_trunk_mesh.top_radius = 0.16
		_trunk_mesh.bottom_radius = 0.24
		_trunk_mesh.height = 2.0
	var trunk_node := MeshInstance3D.new()
	trunk_node.mesh = _trunk_mesh
	trunk_node.position.y = 1.0
	trunk_node.material_override = _make_material(Color(0.31, 0.20, 0.12))
	tree.add_child(trunk_node)

	if _crown_mesh == null:
		_crown_mesh = SphereMesh.new()
		_crown_mesh.radius = 1.0
		_crown_mesh.height = 2.0
		_crown_mesh.radial_segments = 8
		_crown_mesh.rings = 4
	var crown_node := MeshInstance3D.new()
	crown_node.mesh = _crown_mesh
	crown_node.position.y = 2.5
	crown_node.material_override = _make_material(Color(0.17, 0.39, 0.17))
	tree.add_child(crown_node)


static func _make_material(color: Color) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = preload("res://world/map/shaders/procedural_surface.gdshader")
	material.set_shader_parameter("base_color", color)
	material.set_shader_parameter("roughness_value", 0.88)
	material.set_shader_parameter("surface_detail", 0.018)
	return material

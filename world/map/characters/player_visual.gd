extends Node3D
class_name PlayerVisual

@export var skin_color: Color = Color(0.70, 0.43, 0.29)
@export var shirt_color: Color = Color(0.78, 0.73, 0.59)
@export var pants_color: Color = Color(0.12, 0.16, 0.19)
@export var hair_color: Color = Color(0.055, 0.045, 0.04)

var _left_arm: Node3D
var _right_arm: Node3D
var _left_leg: Node3D
var _right_leg: Node3D
var _time: float = 0.0
var _body_materials: Dictionary = {}


func _ready() -> void:
	_build_character()


func _process(delta: float) -> void:
	_time += delta
	var actor := get_parent() as CharacterBody3D
	if actor == null:
		return

	var horizontal_speed := Vector2(actor.velocity.x, actor.velocity.z).length()
	var movement_weight := clampf(horizontal_speed / 3.0, 0.0, 1.0)
	var walk_phase := _time * 8.5
	var swing := sin(walk_phase) * 0.48 * movement_weight

	_left_leg.rotation.x = swing
	_right_leg.rotation.x = -swing
	_left_arm.rotation.x = -swing * 0.72
	_right_arm.rotation.x = swing * 0.72
	rotation.z = sin(_time * 2.0) * 0.025 * movement_weight
	position.y = absf(sin(walk_phase * 2.0)) * 0.035 * movement_weight


func _build_character() -> void:
	# Tỷ lệ người trưởng thành khoảng 1,72 m; dựng hoàn toàn bằng primitive mesh.
	_add_capsule("Torso", Vector3(0.0, 1.18, 0.0), 0.235, 0.62, shirt_color)
	_add_sphere("Pelvis", Vector3(0.0, 0.83, 0.0), Vector3(0.235, 0.17, 0.15), pants_color)
	_add_cylinder("Neck", Vector3(0.0, 1.55, 0.0), 0.075, 0.12, skin_color)
	_add_sphere("Head", Vector3(0.0, 1.70, 0.0), Vector3(0.145, 0.19, 0.135), skin_color)
	_add_sphere("HairCap", Vector3(0.0, 1.825, 0.012), Vector3(0.15, 0.085, 0.14), hair_color)
	_add_sphere("HairBack", Vector3(0.0, 1.72, 0.105), Vector3(0.14, 0.16, 0.065), hair_color)

	# Mặt hướng -Z.
	_add_sphere("Nose", Vector3(0.0, 1.69, -0.132), Vector3(0.026, 0.038, 0.035), skin_color.lightened(0.08))
	_add_sphere("EyeLeft", Vector3(-0.052, 1.725, -0.126), Vector3(0.012, 0.014, 0.008), Color(0.035, 0.025, 0.02))
	_add_sphere("EyeRight", Vector3(0.052, 1.725, -0.126), Vector3(0.012, 0.014, 0.008), Color(0.035, 0.025, 0.02))
	_add_sphere("EarLeft", Vector3(-0.15, 1.69, 0.0), Vector3(0.035, 0.055, 0.04), skin_color)
	_add_sphere("EarRight", Vector3(0.15, 1.69, 0.0), Vector3(0.035, 0.055, 0.04), skin_color)

	_left_arm = _make_pivot("LeftArm", Vector3(-0.265, 1.39, 0.0))
	_right_arm = _make_pivot("RightArm", Vector3(0.265, 1.39, 0.0))
	_add_capsule_to(_left_arm, "UpperArm", Vector3(0.0, -0.17, 0.0), 0.085, 0.36, shirt_color)
	_add_capsule_to(_right_arm, "UpperArm", Vector3(0.0, -0.17, 0.0), 0.085, 0.36, shirt_color)
	_add_capsule_to(_left_arm, "Forearm", Vector3(0.0, -0.40, -0.005), 0.065, 0.30, skin_color)
	_add_capsule_to(_right_arm, "Forearm", Vector3(0.0, -0.40, -0.005), 0.065, 0.30, skin_color)
	_add_sphere_to(_left_arm, "Hand", Vector3(0.0, -0.57, -0.01), Vector3(0.065, 0.075, 0.055), skin_color)
	_add_sphere_to(_right_arm, "Hand", Vector3(0.0, -0.57, -0.01), Vector3(0.065, 0.075, 0.055), skin_color)

	_left_leg = _make_pivot("LeftLeg", Vector3(-0.12, 0.77, 0.0))
	_right_leg = _make_pivot("RightLeg", Vector3(0.12, 0.77, 0.0))
	_add_capsule_to(_left_leg, "Thigh", Vector3(0.0, -0.20, 0.0), 0.105, 0.43, pants_color)
	_add_capsule_to(_right_leg, "Thigh", Vector3(0.0, -0.20, 0.0), 0.105, 0.43, pants_color)
	_add_capsule_to(_left_leg, "Shin", Vector3(0.0, -0.49, 0.0), 0.078, 0.34, pants_color.lightened(0.06))
	_add_capsule_to(_right_leg, "Shin", Vector3(0.0, -0.49, 0.0), 0.078, 0.34, pants_color.lightened(0.06))
	_add_sphere_to(_left_leg, "Shoe", Vector3(0.0, -0.68, -0.055), Vector3(0.095, 0.065, 0.17), Color(0.16, 0.15, 0.13))
	_add_sphere_to(_right_leg, "Shoe", Vector3(0.0, -0.68, -0.055), Vector3(0.095, 0.065, 0.17), Color(0.16, 0.15, 0.13))


func _make_pivot(node_name: String, pivot_position: Vector3) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = node_name
	pivot.position = pivot_position
	add_child(pivot)
	return pivot


func _material(color: Color) -> StandardMaterial3D:
	var key := color.to_html(true)
	if _body_materials.has(key):
		return _body_materials[key] as StandardMaterial3D
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.78
	material.metallic = 0.0
	material.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	_body_materials[key] = material
	return material


func _add_capsule(node_name: String, at: Vector3, radius: float, height: float, color: Color) -> void:
	_add_capsule_to(self, node_name, at, radius, height, color)


func _add_capsule_to(parent: Node3D, node_name: String, at: Vector3, radius: float, height: float, color: Color) -> void:
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	mesh.rings = 5
	_add_mesh(parent, node_name, at, mesh, color)


func _add_sphere(node_name: String, at: Vector3, scale_value: Vector3, color: Color) -> void:
	_add_sphere_to(self, node_name, at, scale_value, color)


func _add_sphere_to(parent: Node3D, node_name: String, at: Vector3, scale_value: Vector3, color: Color) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 16
	mesh.rings = 8
	var instance := _add_mesh(parent, node_name, at, mesh, color)
	instance.scale = scale_value * 2.0


func _add_cylinder(node_name: String, at: Vector3, radius: float, height: float, color: Color) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	_add_mesh(self, node_name, at, mesh, color)


func _add_mesh(parent: Node3D, node_name: String, at: Vector3, mesh: Mesh, color: Color) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.position = at
	instance.mesh = mesh
	instance.material_override = _material(color)
	parent.add_child(instance)
	return instance

extends Node3D
## Môi trường dưới nước: ánh sáng, sương mù xanh lam và bọt khí nổi lên.


func _ready() -> void:
	_setup_environment()
	_setup_light()
	_setup_bubbles()


func _setup_environment() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.03, 0.14, 0.24)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.14, 0.38, 0.52)
	env.ambient_light_energy = 1.15
	env.fog_enabled = true
	env.fog_light_color = Color(0.05, 0.22, 0.34)
	env.fog_density = 0.085
	world_env.environment = env
	add_child(world_env)


func _setup_light() -> void:
	var sun := DirectionalLight3D.new()
	sun.light_color = Color(0.55, 0.85, 0.98)
	sun.light_energy = 1.4
	sun.rotation_degrees = Vector3(-65.0, 20.0, 0.0)
	add_child(sun)


func _setup_bubbles() -> void:
	var particles := GPUParticles3D.new()
	particles.amount = 28
	particles.lifetime = 3.2
	particles.preprocess = 1.5
	particles.position = Vector3(0.0, -2.6, -0.4)

	var proc := ParticleProcessMaterial.new()
	proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	proc.emission_box_extents = Vector3(3.2, 0.4, 1.2)
	proc.direction = Vector3(0.0, 1.0, 0.0)
	proc.spread = 12.0
	proc.initial_velocity_min = 0.6
	proc.initial_velocity_max = 1.2
	proc.gravity = Vector3(0.0, 0.2, 0.0)
	proc.scale_min = 0.6
	proc.scale_max = 1.3
	particles.process_material = proc

	var bubble_mesh := SphereMesh.new()
	bubble_mesh.radius = 0.03
	bubble_mesh.height = 0.06
	bubble_mesh.radial_segments = 8
	bubble_mesh.rings = 4

	var bubble_mat := StandardMaterial3D.new()
	bubble_mat.albedo_color = Color(0.75, 0.94, 1.0, 0.45)
	bubble_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bubble_mat.roughness = 0.1
	bubble_mesh.material = bubble_mat

	particles.draw_pass_1 = bubble_mesh
	add_child(particles)

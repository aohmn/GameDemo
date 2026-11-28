extends Node3D
## Hệ thống VFX dưới nước độc lập (không texture, giới hạn hạt cho Android).
## Chỉ phản hồi dữ liệu hiển thị, không quyết định sát thương hay kết quả gameplay.

var _shockwave: MeshInstance3D
var _shockwave_mat: StandardMaterial3D
var _shockwave_timer: float = 0.0

var _telegraph_ring: MeshInstance3D
var _telegraph_mat: StandardMaterial3D

var _burst_particles: GPUParticles3D


func _ready() -> void:
	_setup_shockwave()
	_setup_telegraph_ring()
	_setup_burst_particles()


func _setup_shockwave() -> void:
	_shockwave = MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.28
	torus.outer_radius = 0.36
	torus.rings = 16
	torus.ring_segments = 8
	_shockwave_mat = StandardMaterial3D.new()
	_shockwave_mat.albedo_color = Color(0.55, 0.92, 1.0, 0.0)
	_shockwave_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_shockwave_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	torus.material = _shockwave_mat
	_shockwave.mesh = torus
	_shockwave.visible = false
	add_child(_shockwave)


func _setup_telegraph_ring() -> void:
	_telegraph_ring = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.48
	sphere.height = 0.96
	sphere.radial_segments = 12
	sphere.rings = 8
	_telegraph_mat = StandardMaterial3D.new()
	_telegraph_mat.albedo_color = Color(1.0, 0.32, 0.18, 0.25)
	_telegraph_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_telegraph_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sphere.material = _telegraph_mat
	_telegraph_ring.mesh = sphere
	_telegraph_ring.visible = false
	add_child(_telegraph_ring)


func _setup_burst_particles() -> void:
	_burst_particles = GPUParticles3D.new()
	_burst_particles.amount = 16
	_burst_particles.lifetime = 0.75
	_burst_particles.one_shot = true
	_burst_particles.explosiveness = 0.9
	_burst_particles.emitting = false

	var proc := ParticleProcessMaterial.new()
	proc.direction = Vector3(0.0, 1.0, 0.0)
	proc.spread = 180.0
	proc.initial_velocity_min = 0.8
	proc.initial_velocity_max = 1.8
	proc.gravity = Vector3(0.0, 0.4, 0.0)
	_burst_particles.process_material = proc

	var p_mesh := SphereMesh.new()
	p_mesh.radius = 0.025
	p_mesh.height = 0.05
	p_mesh.radial_segments = 6
	p_mesh.rings = 4
	var p_mat := StandardMaterial3D.new()
	p_mat.albedo_color = Color(0.8, 0.96, 1.0, 0.7)
	p_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	p_mesh.material = p_mat
	_burst_particles.draw_pass_1 = p_mesh
	add_child(_burst_particles)


func trigger_shockwave(origin: Vector3, color: Color = Color(0.55, 0.92, 1.0)) -> void:
	if _shockwave == null:
		return
	_shockwave.position = origin
	_shockwave.scale = Vector3.ONE * 0.4
	_shockwave.visible = true
	_shockwave_timer = 0.45
	_shockwave_mat.albedo_color = Color(color.r, color.g, color.b, 0.8)
	if _burst_particles != null:
		_burst_particles.position = origin
		_burst_particles.restart()
		_burst_particles.emitting = true


func update_vfx(fish_pos: Vector3, is_telegraphing: bool, delta: float) -> void:
	if _telegraph_ring != null:
		_telegraph_ring.visible = is_telegraphing
		if is_telegraphing:
			_telegraph_ring.position = fish_pos
			var pulse: float = 1.0 + sin(Time.get_ticks_msec() * 0.015) * 0.14
			_telegraph_ring.scale = Vector3.ONE * pulse

	if _shockwave_timer > 0.0 and _shockwave != null:
		_shockwave_timer -= delta
		var progress: float = 1.0 - clampf(_shockwave_timer / 0.45, 0.0, 1.0)
		_shockwave.scale = Vector3.ONE * lerpf(0.4, 2.2, progress)
		_shockwave_mat.albedo_color.a = lerpf(0.8, 0.0, progress)
		if _shockwave_timer <= 0.0:
			_shockwave.visible = false

extends Node3D

## Cần câu, dây câu và phao 3D dựng bằng mesh primitive (không texture).
## Presentation: nghe sự kiện câu cá qua EventBus, nhận hướng ngắm từ Bootstrap, không chứa logic gameplay.

const FishingEventsContract: Script = preload("res://core/contracts/fishing_events.gd")

const WATER_Y: float = -0.15
const HAND_HEIGHT: float = 0.95
const HAND_FORWARD: float = 0.25
const ROD_LENGTH: float = 2.2
const ROD_BASE_RATIO: float = 0.62
const ROD_PITCH_READY: float = 36.0
const ROD_PITCH_STOWED: float = 78.0
const BEND_MAX_DEG: float = 38.0
const CAST_TIME: float = 0.65
const CAST_ARC: float = 1.8
const RETRACT_TIME: float = 0.5
const LINE_SEGMENTS: int = 16
const LINE_HALF_WIDTH: float = 0.03
const BOBBER_RADIUS: float = 0.16

const ROD_COLOR: Color = Color(0.36, 0.22, 0.12)
const LINE_COLOR: Color = Color(0.96, 0.96, 0.9, 0.9)
const LINE_TENSE_COLOR: Color = Color(1.0, 0.35, 0.25, 0.95)
const BOBBER_COLOR: Color = Color(0.9, 0.15, 0.12)
const MARKER_COLOR: Color = Color(1.0, 1.0, 1.0, 0.55)

var _anchor: Node3D
var _facing: Vector3 = Vector3(0.0, 0.0, 1.0)
var _aim_target: Vector3 = Vector3.ZERO
var _aim_valid: bool = false
var _state: String = "IDLE"
var _line_out: bool = false
var _retracting: bool = false
var _flight_t: float = 1.0
var _retract_t: float = 0.0
var _retract_from: Vector3 = Vector3.ZERO
var _cast_target: Vector3 = Vector3.ZERO
var _bobber_pos: Vector3 = Vector3.ZERO
var _tip_pos: Vector3 = Vector3.ZERO
var _tension: float = 0.0
var _tension_target: float = 0.0
var _pitch: float = ROD_PITCH_STOWED
var _clock: float = 0.0

var _rod_base: MeshInstance3D
var _rod_tip: MeshInstance3D
var _bobber: MeshInstance3D
var _line: MeshInstance3D
var _line_mesh: ImmediateMesh
var _line_material: StandardMaterial3D
var _marker: MeshInstance3D


func _ready() -> void:
	_build_nodes()
	_connect_events()


## Gắn cần câu vào một node (thường là nhân vật).
func set_anchor(node: Node3D) -> void:
	_anchor = node


## Bootstrap cập nhật hướng ngắm: hướng nhìn, điểm rơi phao dự kiến và điểm đó có phải mặt nước không.
func set_aim(facing: Vector3, target: Vector3, valid: bool) -> void:
	var flat := Vector3(facing.x, 0.0, facing.z)
	if flat.length_squared() > 0.0001:
		_facing = flat.normalized()
	_aim_target = target
	_aim_valid = valid


func is_line_out() -> bool:
	return _line_out and not _retracting


func get_line_end() -> Vector3:
	return _cast_target


func _process(delta: float) -> void:
	_clock += delta
	var has_anchor: bool = _anchor != null and is_instance_valid(_anchor)
	_rod_base.visible = has_anchor
	_rod_tip.visible = has_anchor
	if not has_anchor:
		_bobber.visible = false
		_marker.visible = false
		_line_mesh.clear_surfaces()
		return
	_tension = lerpf(_tension, _tension_target, clampf(delta * 10.0, 0.0, 1.0))
	_update_rod(delta)
	_update_bobber(delta)
	_update_line()
	_update_marker()


func _hand_position() -> Vector3:
	return _anchor.global_position + Vector3(0.0, HAND_HEIGHT, 0.0) + _facing * HAND_FORWARD


func _update_rod(delta: float) -> void:
	var ready_pose: bool = _aim_valid or is_line_out()
	var want_pitch: float = ROD_PITCH_READY if ready_pose else ROD_PITCH_STOWED
	_pitch = lerpf(_pitch, want_pitch, clampf(delta * 8.0, 0.0, 1.0))
	var hand: Vector3 = _hand_position()
	var dir_h: Vector3 = _facing
	if _line_out:
		var to_bobber: Vector3 = _bobber_pos - hand
		to_bobber.y = 0.0
		if to_bobber.length() > 0.2:
			dir_h = to_bobber.normalized()
	var pitch_r: float = deg_to_rad(_pitch)
	var dir: Vector3 = dir_h * cos(pitch_r) + Vector3.UP * sin(pitch_r)
	var mid: Vector3 = hand + dir * (ROD_LENGTH * ROD_BASE_RATIO)
	var tip_r: float = pitch_r - deg_to_rad(BEND_MAX_DEG) * _tension
	var tip_dir: Vector3 = dir_h * cos(tip_r) + Vector3.UP * sin(tip_r)
	_tip_pos = mid + tip_dir * (ROD_LENGTH * (1.0 - ROD_BASE_RATIO))
	_place_segment(_rod_base, hand, mid)
	_place_segment(_rod_tip, mid, _tip_pos)


func _update_bobber(delta: float) -> void:
	_bobber.visible = _line_out
	if not _line_out:
		return
	if _retracting:
		_retract_t = minf(1.0, _retract_t + delta / RETRACT_TIME)
		var back: Vector3 = _retract_from.lerp(_tip_pos, _retract_t)
		back.y += sin(_retract_t * PI) * 0.8
		_bobber_pos = back
		if _retract_t >= 1.0:
			_line_out = false
			_retracting = false
	elif _flight_t < 1.0:
		_flight_t = minf(1.0, _flight_t + delta / CAST_TIME)
		var fly: Vector3 = _tip_pos.lerp(_cast_target, _flight_t)
		fly.y += sin(_flight_t * PI) * CAST_ARC
		_bobber_pos = fly
	else:
		_bobber_pos = _resting_bobber()
	_bobber.global_position = _bobber_pos


func _resting_bobber() -> Vector3:
	var p: Vector3 = Vector3(_cast_target.x, WATER_Y + 0.02, _cast_target.z)
	match _state:
		"BITE":
			p.y -= 0.10 + sin(_clock * 28.0) * 0.04
		"FIGHT":
			var amp: float = 0.15 + 0.35 * _tension
			p.x += sin(_clock * 6.0) * amp
			p.z += cos(_clock * 5.0) * amp * 0.6
			p.y += sin(_clock * 9.0) * 0.03
		_:
			p.y += sin(_clock * 2.2) * 0.025
	return p


func _update_line() -> void:
	_line_mesh.clear_surfaces()
	if not _line_out:
		return
	var cam: Camera3D = get_viewport().get_camera_3d()
	if cam == null:
		return
	var a: Vector3 = _tip_pos
	var b: Vector3 = _bobber_pos
	var in_flight: bool = _flight_t < 1.0 and not _retracting
	var sag: float = 0.12 if in_flight else lerpf(0.55, 0.04, _tension)
	var view_dir: Vector3 = -cam.global_basis.z
	var side: Vector3 = (b - a).cross(view_dir).normalized() * LINE_HALF_WIDTH
	_line_material.albedo_color = LINE_COLOR.lerp(LINE_TENSE_COLOR, _tension)
	_line_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, _line_material)
	for i in range(LINE_SEGMENTS + 1):
		var t: float = float(i) / float(LINE_SEGMENTS)
		var p: Vector3 = a.lerp(b, t)
		p.y -= sag * 4.0 * t * (1.0 - t)
		_line_mesh.surface_add_vertex(p + side)
		_line_mesh.surface_add_vertex(p - side)
	_line_mesh.surface_end()


func _update_marker() -> void:
	var idle_like: bool = _state == "IDLE" or _state == "RESULT"
	_marker.visible = _aim_valid and not _line_out and idle_like
	if _marker.visible:
		var pulse: float = 1.0 + 0.12 * sin(_clock * 4.0)
		_marker.global_position = Vector3(_aim_target.x, WATER_Y + 0.03, _aim_target.z)
		_marker.scale = Vector3(pulse, 0.05, pulse)


func _place_segment(node: MeshInstance3D, from_pos: Vector3, to_pos: Vector3) -> void:
	var up: Vector3 = (to_pos - from_pos).normalized()
	var ref: Vector3 = Vector3.RIGHT if absf(up.dot(Vector3.RIGHT)) < 0.9 else Vector3.FORWARD
	var x_axis: Vector3 = ref.cross(up).normalized()
	var z_axis: Vector3 = x_axis.cross(up).normalized()
	node.global_transform = Transform3D(Basis(x_axis, up, z_axis), (from_pos + to_pos) * 0.5)


func _build_nodes() -> void:
	var base_len: float = ROD_LENGTH * ROD_BASE_RATIO
	var tip_len: float = ROD_LENGTH * (1.0 - ROD_BASE_RATIO)
	_rod_base = _make_cylinder("RodBase", base_len, 0.03, 0.05)
	_rod_tip = _make_cylinder("RodTip", tip_len, 0.012, 0.03)

	var sphere := SphereMesh.new()
	sphere.radius = BOBBER_RADIUS
	sphere.height = BOBBER_RADIUS * 2.0
	sphere.radial_segments = 10
	sphere.rings = 5
	_bobber = _make_instance("Bobber", sphere, _make_material(BOBBER_COLOR, false))
	_bobber.visible = false

	_line_mesh = ImmediateMesh.new()
	_line_material = _make_material(LINE_COLOR, true)
	_line = _make_instance("FishingLine", _line_mesh, null)
	_line.top_level = true

	var torus := TorusMesh.new()
	torus.inner_radius = 0.3
	torus.outer_radius = 0.45
	torus.rings = 16
	torus.ring_segments = 6
	_marker = _make_instance("CastMarker", torus, _make_material(MARKER_COLOR, true))
	_marker.visible = false


func _make_cylinder(node_name: String, length: float, r_top: float, r_bottom: float) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.height = length
	mesh.top_radius = r_top
	mesh.bottom_radius = r_bottom
	mesh.radial_segments = 6
	mesh.rings = 1
	return _make_instance(node_name, mesh, _make_material(ROD_COLOR, false))


func _make_instance(node_name: String, mesh: Mesh, material: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(node)
	return node


func _make_material(color: Color, unshaded: bool) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	if color.a < 1.0:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if unshaded:
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	else:
		mat.roughness = 0.8
	return mat


func _connect_events() -> void:
	var eb: Node = get_node_or_null("/root/EventBus")
	if eb == null or not eb.has_method("subscribe"):
		return
	eb.call("subscribe", FishingEventsContract.CAST_STARTED, _on_cast_started)
	eb.call("subscribe", FishingEventsContract.STATE_CHANGED, _on_state_changed)
	eb.call("subscribe", FishingEventsContract.FIGHT_UPDATE, _on_fight_update)


func _on_cast_started(_payload: Dictionary) -> void:
	_cast_target = Vector3(_aim_target.x, WATER_Y, _aim_target.z)
	_bobber_pos = _tip_pos
	_flight_t = 0.0
	_line_out = true
	_retracting = false


func _on_state_changed(payload: Dictionary) -> void:
	_state = str(payload.get("to_state", "IDLE"))
	if _state != "FIGHT":
		_tension_target = 0.0
	var finished: bool = _state == "RESULT" or _state == "IDLE"
	if finished and _line_out and not _retracting:
		_retracting = true
		_retract_t = 0.0
		_retract_from = _bobber_pos


func _on_fight_update(payload: Dictionary) -> void:
	var max_t: float = maxf(0.001, float(payload.get("max_tension", 1.0)))
	_tension_target = clampf(float(payload.get("line_tension", 0.0)) / max_t, 0.0, 1.0)

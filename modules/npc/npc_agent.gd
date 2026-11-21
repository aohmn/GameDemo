extends CharacterBody3D
class_name LifeNPC

signal interaction_requested(npc: LifeNPC)

const BODY_COLOR := Color(0.22, 0.48, 0.72)
const SKIN_COLOR := Color(0.82, 0.63, 0.48)
const WALK_SPEED: float = 2.0
const ARRIVAL_DISTANCE: float = 0.8

var npc_id: String = ""
var display_name: String = "NPC"
var age: int = 25
var occupation: String = "Người dân"
var personality: String = "Thân thiện"
var home_position: Vector3 = Vector3.ZERO
var workplace_position: Vector3 = Vector3.ZERO
var shop_position: Vector3 = Vector3.ZERO
var cash_vnd: int = 50000
var current_activity: String = "Ở nhà"
var _route: PackedVector3Array = PackedVector3Array()
var _route_index: int = 0
var _destination: Vector3 = Vector3.ZERO
var _last_schedule_key: String = ""
var _body_mesh: MeshInstance3D


func configure(profile: NPCProfile) -> void:
	if profile == null:
		push_error("LifeNPC: cannot configure from a null profile.")
		return
	npc_id = profile.npc_id
	display_name = profile.display_name
	age = profile.age
	occupation = profile.occupation
	personality = profile.personality
	home_position = profile.home_position
	workplace_position = profile.workplace_position
	shop_position = profile.shop_position
	cash_vnd = maxi(0, profile.cash_vnd)
	name = "NPC_%s" % npc_id


func _ready() -> void:
	_build_visual()
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 0.2
	set_physics_process(true)


func update_schedule(hour: int) -> void:
	var schedule_key := String(JobService.get_activity(hour))
	var target := home_position
	var activity := "Ở nhà"
	if schedule_key == "work":
		target = workplace_position
		activity = "Đi làm: %s" % occupation
	elif schedule_key == "shopping":
		target = shop_position
		activity = "Mua sắm"
	if schedule_key == _last_schedule_key:
		return
	_last_schedule_key = schedule_key
	current_activity = activity
	_set_destination(target)


func _physics_process(delta: float) -> void:
	if _route_index >= _route.size():
		velocity.x = move_toward(velocity.x, 0.0, 8.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 8.0 * delta)
		return
	var waypoint := _route[_route_index]
	var flat_target := Vector3(waypoint.x, global_position.y, waypoint.z)
	var offset := flat_target - global_position
	if offset.length() <= ARRIVAL_DISTANCE:
		_route_index += 1
		return
	var direction := offset.normalized()
	velocity.x = direction.x * WALK_SPEED
	velocity.z = direction.z * WALK_SPEED
	if direction.length_squared() > 0.01:
		look_at(global_position + direction, Vector3.UP)
	move_and_slide()


func get_dialogue() -> String:
	return "%s: Chào bạn! Tôi làm nghề %s. Hiện tại tôi đang: %s." % [display_name, occupation, current_activity]


func serialize_state() -> Dictionary:
	return {
		"version": 1,
		"position": [global_position.x, global_position.y, global_position.z],
		"cash_vnd": cash_vnd,
		"activity": current_activity,
		"schedule_key": _last_schedule_key
	}


func deserialize_state(data: Dictionary) -> bool:
	if int(data.get("version", -1)) != 1:
		return false
	var position_data: Variant = data.get("position", [])
	if not (position_data is Array) or position_data.size() != 3:
		return false
	global_position = Vector3(float(position_data[0]), float(position_data[1]), float(position_data[2]))
	cash_vnd = maxi(0, int(data.get("cash_vnd", cash_vnd)))
	current_activity = str(data.get("activity", current_activity))
	_last_schedule_key = ""
	update_schedule(GameClock.get_hour())
	return true


func _set_destination(target: Vector3) -> void:
	_destination = target
	_route_index = 0
	if global_position.distance_to(target) <= ARRIVAL_DISTANCE:
		_route = PackedVector3Array()
		return
	_route = NavigationService.find_route(global_position, target)
	if _route.is_empty():
		_route = PackedVector3Array([target])
	elif _route[_route.size() - 1].distance_to(target) > ARRIVAL_DISTANCE:
		_route.append(target)


func _build_visual() -> void:
	var body := MeshInstance3D.new()
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.28
	body_mesh.height = 1.25
	body.mesh = body_mesh
	body.position.y = 0.78
	body.material_override = _make_material(BODY_COLOR)
	add_child(body)
	_body_mesh = body

	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.22
	head_mesh.height = 0.44
	head.mesh = head_mesh
	head.position = Vector3(0.0, 1.55, 0.0)
	head.material_override = _make_material(SKIN_COLOR)
	add_child(head)

	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.28
	shape.height = 1.5
	collision.shape = shape
	collision.position.y = 0.75
	add_child(collision)

	var name_label := Label3D.new()
	name_label.text = display_name
	name_label.position.y = 2.0
	name_label.font_size = 28
	name_label.outline_size = 5
	name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(name_label)


func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	return material

extends Node3D

## Dev: chạy riêng cần câu, dây và phao. Giả lập vòng câu bằng sự kiện EventBus (không cần module fishing).

const RIG_SCENE: PackedScene = preload("res://presentation/fishing_rig/fishing_rig.tscn")
const FishingEventsContract: Script = preload("res://core/contracts/fishing_events.gd")

# [giây, tên bước]
const SCRIPT_STEPS: Array[Array] = [
	[1.0, "cast"], [2.2, "WAITING"], [4.0, "BITE"], [4.8, "FIGHT"], [8.0, "RESULT"], [10.0, "IDLE"],
]

var _rig: Node3D
var _anchor: Node3D
var _clock: float = 0.0
var _next_step: int = 0


func _ready() -> void:
	_create_world()
	_anchor = Node3D.new()
	_anchor.name = "Anchor"
	_anchor.position = Vector3(0.0, 0.0, -0.5)
	add_child(_anchor)
	_rig = RIG_SCENE.instantiate() as Node3D
	add_child(_rig)
	_rig.call("set_anchor", _anchor)
	_rig.call("set_aim", Vector3(0.0, 0.0, 1.0), Vector3(0.0, -0.15, 2.7), true)


func _process(delta: float) -> void:
	_clock += delta
	if _next_step >= SCRIPT_STEPS.size():
		return
	if _clock >= float(SCRIPT_STEPS[_next_step][0]):
		_run_step(str(SCRIPT_STEPS[_next_step][1]))
		_next_step += 1


func _run_step(step: String) -> void:
	var eb: Node = get_node_or_null("/root/EventBus")
	if eb == null:
		return
	if step == "cast":
		eb.call("emit_event", FishingEventsContract.STATE_CHANGED, {"from_state": "IDLE", "to_state": "CASTING"})
		eb.call("emit_event", FishingEventsContract.CAST_STARTED, {"spot_id": "dev", "rod_id": "dev"})
		return
	eb.call("emit_event", FishingEventsContract.STATE_CHANGED, {"from_state": "", "to_state": step})
	if step == "FIGHT":
		eb.call("emit_event", FishingEventsContract.FIGHT_UPDATE, {"line_tension": 80.0, "max_tension": 100.0})


func _create_world() -> void:
	var land := _box("Land", Vector3(10.0, 0.4, 4.0), Vector3(0.0, -0.2, -2.0), Color(0.92, 0.84, 0.62))
	add_child(land)
	var water := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(30.0, 30.0)
	water.mesh = plane
	water.position = Vector3(0.0, -0.15, 0.0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.1, 0.45, 0.6)
	water.material_override = mat
	add_child(water)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-50.0, -35.0, 0.0)
	add_child(light)
	var cam := Camera3D.new()
	add_child(cam)
	cam.look_at_from_position(Vector3(0.0, 5.0, 8.0), Vector3(0.0, 0.5, 1.0))
	cam.current = true


func _box(node_name: String, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	node.material_override = mat
	return node

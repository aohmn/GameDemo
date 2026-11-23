## TransitionBuilder: dung cong chuyen map co hinh khoi that, bien hieu Label3D.
## Cong KHONG tu chuyen map; phat DestinationEvents.GATE_ENTERED / GATE_EXITED
## de TravelPanel UI hien bang chon diem den.
extends RefCounted
class_name TransitionBuilder
const DestinationEvents = preload("res://core/contracts/destination_events.gd")

## Mau cau truc cong (nen cong + tru)
const GATE_COLOR := Color(0.25, 0.55, 0.85, 1.0)
const PILLAR_COLOR := Color(0.20, 0.45, 0.72, 1.0)
const BEAM_COLOR := Color(0.18, 0.40, 0.65, 1.0)

## spec Dictionary co cac key:
##   name, position, size, sign_text, gate_id,
##   destinations: Array[Dictionary] voi moi dict co key: id, display_name,
##     scene_path, spawn_id, unlocked
static func build(specs: Array[Dictionary], parent: Node3D) -> void:
	for spec: Dictionary in specs:
		_build_one(spec, parent)


static func _build_one(spec: Dictionary, parent: Node3D) -> void:
	var gate_id: String = str(spec.get("gate_id", spec.get("name", "gate")))
	var pos: Vector3 = spec.get("position", Vector3.ZERO)
	var sz: Vector3 = spec.get("size", Vector3(5.0, 3.0, 3.0))
	var sign_text: String = str(spec.get("sign_text", gate_id))
	var destinations: Array = spec.get("destinations", [])

	# --- Root node ---
	var root := Node3D.new()
	root.name = gate_id
	root.position = pos
	parent.add_child(root)

	# --- Hinh khoi cong vat ly (StaticBody3D) ---
	_build_gate_arch(root, sz)

	# --- Bien hieu noi bat ---
	var label := Label3D.new()
	label.name = "GateSign"
	label.text = sign_text
	label.position = Vector3(0.0, sz.y + 0.5, 0.0)
	label.font_size = 52
	label.outline_size = 10
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.modulate = Color(1.0, 0.95, 0.5, 1.0)
	root.add_child(label)

	# --- Area3D phat event (KHONG tu chuyen map) ---
	var area := Area3D.new()
	area.name = "GateArea"
	area.collision_layer = 0
	area.collision_mask = 1

	var shape := BoxShape3D.new()
	shape.size = sz
	var col := CollisionShape3D.new()
	col.shape = shape
	col.position = Vector3(0.0, sz.y * 0.5, 0.0)
	area.add_child(col)
	root.add_child(area)

	# Luu destinations vao metadata de dung trong callback
	area.set_meta(&"gate_id", gate_id)
	area.set_meta(&"destinations", destinations)
	area.set_meta(&"player_inside", false)

	area.body_entered.connect(_on_body_entered.bind(area))
	area.body_exited.connect(_on_body_exited.bind(area))


## Dung kien truc cong (2 tru + xam ngang) khong texture
static func _build_gate_arch(root: Node3D, sz: Vector3) -> void:
	var pillar_w: float = maxf(0.3, sz.x * 0.08)
	var pillar_h: float = sz.y
	var beam_h: float = maxf(0.2, sz.y * 0.12)
	var depth: float = sz.z

	# Tru trai
	_add_box(root, "PillarL",
		Vector3(-sz.x * 0.5 + pillar_w * 0.5, pillar_h * 0.5, 0.0),
		Vector3(pillar_w, pillar_h, depth),
		PILLAR_COLOR)
	# Tru phai
	_add_box(root, "PillarR",
		Vector3(sz.x * 0.5 - pillar_w * 0.5, pillar_h * 0.5, 0.0),
		Vector3(pillar_w, pillar_h, depth),
		PILLAR_COLOR)
	# Dam ngang tren
	_add_box(root, "Beam",
		Vector3(0.0, pillar_h + beam_h * 0.5, 0.0),
		Vector3(sz.x, beam_h, depth),
		BEAM_COLOR)


static func _add_box(parent: Node3D, box_name: String,
		local_pos: Vector3, box_size: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.name = box_name

	var mesh_inst := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = box_size
	mesh_inst.mesh = box_mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh_inst.material_override = mat
	body.add_child(mesh_inst)

	var col := CollisionShape3D.new()
	var col_shape := BoxShape3D.new()
	col_shape.size = box_size
	col.shape = col_shape
	body.add_child(col)

	body.position = local_pos
	parent.add_child(body)


static func _on_body_entered(body: Node3D, area: Area3D) -> void:
	var player := area.get_tree().get_first_node_in_group("player")
	if body != player:
		return
	if bool(area.get_meta(&"player_inside", false)):
		return
	area.set_meta(&"player_inside", true)

	var gate_id: String = str(area.get_meta(&"gate_id", ""))
	var destinations: Array = area.get_meta(&"destinations", [])
	EventBus.emit_event(DestinationEvents.GATE_ENTERED, {
		"gate_id": gate_id,
		"destinations": destinations,
	})


static func _on_body_exited(body: Node3D, area: Area3D) -> void:
	var player := area.get_tree().get_first_node_in_group("player")
	if body != player:
		return
	if not bool(area.get_meta(&"player_inside", false)):
		return
	area.set_meta(&"player_inside", false)

	var gate_id: String = str(area.get_meta(&"gate_id", ""))
	EventBus.emit_event(DestinationEvents.GATE_EXITED, {"gate_id": gate_id})

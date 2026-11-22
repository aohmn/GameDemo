## Transitions: điểm chuyển map — Area3D + Label3D điểm đích.
extends RefCounted
class_name TransitionBuilder

static func build(specs: Array[Dictionary], parent: Node3D, on_enter: Callable) -> void:
	for i in range(specs.size()):
		var spec: Dictionary = specs[i]
		var area := Area3D.new()
		area.name = spec["name"]
		area.collision_layer = 0
		area.collision_mask = 1
		area.position = spec["position"]

		var shape := BoxShape3D.new()
		shape.size = spec["size"]
		var collision := CollisionShape3D.new()
		collision.shape = shape
		area.add_child(collision)

		var sign := Label3D.new()
		sign.name = "DestinationName"
		sign.text = spec["sign_text"]
		sign.position = Vector3(0.0, 2.0, 0.0)
		sign.font_size = 48
		sign.outline_size = 8
		sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		sign.no_depth_test = true
		area.add_child(sign)

		area.body_entered.connect(on_enter.bind(spec["dest_scene"]))
		parent.add_child(area)

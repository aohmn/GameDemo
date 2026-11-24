extends Node3D

const TerrainBuilder: Script = preload("res://maps/harbor_island/builders/terrain_builder.gd")
const PierBuilder: Script = preload("res://maps/harbor_island/builders/pier_builder.gd")
const PropBuilder: Script = preload("res://maps/harbor_island/builders/prop_builder.gd")
const SectBuildingBuilder: Script = preload("res://maps/harbor_island/builders/sect_building_builder.gd")
const PlazaPathBuilder: Script = preload("res://maps/harbor_island/builders/plaza_path_builder.gd")

## Hướng TỚI mặt trời chuẩn của bản đồ đảo harbor_island.
## Đây là nguồn duy nhất (single source of truth) được Bootstrap đồng bộ sang SkyDome và water shader.
const SUN_DIRECTION: Vector3 = Vector3(-0.368688, 0.766044, 0.526541)


func _ready() -> void:
	TerrainBuilder.build(self)
	PierBuilder.build(self)
	PlazaPathBuilder.build(self)
	SectBuildingBuilder.build(self)
	PropBuilder.build(self)



## Trả về vector đơn vị hướng TỚI mặt trời.
func get_sun_direction() -> Vector3:
	return SUN_DIRECTION


## Lấy ShaderMaterial của mặt nước đại dương để cập nhật uniform.
func get_water_material() -> ShaderMaterial:
	var ocean_node := get_node_or_null("OceanSurface") as MeshInstance3D
	if ocean_node != null:
		return ocean_node.material_override as ShaderMaterial
	return null


## Điểm (x, z) trong thế giới có phải mặt nước không: tia thẳng đứng từ trên xuống không chạm bãi, cầu, thuyền, vách hay cây.
func is_water_at(world_pos: Vector3) -> bool:
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var from_pos := Vector3(world_pos.x, 8.0, world_pos.z)
	var to_pos := Vector3(world_pos.x, -0.6, world_pos.z)
	var query := PhysicsRayQueryParameters3D.create(from_pos, to_pos)
	return space.intersect_ray(query).is_empty()

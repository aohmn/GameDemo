extends Node3D

const TerrainBuilder: Script = preload("res://maps/harbor_island/builders/terrain_builder.gd")
const PierBuilder: Script = preload("res://maps/harbor_island/builders/pier_builder.gd")
const PropBuilder: Script = preload("res://maps/harbor_island/builders/prop_builder.gd")

## Hướng TỚI mặt trời chuẩn của bản đồ đảo harbor_island.
## Đây là nguồn duy nhất (single source of truth) được Bootstrap đồng bộ sang SkyDome và water shader.
const SUN_DIRECTION: Vector3 = Vector3(-0.368688, 0.766044, 0.526541)


func _ready() -> void:
	TerrainBuilder.build(self)
	PierBuilder.build(self)
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


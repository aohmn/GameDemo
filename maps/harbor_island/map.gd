extends Node3D

const TerrainBuilder: Script = preload("res://maps/harbor_island/builders/terrain_builder.gd")
const IslandBuilder: Script = preload("res://maps/harbor_island/builders/island_builder.gd")
const PeakBuilder: Script = preload("res://maps/harbor_island/builders/peak_builder.gd")
const PagodaBuilder: Script = preload("res://maps/harbor_island/builders/pagoda_builder.gd")
const FloraBuilder: Script = preload("res://maps/harbor_island/builders/flora_builder.gd")
const PierBuilder: Script = preload("res://maps/harbor_island/builders/pier_builder.gd")
const SectBuildingBuilder: Script = preload("res://maps/harbor_island/builders/sect_building_builder.gd")
const PlazaPathBuilder: Script = preload("res://maps/harbor_island/builders/plaza_path_builder.gd")

## Hướng TỚI mặt trời chuẩn của bản đồ đảo harbor_island.
## Đây là nguồn duy nhất (single source of truth) được Bootstrap đồng bộ sang SkyDome và water shader.
const SUN_DIRECTION: Vector3 = Vector3(-0.368688, 0.766044, 0.526541)


func _ready() -> void:
	TerrainBuilder.build(self)
	IslandBuilder.build(self)
	PeakBuilder.build(self)
	PierBuilder.build(self)
	PlazaPathBuilder.build(self)
	SectBuildingBuilder.build(self)
	PagodaBuilder.build(self)
	FloraBuilder.build(self)



## Trả về vector đơn vị hướng TỚI mặt trời.
func get_sun_direction() -> Vector3:
	return SUN_DIRECTION


## Lấy ShaderMaterial của mặt nước đại dương để cập nhật uniform.
func get_water_material() -> ShaderMaterial:
	var ocean_node := get_node_or_null("OceanSurface") as MeshInstance3D
	if ocean_node != null:
		return ocean_node.material_override as ShaderMaterial
	return null


## Ao sen (Hồ Linh Ngư) ở bậc ao: tâm, bán kính và cao độ mặt nước.
const POND_CENTER: Vector2 = Vector2(0.0, -11.2)
const POND_RADIUS: float = 3.0
const POND_WATER_Y: float = 1.23
const SEA_WATER_Y: float = -0.15


func _in_pond(world_pos: Vector3) -> bool:
	return (Vector2(world_pos.x, world_pos.z) - POND_CENTER).length() < POND_RADIUS


## Điểm (x, z) có phải mặt nước không: mặt ao sen là nước; còn lại dùng tia thẳng đứng
## từ trên xuống, không chạm bãi, cầu, thuyền, vách hay cây thì là nước.
func is_water_at(world_pos: Vector3) -> bool:
	if _in_pond(world_pos):
		return true
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var from_pos := Vector3(world_pos.x, 14.0, world_pos.z)
	var to_pos := Vector3(world_pos.x, -0.6, world_pos.z)
	var query := PhysicsRayQueryParameters3D.create(from_pos, to_pos)
	return space.intersect_ray(query).is_empty()


## ID điểm câu theo vị trí phao: "spot_ho_linh_ngu" trên ao sen, "spot_cau_tau_ben_cang" ở biển.
func get_fishing_spot_at(world_pos: Vector3) -> String:
	if _in_pond(world_pos):
		return "spot_ho_linh_ngu"
	return "spot_cau_tau_ben_cang"


## Cao độ mặt nước tại điểm (ao sen cao hơn biển) để phao/dây đặt đúng mặt nước.
func get_water_height_at(world_pos: Vector3) -> float:
	return POND_WATER_Y if _in_pond(world_pos) else SEA_WATER_Y

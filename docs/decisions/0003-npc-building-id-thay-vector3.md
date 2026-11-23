# 0003 — NPC dung building_id thay vi Vector3 cung co

**Ngay**: 2026-11-23
**Trang thai**: Da ap dung

## Boi canh

NPCProfile truoc day luu `home_position`, `workplace_position`, `shop_position`
kieu Vector3 truc tiep trong file `.tres`. Dieu nay vi pham nguyen tac
"nguon du lieu duy nhat" (AGENTS phan 6): toa do toa nha da co trong
`hub_layout.tres` / `BuildingSpec.door_point`, nhung NPC lai co ban sao rieng.
Khi di chuyen toa nha, phai sua ca `hub_layout.tres` lan cac `.tres` NPC.

## Quyet dinh

Thay the 3 truong Vector3 bang 3 truong String:
- `home_building_id`
- `workplace_building_id`
- `shop_building_id`

Toa do thuc duoc giai quyet tai runtime qua flow:
1. `MapArea.build_content()` → `_emit_buildings_ready()`
2. `WorldEvents.BUILDINGS_READY` phat Dictionary `{id: door_point}`
3. `NPCDirector._on_buildings_ready()` luu vao `_building_doors`
4. `LifeNPC.set_building_doors(doors)` tra building_id → Vector3
5. `LifeNPC.place_at_current_schedule(activity)` dat vi tri ban dau

NPC KHONG import code world (AGENTS phan 5); moi giao tiep la
Dictionary qua EventBus.

## Hau qua

- Them NPC = them file `.tres` + 3 truong String. Khong sua code.
- Di chuyen toa nha = sua `hub_layout.tres` (mot noi). NPC tu dong cap nhat.
- Khong con ban sao toa do nhan viec o hai noi.

## Thu tuc cap nhat

- `modules/npc/npc_profile.gd`: xoa 3 truong Vector3, them 3 truong String.
- `modules/npc/data/lan.tres`, `minh.tres`: cap nhat theo building_id moi.
- `modules/npc/npc_agent.gd`: them `set_building_doors()`, `place_at_current_schedule()`.
- `modules/npc/npc_director.gd`: dang ky nghe `BUILDINGS_READY`.
- `world/map/areas/map_area.gd`: them `_emit_buildings_ready()`.
- `core/contracts/world_events.gd`: them hang so `BUILDINGS_READY`.

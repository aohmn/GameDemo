# Module Dependency Survey (Phase 0)

## Autoloads (project.godot)
- EventBus, GameClock, SaveCoordinator, EconomyService.

## Modules
Player, NPC (Director/Agent/Profile), Needs (component), Economy, Jobs, Shops, Navigation, World/Map controller, Minimap, PlayerHUD, Save.

## Dependency graph (direct)
- NPCDirector preloads NPCAgent; accesses parent Player; calls ShopService.get_goods(); group save.
- NPCAgent calls JobService.get_activity, NavigationService.find_route, GameClock.
- Minimap preloads NavigationService; holds npc_director ref; reads Player.
- Map3DController preloads Minimap, SurfaceShader, NPCDirector; builds world; sets minimap npc_director.
- PlayerController accesses joystick via get_node; Needs via get_node; visual via get_node.
- PlayerHUD accesses map_root Player and Needs via get_node.
- SaveCoordinator iterates save_participant group and calls serialize/deserialize.

## Cross-module violations
- NPC -> Jobs, Navigation, Shop, GameClock (direct calls).
- Minimap -> Player, NPCDirector (direct refs).
- MapController -> NPCDirector (preload/instantiation), Minimap.
- PlayerHUD -> Player/Needs.
- PlayerController -> Needs/Visual/Joystick.

## Proposed phases
1. Survey done.
2. Core contracts & events.
3. Decouple NPC.
4. Decouple Minimap.
5. Split MapController responsibilities.
6. Standardize Player/Needs/Economy/Inventory/Jobs/Shops/Social.
7. Navigation/World.
8. Save/Load.
9. Verification.

## Notes
No implementation yet. Awaiting approval.
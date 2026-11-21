# Module Dependency Survey

Cập nhật theo mã nguồn hiện tại. Mục tiêu: module không gọi trực tiếp module
gameplay khác; giao tiếp qua EventBus hoặc API được đăng ký.

## Autoloads (project.godot)
Thứ tự: `EventBus`, `GameClock`, `JobSystem`, `WorldNavigation`,
`SaveCoordinator`, `EconomyService`.

- `EventBus` — phát/nhận sự kiện.
- `GameClock` — nguồn thời gian duy nhất.
- `JobSystem` — đọc GameClock/JobService, phát lịch qua `JobEvents`.
- `WorldNavigation` — nhận `ROUTE_REQUESTED`, phát `ROUTE_READY`.
- `SaveCoordinator` — điều phối participant đăng ký độc lập.
- `EconomyService` — nguồn số dư VND.

## Modules và contract sở hữu
- Core: `core/events` (`CoreEvents`, EventBus), `core/contracts`
  (`PlayerEvents`, `WorldEvents`), `core/services` (GameClock, SaveCoordinator).
- Player: `player_controller.gd` (sở hữu health/movement, dùng `PlayerEvents`).
- Needs: `player_needs.gd` (dùng `PlayerEvents`).
- Visual/Sprite: `player_visual.gd`, `player_sprite.gd` (subscribe
  `PlayerEvents.MOTION_CHANGED`).
- HUD/Joystick: `player_hud.gd`, `virtual_joystick.gd` (dùng `PlayerEvents` +
  `CoreEvents`).
- NPC: `npc_director.gd`, `npc_agent.gd` (dùng `JobEvents`, `WorldEvents`).
- Jobs: `job_service.gd`, `job_events.gd`, `job_system.gd` (autoload).
- Navigation: `navigation_service.gd` (autoload `WorldNavigation`, dùng
  `WorldEvents`).
- World/Map: `map_controller.gd` (dựng địa hình, xử lý recovery qua
  `WorldEvents.PLAYER_RECOVERY_REQUESTED`).
- Minimap: `minimap.gd` (dùng `WorldEvents`).
- Economy: `economy_service.gd` (save qua `SAVE_ID`).

## Dependency graph (hiện tại)
- Player → `PlayerEvents`, `WorldEvents`, `SaveCoordinator` (API đăng ký).
- Needs → `GameClock`, `PlayerEvents`, `SaveCoordinator` (API đăng ký).
- Visual/Sprite → `PlayerEvents` (chỉ nhận), EventBus.
- HUD → `PlayerEvents`, `CoreEvents` (chỉ event).
- Joystick → `PlayerEvents` (chỉ phát).
- NPCDirector → `JobEvents` (nhận), `WorldEvents` (nhận/phát),
  `SaveCoordinator` (API đăng ký).
- LifeNPC → `WorldEvents` (ROUTE_REQUESTED/ROUTE_READY), EventBus.
- JobSystem → `GameClock`, `JobService`, `JobEvents`, `CoreEvents`.
- WorldNavigation → `WorldEvents`, `AStar2D`.
- MapController → `WorldEvents` (recovery), preload shader của chính nó.
- Minimap → `WorldEvents` (vị trí Player/NPC, tuyến đường).
- EconomyService → `SaveCoordinator` (đăng ký bởi Bootstrap).

## Điểm đã tách khỏi phụ thuộc trực tiếp
- NPC không còn gọi `JobService`, `NavigationService`, `GameClock`,
  `ShopService`; lịch đi qua `JobSystem`/`JobEvents`, tuyến đi qua
  `WorldNavigation`.
- Minimap không còn tham chiếu `Player` hay `NPCDirector`; nhận vị trí qua
  `WorldEvents`.
- MapController không còn preload/tạo `NPCDirector` hay `Minimap`; hai module là
  node độc lập trong scene.
- PlayerController không còn truy cập `Needs`, `Visual`, `Joystick` qua node
  path; dùng `PlayerEvents`.
- PlayerHUD không còn đọc node Player/Needs; dùng event.
- SaveCoordinator không còn quét group `save_participant` hay tham chiếu
  GameClock; dùng `register_participant(save_id, participant)` và migrate save
  v1 (`clock` → participant `game_clock`).

## Contract công khai
- `core/contracts/player_events.gd` — `PlayerEvents`.
- `core/contracts/world_events.gd` — `WorldEvents`.
- `modules/jobs/job_events.gd` — `JobEvents`.
- `core/events/core_events.gd` — `CoreEvents`.
- `core/services/save_coordinator.gd` — API participant.

## Giới hạn còn lại
- `player_needs.gd` vẫn đọc `GameClock` trực tiếp (module Needs dùng thời gian
  chung; đây là phụ thuộc Core, không phải module gameplay).
- HUD vẫn dùng event thời gian của GameClock qua `CoreEvents` (Core → Presentation).
- Chưa có TransactionCoordinator/Inventory nên giao dịch kinh tế chưa atomic.
- Chưa có kiểm thử runtime trên Godot Android sau đợt tách module.

## Verification
- Toàn bộ `.gd` đã kiểm tra cú pháp bằng `gdparse`.
- Đã grep toàn repo: không còn `save_participant`, `NAVIGATION_SERVICE`,
  `NPC_DIRECTOR_SCRIPT`, `MINIMAP_SCRIPT`.
- Chưa mở Godot Android; chưa xác nhận runtime.

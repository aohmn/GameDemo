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
  (`PlayerEvents`, `WorldEvents`, `JobEvents`), `core/services` (GameClock,
  SaveCoordinator), `core/bootstrap` (composition root).
- Player: `modules/player/player_controller.gd` (sở hữu health/movement, dùng `PlayerEvents`).
- Needs: `modules/needs/player_needs.gd` (dùng `PlayerEvents`).
- Visual/Sprite: `player_visual.gd`, `player_sprite.gd` (subscribe
  `PlayerEvents.MOTION_CHANGED`).
- HUD/Joystick: `player_hud.gd`, `virtual_joystick.gd` (dùng `PlayerEvents` +
  `CoreEvents`).
- NPC: `npc_director.gd`, `npc_agent.gd` (dùng `JobEvents`, `WorldEvents`).
- Jobs: `job_service.gd`, `job_system.gd` (autoload); contract `JobEvents` ở Core.
- Navigation: `navigation_service.gd` (autoload `WorldNavigation`, dùng
  `WorldEvents`).
- World/Map: `map_controller.gd` (dựng địa hình, xử lý recovery qua
  `WorldEvents.PLAYER_RECOVERY_REQUESTED`, yêu cầu đổi map qua
  `WorldEvents.MAP_CHANGE_REQUESTED`).
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
- MapController → `WorldEvents` (recovery, map change), preload shader của chính nó.
- Minimap → `WorldEvents` (vị trí Player/NPC, tuyến đường).
- EconomyService → `SaveCoordinator` (đăng ký bởi Bootstrap nếu tồn tại).
- Bootstrap → Core services + tùy chọn `presentation/player_sprite/player_sprite.tscn`,
  `modules/npc/npc_director.gd`, `/root/EconomyService`.

## Điểm đã tách khỏi phụ thuộc trực tiếp
- NPC không còn gọi `JobService`, `NavigationService`, `GameClock`,
  `ShopService`; lịch đi qua `JobSystem`/`JobEvents`, tuyến đi qua
  `WorldNavigation`.
- Minimap không còn tham chiếu `Player` hay `NPCDirector`; nhận vị trí qua
  `WorldEvents`.
- MapController không còn preload/tạo `NPCDirector` hay `Minimap`; Minimap là
  node độc lập trong scene.
- Scene world không còn `ext_resource` tới `player_sprite.tscn` hay
  `npc_director.gd`; Bootstrap gắn `Visual` và `NPCDirector` lúc chạy nếu module
  tồn tại. Xóa `presentation/` hoặc `modules/npc/` không làm hỏng scene.
- `boot.gd` không tham chiếu `EconomyService` ở compile-time; dùng
  `get_node_or_null("/root/EconomyService")` + kiểm tra null.
- `JobEvents` chuyển sang `core/contracts/`; NPC không còn tham chiếu thư mục
  `modules/jobs`.
- Đổi map đi qua `WorldEvents.MAP_CHANGE_REQUESTED`; Bootstrap giữ vòng đời map
  để gắn lại Presentation/NPC cho map mới. Fallback `change_scene_to_file()`
  khi không có Bootstrap.
- PlayerController không còn truy cập `Needs`, `Visual`, `Joystick` qua node
  path; dùng `PlayerEvents`.
- PlayerHUD không còn đọc node Player/Needs; dùng event.
- SaveCoordinator không còn quét group `save_participant` hay tham chiếu
  GameClock; dùng `register_participant(save_id, participant)` và migrate save
  v1 (`clock` → participant `game_clock`).

## Contract công khai
- `core/contracts/player_events.gd` — `PlayerEvents`.
- `core/contracts/world_events.gd` — `WorldEvents` (gồm `MAP_CHANGE_REQUESTED`).
- `core/contracts/job_events.gd` — `JobEvents`.
- `core/events/core_events.gd` — `CoreEvents`.
- `core/events/event_bus.gd` — API EventBus, gồm `has_listeners()`.
- `core/services/save_coordinator.gd` — API participant.

## Giới hạn còn lại
- `modules/needs/player_needs.gd` vẫn đọc `GameClock` trực tiếp (module Needs dùng thời gian
  chung; đây là phụ thuộc Core, không phải module gameplay).
- HUD vẫn dùng event thời gian của GameClock qua `CoreEvents` (Core → Presentation).
- Chưa có TransactionCoordinator/Inventory nên giao dịch kinh tế chưa atomic.
- Chưa có kiểm thử runtime trên Godot Android sau đợt tách module.

## Verification
- Toàn bộ `.gd` đã kiểm tra cú pháp bằng `gdparse`.
- Đã grep toàn repo: không còn `save_participant`, `NAVIGATION_SERVICE`,
  `NPC_DIRECTOR_SCRIPT`, `MINIMAP_SCRIPT`, không còn tham chiếu
  `modules/jobs/job_events`.
- Import headless Godot 4.7 + boot 150 frame trên bản sao sạch: không
  `Parse Error`.
- Đã xóa lần lượt `modules/jobs`, `modules/npc`, `modules/shops`,
  `modules/economy`, `presentation` rồi import + boot 150 frame: không
  `Parse Error`; chỉ còn lỗi thiếu autoload `JobSystem`/`EconomyService` đúng
  như dự kiến. Bảng chi tiết ở `CHANGELOG.md`.
- Ảnh chụp boot trước/sau giống hệt (SHA-256 trùng).
- Chưa mở Godot Android; chưa xác nhận runtime trên thiết bị.

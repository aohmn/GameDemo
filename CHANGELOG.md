# CHANGELOG

## Bugfix: MapArea dựng nội dung, không trùng Player/HUD, NPC cập nhật theo map

- `MapArea._ready()` gọi `build_content()` đúng 1 lần/map instance:
  - Hub dựng nền + đường chính + đường dọc + cổng chuyển sang hồ câu.
  - Hồ câu dựng địa hình (LakeWater, LakeBanks, DirtPath, FishingDock, cây
    quanh hồ) — không tạo nội dung trùng khi chuyển map.
- `hub_map.tscn` — bỏ Player, HUD, Joystick, Minimap — chỉ giữ root HubMap;
  Player/Camera/HUD/Joystick/Minimap chỉ nằm trong `shared_map.tscn`.
- `Bootstrap._attach_npc_director` — mỗi lần chuyển map: xóa NPCDirector cũ;
  map `npc_spawn_enabled = false` → không tạo NPC; bật → tạo mới đúng số lượng.

### Kiểm tra (§11)
- `gdparse` cho các .gd liên quan — chạy, không lỗi.
- Grep: Player/HUD chỉ nằm trong shared_map.tscn; Player không bị nhân đôi trong
  hub_map/fishing_lake_map.
- Chưa xác nhận trên Godot Android.

## Thiết kế map mới: bản đồ trung tâm 40×40m + khu vực độc lập

- Thu nhỏ bản đồ chính (hub): 40×40m — chỉ nền + đường chính (`RoadMain`) +
  đường dọc đi qua (`RoadSpine`) + lối chuyển vào Hồ câu. Không còn nhà, cây,
  công trình hay hồ cá lẫn vào hub.
- Tách hệ thống chung ra `scenes/shared/shared_map.tscn`: Player, Camera, HUD,
  Joystick, Minimap — độc lập với nội dung từng map. Nối NPCDirector vào shared
  scene thay vì map.
- Tách nội dung map thành modules: `world/map/areas/` (MapArea, HubMapArea,
  FishingLakeMapArea) + `world/map/content/` (ground_builder, road_builder,
  building_builder, tree_builder, object_builder, transition_builder).
  Xóa `map_controller.gd` (logic đã chuyển sang areas + builders).
- Hồ câu: scene riêng (`scenes/fishing_lake_map.tscn` +
  `areas/fishing_lake_map_area.gd`), nội dung: LakeWater, LakeBanks, DirtPath,
  FishingDock, cây quanh hồ. Lối chuyển Player ↔ hub qua
  `WorldEvents.MAP_CHANGE_REQUESTED` — cơ chế chuyển map không thay đổi.
- `MapArea` gọi `WorldNavigation.set_graph(points)` — đồ thị đường theo khu vực;
  Minimap vẽ đường từ `WorldNavigation.get_road_points()`.
- Định vị NPC (Lan, Minh) vào hub: Lan (-10, 0, -8), Minh (-8, 0, 6).
- Cập nhật: `world/map/README.md`, `docs/architecture/module_dependency_survey.md`.

### Kiểm tra (§11)
- `gdparse` toàn bộ .gd mới và sửa (chạy, không lỗi).
- Đọc toàn bộ repo để rà soát code↔docs; tất cả đều tương thích với thiết kế mới.
- Chưa xác nhận trên Godot Android (CHƯA — theo thang AGENTS.md §11).

## Map Controller: dựng nội dung hồ cá theo map_type + kết nối transition

- `_ready()` gọi đúng theo `map_type`:
  - `fishing_lake` → `_build_fishing_lake()` (LakeWater, LakeBanks, DirtPath,
    FishingDock, cây quanh hồ), `_build_lake_ground()` (GroundNorth/South/West/East
    gần hồ), `_build_lake_water_barriers()` (hàng rào nước); không dựng nội dung
    đường/nhà/cây cốt của khu dân cư.
  - Khác (khu dân cư) → `_build_ground()`, `_build_roads()`, `_build_canal()`,
    `_build_buildings()`, `_build_trees()`, `_build_expanded_world()`,
    `_build_world_boundaries()`; không dựng nội dung hồ cá.
- `_build_transition()` gọi cho cả hai map (tạo `MapTransition` Area3D + Label3D
  `DestinationName` — hàm này đã tồn tại nhưng chưa được gọi): tại `fishing_lake`
  ở z = 43, khu dân cư ở z = -43; Player đi vào gửi
  `WorldEvents.MAP_CHANGE_REQUESTED` (fallback `change_scene_to_file()` khi không
  có Bootstrap).
- Sửa ngoại lệ texture: chỉ gọi hàm đã tồn tại, không tạo/thay thế tài nguyên;
  không sửa module khác.

### Kiểm tra (§11)
- `gdparse world/map/map_controller.gd`: không lỗi cú pháp (đã chạy).
- Grep: 3 hàm dựng hồ cá + `_build_transition` được gọi trong `_ready()`; đường dẫn
  scene của cả hai map tồn tại (`world/map/scenes/map_root.tscn`,
  `world/map/scenes/fishing_lake_map.tscn`).
- Chưa xác nhận trên Godot Android (theo thang AGENTS.md §11).

## Tách Player/Needs/HUD/Visual khỏi world/map — Bước 1: Needs

- Di chuyển `world/map/characters/player_needs.gd` → `modules/needs/player_needs.gd`
  (giữ `class_name PlayerNeeds`; đồng nhất file `.uid`).
- `world/map/scenes/map_root.tscn`: ext_resource của node Needs gắn sang
  `res://modules/needs/player_needs.gd`.
- Giao tiếp của Needs với HUD/Player chỉ qua `PlayerEvents` + `EventBus`
  (`core/contracts/player_events.gd`) — không đổi hành vi.
- Cập nhật tham chiếu: `world/map/README.md`, `world/map/characters/README.md`,
  `docs/architecture/module_dependency_survey.md`, `README.md`.
- Thêm `modules/needs/README.md`.

### Kiểm tra (§11) — Mức 2
- `gdparse modules/needs/player_needs.gd`: không error.
- `grep` không còn tham chiếu `world/map/characters/player_needs` ở `.gd`/`.tscn`.
- Chưa kiểm tra: boot/game trên Godot Android.

## Tách Player/Needs/HUD/Visual khỏi world/map — Bước 2: Player

- Di chuyển `world/map/player_controller.gd` → `modules/player/player_controller.gd`
  (giữ `class_name Player3DController`; đồng nhất file `.uid`).
- Thêm `@export var joystick_path: NodePath` trong Player; `world/map/scenes/map_root.tscn`
  gán `joystick_path = NodePath("../HUD/Joystick")` cho node Player.
  Lưu ý: không còn `get_node("../HUD/Joystick")` trong code hiện tại — Joystick nhận hướng
  điều khiển bằng `PlayerEvents.MOVE_INPUT_CHANGED` (phát qua EventBus), nên export là điểm
  gắn kết thay thế, không đổi hành vi.
- Cập nhật tham chiếu: `world/map/README.md`, `world/README.md`,
  `docs/architecture/module_dependency_survey.md`.
- Thêm `modules/player/README.md`.

### Kiểm tra (§11) — Mức 2
- `gdparse modules/player/player_controller.gd`: không error.
- `grep` không còn tham chiếu `world/map/player_controller` ở `.gd`/`.tscn`.
- Chưa kiểm tra: boot/game trên Godot Android.

## Tách Player/Needs/HUD/Visual khỏi world/map — Bước 3: HUD/Joystick

- Di chuyển `world/map/player_hud.gd` → `presentation/hud/player_hud.gd`
  (giữ `class_name PlayerHUD`) và `world/map/virtual_joystick.gd` →
  `presentation/hud/virtual_joystick.gd`; đồng nhất file `.uid`.
- `world/map/scenes/map_root.tscn`: cập nhật đường dẫn ext_resource của node
  `PlayerHUD` và `Joystick` sang `res://presentation/hud/...`.
- HUD chỉ đọc sự kiện (`PlayerEvents`/`CoreEvents` qua EventBus), không đọc
  node Player/Needs — không đổi hành vi.
- Cập nhật tham chiếu: `world/map/README.md`, `world/README.md`,
  `docs/architecture/module_dependency_survey.md`.
- Thêm `presentation/hud/README.md`.

### Kiểm tra (§11) — Mức 2
- `gdparse presentation/hud/player_hud.gd presentation/hud/virtual_joystick.gd`:
  không error.
- `grep` không còn tham chiếu `world/map/player_hud` hay
  `world/map/virtual_joystick` ở `.gd`/`.tscn`.
- Chưa kiểm tra: boot/game trên Godot Android.

## Tách Player/Needs/HUD/Visual khỏi world/map — Bước 4: PlayerVisual

- Di chuyển `world/map/characters/player_visual.gd` →
  `presentation/player_visual/player_visual.gd` (giữ `class_name PlayerVisual`;
  đồng nhất file `.uid`).
- `world/map/scenes/map_root.tscn`: ext_resource của node `VisualRoot` gắn sang
  `res://presentation/player_visual/player_visual.gd`.
- Xóa `world/map/characters/README.md` và thư mục `world/map/characters`
  (rỗng sau khi file đã được di chuyển).
- Cập nhật tham chiếu: `docs/architecture/module_dependency_survey.md`,
  `docs/decisions/0001-player-sprite.md`.
- Thêm `presentation/player_visual/README.md`.

### Kiểm tra (§11) — Mức 2
- `gdparse presentation/player_visual/player_visual.gd`: không error.
- `grep` không còn tham chiếu `world/map/characters/player_visual` ở `.gd`/`.tscn`.
- `test ! -d world/map/characters` — thư mục đã xóa.
- Chưa kiểm tra: boot/game trên Godot Android.

## Gỡ phụ thuộc chéo: JobEvents, Presentation, NPCDirector, Economy tùy chọn

- `JobEvents` chuyển từ `modules/jobs/job_events.gd` sang
  `core/contracts/job_events.gd` (giữ `class_name` và nội dung). NPC dùng
  contract Core, không còn tham chiếu thư mục `modules/jobs`.
- `world/map/scenes/map_root.tscn` bỏ `ext_resource` `player_sprite.tscn` và
  node `Visual`; bỏ luôn node `NPCDirector`. `fishing_lake_map.tscn` bỏ
  `NPCDirector`, tắt NPC bằng `metadata/npc_spawn_enabled = false`.
- `core/bootstrap/boot.gd` trở thành composition root:
  - gắn `Visual` (sprite) vào `Player` nếu
    `res://presentation/player_sprite/player_sprite.tscn` tồn tại, ngược lại giữ
    `VisualRoot` 3D;
  - tạo `NPCDirector` nếu `res://modules/npc/npc_director.gd` tồn tại, đặt
    `spawn_enabled` theo metadata của map;
  - đăng ký `EconomyService` qua `get_node_or_null("/root/EconomyService")` +
    kiểm tra null, không tham chiếu tên autoload ở compile-time.
- Đổi map đi qua `WorldEvents.MAP_CHANGE_REQUESTED`; Bootstrap giữ node Boot
  sống, thay map con và gắn lại Presentation/NPC, nên map hồ câu cũng có sprite.
  `MapController` fallback `change_scene_to_file()` khi không có listener.
- Thêm `EventBus.has_listeners()` để MapController chọn event hay fallback.
- Cập nhật README: `core/bootstrap`, `core/contracts`, `core/events`,
  `core/services`, `world/map`, `world/navigation`,
  `presentation/player_sprite`, `modules/jobs`, `modules/npc`,
  `docs/architecture/module_dependency_survey.md`,
  `docs/decisions/0001-player-sprite.md`.

### Bảng nghiệm thu "xóa X → hỏng gì"

Mỗi trường hợp: bản sao repo sạch, xóa thư mục, `godot --headless --import`,
rồi boot 150 frame. Không trường hợp nào có `Parse Error`.

| Xóa | Lỗi import/boot còn lại | Hành vi quan sát |
|---|---|---|
| `modules/jobs` | 3 lỗi thiếu `res://modules/jobs/job_system.gd` (autoload `JobSystem`) | Boot chạy; NPC vẫn spawn (2), nhưng không nhận `SCHEDULE_CHANGED` mới |
| `modules/npc` | Không có | Boot chạy; không có `NPCDirector`, nhóm `npc` rỗng; Player di chuyển bình thường |
| `modules/shops` | Không có | Boot chạy; không ảnh hưởng luồng hiện tại (shop chỉ có dữ liệu mẫu) |
| `modules/economy` | 2 lỗi thiếu autoload `EconomyService` | Boot chạy; `economy=false`; không có số dư VND |
| `presentation` | Không có | Boot chạy; `Visual` vắng mặt, `VisualRoot` 3D hiển thị (15 mesh con tại lúc ghi chép; hiện `presentation/player_visual` có 23 mesh); Player di chuyển bình thường |

### Bằng chứng
- Ảnh chụp boot trước/sau thay đổi giống hệt nhau:
  SHA-256 `3f9f9e9a324ae573e9b126cded056c5f9c375ce5bf062621be552da0b6d9fed0`.
- Chuyển map sang `fishing_lake_map.tscn`: có `Visual`, có `NPCDirector` với
  `spawn_enabled=false`, nhóm `npc` = 0, Player ở `lake_entry` (0, 0.05, 22).
- Đo di chuyển sau 40 physics frame: 2.5967 đơn vị ở mọi trường hợp (kể cả khi
  xóa `presentation` hoặc `modules/npc`).

### Mức kiểm tra (§11)
- **Mức 2**: `gdparse` toàn bộ file thay đổi, grep đường dẫn, cấu trúc file.
- **Thêm (ngoài thang §11)**: import và boot 150 frame bằng Godot 4.7 headless
  trên Linux/proot, có ảnh chụp.
- **Mức 3–4**: người dùng đã mở project và chạy kiểm tra thực tế trên Godot
  Android, xác nhận trước khi commit (2026-11-22). Repo không lưu log chi tiết
  từng bước cảm ứng, âm thanh và hiệu năng.
- Giới hạn công cụ: Godot ARM64 chính thức crash khi quét `/dev` dưới proot;
  bản dùng để test có patch cục bộ tại offset `0x40f4b8` (`mov x0,#0`) chỉ trong
  binary test, không liên quan mã nguồn game.

## Tách phụ thuộc module (Minimap, NPC, MapController, Player/HUD, Save)

- Thêm `core/contracts/player_events.gd` (`PlayerEvents`) và
  `core/contracts/world_events.gd` (`WorldEvents`) làm hợp đồng sự kiện dùng chung.
- Thêm `modules/jobs/job_events.gd` (`JobEvents`) và autoload `JobSystem`:
  đọc `GameClock`/`JobService` rồi phát lịch qua `SCHEDULE_CHANGED`; NPC không
  còn gọi trực tiếp các module này.
- Chuyển `NavigationService` thành autoload `WorldNavigation`, giao tiếp bằng
  `ROUTE_REQUESTED`/`ROUTE_READY` thay vì gọi hàm trực tiếp. Vẫn dùng
  pathfinding `AStar2D` thật, không fallback đi thẳng.
- NPC: nhận lịch và tuyến đường qua event, nhận vị trí Player qua
  `PLAYER_POSITION_CHANGED`, phát `NPC_POSITIONS_CHANGED`. Bỏ đọc
  `GameClock`, `JobService`, `NavigationService`, `ShopService`.
- Minimap: nhận vị trí Player/NPC và tuyến đường qua event; bỏ tham chiếu
  `Player`, `NPCDirector`, `NavigationService`.
- MapController: không còn tạo/điều khiển NPC hay Minimap; NPC và Minimap là
  node độc lập trong `map_root.tscn`. `fishing_lake_map.tscn` tắt NPC bằng
  `spawn_enabled = false`.
- PlayerController/HUD/Needs/Joystick/Visual/Sprite giao tiếp qua `PlayerEvents`
  và `CoreEvents`; Player không còn truy cập node Needs/Visual/Joystick.
- Player phát `PLAYER_RECOVERY_REQUESTED`; MapController gọi `Player.recover_to()`
  thay vì Player đọc nội bộ MapController.
- SaveCoordinator: bỏ quét group `save_participant` và phụ thuộc GameClock;
  thêm `register_participant(save_id, participant)` / `unregister_participant`.
  Save version 2 dùng section `participants`; version 1 được migrate từ section
  `clock` sang participant `game_clock`.
- Cập nhật `project.godot` (autoload `JobSystem`, `WorldNavigation`) và tài liệu:
  `core/contracts/README.md`, `core/events/README.md`, `core/services/README.md`,
  README các module liên quan, `docs/architecture/module_dependency_survey.md`.
- Đã kiểm tra cú pháp toàn bộ `.gd` bằng `gdparse` và grep toàn repo; chưa mở
  Godot Android nên **chưa xác nhận parser/runtime trên thiết bị**.

## World Map: Two-finger pan and zoom fix
- Sửa thao tác hai ngón: cập nhật vị trí tâm bản đồ theo chuyển động của hai ngón đồng thời với pinch zoom.
- Giữ nguyên kéo một ngón, giới hạn zoom và giới hạn pan.
- Chưa xác nhận parser và gameplay runtime trên Godot Android.

## Player Sprite (HD-2D)

- Player dùng sprite billboard (`AnimatedSprite3D`); ngoại lệ texture ghi ở `docs/decisions/0001-player-sprite.md`.
- Thêm `tools/build_player_atlas.py`: cắt 3 sprite sheet, căn đầu/chân, chuẩn hóa kích thước, sinh atlas và SpriteFrames.
  (Công cụ này hiện đã gỡ khỏi repo; atlas và SpriteFrames vẫn nằm ở `assets/characters/player/`.)
- Thêm `presentation/player_sprite/` (chọn hướng, idle/walk, lật cho hướng phải).
- `player_controller.gd` báo vận tốc cho node `Visual` và ẩn `VisualRoot` (3D primitive, giữ làm dự phòng); `map_root.tscn` thêm `Visual`.
- Đã chạy thử trên Godot 4.7 Linux (import, chạy scene, ảnh chụp 4 hướng). Chưa xác nhận trên Godot Android.
## NPC Minimap API consistency

- Khai báo tham chiếu NPCDirector có kiểu rõ ràng trong WorldMinimap.
- Giữ API get_npcs() làm điểm truy cập danh sách NPC hợp lệ.
- Xác nhận MapController tạo NPCDirector trước khi dựng minimap.
- Cập nhật README và Roadmap.
- Chưa xác nhận parser/runtime trên Godot Android.

## Data format: Godot Resources only

- Thay dữ liệu hồ sơ NPC từ JSON sang `NPCProfile` Resource `.tres`.
- Thay dữ liệu hàng hóa từ JSON sang `ShopGood` Resource `.tres`.
- Cập nhật NPCDirector, NPC agent và ShopService dùng Resource có kiểu.
- Xóa `npc_profiles.json` và `goods.json`; không còn đọc JSON cho cấu hình NPC/Shop.
- Cập nhật README module và Roadmap.
- Chưa xác nhận parser/runtime trên Godot Android.

## NPC & Life Simulation — Prototype foundation

- Thêm `NPCDirector` và `LifeNPC` dùng chung, khởi tạo hai NPC dữ liệu mẫu trong khu dân cư.
- Thêm danh tính NPC, nghề nghiệp, tính cách, vị trí nhà/nơi làm/nơi mua sắm và tiền mặt mô phỏng.
- Thêm lịch sinh hoạt theo GameClock: ở nhà, đi làm và mua sắm.
- NPC lấy route từ NavigationService và di chuyển theo các điểm đường hiện có.
- Thêm nút cảm ứng nói chuyện, hội thoại trạng thái và danh mục hàng mẫu.
- Thêm JobService, ShopService và EconomyService với số dư VND integer; chưa có giao dịch mua bán vì chưa có Inventory/TransactionCoordinator.
- Đăng ký NPCDirector vào SaveCoordinator để lưu trạng thái NPC.
- Cập nhật `docs/roadmap/ROADMAP.md` với tiến độ đã có, phần còn thiếu và kế hoạch kiểm thử.
- Chưa xác nhận parser hoặc gameplay runtime trên Godot Android.

## World Map: Full-screen layout fix

- Khi chạm minimap, WorldMinimap mở rộng Control phủ toàn bộ viewport.
- Bản đồ lớn được vẽ trên toàn màn hình, không còn bị giới hạn trong khung minimap.
- Khi đóng bản đồ, khôi phục anchors và offsets ban đầu của minimap.
- Giữ nguyên thao tác zoom, pan và waypoint hiện có.
- Chưa xác nhận parser và runtime trên Godot Android.

## World Map: Zoom và Pan

- Thêm zoom bản đồ bằng thao tác chụm/xòe hai ngón.
- Thêm nút zoom `+` và `−`, giới hạn mức zoom từ 1x đến 4x.
- Thêm thao tác kéo bản đồ bằng một ngón tay.
- Giữ waypoint khi đóng và mở lại bản đồ.
- Giữ bản đồ lớn mở sau khi chọn waypoint để người chơi xem vị trí.
- Chưa xác nhận parser và runtime trên Godot Android.

## Navigation Foundation: minimap route preview

- Connect the full-map waypoint selection to `NavigationService.find_route`.
- Draw the returned AStar2D route on the full map.
- Show route-found status; clear the previous route when opening the map.
- Route preview only; player movement remains manual.
- Godot Android parser and runtime verification pending.

## Phase 3.2: World Minimap

- Thêm minimap nhỏ ở góc trên bên phải HUD.
- Hiển thị sơ đồ riêng cho khu dân cư và hồ câu.
- Cập nhật vị trí Player theo thời gian thực.
- Giữ bản đồ hướng Bắc lên trên, không xoay theo nhân vật.
- Dựng bằng Control drawing, không sử dụng texture.
- Chưa xác nhận parser và runtime trên Godot Android.

## Phase 3.1: Map Fall Protection

- Thêm collision wall vô hình ở bốn cạnh hai map.
- Thêm barrier ngăn Player đi vào mặt nước hồ câu.
- Chừa lối đi phía nam hồ để tiếp cận bến câu.
- Tự phục hồi Player về Spawn Point nếu rơi thấp hơn Y = -10.
- Chưa xác nhận runtime trên Godot Android.


## Giai đoạn 0: khung khởi động

- Thiết lập Boot scene làm màn hình khởi động.
- Thêm Bootstrap script với log khởi động.
- Thiết lập tên ProjectGame.
- Thiết lập màn hình ngang Android.
- Chưa triển khai gameplay hoặc module khác.

- Giai đoạn 0: thêm EventBus (autoload, generic event) và CoreEvents.BOOT_COMPLETED; boot.gd phát boot_completed.

- Giai đoạn 0: thêm GameClock (autoload, thời gian số nguyên phút, hour_changed/day_changed, serialize/deserialize) và scene tự kiểm tra tests/game_clock_selftest.tscn.

## Phase 1: Shader Map Prototype

- Thêm map nền procedural bằng CanvasItem shader, không dùng texture.
- Thêm địa hình, đường chính, đường nhánh và kênh nước.
- Thêm MapShaderController quản lý tham số shader và viewport.
- Boot khởi tạo map làm nền, giữ EventBus và UI hiện có.

## Phase 2: 3D Third-person Map Prototype

- Thay map CanvasItem 2D bằng scene môi trường Node3D.
- Tạo đường giao thông, vỉa hè, kênh nước, nhà phố và cây bằng Primitive Mesh.
- Thêm Player CharacterBody3D với trọng lực và va chạm.
- Thêm camera third-person dùng SpringArm3D.
- Thêm joystick cảm ứng và thao tác vuốt để xoay camera.
- Giữ shader map 2D cũ làm prototype tham khảo, không còn dùng trong scene chính.
- Chưa xác nhận runtime trên Godot Android.

## Phase 2.1: Fix mobile virtual joystick

- Chuyển joystick từ `_gui_input()` sang `_input()` để nhận touch ổn định.
- Chuyển tọa độ viewport sang tọa độ Control trước khi kiểm tra vùng chạm.
- Đánh dấu touch/drag của joystick đã xử lý để không lọt xuống camera.
- Định danh VirtualJoystick và khai báo kiểu rõ ràng trong PlayerController.

## Phase 2.1: Top-down Angled Camera

- Chuyển camera từ third-person thấp sang top-down nghiêng 55 độ.
- Tăng khoảng cách SpringArm để bao quát khu vực xung quanh.
- Camera tự xoay mượt theo hướng di chuyển của nhân vật.
- Khóa góc tham chiếu điều khiển khi bắt đầu di chuyển,
  tránh hiện tượng camera và hướng đi tự kéo lệch lẫn nhau.
- Bỏ thao tác vuốt phải để xoay camera thủ công.
- Cập nhật hướng dẫn điều khiển trong README map.
- Chưa xác nhận runtime trên Godot Android.

## Phase 2.2: Fixed Angled Follow Camera

- Tách CameraPivot khỏi transform xoay của Player bằng top_level.
- Giữ camera ở góc nghiêng 55 độ, khoảng cách 8 đơn vị.
- Camera chỉ bám theo vị trí nhân vật, không xoay theo hướng di chuyển.
- Hướng joystick sử dụng hệ trục thế giới cố định.
- Nhân vật vẫn quay mặt theo hướng đang đi.
- Chưa xác nhận runtime trên Godot Android.

## Phase 3: Two Map Travel Prototype

- Thêm map Khu dân cư và map Hồ câu.
- Dùng chung Player Controller, Camera và Virtual Joystick.
- Thêm vùng chuyển map hai chiều bằng Area3D.
- Hiển thị tên địa điểm đích bằng Label3D.
- Truyền Spawn Point ID qua SceneTree metadata khi đổi scene.
- Dựng hồ, bờ hồ, đường đất và bến câu bằng Primitive Mesh.
- Chưa xác nhận parser và runtime trên Godot Android.

## Visual Pass: Procedural Character and Surface Shader

- Thay capsule hiển thị Player bằng nhân vật 3D dựng từ primitive mesh: đầu, tóc, tai, mắt, thân, tay, chân và giày.
- Thêm chuyển động tay/chân procedural dựa trên vận tốc Player; giữ nguyên CharacterBody3D và collision hiện tại.
- Thêm spatial shader tạo biến thiên bề mặt bằng hàm toán học, không dùng texture.
- Dùng shader vật liệu procedural cho mesh môi trường; tinh chỉnh ambient light, ánh sáng mặt trời, filmic tonemapping và fog.
- Chưa xác nhận parser hoặc runtime trên Godot Android.


## World HUD, Minimap và bố trí đường phố

- Sửa minimap để các tuyến đường và kênh nước được vẽ theo tọa độ thế giới quanh Player; sửa vị trí kênh nước từ `x = 175` về `x = 25`.
- Điều chỉnh cây khu dân cư ra ngoài vỉa hè và lùi nhà gần giao lộ khỏi mặt đường.
- Thêm PlayerHUD với avatar hình học không texture, thanh sức khỏe, giờ và thứ lấy từ GameClock.
- Thêm API sức khỏe runtime `apply_damage()` / `restore_health()` cho Player.
- Chưa xác nhận parser và gameplay runtime trên Godot Android.

## Phase 4: Player Needs, HUD và Save

- Thêm nhu cầu đói, khát, năng lượng; tiêu hao theo phút GameClock.
- Thêm API và nút cảm ứng ăn, uống, nghỉ; ăn/uống đang miễn phí dạng prototype cho đến khi tích hợp Inventory; đói/khát kiệt sức gây hao máu nhẹ.
- Mở rộng HUD hiển thị avatar, máu, ba thanh nhu cầu, giờ và thứ.
- Thêm SaveCoordinator: lưu GameClock, vị trí, máu và nhu cầu; tự lưu định kỳ và khi app pause/đóng.
- Sửa tọa độ thao tác minimap về hệ tọa độ local của Control; thêm preview tuyến đường waypoint.
- Thêm kiểm tra vị trí an toàn cho cây và nhà so với hành lang đường.
- Tái sử dụng mesh/material và giới hạn tần suất redraw minimap để giảm chi phí trên Android.
- Chưa xác nhận Godot Parser hoặc gameplay runtime trên Android.

## World Map: Road height fix
- Sua do cao mat duong trong world/map/map_controller.gd: RoadShoulderMain 0.04, MainRoad/CrossRoad 0.05, DistrictRoad/DistrictCrossRoad 0.045 (chuyen sang _add_static_box), Sidewalk 0.08, RoadMarking day 0.05 cao 0.012 (center y=0.056). Khong con hai khoi khac mau co mat tren bang nhau.
- Vong lap cay trong _build_expanded_world() bo qua vi tri khong qua _is_tree_position_clear() de het warning.
- Chưa xác nhận trên Godot Android (theo thang mức AGENTS.md §11).

## Minimap gesture fix
- Sửa pan kết hợp pinch zoom bằng hai ngón.

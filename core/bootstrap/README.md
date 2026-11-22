# Bootstrap

## Mục đích
Composition root của ProjectGame: nơi duy nhất biết cách ghép World,
Presentation và các module gameplay tùy chọn. Module không tự gắn cứng node
của module khác vào scene (AGENTS §5).

## Cấu trúc
- `boot.gd`: script của `scenes/boot/boot.tscn`.
- `boot.tscn` giữ node Boot sống suốt phiên chơi; map hiện tại là con của Boot.

## Việc Bootstrap làm
1. Ẩn tiêu đề khởi động, đăng ký `GameClock` với `SaveCoordinator`.
2. Đăng ký `EconomyService` **nếu tồn tại**: `get_node_or_null("/root/EconomyService")`
   + kiểm tra null, đọc `SAVE_ID` qua `get_script_constant_map()`. Không tham
   chiếu tên class/autoload ở compile-time, nên gỡ module economy thì boot vẫn
   parse và chạy.
3. Nghe `WorldEvents.MAP_CHANGE_REQUESTED` để đổi map mà không phá node Boot.
4. Instantiate map, gắn Presentation/NPC, rồi mới `add_child`.
5. Gọi `SaveCoordinator.load_game()`, phát `CoreEvents.BOOT_COMPLETED`.

## Gắn module tùy chọn
- **Presentation**: nếu
  `res://presentation/player_sprite/player_sprite.tscn` tồn tại thì instantiate,
  đặt tên `Visual`, `add_child` vào `Player`. Nếu không, giữ `VisualRoot` (3D)
  hiển thị. Dùng `ResourceLoader.exists()` + `load()`, không `preload`.
- **NPC**: nếu `res://modules/npc/npc_director.gd` tồn tại thì `new()` node
  `NPCDirector`, đặt `spawn_enabled` theo metadata `npc_spawn_enabled` của map
  (mặc định `true`), chèn trước `HUD`. Giữ nguyên nhóm `npc` và event
  `NPC_POSITIONS_CHANGED` cho minimap.
- Cả hai được gắn vào map **trước** `add_child(map)` để thứ tự `_ready()` và
  hình ảnh giống bố cục scene cũ.

## Đổi map
`WorldEvents.MAP_CHANGE_REQUESTED` payload `{ "scene_path": String }`.
Bootstrap `call_deferred` việc đổi map, gỡ map cũ, gắn Presentation/NPC cho map
mới rồi thay thế. Nhờ vậy `fishing_lake_map.tscn` cũng có sprite và NPC director
đúng cấu hình sau khi chuyển map.

## Phụ thuộc
- Core: `EventBus`, `GameClock`, `SaveCoordinator`, `CoreEvents`, `WorldEvents`.
- Tùy chọn: `presentation/player_sprite/player_sprite.tscn`,
  `modules/npc/npc_director.gd`, autoload `/root/EconomyService`.
- Không import trực tiếp module gameplay nào ở compile-time.

## Kiểm tra
- `gdparse core/bootstrap/boot.gd`.
- Import headless Godot 4.7 + boot 150 frame: không `Parse Error`, log có
  `[Boot] ProjectGame 3D khởi động`.
- Đã xóa từng thư mục `modules/jobs`, `modules/npc`, `modules/shops`,
  `modules/economy`, `presentation` trong bản sao và chạy lại: boot vẫn hoạt
  động, chỉ thiếu đúng phần của module bị xóa. Chi tiết bảng ở `CHANGELOG.md`.
- Ảnh chụp boot trước/sau thay đổi giống hệt (cùng SHA-256).
- Chưa chạy trên Godot Android; xem mức kiểm tra trong `CHANGELOG.md`.

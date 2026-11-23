# NPC Simulation

## Mục đích
Prototype NPC data-driven cho khu dân cư: danh tính, lịch sinh hoạt, di chuyển
theo mạng đường, hội thoại và lưu trạng thái. Module không gọi trực tiếp
GameClock, JobService, NavigationService hay ShopService.

## Thành phần
- `npc_profile.gd`: Resource class `NPCProfile`, định nghĩa dữ liệu nhân vật.
  Trường vị trí: `home_building_id`, `workplace_building_id`, `shop_building_id` (String).
  Không dùng Vector3 cứng — tọa độ được tra từ Dictionary của `WorldEvents.BUILDINGS_READY`.
- `data/lan.tres`, `data/minh.tres`: hai hồ sơ NPC mẫu dạng Godot Resource.
- `npc_director.gd`: nạp Resource, tạo NPC, nhận lịch qua event, tìm NPC gần
  Player (theo vị trí Player phát qua event) và dựng UI tương tác.
- `npc_agent.gd`: hành vi dùng chung cho mọi NPC; không viết script riêng theo tên.

## Thêm NPC mới
Tạo một Resource `.tres` mới dùng script `npc_profile.gd`, điền ID ổn định,
tên, tuổi, nghề, tính cách, `home_building_id`, `workplace_building_id`,
`shop_building_id` và tiền mặt; sau đó thêm resource vào mảng
`NPC_PROFILES` trong `npc_director.gd`. Không cần tạo script NPC riêng.

## API
- `NPCDirector.get_npc_count()`
- `NPCDirector.get_npcs() -> Array[LifeNPC]`: trả về danh sách NPC còn hợp lệ.
- `NPCDirector.serialize_state()` / `deserialize_state()`
- `LifeNPC.configure(profile: NPCProfile)`
- `LifeNPC.set_building_doors(doors: Dictionary)` — nhan {id: Vector3} tu NPCDirector,
  chuyen building_id -> toa do (home/workplace/shop_position).
- `LifeNPC.place_at_current_schedule(activity: StringName)` — dat vi tri ban dau.
- `LifeNPC.apply_schedule(activity: StringName)`
- `LifeNPC.get_dialogue()`

## Sự kiện (qua EventBus)
NPC chỉ giao tiếp bằng event hoặc API của module sở hữu; không đọc trực tiếp
node/dịch vụ của module khác.

### Nhận
- `JobEvents.SCHEDULE_CHANGED` — lịch hiện tại do `JobSystem` phát
  (`{ "hour", "activity", "shift_start", "shift_end" }`). `NPCDirector` gọi
  `LifeNPC.apply_schedule(activity)`.
- `WorldEvents.PLAYER_POSITION_CHANGED` — vị trí Player để tìm NPC gần nhất.
- `WorldEvents.BUILDINGS_READY` — khi MapArea dung xong toan bo cong trinh;
  payload `{ "buildings": {id: Vector3} }`. NPCDirector cap nhat `_building_doors`
  va goi `set_building_doors` + `place_at_current_schedule` cho tung NPC.
  Flow: `MapArea._emit_buildings_ready()` → `NPCDirector._on_buildings_ready()`
  → `LifeNPC.set_building_doors()` → `LifeNPC.place_at_current_schedule()`.
- `WorldEvents.ROUTE_READY` — tuyến đường do `WorldNavigation` trả về, ghép
  theo `request_id` của từng NPC.

### Phát
- `JobEvents.SCHEDULE_SNAPSHOT_REQUESTED` — yêu cầu lịch hiện tại khi khởi tạo
  hoặc sau khi tải save.
- `WorldEvents.NPC_POSITIONS_CHANGED` — danh sách vị trí NPC cho minimap
  (`{ "npcs": [{ "id": String, "position": Vector3 }] }`).
- `WorldEvents.ROUTE_REQUESTED` — yêu cầu tuyến đường cho NPC.

## Lưu trạng thái
`NPCDirector` tự đăng ký với `SaveCoordinator` qua
`register_participant("npc_world", self)` và hủy đăng ký trong `_exit_tree()`.
Không dùng group `save_participant`. Sau khi tải save, director phát
`SCHEDULE_SNAPSHOT_REQUESTED` để `JobSystem` trả lại lịch hiện tại thay vì đọc
GameClock.

## Phụ thuộc
- `core/events` (EventBus), `core/contracts` (`WorldEvents`,
  `core/contracts/job_events.gd` → `JobEvents`).
- `SaveCoordinator` chỉ qua API đăng ký participant.
- Không preload hay gọi trực tiếp GameClock, JobService, ShopService,
  NavigationService.
- Không tham chiếu thư mục `modules/jobs`; `JobEvents` là contract Core.

## Vòng đời scene
`NPCDirector` là node độc lập gắn vào `shared_map.tscn` (SharedMap scene độc
lập với map). `core/bootstrap/boot.gd` kiểm tra
`res://modules/npc/npc_director.gd` có tồn tại hay không rồi nối
`NPCDirector` vào SharedMap. Nhờ vậy xóa module NPC không làm hỏng scene
world; game vẫn chạy, chỉ không có NPC.

Scene world khai báo có tạo NPC hay không bằng metadata, không bằng node:
`metadata/npc_spawn_enabled = false` (ví dụ `fishing_lake_map.tscn`).
Bootstrap đọc metadata này và đặt `spawn_enabled` tương ứng.

## Giới hạn prototype
- Hai NPC dữ liệu mẫu.
- Mô phỏng chuyển động khi NPC đang được load trong scene; chưa có
  streaming/off-screen simulation.
- Điểm đến lịch trình là tọa độ mẫu, chưa có Location Registry/entrance system.
- Hội thoại là câu chào theo dữ liệu, chưa có cây hội thoại.
- Tiền NPC là dữ liệu mô phỏng, chưa phải ví Player.
- Shop chỉ còn dữ liệu mẫu; NPC chưa hiển thị danh mục hàng.
- Chưa có runtime verification trên Godot Android.

## Kiểm tra
- `gdparse` cho các file `.gd` (đã chạy, không lỗi cú pháp).
- Chạy `scenes/boot/boot.tscn` (không chạy trực tiếp `map_root.tscn`) để
  Bootstrap tạo `NPCDirector`; xác nhận node `NPCDirector` tồn tại và nhóm
  `npc` có 2 NPC.
- Xóa tạm thư mục `modules/npc/`, import và boot 150 frame: game vẫn chạy,
  không có `Parse Error`, không có `NPCDirector`, nhóm `npc` rỗng.
- Mở Godot Android, chạy `boot.tscn`, tua GameClock qua 07:00 và 17:00 để
  xác nhận NPC nhận lịch qua event và đi theo tuyến đường.
- Lưu rồi tải lại để xác nhận đăng ký participant và khôi phục trạng thái NPC.

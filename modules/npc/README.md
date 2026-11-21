# NPC Simulation

## Mục đích
Prototype NPC data-driven cho khu dân cư: danh tính, lịch sinh hoạt, di chuyển
theo mạng đường, hội thoại và lưu trạng thái. Module không gọi trực tiếp
GameClock, JobService, NavigationService hay ShopService.

## Thành phần
- `npc_profile.gd`: Resource class `NPCProfile`, định nghĩa dữ liệu nhân vật.
- `data/lan.tres`, `data/minh.tres`: hai hồ sơ NPC mẫu dạng Godot Resource.
- `npc_director.gd`: nạp Resource, tạo NPC, nhận lịch qua event, tìm NPC gần
  Player (theo vị trí Player phát qua event) và dựng UI tương tác.
- `npc_agent.gd`: hành vi dùng chung cho mọi NPC; không viết script riêng theo tên.

## Thêm NPC mới
Tạo một Resource `.tres` mới dùng script `npc_profile.gd`, điền ID ổn định,
tên, tuổi, nghề, tính cách, vị trí và tiền mặt; sau đó thêm resource vào mảng
`NPC_PROFILES` trong `npc_director.gd`. Không cần tạo script NPC riêng.

## API
- `NPCDirector.get_npc_count()`
- `NPCDirector.get_npcs() -> Array[LifeNPC]`: trả về danh sách NPC còn hợp lệ.
- `NPCDirector.serialize_state()` / `deserialize_state()`
- `LifeNPC.configure(profile: NPCProfile)`
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
- `core/events` (EventBus), `core/contracts` (`WorldEvents`),
  `modules/jobs/job_events.gd` (`JobEvents`).
- `SaveCoordinator` chỉ qua API đăng ký participant.
- Không preload hay gọi trực tiếp GameClock, JobService, ShopService,
  NavigationService.

## Vòng đời scene
`NPCDirector` là node độc lập trong `world/map/scenes/map_root.tscn`;
`Map3DController` không tạo hay điều khiển NPC. Scene kế thừa có thể đặt
`spawn_enabled = false` để tắt NPC mà không cần sửa controller.

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
- Mở Godot Android, chạy `map_root.tscn`, tua GameClock qua 07:00 và 17:00 để
  xác nhận NPC nhận lịch qua event và đi theo tuyến đường.
- Lưu rồi tải lại để xác nhận đăng ký participant và khôi phục trạng thái NPC.

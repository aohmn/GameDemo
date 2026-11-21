# NPC Simulation

## Mục đích
Prototype NPC data-driven cho khu dân cư: danh tính, lịch sinh hoạt, di chuyển theo mạng đường, hội thoại và lưu trạng thái.

## Thành phần
- `npc_profile.gd`: Resource class `NPCProfile`, định nghĩa dữ liệu nhân vật.
- `data/lan.tres`, `data/minh.tres`: hai hồ sơ NPC mẫu dạng Godot Resource.
- `npc_director.gd`: nạp Resource, tạo NPC, cập nhật lịch, tìm NPC gần Player và UI tương tác.
- `npc_agent.gd`: hành vi dùng chung cho mọi NPC; không viết script riêng theo tên.

## Thêm NPC mới
Tạo một Resource `.tres` mới dùng script `npc_profile.gd`, điền ID ổn định, tên, tuổi, nghề, tính cách, vị trí và tiền mặt; sau đó thêm resource vào mảng `NPC_PROFILES` trong `npc_director.gd`. Không cần tạo script NPC riêng.

## API
- `NPCDirector.get_npc_count()`
- `NPCDirector.serialize_state()` / `deserialize_state()`
- `LifeNPC.configure(profile: NPCProfile)`
- `LifeNPC.update_schedule(hour: int)`
- `LifeNPC.get_dialogue()`

## Sự kiện và phụ thuộc
- Đọc `GameClock`.
- Đăng ký `CoreEvents.HOUR_CHANGED` qua `EventBus`.
- Dùng `NavigationService.find_route()` để lấy các điểm đường.
- Dùng `ShopService.get_goods()` để hiển thị hàng mẫu.
- Được tạo bởi `Map3DController`; không điều khiển Player.

## Giới hạn prototype
- Hai NPC dữ liệu mẫu.
- Mô phỏng chuyển động khi NPC đang được load trong scene; chưa có streaming/off-screen simulation.
- Điểm đến lịch trình là tọa độ mẫu, chưa có Location Registry/entrance system.
- Hội thoại là câu chào theo dữ liệu, chưa có cây hội thoại.
- Tiền NPC là dữ liệu mô phỏng, chưa phải ví Player.
- Chưa có runtime verification trên Godot Android.

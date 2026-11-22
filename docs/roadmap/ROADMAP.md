# ProjectGame — Roadmap và tiến độ

Cập nhật: 2026-11-22  
Nguồn chính: repo `GameDemo` / nhánh `main`  
Nguyên tắc trạng thái: **Đã có mã nguồn** không đồng nghĩa **đã kiểm chứng runtime**. Theo `AGENTS.md` §11, tính năng chỉ được đánh dấu Done sau khi mở và chạy kiểm tra trên Godot Android.

## 1. Tiến độ đã làm

| Hệ thống | Nội dung có trong mã nguồn | Trạng thái xác minh |
|---|---|---|
| Core Bootstrap | Boot scene, EventBus, sự kiện khởi động | Có mã nguồn; chưa xác nhận runtime Android trong đợt này |
| GameClock | Thời gian theo phút, giờ/ngày, tua thời gian, serialize | Có mã nguồn; chưa xác nhận runtime Android trong đợt này |
| SaveCoordinator | Đăng ký participant độc lập (`register_participant`), save version 2, migrate v1, autosave và pause/close | Có mã nguồn; cần kiểm tra save/load thực tế trên Android |
| Player | CharacterBody3D, joystick, camera bám theo, hồi phục khi rơi (qua event) | Có mã nguồn; cần kiểm tra điều khiển/collision trên Android |
| World | Khu dân cư và hồ câu prototype, Mesh, đường, nhà, cây, ranh giới | Có mã nguồn; cần rà soát va chạm và hiệu năng thực tế |
| Navigation | `WorldNavigation` autoload, AStar2D trên giao lộ, route qua event | Có mã nguồn; chưa phải tự động dẫn đường cho Player |
| Minimap | Bản đồ nhỏ/lớn, pan, zoom, waypoint và preview tuyến qua event | Có mã nguồn; cần kiểm tra thao tác cảm ứng |
| Player HUD | Avatar hình học, máu, nhu cầu, giờ và thứ qua event | Có mã nguồn; cần kiểm tra bố cục trên màn hình điện thoại |
| Player Needs | Đói, khát, năng lượng; ăn/uống/nghỉ prototype qua event | Có mã nguồn; ăn/uống chưa tiêu thụ vật phẩm Inventory |
| Player Save | Vị trí Player, máu, nhu cầu và GameClock qua participant | Có mã nguồn; cần kiểm tra khôi phục sau khi thoát/mở lại |
| Đồ họa procedural | Primitive Mesh, ShaderMaterial, không dùng texture | Có mã nguồn; chưa profiling Android |

## 2. Đợt hiện tại — NPC & Life Simulation

Mục tiêu: đưa NPC có danh tính và lịch sinh hoạt vào khu dân cư, tạo nền móng cho việc làm, cửa hàng và kinh tế.

| # | Hạng mục | Tiến độ mã nguồn | Còn lại |
|---:|---|---|---|
| 1 | NPC Core | Đã có `NPCDirector` và `LifeNPC` dùng chung | Kiểm tra khởi tạo và vòng đời node trên Android |
| 2 | NPC Identity | Có ID, tên, tuổi, nghề, tính cách và dữ liệu vị trí | Đã chuyển hồ sơ mẫu sang Resource `.tres`; cần kiểm tra nạp Resource trong Godot Android |
| 3 | NPC AI | Có hành vi theo trạng thái lịch cơ bản | Chưa có nhu cầu, phản ứng môi trường hay ra quyết định đa mục tiêu |
| 4 | Daily Schedule | Ở nhà / đi làm / mua sắm theo GameClock | Chưa có lịch theo ngày trong tuần, cuối tuần hoặc ngày nghỉ |
| 5 | NPC Navigation | NPC nhận tuyến qua `WorldNavigation`/event, đi theo các điểm đường | Chưa có tránh vật cản, lối vào nhà/cửa hàng và local pathfinding |
| 6 | NPC Interaction | Có nút cảm ứng khi Player ở gần NPC (vị trí qua event) | Cần kiểm tra vùng tương tác, UI và thao tác trên thiết bị |
| 7 | Dialogue | Có hội thoại chào hỏi theo dữ liệu NPC | Chưa có hội thoại phân nhánh, lựa chọn và điều kiện |
| 8 | Job System | `JobSystem` phát lịch qua `JobEvents`; có khung giờ làm | Chưa có tuyển dụng Player, hợp đồng, chấm công và tính lương |
| 9 | Economy | Có EconomyService số dư VND integer và API thu/chi | Chưa có giao dịch atomic và UI ví; chưa kết nối Player với công việc |
| 10 | Shop System | Có danh mục hàng mẫu, ID và giá VND | Chưa có tồn kho, mua bán thật và kết nối Inventory |
| 11 | NPC Persistence | NPCDirector đăng ký participant save độc lập | Cần kiểm tra SaveCoordinator khôi phục NPC thực tế |
| 12 | World Simulation | Hai NPC được cập nhật lịch qua event khi khu dân cư đang load | Chưa có mô phỏng off-screen, NPC streaming hoặc mô phỏng dân số lớn |

**Kết luận đợt hiện tại:** đã dựng nền móng prototype cho cả 12 nhánh, nhưng không coi cả 12 là hoàn thành. Những phần còn thiếu được ghi rõ ở cột cuối; tất cả đều đang chờ kiểm tra Godot Android.

## 3. Quyết định định dạng dữ liệu

- Dữ liệu cấu hình NPC và hàng hóa dùng Godot Resource `.tres`, không dùng JSON.
- `NPCProfile` và `ShopGood` là Resource class có static typing.
- Save game runtime vẫn dùng cơ chế serialize của SaveCoordinator; quyết định không dùng JSON áp dụng cho dữ liệu cấu hình, không tự ý thay đổi định dạng save hiện có.

## 3.1. Đợt tách phụ thuộc module

- NPC, Minimap, MapController, Player/HUD và Save đã được tách khỏi phụ thuộc trực tiếp.
- Giao tiếp qua `PlayerEvents`, `WorldEvents`, `JobEvents`, `CoreEvents` và API
  đăng ký participant.
- Đã kiểm tra cú pháp bằng `gdparse`; **chưa mở Godot Android** nên các mục
  trong bảng vẫn giữ trạng thái "chưa xác nhận runtime".

## 4. Các giai đoạn tiếp theo

### Giai đoạn A — Kiểm thử và ổn định NPC prototype
- Xác nhận marker NPC trên cả minimap nhỏ/lớn thông qua `WorldEvents.NPC_POSITIONS_CHANGED`.
- Mở project bằng Godot Android, xử lý toàn bộ parser error và resource error.
- Chạy khu dân cư, xác nhận 2 NPC xuất hiện đúng vị trí.
- Tua GameClock qua 06:00, 07:00, 17:00, 19:00 để kiểm tra lịch và event `JobEvents.SCHEDULE_CHANGED`.
- Kiểm tra NPC đi đúng đường, không xuyên nhà/kênh và không kẹt ở giao lộ.
- Kiểm tra nút nói chuyện trên màn hình cảm ứng.
- Thoát game, mở lại và xác nhận vị trí/trạng thái NPC được khôi phục qua participant `npc_world`.

### Giai đoạn B — Gameplay kinh tế thật
- Thiết kế Inventory làm nguồn dữ liệu vật phẩm duy nhất.
- Hoàn thiện TransactionCoordinator để mua hàng atomic giữa Economy và Inventory.
- Shop có vị trí, giờ mở cửa, tồn kho và giao diện mua/bán; dữ liệu hàng hóa cấu hình bằng Resource `.tres`.
- Job có tuyển dụng, ca làm, chấm công, lương và lịch nghỉ.
- Nhu cầu Player tiêu thụ vật phẩm thật thay vì hồi miễn phí.

### Giai đoạn C — NPC Simulation sâu
- Dữ liệu NPC tách Resource `.tres`, thêm NPC không cần viết script mới.
- Lịch theo thứ trong tuần, ngày nghỉ và sự kiện.
- Nhu cầu, ngân sách, mua sắm và hành vi xã hội.
- Hội thoại có lựa chọn, quan hệ và ghi nhớ tương tác.
- Mô phỏng off-screen theo bước thời gian, không cần giữ toàn bộ NPC hoạt động vật lý.

### Giai đoạn D — Mở rộng thế giới
- Location Registry, POI và điểm vào nhà/cửa hàng.
- Navigation theo lối đi bộ, tránh vật cản.
- Chunk/region streaming và lưu trạng thái độc lập scene.
- Thêm khu chợ, cửa hàng, nơi làm việc và khu dân cư có chức năng.
- Tối ưu số NPC, draw call, physics và bộ nhớ trên Android.

## 5. Tiêu chí hoàn thành

Một hạng mục chỉ chuyển sang **Done** khi có đủ:
1. Không có parser/resource error trong Godot Android.
2. Chức năng được chạy thử thực tế trên Godot Android.
3. README module và CHANGELOG được cập nhật.
4. Không có regression đã biết.
5. Kết quả kiểm tra được ghi lại, không suy diễn từ kiểm tra file tĩnh.

## 6. Quy ước trạng thái

- **Đã có mã nguồn:** file/logic đã được tạo hoặc tích hợp.
- **Chờ Godot Android:** chưa có xác nhận parser/runtime trên thiết bị.
- **Đang phát triển:** mới có nền móng, còn thiếu các chức năng quan trọng.
- **Chưa làm:** chưa có implementation.
- **Done:** chỉ dùng sau khi đạt tiêu chí ở mục 4.

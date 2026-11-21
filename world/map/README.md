# World Map — Continuous Open World

## 1. Mục tiêu

World Map là nền tảng thế giới mở liền mạch của ProjectGame.

ProjectGame sử dụng một thế giới chung có ranh giới địa lý. Thành phố,
khu dân cư, ngoại ô, vùng nông thôn và các địa điểm hoạt động là những
khu vực thuộc cùng một thế giới, không phải các màn chơi độc lập.

Định hướng là một thành phố Việt Nam hiện đại cùng vùng ngoại ô và nông
thôn bao quanh. Thế giới được mở rộng dần theo từng giai đoạn phát triển.

## 2. Trạng thái triển khai

### Đã có trong prototype hiện tại

- Một scene thế giới chính: `scenes/map_root.tscn`.
- Player dùng `CharacterBody3D`.
- Camera góc nghiêng và điều khiển joystick cảm ứng.
- Mặt đất và môi trường được dựng bằng Mesh.
- Đường chính, đường ngang và kênh nước.
- Các cụm nhà dân cư.
- Giới hạn địa hình và collision.
- Minimap vẽ bằng Control drawing.
- Chạm minimap: Control mở rộng phủ toàn viewport và hiển thị bản đồ lớn độc lập với khung minimap.
- Hỗ trợ zoom bằng thao tác chụm/xòe hai ngón và nút +/−.
- Hỗ trợ kéo bản đồ bằng một ngón tay.
- Chạm vị trí để đặt waypoint; bản đồ giữ trạng thái mở để xem vị trí.
- Waypoint được giữ khi đóng và mở lại bản đồ.

### Chưa triển khai

- Chunk streaming và giải phóng khu vực xa.
- Dữ liệu Region/District/Location độc lập.
- Navigation pathfinding giữa các địa điểm.
- Tuyến đường thực tế trên bản đồ.
- Hệ thống POI và bộ lọc địa điểm.
- NPC streaming và mô phỏng theo khoảng cách.
- Lưu waypoint qua SaveCoordinator.
- Địa hình, công trình và đường phố hoàn chỉnh.
- Kiểm thử runtime trên thiết bị Android.

Không xem các mục chưa triển khai là tính năng đã hoàn thành.

## 3. Scene chính

- Scene: `scenes/map_root.tscn`
- Controller: `map_controller.gd`
- Player: `player_controller.gd`
- Minimap: `minimap.gd`
- Player HUD: `player_hud.gd`
- Joystick: `virtual_joystick.gd`

`map_root.tscn` là điểm khởi đầu của thế giới liên tục.

`fishing_lake_map.tscn` hiện được giữ lại làm scene prototype cũ,
không còn là đích chuyển scene trong luồng thế giới chính.

## 4. Quy tắc thế giới

- Chỉ có một thế giới liên tục trong luồng chơi chính.
- Không chuyển scene khi người chơi đi giữa các khu vực thông thường.
- Các khu vực là phân vùng logic trong cùng thế giới.
- Địa điểm phải có ID ổn định.
- Spawn point phải được quản lý bằng dữ liệu, không dựa vào tên scene.
- Không tạo bản đồ vô tận ngẫu nhiên.
- Thế giới có ranh giới và được mở rộng có chủ đích.
- Không tải toàn bộ thế giới chi tiết cùng lúc khi quy mô tăng.

## 5. Quy hoạch khu vực dài hạn

- Urban Core: trung tâm đô thị, văn phòng, thương mại.
- Residential: khu dân cư và nhà ở.
- Suburban: ngoại ô, gara, cửa hàng nhỏ.
- Industrial: nhà máy, kho bãi và khu sản xuất.
- Countryside: đồng ruộng, trang trại và làng quê.
- Riverside: khu dân cư ven sông, bến tàu và chợ.
- Recreation: công viên, hồ câu và hoạt động giải trí.

Đây là quy hoạch mục tiêu, không có nghĩa tất cả khu vực đã được xây dựng.

## 6. Kiến trúc mục tiêu

```text
world/
├── map/
│   ├── README.md
│   ├── map_controller.gd
│   ├── minimap.gd
│   └── scenes/
├── regions/
│   ├── region_definition.gd
│   └── region_registry.gd
├── locations/
│   ├── location_definition.gd
│   └── location_registry.gd
├── streaming/
│   ├── chunk_definition.gd
│   └── chunk_manager.gd
└── navigation/
    ├── world_navigation.gd
    └── waypoint_service.gd
```

Chỉ tạo module khi có tính năng sử dụng thực tế. Không tạo hàng loạt
thư mục rỗng.

## 7. Chunk Streaming

Khi thế giới đủ lớn, chia thế giới thành các Chunk theo tọa độ.

- Chunk gần Player: dựng chi tiết.
- Chunk ở khoảng cách trung bình: giảm chi tiết.
- Chunk xa: giải phóng mesh và collision không cần thiết.
- Dữ liệu gameplay quan trọng phải được lưu độc lập với scene.
- Việc giải phóng Chunk không được làm mất trạng thái NPC, vật phẩm
  hoặc địa điểm.

Chunk Manager không sở hữu logic NPC, Economy hoặc Inventory.

## 8. Minimap và World Map

`WorldMinimap` phụ trách hiển thị bản đồ và tương tác chọn waypoint.

- Minimap hiển thị hướng Bắc cố định.
- Bản đồ toàn màn hình hiển thị phạm vi thế giới hiện tại.
- Vị trí Player lấy từ Player Node.
- Waypoint chỉ là điểm đến được đánh dấu.
- Chọn waypoint không tự dịch chuyển Player.
- Tuyến đường chỉ được hiển thị khi Navigation cung cấp dữ liệu đường đi.

Hiện tại waypoint chỉ là dữ liệu tạm trong runtime, chưa lưu qua Save.

## 9. Đồ họa

Tuân thủ AGENTS.md:

- Không sử dụng texture trong giai đoạn hiện tại.
- Dùng MeshInstance3D, Primitive Mesh, ArrayMesh hoặc SurfaceTool.
- Dùng StandardMaterial3D và ShaderMaterial khi phù hợp.
- Tái sử dụng Mesh và Material.
- Giới hạn draw call và collision.
- Ưu tiên hiệu năng Android.

## 10. Kiểm thử Godot Android

1. Mở project bằng Godot Android.
2. Chạy Boot scene.
3. Kiểm tra Player xuất hiện ở khu dân cư.
4. Di chuyển trên đường chính.
5. Kiểm tra các khu vực mở rộng và giới hạn bản đồ.
6. Chạm minimap để mở bản đồ toàn màn hình.
7. Dùng hai ngón chụm/xòe để zoom và một ngón kéo bản đồ.
8. Thử nút +/− và kiểm tra giới hạn zoom.
9. Chạm vị trí trên bản đồ để đặt waypoint.
10. Đóng rồi mở lại bản đồ, xác nhận waypoint vẫn còn.
11. Kiểm tra joystick, camera và collision.

## 11. Giới hạn hiện tại

Đây là prototype thế giới liên tục quy mô nhỏ, không phải bản đồ
thành phố hoàn chỉnh.

Chưa có Chunk Streaming, Navigation routing, Location Registry,
NPC simulation streaming hoặc kiểm thử hiệu năng dài hạn.

Không tuyên bố hoàn thành các hệ thống trên cho đến khi có mã nguồn
và kết quả kiểm thử thực tế.


## 12. Điều khiển World Map

- Chạm minimap: mở bản đồ lớn phủ toàn màn hình, không bị giới hạn trong khung minimap.
- Đóng bản đồ lớn: khôi phục vị trí và kích thước minimap ban đầu.
- Kéo một ngón: di chuyển khung bản đồ.
- Chụm/xòe hai ngón: thu nhỏ/phóng to quanh tâm thao tác.
- Nút `+` và `−`: điều chỉnh zoom.
- Chạm vị trí trong vùng bản đồ: đặt waypoint.
- Nút `ĐÓNG`: quay lại minimap.

Zoom được giới hạn từ 1x đến 4x. Waypoint được giữ trong runtime khi
đóng và mở lại bản đồ; hiện chưa được lưu qua SaveCoordinator.


## 13. Minimap, Player HUD và bố trí môi trường

- Minimap vẽ đường theo tọa độ thế giới tương đối với Player; hướng Bắc cố định.
- Kênh nước trên bản đồ dùng đúng tọa độ `x = 25`.
- Cụm cây khu dân cư đặt ngoài mép vỉa hè; nhà gần giao lộ được lùi khỏi đường ngang.
- `PlayerHUD` hiển thị avatar hình học, thanh sức khỏe, giờ và thứ trong tuần.
- Đồng hồ UI chỉ đọc `GameClock`; không tự quản lý hoặc tăng thời gian.
- `Player3DController` cung cấp `apply_damage()` và `restore_health()` cùng signal `health_changed`.
- Máu hiện là trạng thái runtime của Player, chưa được tích hợp SaveCoordinator hoặc hệ thống chiến đấu.

### Kiểm tra trên Godot Android

1. Chạy map và xác nhận minimap luôn giữ Player ở tâm, đường di chuyển tương ứng với vị trí thực.
2. Chạm minimap để mở bản đồ lớn, kéo/zoom và đặt waypoint.
3. Quan sát các cây dọc khu dân cư và nhà quanh giao lộ, bảo đảm không nằm trên mặt đường.
4. Xác nhận avatar, thanh máu và đồng hồ hiển thị ở góc trái trên; minimap ở góc phải trên.
5. Tạm gọi `apply_damage()`/`restore_health()` từ debugger hoặc mã thử để xác nhận thanh máu cập nhật.
6. Tua `GameClock` để xác nhận đồng hồ UI thay đổi theo nguồn thời gian chung.

Chưa có kết quả chạy thực tế trên Godot Android cho lần cập nhật này.

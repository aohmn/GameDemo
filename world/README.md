# WORLD SYSTEM — KIẾN TRÚC THẾ GIỚI

## 1. Mục đích

World System quản lý cấu trúc không gian và vị trí địa lý trong ProjectGame.

Đây là tầng chịu trách nhiệm tổ chức thế giới thành các vùng, khu vực và địa điểm. World cung cấp dữ liệu vị trí cho những hệ thống gameplay khác mà không sở hữu logic kinh tế, nhân vật, NPC hoặc giao diện.

Định hướng thế giới:
- Bối cảnh Việt Nam hiện đại.
- Thế giới mở có nhiều khu vực.
- Mỗi khu vực có địa điểm và hoạt động riêng.
- Có thể mở rộng bản đồ mà không phải viết lại hệ thống cũ.
- Hỗ trợ di chuyển vật lý trong khu vực gần.
- Hỗ trợ mô phỏng hành trình khi di chuyển xa.
- Tối ưu cho thiết bị Android.

## 2. Phạm vi trách nhiệm

World quản lý:

- Regions: vùng địa lý lớn.
- Districts: quận, huyện hoặc khu vực trực thuộc Region.
- Locations: địa điểm cụ thể.
- Navigation: dữ liệu và khả năng tìm đường.
- Spawning: vị trí xuất hiện của nhân vật và đối tượng.
- World Loading: tải và giải phóng khu vực.
- Current Location: địa điểm hiện tại của người chơi.

World không trực tiếp quản lý:

- Tiền và giao dịch.
- Inventory và vật phẩm.
- Nhu cầu nhân vật.
- Hành vi và lịch trình NPC.
- Điều khiển nhân vật.
- Giao diện chọn điểm đến.
- Logic tính toán và thực hiện giao dịch vận chuyển.

Những chức năng trên thuộc module sở hữu tương ứng.

## 3. Cấu trúc địa lý

Cấu trúc phân cấp:

    World
    └── Region
        └── District
            └── Location
                └── Spawn Point

### 3.1. Region

Region đại diện cho một vùng địa lý lớn.

Ví dụ:
- Vùng đô thị.
- Vùng nông thôn.
- Vùng ven sông.
- Vùng ngoại ô.

Một Region chứa nhiều District.

### 3.2. District

District đại diện cho một quận, huyện, thị xã hoặc khu vực địa lý tương đương.

District thuộc một Region và chứa nhiều Location.

### 3.3. Location

Location đại diện cho một địa điểm cụ thể trong thế giới.

Ví dụ:
- Nhà người chơi.
- Chợ truyền thống.
- Cửa hàng.
- Bệnh viện.
- Bến xe.
- Nơi làm việc.
- Khu dân cư.

Mỗi Location phải có ID ổn định, không sử dụng tên hiển thị làm định danh.

Thông tin định hướng:

    location_id
    region_id
    district_id
    display_name
    scene_path
    spawn_point_id
    unlocked
    location_type

Các trường dữ liệu chính thức sẽ được xác định khi triển khai Location Data.

### 3.4. Spawn Point

Spawn Point là vị trí xuất hiện hợp lệ bên trong một Location.

Ví dụ:
- Cổng nhà.
- Cửa chính cửa hàng.
- Bến xe.
- Điểm xuất hiện khi chuyển khu vực.

Spawn Point phải có ID ổn định để hệ thống chuyển khu vực có thể xác định vị trí xuất hiện.

## 4. Location Manager

Location Manager quản lý trạng thái địa điểm hiện tại.

Trách nhiệm:

- Lưu ID Location hiện tại.
- Tra cứu thông tin Location.
- Xác định Region và District chứa Location.
- Cung cấp thông tin vị trí cho hệ thống khác.
- Cập nhật Location khi người chơi đến địa điểm mới.
- Xác định Spawn Point khi chuyển khu vực.

Không cho phép module khác tự sửa dữ liệu nội bộ của Location Manager.

Các module phải sử dụng API công khai.

API định hướng:

    get_current_location_id()
    get_location(location_id)
    get_current_region_id()
    get_current_district_id()
    set_current_location(location_id)

Đây là API thiết kế, chưa khẳng định đã được triển khai.

## 5. Navigation

Navigation quản lý khả năng di chuyển giữa các vị trí.

Phạm vi:

- Đường đi trong khu vực.
- Kết nối giữa các Location.
- Tuyến đường giữa các District.
- Tuyến đường giữa các Region.
- Khoảng cách và loại đường.
- Khả năng sử dụng phương tiện trên tuyến.

Navigation cần phân biệt:

### 5.1. Local Navigation

Dùng cho di chuyển vật lý trong khu vực đang được tải.

Có thể sử dụng NavigationRegion3D và NavigationAgent3D khi gameplay cần.

Player Controller vẫn chịu trách nhiệm điều khiển nhân vật, va chạm và chuyển động vật lý.

World cung cấp dữ liệu không gian và khả năng tìm đường, không trực tiếp điều khiển nhân vật.

### 5.2. Long-distance Route

Dùng cho hành trình giữa các địa điểm xa hoặc khác khu vực.

Tuyến đường cần có dữ liệu độc lập với scene 3D.

Thông tin định hướng:

    route_id
    from_location_id
    to_location_id
    distance_km
    road_type
    allowed_travel_modes
    travel_overhead_minutes

Khoảng cách và thời gian phải được tính từ dữ liệu tuyến đường và phương thức di chuyển.

Không sử dụng khoảng cách đường chim bay làm khoảng cách hành trình chính thức khi đã có dữ liệu đường đi.

## 6. Hybrid Travel — cơ chế di chuyển

ProjectGame sử dụng mô hình kết hợp hai phương thức:

### 6.1. Di chuyển vật lý gần

Khi người chơi di chuyển trong phạm vi khu vực đang hoạt động:

1. Người chơi chọn điểm đến.
2. World xác định Location và khả năng tiếp cận.
3. Điểm đến được đánh dấu.
4. Người chơi tự điều khiển nhân vật.
5. Khi đến nơi, Location Manager cập nhật địa điểm hiện tại.

Đặc điểm:

- Không dịch chuyển tức thời.
- Không tự động tua thời gian theo thời lượng tuyến đường.
- Thời gian trong game tiếp tục vận hành theo cơ chế hiện tại.
- Player Controller chịu trách nhiệm di chuyển và va chạm.

### 6.2. Mô phỏng hành trình xa

Khi điểm đến nằm ngoài phạm vi di chuyển vật lý phù hợp:

1. Người chơi chọn điểm đến.
2. Travel System lập kế hoạch hành trình.
3. Kiểm tra điều kiện và phương tiện.
4. Tính thời gian và chi phí.
5. Hiển thị thông tin để người chơi xác nhận.
6. Thực hiện hành trình.
7. Cập nhật thời gian trong game.
8. Tải khu vực đích.
9. Đặt nhân vật tại Spawn Point.
10. Cập nhật Location hiện tại.

World chịu trách nhiệm cung cấp thông tin khu vực, Location, Scene và Spawn Point.

Travel System chịu trách nhiệm điều phối hành trình.

Không để World tự trừ tiền hoặc tự quản lý giao dịch.

### 6.3. Quy tắc phân loại

Không hard-code khoảng cách hoặc điều kiện di chuyển trực tiếp vào giao diện.

Ngưỡng phân loại Local Travel và Simulated Travel phải có khả năng cấu hình.

Quyết định phương thức di chuyển cần xét:

- Khu vực hiện tại.
- Khu vực đích.
- Khả năng tiếp cận.
- Tuyến đường.
- Phương tiện.
- Trạng thái thế giới.

Chưa ấn định ngưỡng khoảng cách chính thức.

## 7. Quan hệ với các module khác

### Player

- Player Controller điều khiển chuyển động vật lý.
- World cung cấp thông tin vị trí và điểm đến.
- Không để World điều khiển trực tiếp input của Player.

### Transportation

Transportation quản lý nghiệp vụ vận chuyển và hành trình.

Trách nhiệm:

- Lập kế hoạch.
- Chọn phương thức di chuyển.
- Kiểm tra điều kiện.
- Tính thời gian.
- Tính chi phí.
- Thực hiện hành trình.

Transportation sử dụng dữ liệu tuyến đường và Location từ World.

### GameClock

GameClock là nguồn thời gian duy nhất của game.

- World không tạo đồng hồ riêng.
- Local Movement không tự ý thay đổi thời gian.
- Simulated Travel sử dụng GameClock API để cập nhật thời gian hành trình.
- Những hệ thống phụ thuộc thời gian phải xử lý đúng khoảng thời gian đã trôi qua.

### Economy

Economy là nguồn dữ liệu tiền duy nhất.

- World không quản lý số dư.
- World không tự trừ tiền.
- Mọi chi phí hành trình phải thông qua Economy API khi module Economy được triển khai.

### NPC

NPC sở hữu dữ liệu và hành vi của NPC.

World cung cấp:
- Location.
- Khu vực hoạt động.
- Dữ liệu không gian.
- Thông tin cần thiết để xác định nơi xuất hiện.

Không đặt lịch trình hoặc hành vi NPC trong World.

### Presentation

Presentation chịu trách nhiệm giao diện bản đồ và chọn điểm đến.

World cung cấp dữ liệu để hiển thị.

UI không chứa logic nghiệp vụ của World hoặc Transportation.

## 8. Giao tiếp và sự kiện

Các module giao tiếp bằng API hoặc Event.

API dùng cho yêu cầu cần kết quả trực tiếp.

Event dùng để thông báo thay đổi trạng thái.

Các sự kiện định hướng:

    location_changed
    region_changed
    district_changed
    world_location_loaded
    world_location_unloaded

Payload định hướng:

    {
        "previous_location_id": "home_player",
        "current_location_id": "market_binh_an",
        "region_id": "region_example",
        "district_id": "district_example"
    }

Đây là ví dụ hợp đồng dữ liệu, không phải sự kiện đã được đăng ký trong EventBus hiện tại.

Không tạo EventBus riêng cho World.

Sử dụng EventBus dùng chung theo quy tắc Core.

## 9. Tải và giải phóng khu vực

World cần hỗ trợ tải và giải phóng khu vực theo nhu cầu.

Định hướng:

- Chỉ tải khu vực cần thiết.
- Giải phóng tài nguyên không còn sử dụng.
- Tránh giữ nhiều scene lớn trong bộ nhớ.
- Duy trì dữ liệu cần thiết khi chuyển khu vực.
- Đặt nhân vật đúng Spawn Point.
- Không làm mất trạng thái gameplay cần lưu.

Việc tải Scene cần phối hợp với hệ thống chuyển Scene cấp ứng dụng.

Không để World tự tạo một SceneRouter trùng lặp.

## 10. Save và Load

World chịu trách nhiệm cung cấp dữ liệu cần lưu của mình.

Dữ liệu định hướng:

    current_region_id
    current_district_id
    current_location_id
    current_spawn_point_id

Quy tắc:

- Mỗi module tự serialize dữ liệu sở hữu.
- SaveCoordinator điều phối quá trình lưu và tải.
- Dữ liệu có version.
- Kiểm tra ID và dữ liệu trước khi khôi phục.
- Có giá trị mặc định an toàn khi dữ liệu không còn tồn tại.
- Không để World ghi đè dữ liệu của module khác.

Trạng thái hành trình đang thực hiện chỉ được lưu khi Travel System có cơ chế phục hồi hợp lệ.

## 11. Cấu trúc thư mục định hướng

Cấu trúc dự kiến:

    world/
    ├── README.md
    ├── map/
    │   ├── scenes/
    │   ├── map_controller.gd
    │   ├── player_controller.gd
    │   ├── virtual_joystick.gd
    │   └── README.md
    │
    ├── regions/
    ├── districts/
    ├── locations/
    ├── navigation/
    ├── spawning/
    └── loading/

Không tạo hàng loạt thư mục rỗng.

Chỉ bổ sung thư mục khi có chức năng thực sự cần sử dụng.

Không di chuyển file hiện có nếu chưa có yêu cầu và kế hoạch chuyển đổi rõ ràng.

## 12. Quy tắc kiến trúc

- World chỉ sở hữu logic và dữ liệu thuộc phạm vi World.
- Không tạo GameManager khổng lồ.
- Không tạo phụ thuộc vòng tròn.
- Không truy cập trực tiếp dữ liệu nội bộ module khác.
- Sử dụng API hoặc Event để giao tiếp.
- Dữ liệu tách khỏi logic.
- ID phải ổn định.
- Có thể kiểm tra độc lập.
- Không tạo abstraction không có nhu cầu thực tế.
- Ưu tiên hiệu năng Android.
- Không sử dụng texture trong giai đoạn đồ họa hiện tại.
- Ưu tiên Mesh, Primitive Mesh và Shader.

## 13. Trạng thái hiện tại

### Đã có trong repo

- Scene bản đồ 3D prototype.
- Map Controller tạo môi trường bằng Primitive Mesh.
- Player CharacterBody3D.
- Điều khiển bằng Virtual Joystick.
- Camera góc nhìn cố định nghiêng.
- Môi trường thử nghiệm gồm mặt đất, đường, kênh nước, nhà và cây.

Các thành phần hiện tại nằm trong:

    world/map/

### Chưa triển khai

- Region Data.
- District Data.
- Location Data.
- Location Manager.
- Spawn Point Registry.
- Navigation Data.
- Long-distance Route.
- World Loading Manager.
- World Map UI.
- Hybrid Travel.
- Tích hợp Location với SaveCoordinator.

Các nội dung này là định hướng kiến trúc, không phải tính năng đã hoàn thành.

## 14. Lộ trình phát triển

### Phase 1 — Location Foundation

- Xây dựng Location Data.
- Chuẩn hóa ID.
- Xây dựng Location Manager.
- Xác định Location hiện tại.
- Tích hợp với MapRoot hiện có.

### Phase 2 — Region và District

- Xây dựng Region Data.
- Xây dựng District Data.
- Thiết lập quan hệ phân cấp.
- Tra cứu Location theo khu vực.

### Phase 3 — Spawn System

- Xây dựng Spawn Point Data.
- Xác định điểm xuất hiện.
- Hỗ trợ chuyển vị trí nhân vật.

### Phase 4 — Local Navigation

- Xây dựng dữ liệu điều hướng.
- Tích hợp NavigationRegion3D khi cần.
- Hỗ trợ chọn điểm đến gần.
- Kiểm tra khả năng tiếp cận.

### Phase 5 — World Map

- Hiển thị vị trí hiện tại.
- Hiển thị các Location.
- Chọn điểm đến.
- Hiển thị trạng thái mở khóa.

### Phase 6 — Long-distance Route

- Xây dựng dữ liệu tuyến đường.
- Xác định kết nối giữa Location.
- Cung cấp dữ liệu cho Travel Planner.

### Phase 7 — Hybrid Travel Integration

- Kết nối World với Transportation.
- Phân loại di chuyển gần và xa.
- Hỗ trợ chuyển khu vực.
- Cập nhật Location sau hành trình.
- Tích hợp GameClock.

### Phase 8 — Save và mở rộng

- Tích hợp SaveCoordinator.
- Kiểm tra khôi phục vị trí.
- Mở rộng số lượng khu vực.
- Tối ưu tải và giải phóng tài nguyên.

## 15. Kiểm tra

Mỗi giai đoạn cần kiểm tra:

- ID và dữ liệu hợp lệ.
- Quan hệ Region, District, Location.
- Tra cứu Location.
- Spawn Point hợp lệ.
- Scene tồn tại.
- Chuyển khu vực đúng vị trí.
- Không làm mất trạng thái cần lưu.
- Không tạo phụ thuộc vòng tròn.
- Hiệu năng trên Android.

Quy trình kiểm tra:

1. Kiểm tra cấu trúc và dữ liệu bằng Termux.
2. Mở dự án bằng Godot Android.
3. Kiểm tra lỗi parser và Resource.
4. Chạy thử chức năng thực tế.
5. Ghi rõ kết quả kiểm tra và giới hạn còn tồn tại.

Không báo cáo tính năng hoàn thành nếu chưa có kết quả kiểm tra thực tế.

---

Tài liệu này là hợp đồng kiến trúc tổng thể của World System. Mọi triển khai phải tuân thủ AGENTS.md và cập nhật README của module liên quan.

## Navigation Foundation — route preview

The `world/navigation/` module contains an AStar2D road-graph foundation and
runs as the autoload `WorldNavigation`.

- `navigation_service.gd` (autoload `WorldNavigation`) builds a graph from the configured road intersections.
- Modules request a route with `WorldEvents.ROUTE_REQUESTED` and receive `WorldEvents.ROUTE_READY`; there is no direct function call.
- `world/map/minimap.gd` requests a route when the player selects a waypoint.
- NPCs request routes through the same events.
- The full map draws the returned route and reports whether a route was found.

This is visual route preview only. It does not move the player automatically,
does not include obstacle-aware local navigation, and does not yet model
sidewalks, entrances, one-way roads, traffic, or road closures.

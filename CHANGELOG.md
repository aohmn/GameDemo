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

# CHANGELOG

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

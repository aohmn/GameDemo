# CHANGELOG

## Chưa phát hành

- Tạo module cửa hàng độc lập `modules/shop/` (danh mục cần câu .tres qua ShopItemSpec, hiển thị giá VND và chỉ số, mua vật phẩm kiểm tra số dư và chặn mua trùng, phát sự kiện ITEM_ADDED sang Inventory, trang bị cần câu đồng bộ sang Fishing API, lưu/tải user://shop.cfg, README, ROADMAP, dev.tscn chạy độc lập, và ServiceCoordinator điều phối giao dịch atomic tại Bootstrap).
- Tạo module kinh tế độc lập `modules/economy/` (quản lý số dư VND, bảng giá cá .tres qua FishPriceSpec, tính giá theo trọng lượng và số lượng, kiểm tra giao dịch không bán vượt, ghi lịch sử, ConfigFile user://economy.cfg, phát sự kiện EventBus, README, ROADMAP, dev.tscn chạy độc lập, và điều phối giao dịch bán cá atomic tại Bootstrap).
- Tạo giao diện túi cá `presentation/fishing_inventory_ui/` (hiển thị danh sách cá, tên có dấu, số lượng, khối lượng g/kg, trạng thái túi trống, nút mở/đóng modal tối ưu cho mobile, cập nhật tự động qua sự kiện EventBus, scene dev.tscn chạy độc lập, nạp tùy chọn tại Bootstrap).
- Tạo module túi đồ độc lập `modules/inventory/` (lưu trữ cá theo fish_id, số lượng và tổng trọng lượng, lắng nghe FISH_CAUGHT từ EventBus, lưu/tải user://inventory.cfg bằng ConfigFile, README, ROADMAP và dev.tscn chạy riêng; nạp tùy chọn tại Bootstrap).
- Sửa FishingLogic hồi phục sức cá khi lực căng ngoài vùng an toàn (`+ (fatigue * 0.15) * delta`) giới hạn tối đa sức cá ban đầu và kiểm tra toàn bộ FSM, scene Fishing Dev.
- Điều chỉnh thứ tự khởi tạo Camera trước SkyDome trong `maps/harbor_island/dev.gd` để SkyDome liên kết camera mục tiêu ngay từ đầu.
- Tạo module logic câu cá `modules/fishing/` (FSM 6 trạng thái, cửa sổ giật cần 0.8s, giằng co lực căng dây, dữ liệu .tres có kiểu gồm 6 loài cá, 2 cần câu, 1 điểm câu, dev.tscn chạy độc lập, RNG seed) và đồng bộ giá trị mặc định sun_dir/sun_direction giữa water và SkyDome (Mức 1 tĩnh; chưa kiểm tra mức 2-3 do môi trường không có Godot CLI).
- Tạo module core gồm EventBus autoload (dùng Callable, tự dọn dẹp node giải phóng), hợp đồng sự kiện (FishingEvents, InventoryEvents, EconomyEvents), GameClock autoload (theo dõi giờ và phát tín hiệu), và đồng bộ hướng mặt trời một nguồn duy nhất từ map sang SkyDome và water shader (Mức 1 tĩnh; chưa kiểm tra mức 2-3 do môi trường không có Godot CLI).
- Viết lại water shader cartoon nhẹ cho Android (2 lần noise mỗi điểm ảnh thay vì ~80), mặt nước 600 m mờ dần về màu chân trời, không còn lộ mép. Mức 2 (Godot Linux, không SHADER ERROR); chưa kiểm tra mức 3 trên Godot Android.
- Xác nhận và làm rõ hình học tấm ván nâu bên phải cầu tàu (DockedBoat2) trong hệ thống builder (Mức 2).

- Tách `maps/harbor_island/map.gd` thành các builder nhỏ (terrain_builder, pier_builder, prop_builder) đều dưới 200 dòng, giữ nguyên 100% hình học bản đồ (Mức 2).

- Điều chỉnh vị trí spawn Player ra giữa cầu tàu tại x=-2.0, z=10.0; xác nhận khoảng cách tới lan can hai bên đạt 2.25m (> 1.5m) (Mức 2).

- Cấu hình hiển thị màn hình ngang `display/window/handheld/orientation = landscape` trong project.godot (Mức 2).

- Nạp map động qua ResourceLoader.exists và load đường dẫn chuỗi trong MapManager, kiểm tra tồn tại Player scene tại Bootstrap (Mức 2).

- Nâng cấp water shader đại dương chân thực bằng domain-warped procedural noise, Fresnel, Blinn-Phong specular và tính shoreline theo hình học bờ biển thực tế.
- Bổ sung scene dev kiểm tra mặt nước `maps/harbor_island/dev.tscn` với camera quỹ đạo nhiều góc nhìn.
- Tạo water shader procedural cho đại dương đảo harbor_island: chuyển màu nước nông xanh ngọc sang nước sâu xanh lam, sóng nhẹ, phản chiếu và viền bọt trắng tinh tế gần bờ cát.
- Đóng khe hở ranh giới phía Nam tại x=-9 đến -1 ven bãi cát mà không chặn lối lên cầu tàu.
- Sửa công thức tính sun_disc theo góc (acos/angle) để mặt trời procedural có kích thước nhỏ, sắc nét và tự nhiên.
- Đồng bộ collision_layer = 1 mặc định cho toàn bộ ranh giới, địa hình, vách núi và cầu tàu để Player cản chạm vững chắc, không bị xuyên tường rơi xuống biển.
- Tích hợp Sky Dome vào Bootstrap (`main.gd`) với cơ chế nạp tùy chọn độc lập.
- Tinh chỉnh cửa biển thông thoáng ra đại dương tại đảo bến cảng và phân tách collision layer ranh giới barrier.
- Bổ sung dốc thoai thoải kết nối bãi cát lên cầu tàu giúp Player di chuyển liền mạch và loại bỏ va chạm chồng lấn thuyền/cầu tàu.
- Đổi map khởi đầu từ vietnam_street thành harbor_island với ID và đường dẫn `maps/harbor_island/`.
- Chuẩn hóa cao độ địa hình bến cảng, bảo đảm Player spawn ổn định tại y=0.05 không bị rơi.
- Tinh chỉnh nối cầu tàu với bờ, mở cửa biển tự nhiên thông ra bắc và bổ sung ranh giới chống rơi xuống biển.
- Cập nhật định hướng dự án sang game phiêu lưu khám phá và câu cá tại AGENTS.md và tạo decision 0001.
- Chuyển map hiện tại thành đảo bến cảng nhiệt đới (~50x50m) có đại dương bao quanh, vịnh tự nhiên, cầu tàu gỗ, núi đá, công trình và rặng dừa.
- Bổ sung collision đầy đủ cho địa hình, biển, cầu tàu, thuyền, núi đá và cây cối trên đảo.
- Cập nhật README gốc và README của map phản ánh đúng bối cảnh đảo nhiệt đới.
- Giữ nguyên hướng nhìn cuối cùng khi Player dừng lại (idle).
- Thêm joystick cảm ứng độc lập, hỗ trợ cảm ứng và chuột.
- Bootstrap tải joystick tùy chọn để không phụ thuộc cứng vào module presentation.
- Bổ sung scene dev và tài liệu sử dụng joystick.
- Thêm MapManager để tải, thay thế và giải phóng map theo ID.
- Chuyển Bootstrap từ preload trực tiếp sang khởi tạo MapManager.
- Bổ sung tài liệu cho Bootstrap và map vietnam_street.
- Bootstrap tạo Player, nối signal joystick với API di chuyển của Player và camera bám nhân vật.
- Map vietnam_street bổ sung collider cho mặt đất, vỉa hè, lề đường và công trình.
- Sửa hướng trục UV Y của Player để đầu ở trên, chân ở dưới.

# CHANGELOG

## Chưa phát hành

- Tích hợp Pháp Bảo & Trang Bị vào game chính: thêm 3 trang bị mới (Cước Bạch Liên, Mồi Linh Trùng, Định Hải Châu); giao diện trang bị `presentation/equipment_ui/` với 5 slot (cần/dây/mồi/pháp bảo/di vật), nối qua `ui_action_router` → `service_coordinator` → `EquipmentAPI`; Bootstrap tải EquipmentAPI và EquipmentUI tự động khi module tồn tại; refactor `_init_services()` dùng helper `_load_api()` giữ main.gd 289 dòng (Mức 2, boot đạt Player y=0.050, HUD 5 children; chưa chạy Godot Android).

- Điểm câu Hồ Linh Ngư & nhận diện vùng câu động: bổ sung `spot_ho_linh_ngu` với hệ sinh thái cá nước ngọt (Cá Chép Linh, Cá Trắm Ngọc) trên cao nguyên đảo bến cảng; `maps/harbor_island/map.gd` và `CastCoordinator` tự động nhận diện điểm câu theo vị trí rơi phao và hiển thị trực quan trên Fishing UI (Mức 2, kiểm thử nhận diện vùng & nạp cá đạt; chưa chạy Godot Android).

- Dọn dẹp kỹ thuật & chuẩn hóa độc lập: loại bỏ preload chéo module trong các scene dev (`maps/harbor_island/dev.gd`, `presentation/.../dev.gd`); tối ưu cấu trúc các file chạm trần 300 dòng (`fishing_logic`, `gameplay/dev`, `fishing_inventory_ui`, `main`) xuống <= 283 dòng (Mức 2, toàn bộ 15/15 dev scenes & 10/10 test gameplay đạt; chưa chạy Godot Android).

- Sửa lỗi InventoryAPI thiếu `load_data()` khiến túi cá không tải được khi mở lại game; chỉnh cao nguyên, dốc lối đi, Hồ Linh Ngư và bờ cát vịnh cầu tàu trên `harbor_island` hết bị chìm và thả cần được ở mạn cầu tàu lẫn Hồ Linh Ngư (Mức 2, Godot Android).
- Đồ họa map procedural (không texture): bộ shader dùng chung `assets/shaders/` (ván sàn, gỗ, ngói, đá lát, bạch ngọc, đá thô, tán lá) chọn theo tên node qua `ProcMaterial`; cát gợn sóng, cỏ có mảng và hoa, vách núi có tầng đá; bỏ tấm `PlateauCenter` thừa gây vệt đen; bóng đổ 2 tầng cho Android (Mức 2, render bằng Mesa; chưa đo FPS trên điện thoại).
- Popup bắt cá ghi rõ linh khí nằm trong cá và chỉ vào tu vi khi mở Túi bấm Hấp thu (trước đó ghi "+N Linh Khí" khiến người chơi tưởng tu vi tự tăng) (Mức 2; chưa chạy Godot Android).
- Hấp thu linh khí: HUD tu vi (`presentation/cultivation_ui/`), nút Hấp thu/Bán trong túi cá, nút ĐỘT PHÁ, thông báo khi bị từ chối thả cần; `scenes/boot/ui_action_router.gd` nối UI với logic; cần carbon yêu cầu cảnh giới 1 (Mức 2, chạm mô phỏng; chưa chạy Godot Android).
- Sửa lỗi nghiêm trọng: inventory, cultivation, crafting, equipment, map_manager gọi `EventBus.emit` (không tồn tại) nên mọi sự kiện của chúng bị nuốt; nay gọi `emit_event`.
- Sửa lỗi nút "Thả Cần" sáng nhưng chạm không ăn trên điện thoại: UI bị vẽ lại mỗi khung vật lý làm nút ẩn/hiện liên tục và Godot hủy trạng thái nhấn; nay `set_near_fishing_spot` bỏ qua khi không đổi và `_set_visible_widgets` không ẩn rồi hiện lại (Mức 2, tái hiện bằng chạm giữ 0,1 s; chưa chạy Godot Android).
- Fishing chuẩn thiết kế tu tiên: cần câu phẩm N chỉ câu được cá phẩm ≤ N+1 (`FishingCalculator.max_catchable_fish_tier`); cổng cảnh giới của điểm câu/cần câu qua `FishingAPI.set_realm_provider` + sự kiện `fishing_cast_denied`; Bootstrap tạo Cultivation (trước đó chưa nối vào game); sửa test dev bị sai do lambda bắt biến theo giá trị, thêm test phẩm cấp (Mức 2, 10/10 test xanh; chưa chạy Godot Android).
- Sửa lỗi khó thả cần: thêm lan can đầu cầu chính (`BoundMainPierEnd`) để nhân vật không đi rơi khỏi cầu rồi bị đưa về điểm xuất phát; tăng tầm thả phao lên 4 m; gợi ý trên UI chỉ rõ cách ra điểm câu (Mức 2, chưa chạy Godot Android).
- Sửa kiến trúc: chuyển `gameplay/fishing/` vào `modules/fishing/gameplay/` (module fishing không còn preload ra thư mục ngoài, thử xóa từng module vẫn boot); sửa lỗi parse `modules/fishing/gameplay/dev.gd` và lỗi `look_at` của `modules/player/scenes/dev.gd` (Mức 2, chưa chạy Godot Android).
- TASK 13: Hoàn thiện Fishing UI phong cách Genshin Impact x Sea of Thieves — thiết kế lại toàn bộ bảng HUD tiên hiệp biển khơi trung tâm và cụm phím điều khiển cảm ứng tối ưu Android ngang; hiển thị rõ trạng thái câu, thanh tiến trình thu phục cá, thanh lực căng dây đa sắc theo vùng an toàn, độ bền cần/dây thời gian thực, phản hồi hành vi cá (mệt lả, giãy bứt tốc, tạm nghỉ) và popup kết quả câu; đồng bộ đầy đủ với FishingController, FishingBattle, FishingRig và EventBus (FIGHT_UPDATE bổ sung metadata độ bền và chế độ cá); tách tiện ích FishingUITheme đảm bảo <300 dòng/file, không dùng texture.
- TASK 12: Đồng bộ module câu cá — chuẩn hoá tên trạng thái FIGHT thống nhất giữa Controller, UI, Rig và EventBus; trang bị dây câu và cần câu ảnh hưởng trực tiếp giới hạn lực căng, tốc độ thu/xả và độ bền trong battle (hỗ trợ ROD_BROKEN); 5 kỹ năng tu đạo có tác dụng gameplay cụ thể (Thính Thủy +0.35s cửa sổ, Ngự Câu +10 vùng an toàn, Tỏa Ngư -35% lực cá giới hạn 1 lần/phiên, Thu Linh +35% linh khí, Linh Nhãn thấu thị phẩm cấp cá); FishData đọc spirit_qi từ FishSpec; FishingAPI truyền line_res; Presentation UI/Rig xử lý state CAUGHT/ESCAPED/FAILED; dev test dùng typed Resources thay vì Resource.set().
- TASK 11: Xây dựng module câu cá hoàn chỉnh `gameplay/fishing/` (FSM 8 trạng thái IDLE, CASTING, WAITING, BITE, FIGHT, CAUGHT, ESCAPED, FAILED với ma trận kiểm soát chuyển đổi chống nhảy cóc; tách biệt `fishing_calculator.gd` cho toàn bộ phép tính toán học; bổ sung `FishData` và `FishAI` phản kháng theo đợt bứt tốc/nhử chùng dây; `TensionSystem` và `FishingBattle` giằng co thời gian thực chống nhấn nút đơn giản; mở rộng `FishingRod`, `FishingLine`, `BaitSystem` và khung 5 kỹ năng tu đạo `FishingSkill`; kết nối trực tiếp vào `modules/fishing/api/fishing_api.gd` và `EventBus`, scene kiểm thử độc lập `dev.tscn`).
- TASK 10: Thiết kế lại toàn bộ cảnh quan và bố cục Đảo Bến Cảng theo phong cách Genshin Impact x Sea of Thieves (tạo `docs/art.md`, triển khai Procedural Triplanar `terrain.gdshader` không texture cho cát bờ biển, đồi cỏ và vách đá xếp tầng, nâng cấp `water.gdshader` độ sâu 3 tầng, bọt sóng cuộn và cel-glint ánh mặt trời, bố cục hoàn chỉnh 8 khu vực gồm Bến Cảng, Quảng Trường Trung Tâm với Trận Pháp Truyền Tống bát quái, Tiên Các trên cao nguyên, Thương Hội, Lò Chế Tạo, Kho Linh Ngư, Hồ Linh Ngư khởi đầu và Đài Quan Hải vọng cảnh ngắm biển; va chạm và spawn player ổn định, tối ưu GPU mobile).
- TASK 09: Xây dựng Đảo Bến Cảng thành đại bản doanh tu tiên (chia nhỏ qua các builder: PlazaPathBuilder, SectBuildingBuilder; bổ sung Quảng trường trung tâm, Tiên Các 2 tầng bạch ngọc, Thương Hội gỗ đỏ, Lò Chế Tạo huyền thạch, Kho Linh Ngư, Hồ Linh Ngư xanh biếc và đường đi đá phiến kết nối liền mạch; collision đầy đủ, không dùng texture).
- TASK 08: Hệ thống đa bản đồ Multi-Map (tạo MapDefinition, MapConnection bằng Resource .tres, MapEvents contract, nâng cấp MapManager hỗ trợ đăng ký, mở khóa, kiểm tra cảnh giới và chuyển đổi bản đồ, tích hợp đảo bến cảng harbor_island hiện tại, bảo toàn nguyên vẹn 100% Player, Inventory, Cultivation, Economy, Equipment).
- TASK 07: Hệ thống chế tạo và rèn đúc pháp bảo `modules/crafting/` (RecipeSpec Resource, công thức rèn cần trúc và cần carbon, kiểm tra cảnh giới tu vi, hàng đợi chế tạo theo thời gian và hủy lệnh, quy trình atomic với cơ chế rollback nguyên liệu qua ServiceCoordinator, lưu trữ user://crafting.cfg).
- TASK 06: Hệ thống pháp bảo và trang bị `modules/equipment/` (8 phẩm cấp, 5 vị trí trang bị cần/dây/mồi/bảo vật 1/bảo vật 2, tính toán chỉ số tổng hợp, kiểm tra cảnh giới yêu cầu, ngăn trang bị trùng lặp, lưu trữ user://equipment.cfg tương thích với cần câu cũ, đồng bộ sang Fishing API).
- TASK 05: Kho đồ và hệ thống vật phẩm tu tiên đa năng (tạo ItemSpec Resource phân 5 nhóm vật phẩm và 6 phẩm cấp, nâng cấp InventoryLogic hỗ trợ thêm/lấy/xếp chồng/kiểm tra tồn tại/lọc nhóm/giới hạn kho, nâng cấp save v2 tương thích ngược 100% với dữ liệu cá, bán cá và hấp thu linh khí).
- TASK 04: Kết nối câu cá và tu luyện (triển khai `ServiceCoordinator.absorb_fish_qi` cho phép người chơi hấp thu linh khí từ cá trong túi đồ thành tu vi, kiểm tra số lượng và tính atomic không mất cá/tu vi khi lỗi, lưu dữ liệu sau hấp thu).
- TASK 03: Hệ thống Tu Luyện `modules/cultivation/` độc lập (12 cảnh giới x 9 tầng qua RealmSpec và 12 file .tres, tích lũy tu vi, thăng tầng tự động 1->9, API đột phá đại cảnh giới, lưu trữ user://cultivation.cfg, dev scene chạy độc lập).
- TASK 02: Hệ thống Linh Thạch (chuyển tiền tệ sang Linh Thạch hạ phẩm, hỗ trợ 4 phẩm cấp qua SpiritStoneSpec, cập nhật ShopItemSpec/FishPriceSpec sang giá Linh Thạch, bảo toàn dữ liệu save v1->v2, giao dịch atomic nhất quán không mất tiền/vật phẩm).
- TASK 01: Chuẩn hóa dữ liệu câu cá tu tiên (FishSpec phẩm cấp/linh khí/nguyên tố/thiên tượng; RodSpec phẩm cấp pháp bảo/độ bền/cảnh giới/hiệu ứng; SpotSpec loại nước/nguy hiểm/cảnh giới/thiên tượng; cập nhật 9 file .tres tương thích hoàn toàn; tài liệu README/ROADMAP).
- Đổi hướng dự án sang game câu cá tu tiên, cập nhật AGENTS.md, README.md, quyết định kiến trúc 0002, roadmap tu tiên và sổ ý tưởng (Mức 1, chỉ tài liệu).
- Sửa lỗi rollback bán cá làm mất cá trong `ServiceCoordinator.sell_fish`: thêm phương thức `restore_fish(fish_id, count, weight_g)` vào `InventoryLogic` và `InventoryAPI` để khôi phục chính xác số lượng và khối lượng cá khi giao dịch bán thất bại thay vì chỉ thêm 1 con cá.
- Chỉ cho thả cần khi điểm rơi phao (3,2 m phía trước nhân vật) là mặt nước: `map.is_water_at()` dò bằng tia vật lý, `scenes/boot/cast_coordinator.gd` nối Player, Map, UI; bỏ tọa độ cầu tàu cứng trong `main.gd`; tự hủy câu khi đi xa hơn 8 m.
- Thêm `presentation/fishing_rig/`: cần câu, dây câu, phao 3D không texture bám nhân vật, phản ứng theo sự kiện câu cá (Mức 2; chưa xem trên Godot Android).
- Sửa lỗi `Failed to retrieve non-existent singleton 'EventBus'`: loại bỏ `Engine.get_singleton("EventBus")` (vốn chỉ dành cho engine singleton C++), chuyển sang truy xuất Autoload node trực tiếp trên SceneTree root (`st.root.get_node("EventBus")`) trong toàn bộ các API module (fishing, inventory, economy, shop).
- Sửa lỗi nhân vật rơi khỏi bản đồ: tăng chiều cao ranh giới đảo lên 4m, bổ sung ranh giới khép kín phía Bắc (vịnh biển) và bến cảng, thêm cơ chế an toàn phát hiện rơi vực (y < -2.0) tự động đưa nhân vật về cầu tàu.
- Bổ sung Fishing UI (`presentation/fishing_ui/`): cụm nút Thả cần, Giật cần, Kéo dây, Xả dây góc dưới phải tối ưu cho mobile, chỉ cho phép thả cần khi đứng gần điểm câu hợp lệ, thanh hiển thị lực căng và thông báo trạng thái câu; tích hợp điều khiển FishingAPI qua Bootstrap.
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

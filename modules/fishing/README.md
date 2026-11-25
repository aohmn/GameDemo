# Fishing Module — ProjectGame

Module logic mô phỏng câu cá độc lập (`modules/fishing/`).
Chỉ phụ thuộc vào `core/` (EventBus và FishingEvents contracts), không phụ thuộc vào bất kỳ module gameplay nào khác.

## Cấu trúc module
```
modules/fishing/
├── README.md
├── api/
│   └── fishing_api.gd             # API công khai kết nối EventBus
├── logic/
│   └── fishing_logic.gd           # Máy trạng thái câu cá, giằng co, RNG seed
├── data/
│   ├── fish_spec.gd               # Resource script FishSpec
│   ├── rod_spec.gd                # Resource script RodSpec
│   ├── spot_spec.gd               # Resource script SpotSpec
│   └── resources/
│       ├── fish_ca_com.tres
│       ├── fish_ca_doi.tres
│       ├── fish_ca_chem.tres
│       ├── fish_ca_mu.tres
│       ├── fish_ca_thu.tres
│       ├── fish_ca_ngu_dai_duong.tres
│       ├── rod_truc_nhiem.tres
│       ├── rod_carbon_bien_sau.tres
│       └── spot_cau_tau_ben_cang.tres
└── scenes/
    ├── dev.gd                     # Điều khiển scene thử nghiệm độc lập
    └── dev.tscn                   # Scene dev kiểm tra các nút và log trạng thái
```

## 1. Máy trạng thái (Finite State Machine)
- **IDLE**: Nghỉ, sẵn sàng quăng câu.
- **CASTING**: Đang vung cần quăng phao xuống nước.
- **WAITING**: Chờ cá cắn câu theo thời gian tính từ `SpotSpec` kết hợp độ hiếm cá.
- **BITE**: Cá cắn câu! Mở cửa sổ phản xạ trong 0.8 giây để `strike()`.
  - Giật sớm khi còn `WAITING` -> Thất bại (`reason: early`).
  - Quá 0.8 giây không giật -> Thất bại (`reason: late`).
- **FIGHT**: Giằng co giữa người chơi và cá:
  - Giữ `reel(true)`: Tăng lực căng dây cước (`line_tension`).
  - Giữ `release(true)`: Xả chùng dây cước.
  - Cá vùng vẫy tạo các xung lực kéo định kỳ theo chu kỳ sóng sin.
  - Khi lực căng nằm trong vùng an toàn (`safe_tension_min` đến `safe_tension_max`), sức cá (`fish_strength`) giảm dần.
  - Ngoài vùng an toàn, cá hồi phục một phần sức (tối đa bằng sức chịu đựng ban đầu của cá).
  - Nếu lực căng vượt quá `max_tension` của cần -> Đứt dây (`reason: line_break`).
  - Khi sức cá giảm về 0 -> Bắt được cá thành công!
- **RESULT**: Kết thúc lượt câu, phát sự kiện `fish_caught` hoặc `fish_lost`.

## 2. Dữ liệu (.tres) chuẩn hóa Tu Tiên
Toàn bộ dữ liệu được lưu bằng file tài nguyên Godot (`.tres`) có kiểu tĩnh kế thừa từ Resource:
- **FishSpec**:
  - *Thuộc tính đã triển khai*: ID, tên tiếng Việt có dấu, mô tả, phẩm cấp (`tier`: Phàm/Linh/Yêu/Tiên/Thần/Thái Cổ), linh khí nhận được (`spirit_qi`), giá trị trao đổi cơ bản (`base_value`), thuộc tính nguyên tố (`element`), cân nặng min/max (gam), sức chịu đựng, độ hiếm (1-4), lực kéo xung, loại vùng nước sinh sống (`habitat_water_type`), điều kiện thiên tượng (`weather_condition`).
  - *Phần để mở rộng*: Động thái linh ngư (kỹ năng né tránh, nộ khí khi giằng co) khi module skills và cultivation tích hợp sâu hơn.
- **RodSpec**:
  - *Thuộc tính đã triển khai*: ID, tên tiếng Việt có dấu, mô tả, phẩm cấp pháp bảo (`tier`: Phàm/Linh/Huyền/Địa/Thiên/Thánh/Tiên/Thần), độ bền tối đa và hiện tại (`max_durability`, `current_durability`), cảnh giới yêu cầu (`required_realm_level`), vùng lực căng an toàn (`safe_tension_min`, `safe_tension_max`), ngưỡng đứt dây (`max_tension`), tốc độ kéo/xả, tốc độ bào mòn sức cá, hệ số kiểm soát (`control_power`), hiệu ứng pháp bảo đặc biệt (`special_effect`).
  - *Phần để mở rộng*: Luyện khí khảm ngọc/phù văn gia hộ pháp bảo khi module luyện khí ra mắt.
- **SpotSpec**:
  - *Thuộc tính đã triển khai*: ID, tên điểm câu, mô tả, loại vùng nước (`water_type`), cấp độ nguy hiểm (`danger_level`), cảnh giới yêu cầu (`required_realm_level`), thời gian chờ min/max, điều kiện thời gian (`time_condition`), điều kiện thiên tượng (`weather_condition`), bảng cá theo tỷ trọng (`fish_table`).
  - *Phần để mở rộng*: Linh mạch phụ trợ, cấm chế trận pháp bảo hộ vùng nước bí cảnh.

## 3. Khả năng chạy độc lập & tái lập (Determinism)
- `FishingLogic` sử dụng `RandomNumberGenerator` cho phép truyền hạt giống `seed` để chạy test tự động lặp lại được kết quả.
- Chạy thử riêng biệt qua `scenes/dev.tscn`.

## Luật phẩm cấp và cảnh giới
- Cần câu phẩm N chỉ mắc được cá phẩm ≤ N+1 (`FishingCalculator.max_catchable_fish_tier`). Điểm câu không có cá hợp phẩm cấp thì từ chối thả cần.
- `FishingAPI.set_realm_provider(Callable)`: Bootstrap gắn cảnh giới hiện tại. Cảnh giới thấp hơn `required_realm_level` của điểm câu hoặc cần câu thì bị từ chối.
- Từ chối thả cần phát `fishing_cast_denied` với `reason` là `spot_realm`, `rod_realm` hoặc `no_fish_for_rod`.

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
  - Nếu lực căng vượt quá `max_tension` của cần -> Đứt dây (`reason: line_break`).
  - Khi sức cá giảm về 0 -> Bắt được cá thành công!
- **RESULT**: Kết thúc lượt câu, phát sự kiện `fish_caught` hoặc `fish_lost`.

## 2. Dữ liệu (.tres)
Toàn bộ dữ liệu được lưu bằng file tài nguyên Godot (`.tres`) có kiểu tĩnh kế thừa từ Resource:
- **FishSpec**: ID, tên tiếng Việt có dấu, cân nặng min/max (gam), sức chịu đựng, độ hiếm (1-4), lực kéo xung.
- **RodSpec**: Vùng lực căng an toàn, ngưỡng đứt dây, tốc độ kéo/xả, tốc độ bào mòn sức cá.
- **SpotSpec**: Tỷ lệ xuất hiện các loài cá, khoảng thời gian chờ min/max.

## 3. Khả năng chạy độc lập & tái lập (Determinism)
- `FishingLogic` sử dụng `RandomNumberGenerator` cho phép truyền hạt giống `seed` để chạy test tự động lặp lại được kết quả.
- Chạy thử riêng biệt qua `scenes/dev.tscn`.

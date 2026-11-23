# Sky Dome Module

Module vòm trời procedural 3D nhiệt đới không dùng texture, chạy trên GL Compatibility và Android.

## Tính năng

- Vòm cầu SphereMesh quay mặt trong (`cull_front`), bán kính lớn và luôn bám theo camera mục tiêu.
- Gradient bầu trời nhiệt đới: xanh đậm thiên đỉnh (`sky_top_color`) chuyển dần sang xanh ngọc nhạt ở chân trời (`sky_horizon_color`).
- Vùng sáng chân trời (`horizon_glow`) và mặt trời procedural (`sun_disc`, `sun_halo`).
- Mây procedural sinh bằng hàm toán học không vòng lặp nặng, chuyển động nhẹ theo thời gian.
- Không sử dụng texture ảnh hay sampler2D.
- Không có collision, không che khuất vật thể trong game.

## API

- `set_follow_target(target: Node3D) -> void`: Gán node mục tiêu (thường là Camera3D) để vòm trời bám vị trí.
- `get_shader_material() -> ShaderMaterial`: Trả về vật liệu shader để tùy chỉnh uniform nếu cần.

## Cấu trúc

- `logic/sky_dome.gd`: khởi tạo vòm trời và xử lý bám mục tiêu.
- `assets/sky_dome.gdshader`: spatial shader vòm trời procedural.
- `scenes/sky_dome.tscn`: scene chính của module.
- `scenes/dev.gd` & `scenes/dev.tscn`: scene kiểm thử độc lập xoay camera ngắm trời.

## Kiểm thử độc lập

Mở và chạy `scenes/dev.tscn` để xem bầu trời xoay quanh camera mà không cần Bootstrap hay Map.

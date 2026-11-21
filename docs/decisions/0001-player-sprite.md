# 0001 — Ngoại lệ texture cho sprite nhân vật Player

- Ngày: 2026-11-21
- Trạng thái: Chấp nhận (người dùng chọn phương án B)
- Liên quan: AGENTS §0, §3, §4

## Bối cảnh

AGENTS §4 cấm dùng ảnh làm texture trong giai đoạn đồ họa hiện tại, và theo
bảng ưu tiên §0 thì §4 thắng §3 (HD-2D). Người dùng muốn Player là nhân vật
sprite 2D đặt trong thế giới 3D, dùng 3 sprite sheet do người dùng cung cấp
(`Player_idle.png`, `Player_Walk_Left.png`, `Player_Walk_UpDown.png`).

## Quyết định

Cho phép MỘT ngoại lệ hẹp: texture sprite của nhân vật Player, hiển thị bằng
`AnimatedSprite3D` ở chế độ billboard.

- Phạm vi: chỉ sprite Player. Môi trường, nhà cửa, đường, vật thể vẫn KHÔNG
  dùng texture (§4 giữ nguyên).
- NPC hoặc nhân vật khác muốn dùng sprite phải ghi thêm quyết định riêng.
- Ảnh phải nằm trong repo (`assets/characters/`), không tải từ Internet.
- Ảnh gốc giữ ở `assets/characters/player/source/`. Atlas và SpriteFrames
  được sinh lại bằng `tools/build_player_atlas.py`, không sửa tay.

## Hệ quả

- Repo đã có nhân vật 3D primitive `Player/VisualRoot` (`world/map/characters/player_visual.gd`).
  Giữ nguyên làm dự phòng: khi có node `Visual` (sprite) thì `VisualRoot` bị ẩn và tắt xử lý,
  không bị xóa. Muốn quay lại 3D: xóa node `Visual` khỏi `map_root.tscn`.

- Thiếu walk sang phải: dùng lật ngang của walk trái.
- Chưa có hướng chéo: chọn hướng gần nhất theo trục lớn hơn (có độ trễ).
- Sheet gốc không đều ô và idle nhỏ hơn walk ~8%; công cụ tự cắt, căn chân,
  căn đầu và thu nhỏ idle cho khớp.
- Ảnh gốc bị resize (viền mờ) nên dùng lọc tuyến tính, không dùng nearest.
- Hiển thị đứng trong world 3D nên cần `ground_clearance_m` tạm thời cho tới
  khi mặt đường trong `world/map` được sửa cho khớp collision.

## Phương án đã loại

- A: giữ nhân vật 3D bằng primitive (đúng §4, đã có `PlayerVisual`) nhưng không dùng được các sheet đã có.

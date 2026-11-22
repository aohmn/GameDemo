# presentation/player_sprite

## Mục đích
Hiển thị Player bằng sprite HD-2D (billboard) trong thế giới 3D.
Ngoại lệ texture: xem `docs/decisions/0001-player-sprite.md`.

## Chức năng
- Nhận vận tốc trên mặt phẳng, chọn hướng (xuống, lên, trái, phải) và animation.
- Đứng yên dùng `idle_*`, di chuyển dùng `walk_*`. Hướng phải = lật `*_left`.
- Đổi hướng có độ trễ (`AXIS_SWITCH_RATIO`) để không nháy khi đi chéo.
- Tốc độ animation bám tốc độ di chuyển.
- Đặt chân tại gốc node, chiều cao nhân vật = `world_height_m`.

## Cấu trúc
    presentation/player_sprite/
    ├── player_sprite.gd     # class PlayerSprite (AnimatedSprite3D)
    ├── player_sprite.tscn
    └── README.md
    assets/characters/player/
    ├── source/              # 3 sprite sheet gốc
    ├── player_atlas.png     # SINH RA bởi công cụ (đã gỡ khỏi repo — xem docs/decisions/0001)
    └── player_frames.tres   # SINH RA, đừng sửa tay

## API công khai
- `set_motion(planar_velocity: Vector2)`: x = trục X thế giới, y = trục Z.
- `get_facing() -> Facing`, `is_moving() -> bool`.
- Export: `character_height_px`, `world_height_m`, `ground_clearance_m`.

## Event
Nhận `PlayerEvents.MOTION_CHANGED` (payload `{ "velocity": Vector2 }`) và gọi
`set_motion`. Không phát event.

## Dependencies
Không phụ thuộc module gameplay. `PlayerController` không giữ tham chiếu tới
sprite; node chỉ subscribe event của Player.

## Tích hợp
`core/bootstrap/boot.gd` instantiate `player_sprite.tscn` và gắn làm con tên
`Visual` của node Player sau khi dựng map, trước khi map vào tree. Scene world
không còn `ext_resource` tới sprite. Nếu scene không tồn tại, Bootstrap bỏ qua
và `VisualRoot` (nhân vật 3D primitive) vẫn hiển thị.
Sprite tự đăng ký `PlayerEvents.MOTION_CHANGED`; `PlayerController` không
tham chiếu node này.
Có `Visual` thì `VisualRoot` (nhân vật 3D primitive) tự ẩn và tắt xử lý; không bị xóa, dùng làm dự phòng.

## Tái tạo atlas
    python3 tools/build_player_atlas.py assets/characters/player/source assets/characters/player
    (Công cụ đã gỡ khỏi repo; nếu cần tái tạo atlas/SpriteFrames, cần có code công cụ.)
Sau đó cập nhật `character_height_px` theo số script in ra. Đổi thứ tự hoặc
fps animation: tạo lại công cụ (chưa có trong repo) và chạy lệnh ở trên.

## Kiểm tra
- Mở `scenes/boot/boot.tscn`, chạy thử 4 hướng bằng joystick; xác nhận Player
  có node con `Visual` do Bootstrap gắn.
- Quan sát: không nháy khi đi chéo, chân đúng mặt đất, idle và walk cùng cỡ.
- Xóa tạm thư mục `presentation/`, import và boot: không `Parse Error`,
  `Visual` vắng mặt, `VisualRoot` hiển thị với 23 mesh nối điểm, Player vẫn đi được.

## Giới hạn đã biết
- Chưa có chạy, ngồi, ngủ, tương tác, hướng chéo.
- Thứ tự 14 frame của `walk_left` (hai hàng ghép lại) chưa được xác nhận trên máy thật.
- `ground_clearance_m = 0.0` là giá trị mặc định hiện tại (chưa chuẩn hóa giá trị thật cho mặt đường map).
- Chưa kiểm tra trên Godot Android, chưa đo hiệu năng.

# fishing_rig

Cần câu, dây câu và phao 3D dựng bằng mesh primitive (không texture). Tầng Presentation.

## Chức năng
- Cần câu 2 đoạn gắn tay nhân vật: hạ thấp khi chưa sẵn sàng, nâng lên khi hướng ra mặt nước, cong theo lực căng khi cá giằng co.
- Phao bay theo đường cong khi thả, nhấp nhô khi chờ, chìm khi cá cắn, giật khi giằng co, thu về khi kết thúc.
- Dây câu dạng dải bám camera, võng khi chùng, căng và đổi sang màu đỏ khi lực căng cao.
- Vòng đánh dấu điểm rơi phao trên mặt nước khi được phép thả cần.

## API (Bootstrap gọi)
- `set_anchor(node: Node3D)`: node mà cần câu bám theo.
- `set_aim(facing: Vector3, target: Vector3, valid: bool)`: hướng nhìn, điểm rơi phao dự kiến, điểm đó có phải nước không.
- `is_line_out() -> bool`, `get_line_end() -> Vector3`.

## Event nghe (EventBus)
`fishing_cast_started`, `fishing_state_changed`, `fishing_fight_update` (hợp đồng ở `core/contracts/fishing_events.gd`).

## Phụ thuộc
Chỉ `core/`. Không biết module fishing; xóa thư mục này thì game vẫn chạy (mất cần câu).

## Kiểm tra
`scenes/dev.tscn` giả lập một vòng câu bằng sự kiện (thả, chờ, cắn, giằng co, thu dây).

## Trạng thái
Mức 2 (Godot 4.7 headless). Chưa xem trực quan trên Godot Android.

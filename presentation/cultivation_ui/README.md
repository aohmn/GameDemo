# cultivation_ui

HUD tu vi (Presentation): cảnh giới, tầng, thanh tu vi, nút ĐỘT PHÁ và thông báo ngắn.

## API
- `set_cultivation_api(api)`: gắn `CultivationAPI` (chỉ dùng `get_cultivation_info`).
- `refresh()`: vẽ lại; chỉ gọi khi có sự kiện (không gọi mỗi khung, nếu không nút bị ẩn/hiện làm chạm không ăn).
- `show_toast(text)`: thông báo ngắn 3 giây.

## Tín hiệu
- `breakthrough_requested`: người chơi bấm ĐỘT PHÁ (Bootstrap nối tới `ui_action_router`).

## Event nghe
`cultivation_exp_gained`, `cultivation_layer_upgraded`, `cultivation_breakthrough_success`, `cultivation_breakthrough_failed`.

## Phụ thuộc
Chỉ `core/`. Xóa thư mục này thì game vẫn chạy (mất HUD tu vi).

## Trạng thái
Mức 2 (Godot 4.7 headless, chạm mô phỏng có độ trễ). Chưa xem trên Godot Android.

# Shop UI (`presentation/shop_ui/`)

Giao diện Thương Hội cho phép người chơi mua cần câu bằng Linh Thạch và đổi cần đang sử dụng.

## Nguyên tắc độc lập
- Không `preload` hay phụ thuộc vào các module khác; chỉ dùng hợp đồng `core/contracts/economy_events.gd` và `core/contracts/cultivation_events.gd`.
- Nhận `shop_api`, `economy_api`, `cultivation_api` qua `setup(...)` từ Bootstrap / `UIActionRouter`.
- Phát signal `buy_requested(item_id)` và `equip_requested(shop_item_id)` để `ServiceCoordinator` xử lý giao dịch atomic.
- Nút "Thương Hội" chỉ hiện khi `set_near_shop(true)` và chỉ cập nhật khi trạng thái thay đổi để không hủy thao tác chạm.

## Kiểm tra độc lập
Mở scene `presentation/shop_ui/scenes/dev.tscn`.

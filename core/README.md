# Core — ProjectGame

Module nền tảng cung cấp các dịch vụ dùng chung độc lập, hoàn toàn không phụ thuộc vào logic gameplay của các module.

## Cấu trúc thư mục
```
core/
├── events/
│   └── event_bus.gd       # Autoload EventBus: subscribe, unsubscribe, emit_event
├── contracts/
│   ├── fishing_events.gd   # Danh mục tên sự kiện và mô tả payload câu cá
│   ├── inventory_events.gd # Danh mục tên sự kiện và mô tả payload túi đồ
│   └── economy_events.gd   # Danh mục tên sự kiện và mô tả payload tiền tệ / giao dịch
├── clock/
│   └── game_clock.gd      # Autoload GameClock: đồng hồ ngày/đêm, tốc độ thời gian, tín hiệu giờ mới
└── README.md
```

## 1. EventBus (`core/events/event_bus.gd`)
- Quản lý giao tiếp lỏng (loose coupling) giữa các module qua sự kiện chuỗi.
- Dùng `Callable`.
- An toàn trước bộ nhớ giải phóng: Khi một `Node` bị `queue_free()` hoặc `free()`, `EventBus` tự động kiểm tra `is_instance_valid(target)` để bỏ qua và thanh lọc các Callable rác, ngăn chặn rò rỉ tham chiếu.

### Cách sử dụng
```gdscript
# Đăng ký
EventBus.subscribe("fishing_fish_caught", _on_fish_caught)

# Hủy đăng ký
EventBus.unsubscribe("fishing_fish_caught", _on_fish_caught)

# Phát sự kiện
EventBus.emit_event("fishing_fish_caught", {
    "player_id": "player_01",
    "fish_id": "fish_carp_01",
    "weight": 2.5,
    "quality": 1
})
```

## 2. Contracts (`core/contracts/`)
Định nghĩa hằng chuỗi định danh sự kiện và cấu trúc payload tương ứng:
- `FishingEvents`: Quăng cần, cá cắn, kéo thành công, cá trốn thoát.
- `InventoryEvents`: Thêm/bớt vật phẩm, cập nhật túi đồ, túi đầy.
- `EconomyEvents`: Thay đổi số dư VND, giao dịch hoàn tất, giao dịch lỗi.

## 3. GameClock (`core/clock/game_clock.gd`)
- Cung cấp thời gian trong game (`current_time` từ 0.0 đến 24.0).
- Hỗ trợ tốc độ thời gian (`time_speed`).
- Phát tín hiệu `hour_changed(new_hour: int)` và `day_changed(new_day: int)` phục vụ hành vi cá cắn câu theo khung giờ.

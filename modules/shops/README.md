# Shops

`ShopGood` là Resource class mô tả hàng hóa bằng các trường có kiểu: ID, tên, giá VND integer, mức hồi đói và khát. Dữ liệu mẫu nằm trong `data/water_bottle.tres` và `data/bread.tres`.

API: `ShopService.get_goods() -> Array[ShopGood]`.

Thêm hàng hóa mới bằng cách tạo Resource `.tres` dùng script `shop_good.gd` và thêm vào mảng `GOODS` trong `shop_service.gd`. Không dùng JSON cho dữ liệu cấu hình của module này.

Chưa có cửa hàng tương tác hoàn chỉnh, tồn kho, thanh toán hoặc kết nối Inventory.

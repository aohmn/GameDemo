# CHANGELOG

## Chưa phát hành

- Sửa và chuẩn hóa ranh giới va chạm đảo bến cảng (harbor_island): Player va chạm vững chắc với ranh giới, không xuyên tường, thông suốt lối đi cầu tàu và chừa cửa biển phía Bắc.
- Hoàn thiện module Sky Dome procedural cho Godot 4.7 GL Compatibility và tích hợp qua Bootstrap.
- Tạo module Sky Dome (`modules/sky_dome/`) với shader spatial procedural nhiệt đới: gradient, mặt trời và mây nhẹ trên mobile, hỗ trợ bám camera.
- Tích hợp Sky Dome vào Bootstrap (`main.gd`) với cơ chế nạp tùy chọn độc lập.
- Tinh chỉnh cửa biển thông thoáng ra đại dương tại đảo bến cảng và phân tách collision layer ranh giới barrier.
- Bổ sung dốc thoai thoải kết nối bãi cát lên cầu tàu giúp Player di chuyển liền mạch và loại bỏ va chạm chồng lấn thuyền/cầu tàu.
- Đổi map khởi đầu từ vietnam_street thành harbor_island với ID và đường dẫn `maps/harbor_island/`.
- Chuẩn hóa cao độ địa hình bến cảng, bảo đảm Player spawn ổn định tại y=0.05 không bị rơi.
- Tinh chỉnh nối cầu tàu với bờ, mở cửa biển tự nhiên thông ra bắc và bổ sung ranh giới chống rơi xuống biển.
- Cập nhật định hướng dự án sang game phiêu lưu khám phá và câu cá tại AGENTS.md và tạo decision 0001.
- Chuyển map hiện tại thành đảo bến cảng nhiệt đới (~50x50m) có đại dương bao quanh, vịnh tự nhiên, cầu tàu gỗ, núi đá, công trình và rặng dừa.
- Bổ sung collision đầy đủ cho địa hình, biển, cầu tàu, thuyền, núi đá và cây cối trên đảo.
- Cập nhật README gốc và README của map phản ánh đúng bối cảnh đảo nhiệt đới.
- Giữ nguyên hướng nhìn cuối cùng khi Player dừng lại (idle).
- Thêm joystick cảm ứng độc lập, hỗ trợ cảm ứng và chuột.
- Bootstrap tải joystick tùy chọn để không phụ thuộc cứng vào module presentation.
- Bổ sung scene dev và tài liệu sử dụng joystick.
- Thêm MapManager để tải, thay thế và giải phóng map theo ID.
- Chuyển Bootstrap từ preload trực tiếp sang khởi tạo MapManager.
- Bổ sung tài liệu cho Bootstrap và map vietnam_street.
- Bootstrap tạo Player, nối signal joystick với API di chuyển của Player và camera bám nhân vật.
- Map vietnam_street bổ sung collider cho mặt đất, vỉa hè, lề đường và công trình.
- Sửa hướng trục UV Y của Player để đầu ở trên, chân ở dưới.

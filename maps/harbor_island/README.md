# Đảo Bến Cảng Nhiệt Đới (Harbor Island)

Map đảo bến cảng nhiệt đới quy mô ~50 × 50 m, khởi tạo trong hệ thống với ID:

`harbor_island`

## Bối cảnh và thiết kế

- **Địa hình đảo nhiệt đới**: Vùng biển đại dương bao quanh đảo (nước trong xanh, đáy biển không dùng collider đi bộ giả lập).
- **Vịnh tự nhiên & Cửa biển**: Núi đá và đồi cao bo quanh tạo vịnh kín gió, mở lối cửa biển thông ra đại dương ở phía bắc (giữa 2 sườn núi).
- **Bến cảng & Cầu tàu**: Cầu tàu gỗ vươn từ bờ cát ra vịnh nước, nối liền mạch với cầu tàu ngang chữ T tạo bến đỗ thuyền cùng các thuyền gỗ neo đậu.
- **Công trình bến cảng**: Nhà kho bến cảng (Fishery Warehouse), chòi mồi câu (Bait Hut), các thùng gỗ hậu cần ven cảng.
- **Hệ thực vật nhiệt đới**: Hàng dừa và cây cối tán tròn phân bổ ven biển và triền đồi.

## Quy chuẩn kỹ thuật

- Mặt nước đại dương sử dụng `water.gdshader` procedural cao cấp:
  - Độ sâu và màu nước tính toán dựa trên khoảng cách hình học bờ biển thực tế (bãi cát, vách đá, cầu tàu).
  - Hệ sóng đa tầng domain-warped noise kết hợp vi mô, loại bỏ triệt để khuôn lặp hay vân sọc song song.
  - Phản chiếu quang học Fresnel, highlight mặt trời Blinn-Phong và tán xạ xanh ngọc tự nhiên.
  - Bọt biển hữu cơ bám theo mép bờ cát thực tế.
- PlaneMesh mặt nước được chia lưới `64 × 64` đỉnh cho độ nhấp nhô mượt mà.
- Scene kiểm thử trực quan độc lập: `maps/harbor_island/dev.tscn` (camera quỹ đạo xoay quanh bến cảng).
- Dựng hình hoàn toàn bằng Primitive Mesh (BoxMesh, PlaneMesh, CylinderMesh, SphereMesh, PrismMesh) và StandardMaterial3D/ShaderMaterial.
- Không sử dụng texture ảnh hay sampler2D.
- Hệ thống StaticBody3D và CollisionShape3D đầy đủ trên mặt đất, bãi biển, cầu tàu, vách núi, cây cối, thuyền và công trình.
- Ranh giới đảo vô hình ngăn người chơi rơi khỏi rìa đảo và cầu tàu xuống biển.
- Cao độ chuẩn hóa: mặt đất và bãi cát khớp chuẩn điểm spawn Player tại `y = 0.05`, đảm bảo người chơi tiếp đất ổn định, không rơi tự do.

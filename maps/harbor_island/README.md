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

- Dựng hình hoàn toàn bằng Primitive Mesh (BoxMesh, PlaneMesh, CylinderMesh, SphereMesh, PrismMesh) và StandardMaterial3D màu.
- Không sử dụng texture ảnh hay sampler2D.
- Hệ thống StaticBody3D và CollisionShape3D đầy đủ trên mặt đất, bãi biển, cầu tàu, vách núi, cây cối, thuyền và công trình.
- Ranh giới đảo vô hình ngăn người chơi rơi khỏi rìa đảo và cầu tàu xuống biển.
- Cao độ chuẩn hóa: mặt đất và bãi cát khớp chuẩn điểm spawn Player tại `y = 0.05`, đảm bảo người chơi tiếp đất ổn định, không rơi tự do.

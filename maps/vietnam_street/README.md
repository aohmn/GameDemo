# Đảo Bến Cảng Nhiệt Đới (Tropical Harbor Island)

Map đảo bến cảng nhiệt đới quy mô ~50 × 50m, khởi tạo trong hệ thống với ID:

`vietnam_street`

## Bối cảnh và thiết kế

- **Địa hình đảo nhiệt đới**: Vùng biển đại dương bao quanh đảo (nước trong xanh, đáy biển có va chạm).
- **Vịnh tự nhiên & Cửa biển**: Núi đá và đồi cao bo quanh tạo vịnh kín gió, mở lối ra đại dương ở phía bắc.
- **Bến cảng & Cầu tàu**: Cầu tàu gỗ vươn dài ra vịnh tạo bến đỗ thuyền chữ T cùng các thuyền gỗ neo đậu.
- **Công trình bến cảng**: Nhà kho bến cảng (Fishery Warehouse), chòi mồi câu (Bait Hut), các chồng thùng gỗ hậu cần.
- **Hệ thực vật nhiệt đới**: Hàng dừa và cây cối tán tròn phân bổ ven biển và triền đồi.

## Quy chuẩn kỹ thuật

- Dựng hình hoàn toàn bằng Primitive Mesh (BoxMesh, PlaneMesh, CylinderMesh, SphereMesh, PrismMesh) và StandardMaterial3D màu.
- Không sử dụng texture ảnh hay sampler2D.
- Hệ thống StaticBody3D và CollisionShape3D đầy đủ trên mặt đất, bãi biển, cầu tàu, vách núi, cây cối, thuyền và công trình.
- Giữ vững điểm spawn người chơi an toàn không rơi, tương thích 100% với Bootstrap `main.gd` và Player hiện tại.

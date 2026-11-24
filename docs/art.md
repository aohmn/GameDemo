# Quy Chuẩn Đồ Họa (Art Direction) — ProjectGame

Tài liệu quy định phong cách đồ họa chính thức cho toàn bộ dự án theo AGENTS.md §4.

---

## 1. Định Hướng Nghệ Thuật: Genshin Impact x Sea of Thieves

- **Tổng thể**: Tiên hiệp khoáng đạt hòa quyện chất phiêu lưu biển cả. Màu sắc tươi sáng, trong trẻo, giàu sức sống và ngập tràn linh khí (Genshin Impact), kết hợp với biển khơi sống động, sóng cuộn bọt nước nghệ thuật và chất mộc phóng khoáng của bến tàu, mạn thuyền (Sea of Thieves).
- **Map 3D**: 100% hình khối hình học (Primitive Mesh, SurfaceTool) và Procedural Shader toán học.
- **CẤM TEXTURE**: Tuyệt đối không dùng ảnh PNG/JPG/WebP làm texture, không dùng `sampler2D` trong shader.
- **Nhân vật & Vật thể 2D**: Quad billboard đầy đủ (không FIXED_Y), vẽ hoàn toàn bằng SDF/toán học, chân đặt đúng gốc node, chiều cao chuẩn ~1.75 m.

---

## 2. Bảng Màu Tiên Đạo Biển Khơi (Color Palette)

| Yếu tố | Mã Màu / Tone | Ý nghĩa & Ứng dụng |
| :--- | :--- | :--- |
| **Bạch Ngọc (Tiên Các)** | `#EAF5F0` / `(0.92, 0.96, 0.94)` | Thân điện, cột đá, bậc thềm thanh khiết của Tiên Các |
| **Ngọc Bích Biển (Mái ngói/Trận pháp)** | `#2E7366` / `(0.18, 0.45, 0.40)` | Mái cong tiên hiệp, đài sen, hoa văn pháp trận |
| **Linh Kim (Hoàng Kim)** | `#D9B347` / `(0.85, 0.70, 0.28)` | Đỉnh tháp hồ lô, viền hoa văn, pháp trận truyền tống |
| **Hồng Mộc (Thương Hội)** | `#8C382E` / `(0.55, 0.22, 0.18)` | Gỗ sơn đỏ phong cách thương trấn cổ đại |
| **Huyền Thạch (Lò Luyện & Vách Đá)** | `#403830` / `(0.25, 0.22, 0.19)` | Vách đá bazan sừng sững, thân lò rèn chân hỏa |
| **Cát Vàng Nắng Ấm** | `#F0DAA0` / `(0.94, 0.85, 0.63)` | Bãi cát ven biển óng ánh ánh mặt trời nhiệt đới |
| **Cỏ Tiên Thanh Lục** | `#52B846` / `(0.32, 0.72, 0.27)` | Thảm cỏ sườn đồi xanh biếc, tươi mát |
| **Nước Biển Cạn (Bờ)** | `#5CE0D2` / `(0.36, 0.88, 0.82)` | Vùng nước nông trong vắt nhìn thấy cát |
| **Nước Biển Lạc Thủy (Vừa)** | `#1F8FC2` / `(0.12, 0.56, 0.76)` | Nước biển vùng rạn san hô, vịnh đảo |
| **Hải Uyên Thâm Lam (Sâu)** | `#0C4578` / `(0.05, 0.27, 0.47)` | Biển sâu xa bờ, thăm thẳm hùng vĩ |
| **Bọt Nước (Foam)** | `#F8FDFF` / `(0.97, 0.99, 1.00)` | Viền bọt sóng vỗ bờ, bọt cuộn quanh chân cầu tàu |

---

## 3. Quy Chuẩn Shading & Hiệu Ứng Procedural (Procedural Shaders)

### 3.1. Địa Hình Tự Nhiên (Terrain Triplanar SDF Shader)
- Không dùng texture lặp.
- Sử dụng hàm tạo vân nhiễu đa tần số (Cellular/Gradient hash noise) không dùng `sin()` để ổn định hiệu năng GPU Adreno/Mali trên thiết bị di động.
- Hòa trộn mượt mà theo độ cao (`y`) và độ dốc pháp tuyến (`NORMAL.y`):
  - Dưới mực nước (`y < 0.05`): Cát ẩm và sỏi ướt.
  - Vùng bờ cát (`0.05 <= y < 0.6`): Cát mịn màu vàng nắng với gợn sóng gió nhẹ.
  - Vùng thảm cỏ (`y >= 0.6` và `NORMAL.y > 0.65`): Thảm cỏ xanh tươi, biến thiên sắc độ theo hướng gió và ánh sáng.
  - Vùng sườn dốc & Vách đá (`NORMAL.y <= 0.65` hoặc `y > 2.0`): Lớp đá trầm tích xếp tầng (stratified rock) đặc trưng của hải đảo.

### 3.2. Mặt Nước Biển (Sea of Thieves Style Water)
- Dải màu 3 tầng: Nông (`water_shallow`), Vừa (`water_mid`), Sâu (`water_deep`).
- Bọt nước ven bờ (`edge foam`): Tự động phát hiện khoảng cách tiếp xúc bờ biển (`coast_dist`) kết hợp nhiễu viền bọt.
- Vòng sóng cuộn bờ (`wave foam rings`): Các dải bọt chuyển động tịnh tiến nhịp nhàng từ ngoài khơi đánh vào bờ cát.
- Lấp lánh mặt trời (Specular Glint / Cel Reflection): Phản xạ nguồn sáng chính với ngưỡng sáng sắc nét (stylized cel-cut).
- Mờ biên chân trời (`Horizon Fog / Distance Fade`): Triệt tiêu mép nước phẳng, hòa quyện với đường chân trời SkyDome.

### 3.3. Ánh Sáng & Khí Quyển (Genshin Style Lighting & Atmosphere)
- `DirectionalLight3D` nắng ấm nhiệt đới góc nghiêng ~50 độ tạo bóng đổ mềm, đổ dài trên thềm cát và bến cảng.
- `WorldEnvironment`:
  - Ambient sky light dịu mát, không tạo góc khuất đen tối hoàn toàn.
  - Tonemap Filmic/ACES nhẹ nhàng.
  - Sương mù mỏng thanh thoát (`Volumetric/Distance Fog`) tạo chiều sâu lớp lớp giữa biển cả và Tiên Các trên cao.

---

## 4. Tối Ưu Hóa GPU Android (Mobile Optimization)
1. **Unshaded / Stylized Light trong Shader**: Giảm thiểu tính toán lighting phức tạp trong fragment shader khi không cần thiết.
2. **Khử hàm đắt tiền**: Tuyệt đối không dùng Ray-marching 3D trong shader nước/địa hình.
3. **Tái sử dụng Mesh & Material**: Các chi tiết lặp lại (cọc gỗ cầu tàu, lan can đá, cây cảnh) dùng chung MeshInstance3D và ShaderMaterial.
4. **Collision tinh giản**: Dùng `BoxShape3D` và `CylinderShape3D`, tuyệt đối không dùng `ConcavePolygonShape3D` cho địa hình động.

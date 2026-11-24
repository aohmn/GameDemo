# Đảo Bến Cảng (Harbor Island)

Đại bản doanh tu tiên khởi đầu và căn cứ trở về của người chơi trong thế giới câu cá tu đạo.

## Phong Cách Nghệ Thuật (Art Direction)
- Kết hợp phong cách **Genshin Impact** (tiên đạo trong trẻo, ánh sáng nhiệt đới rực rỡ, thảm cỏ xanh mướt, kiến trúc ngọc bích cổ phong) và **Sea of Thieves** (mặt nước biển có dải màu theo độ sâu, sóng bọt cuộn bờ, bến tàu mạn thuyền gỗ mộc mạc).
- **100% Procedural Shader & Primitive Mesh**: Tuyệt đối không dùng ảnh texture (`sampler2D`). Địa hình dùng `terrain.gdshader`, đại dương dùng `water.gdshader`.
- Chi tiết quy chuẩn được quy định tại `docs/art.md`.

## 8 Khu Vực Chính Trên Bản Đồ (50 × 50 m)
1. **Bến Cảng**: Cầu tàu gỗ vươn ra biển (`PierBuilder`), cọc gỗ cắm sâu đáy nước, 2 thuyền đánh cá neo đậu và điểm câu cá ven biển.
2. **Quảng Trường Trung Tâm** (`PlazaPathBuilder`): Nơi giao lưu sinh hoạt, đài hoa cương và **Trận Pháp Truyền Tống** bát quái 4 trụ thạch trận phong tỏa linh lực (dùng chuyển map).
3. **Tiên Các** (`SectBuildingBuilder`): Tọa lạc trên cao nguyên phía Bắc (`y=0.9` tới `y=5.0`), điện 2 tầng bạch ngọc, mái ngói ngọc bích viền kim sắc, đỉnh hồ lô tụ linh khí. Nơi tĩnh tọa tu luyện và đón kiếp đột phá cảnh giới.
4. **Thương Hội** (`SectBuildingBuilder`): Nằm phía Đông đảo, kiến trúc hồng mộc cổ trấn, biển hiệu mạ vàng. Nơi mua bán cần câu, dây, mồi và pháp bảo.
5. **Lò Chế Tạo & Kho Linh Ngư** (`SectBuildingBuilder`): Phía Tây đảo, lò luyện huyền thạch rực ánh chân hỏa và nhà kho gỗ trữ linh ngư, tài nguyên.
6. **Hồ Linh Ngư** (`PlazaPathBuilder`): Nằm giữa Quảng trường và Tiên Các, mặt nước xanh ngọc bích tĩnh lặng, đài sen giữa hồ, là điểm câu cá khởi đầu.
7. **Đài Quan Hải** (`SectBuildingBuilder`): Vọng cảnh lâu bát giác nhô ra phía biển Đông Bắc, nơi tĩnh tâm ngắm biển, quan sát thiên tượng và cảm ngộ thiên đạo.
8. **Mạng Lưới Đường Đi** (`PlazaPathBuilder`): Đá phiến liên kết liền mạch từ Bến Cảng -> Quảng Trường -> Thương Hội / Lò Chế Tạo / Hồ Linh Ngư / Tiên Các / Đài Quan Hải.

## Cấu Trúc Mã Nguồn
```
maps/harbor_island/
├── map.gd                   # Script gốc quản lý map, ánh sáng mặt trời SUN_DIRECTION
├── map.tscn                 # Scene Node3D gốc
├── terrain.gdshader         # Procedural Triplanar shader địa hình (cát, cỏ, vách đá)
├── water.gdshader           # Stylized ocean shader (sóng, 3 tầng sâu, bọt bờ, specular glint)
├── map_definition.tres      # Resource đăng ký MapDefinition vào hệ thống multi-map
├── builders/
│   ├── terrain_builder.gd   # Địa hình biển, bãi cát, cao nguyên và vách đá bazan
│   ├── pier_builder.gd      # Cầu tàu, dốc dắt, cọc gỗ và thuyền neo đậu
│   ├── plaza_path_builder.gd# Quảng trường, trận pháp truyền tống, hồ cá và lối đi
│   ├── sect_building_builder.gd # Tiên Các, Thương Hội, Lò Luyện, Đài Quan Hải
│   └── prop_builder.gd      # Thùng hàng bến cảng và hàng cây linh thụ
└── dev.tscn                 # Scene kiểm tra độc lập module
```

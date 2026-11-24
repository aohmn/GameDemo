# Đảo Bến Cảng (Harbor Island) — Đại Bản Doanh Tu Tiên

Map đảo bến cảng quy mô ~50 × 50 m, khởi tạo trong hệ thống với ID: `harbor_island`.
Được xây dựng thành đại bản doanh thanh bình, tràn đầy linh khí cho tu sĩ câu cá.

## Cấu trúc module map
```
maps/harbor_island/
├── README.md
├── map.gd                         # Script điều khiển map chính (42 dòng)
├── map.tscn                       # Scene bản đồ
├── map_definition.tres            # Tài nguyên MapDefinition
├── water.gdshader                 # Shader mặt nước procedural nhẹ cho Android
├── builders/
│   ├── terrain_builder.gd         # Địa hình đảo, bãi cát, vách núi và ranh giới (157 dòng)
│   ├── pier_builder.gd            # Bến cảng, cầu tàu chữ T, cọc gỗ, thuyền neo đậu (122 dòng)
│   ├── plaza_path_builder.gd      # Quảng trường trung tâm, Hồ Linh Ngư, các lối đi đá (98 dòng)
│   ├── sect_building_builder.gd   # Tiên Các, Thương Hội, Lò Chế Tạo, Kho Linh Ngư (150 dòng)
│   └── prop_builder.gd            # Thùng gỗ, rặng dừa cảnh quan (109 dòng)
└── scenes/
    ├── dev.gd                     # Scene dev chạy thử map độc lập
    └── dev.tscn
```

## Các khu vực trên Đảo Bến Cảng
1. **Địa hình & Bãi biển**: Bãi cát vàng mịn bao quanh, vách đá che chắn gió bão và vịnh nước êm ả.
2. **Bến cảng & Cầu tàu**: Cầu tàu gỗ vươn ra biển với thuyền neo đậu, điểm xuất hiện ban đầu của người chơi.
3. **Quảng trường trung tâm**: Đan đài hoa văn thanh thạch kết nối 4 hướng đi.
4. **Tiên Các**: Tọa lạc phía Bắc nhìn ra vịnh, kiến trúc 2 tầng bạch ngọc, nơi tĩnh tọa tu luyện và đột phá cảnh giới.
5. **Thương Hội**: Tọa lạc phía Đông, phong cách cổ phong gỗ đỏ, nơi giao thương trao đổi linh thạch và pháp bảo.
6. **Lò Chế Tạo & Kho Linh Ngư**: Tọa lạc phía Tây, gồm lò luyện huyền thạch rực ánh chân hỏa và kho chứa linh ngư.
7. **Hồ Linh Ngư**: Hồ nước xanh ngọc lục bảo có đài sen tĩnh tâm, nơi ngắm linh ngư và dưỡng tâm.
8. **Đường đi đá phiến**: Mạng lưới đường lát đá kết nối liền mạch mọi khu vực.

## Quy chuẩn kỹ thuật (AGENTS.md)
- Hoàn toàn dựng bằng Primitive Mesh và Shader/Color Material, tuyệt đối không dùng texture ảnh.
- Tất cả các file code đều ≤ 157 dòng (đạt chuẩn ≤ 300 dòng).
- Bổ sung StaticBody3D và CollisionShape3D đầy đủ cho mọi công trình, bờ hồ và ranh giới.
- Tối ưu hiệu năng cho Godot Android.

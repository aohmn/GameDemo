# assets/shaders

Shader và vật liệu procedural dùng chung, **không dùng texture** (AGENTS §4): mọi chi tiết bề mặt sinh bằng toán trong fragment shader.

## Thành phần
- `proc_common.gdshaderinc`: hash, noise, `face_uv` (chọn toạ độ theo mặt trội của pháp tuyến).
- `proc_planks` (ván sàn), `proc_wood` (gỗ vân dọc), `proc_roof` (mái ngói), `proc_paving` (đá lát), `proc_marble` (bạch ngọc), `proc_rough` (đá thô), `proc_foliage` (tán lá).
- `proc_material.gd`: `ProcMaterial.make(node_name, color)` chọn shader theo từ khóa trong tên node (Roof, Planks, Trunk, Plaza...), có cache. Tên không khớp thì dùng StandardMaterial3D màu phẳng.

## Quy ước
- Màu chủ đạo truyền qua `base_color`; `dark_color` tự suy ra từ màu đó.
- Toạ độ lấy theo thế giới nên các mặt cạnh nhau liền mạch, không cần UV.
- Chi phí: tối đa vài lần noise mỗi điểm ảnh, không có vòng lặp, phù hợp GLES3/Android.

## Thêm loại bề mặt mới
Tạo `proc_<tên>.gdshader`, thêm từ khóa vào `kind_for_name` trong `proc_material.gd`.

## Trạng thái
Mức 2: biên dịch và render được bằng Godot 4.7 (Mesa llvmpipe). Chưa đo FPS trên điện thoại.

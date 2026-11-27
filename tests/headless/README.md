# tests_headless

Kịch bản kiểm tra chạy bằng Godot 4.7 headless (không cần mở editor). Copy vào `tests/headless/` của repo.

Chạy từ thư mục dự án (GODOT = đường dẫn binary Godot 4.7):

    $GODOT --headless --path . --script tests/headless/<tên>.gd

| File | Kiểm tra | Kết quả đúng |
|---|---|---|
| walk_route.gd | đi bộ spawn → cổng → quảng trường → cầu vòm → bệ Tiên Các | in `tới waypoint 7`; waypoint 8 "KẸT" là đúng (đâm vào tháp) |
| island_edges.gd | mép đảo, không rơi | y không âm, x/z dừng ở mép |
| water_checks.gd | `is_water_at`, `get_fishing_spot_at` | cuối cầu = true, ao sen = spot_ho_linh_ngu |
| cast_pond.gd | thả cần ở bờ ao | `state=WAITING` |
| tap_cast.gd | chạm giữ ~0,1 s nút Thả Cần | `state=WAITING` |
| tap_cast_strike.gd | chạm nút Giật Cần khi cá cắn | `state=FIGHT` |
| tap_absorb_sell_breakthrough.gd | chạm Hấp thu / Bán / Đột phá | tu vi tăng, tiền tăng, đổi cảnh giới |
| screenshot.gd | chụp ảnh: `xvfb-run -a $GODOT --rendering-driver opengl3 --path . --script tests/headless/screenshot.gd -- "x,z,y" out.png` | file PNG (cần xvfb + mesa) |

Lưu ý: các script đọc biến nội bộ của `scenes/boot/main.gd` (`_fishing_ui`, `_fishing_api`, `_map_manager`...). Nếu đổi tên biến thì sửa script theo.
Chạm giả lập đẩy sự kiện chuột vào SubViewport 1280x576 và giữ vài khung vật lý, vì chạm thật trên điện thoại không bao giờ nhấn-nhả trong cùng một khung.

# Báo cáo kiểm tra bộ `tests/headless`

- **Ngày chạy**: 2026-11-27
- **Môi trường**: Godot v4.7-stable (`--headless --audio-driver Dummy`), proot Ubuntu ARM64
- **Mức kiểm tra**: Mức 2 (Godot headless thực thi không lỗi, toàn bộ 7 kịch bản thoát mã 0)

## Kết quả từng kịch bản

| Kịch bản | Trạng thái | Kết quả ghi nhận |
|---|---|---|
| `walk_route.gd` | Đạt (`EXIT: 0`) | Tới waypoint 7 `(0.0, -19.6) y=2.31`; kẹt tại waypoint 8 `(-0.0, 2.65, -20.47)` đúng thiết kế |
| `island_edges.gd` | Đạt (`EXIT: 0`) | Tất cả 6 hướng mép đảo đều dừng an toàn, `y >= 0.0` (đài quan hải `y=0.0`, sân Tiên Các `y=2.2`) |
| `water_checks.gd` | Đạt (`EXIT: 0`) | Cuối cầu/biển đông: `nước=true (spot_cau_tau_ben_cang)`; ao sen/cầu đá: `nước=true (spot_ho_linh_ngu)`; trên cầu/bờ/quảng trường: `nước=false` |
| `cast_pond.gd` | Đạt (`EXIT: 0`) | Bờ ao `(4.28, 1.00, -11.2)`, nút `Thả Cần` bật, `state=WAITING` |
| `tap_cast.gd` | Đạt (`EXIT: 0`) | Chạm giữ 6 khung (~0,1 s) vào nút Thả Cần: `state=WAITING` |
| `tap_cast_strike.gd` | Đạt (`EXIT: 0`) | Chạm giữ 4 khung nút Giật Cần khi cá cắn: `state=FIGHT` |
| `tap_absorb_sell_breakthrough.gd` | Đạt (`EXIT: 0`) | Hấp thu +25 tu vi (`25/100`), Bán +38 Linh Thạch, Đột phá lên `Tụ Khí · Tầng 1` |

## Ghi chú
- `screenshot.gd` chưa chạy trong lượt này (không yêu cầu xuất ảnh PNG).
- Chưa chạy thử trực tiếp trên Godot Android (Mức 3).

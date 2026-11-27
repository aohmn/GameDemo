# Bảng cân bằng tu vi đầu game (Luyện Thể)

## 1. Mục tiêu thiết kế
- Lên **Tầng 1 → Tầng 2** (vượt tầng 1) sau khoảng **~5 con cá** đầu tiên.
- Hoàn thành toàn bộ **9 tầng Luyện Thể** (đột phá lên **Tụ Khí**) trong **~30–40 phút** chơi thực tế (tính tốc độ trung bình ~3 con/phút, có bán bớt cá lấy Linh Thạch).

## 2. Tu vi từng tầng — Luyện Thể (`realm_luyen_the.tres`)

| Tầng | Tu vi cũ | Tu vi mới | Số cá ước tính (Cầu Tàu / Hồ) |
|---|---:|---:|---:|
| Tầng 1 | 100 | **50** | ~5 con Cá Cơm / ~3–4 con hỗn hợp |
| Tầng 2 | 150 | **75** | ~4 con |
| Tầng 3 | 220 | **110** | ~5–6 con |
| Tầng 4 | 320 | **150** | ~7–8 con |
| Tầng 5 | 460 | **200** | ~9–11 con |
| Tầng 6 | 650 | **260** | ~11–14 con |
| Tầng 7 | 900 | **330** | ~13–18 con |
| Tầng 8 | 1.250 | **405** | ~16–22 con |
| Tầng 9 | 1.700 | **520** | ~20–28 con |
| **Tổng Luyện Thể** | **5.750** | **2.100** | **~92–112 con (~31–37 phút)** |

## 3. Linh khí các loài cá đầu game (`spirit_qi`)

| ID cá | Tên hiển thị | Phẩm cấp | Điểm câu | `spirit_qi` cũ | `spirit_qi` mới |
|---|---|---:|---|---:|---:|
| `fish_ca_com` | Cá Cơm Biển | 0 | Cầu Tàu | 5 | **10** |
| `fish_ca_doi` | Cá Đối Mục | 0 | Cầu Tàu, Hồ Linh Ngư | 10 | **15** |
| `fish_ca_chem` | Cá Chẽm Bờ | 1 | Cầu Tàu, Hồ Linh Ngư | 25 | 25 |
| `fish_ca_chep_linh` | Cá Chép Linh | 1 | Hồ Linh Ngư | 35 | 35 |
| `fish_ca_mu` | Cá Mú Đỏ | 1 | Cầu Tàu | 50 | 50 |
| `fish_ca_tram_ngoc` | Cá Trắm Ngọc | 2 | Hồ Linh Ngư | 75 | 75 |
| `fish_ca_thu` | Cá Thu Vàng | 2 | Cầu Tàu | 120 | 120 |
| `fish_ca_ngu_dai_duong` | Cá Ngừ Đại Dương | 2 | Cầu Tàu | 300 | 300 |

## 4. Sản lượng trung bình (cần khởi đầu Phẩm 0)
- **Cầu Tàu Bến Cảng** (cá Phẩm ≤ 1): trung bình **~18,8 linh khí/con** (trước đây ~15,3).
- **Hồ Linh Ngư** (cá Phẩm ≤ 1): trung bình **~26,8 linh khí/con** (trước đây ~25,6).
- **Pha trộn thực tế**: ~21–23 linh khí/con → 2.100 tu vi tương ứng ~92–100 con cá hấp thu (~31–35 phút chơi, cộng thêm ~15–20% cá bán lấy Linh Thạch nằm gọn trong 35–40 phút).

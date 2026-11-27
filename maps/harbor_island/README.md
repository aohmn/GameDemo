# harbor_island — Tiên Đảo Bến Cảng

Map tiên hiệp bậc thang giữa biển mây, dựng hoàn toàn bằng mesh procedural và shader (không texture).

## Bố cục (x đông+, z nam+, camera nhìn từ nam)
- **Bậc 0 (y=0) Bến cảng**: cầu tàu gỗ (giữ nguyên vị trí cho gameplay câu cá), bài phường đầu cầu, quảng trường tròn với Trận Pháp Truyền Tống, Đài Quan Hải (đình sáu cột mái tròn, có bậc lên) ở mũi đông.
- **Bậc 1 (y=1) Ao sen**: Hồ Linh Ngư với cầu đá vòm bạch ngọc, Thương Hội (lầu gỗ hai tầng, đông), Lò Luyện đan (đan lô ba chân dưới đình tròn, tây).
- **Bậc 2 (y=2,2) Tiên Các**: bài phường, hai đình bên, tháp ba tầng mái cong ngọc bích trên bệ bạch ngọc, đỉnh hồ lô vàng.
- **Phông nền**: mười ngọn núi đá vôi thon cao mờ sương, thác nước, biển mây, đá lơ lửng phát linh quang, tùng, trúc, đào hoa.

## Builder (mỗi file một trách nhiệm, tất cả dưới 300 dòng)
- `terrain_builder`: môi trường, ánh sáng, biển, đáy biển. `island_builder`: ba bậc nền, bậc thang, tường chắn vô hình.
- `peak_builder`: núi đá vôi, thác, sương, đá lơ lửng. `pier_builder`: cầu tàu và thuyền.
- `plaza_path_builder`: quảng trường, truyền tống, lối đi, ao sen, cầu vòm. `sect_building_builder`: Thương Hội, Lò Luyện, Đài Quan Hải.
- `pagoda_builder`: Tiên Các. `flora_builder`: cây cối, trúc, đá, thùng hàng.
- `arch_kit` (mesh mái cong, mái tròn, cầu vòm), `parts` (cột, đèn, đình, bài phường), `util` (tạo node, collider).

## API map (cho Bootstrap/UI)
- `is_water_at(pos)`: ao sen là nước; nơi khác dùng tia vật lý. `get_fishing_spot_at(pos)`: `spot_ho_linh_ngu` trên ao, còn lại `spot_cau_tau_ben_cang`.
- `get_water_height_at(pos)`: cao độ mặt nước (ao cao hơn biển) để đặt phao/dây.

## Ghi chú
- Mốc gameplay giữ cố định: chỗ xuất phát (-2, 0,05, 10), cầu tàu và lan can đầu cầu.
- Mức 2: render bằng Mesa llvmpipe, đi bộ toàn tuyến bến → quảng trường → cầu vòm → Tiên Các. Chưa đo FPS trên Android.

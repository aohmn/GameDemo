# AGENTS.md — LUẬT PHÁT TRIỂN PROJECTGAME

Áp dụng cho toàn bộ repo. Thứ tự ưu tiên khi xung đột: **1** điện thoại Android · **2** trung thực khi kiểm tra · **3** kiến trúc module · **4** nguồn dữ liệu duy nhất · **5** không texture · **6** Save/Load · **7** Presentation/UI · **8** GDScript/Godot.
## 1. ĐƯỜNG DẪN VÀ CẤU TRÚC

Thư mục làm việc duy nhất: `/storage/emulated/0/Download/GameDemo/`

Cấu trúc hiện tại (danh sách theo `find`/`ls`, tự cập nhật khi file được tạo/di chuyển):

    GameDemo/
    ├── AGENTS.md, README.md, CHANGELOG.md, LICENSE, project.godot, .gitignore
    ├── docs/{architecture,decisions,roadmap}/
    ├── core/{bootstrap,contracts,services,events}/
    ├── modules/{player,needs,jobs,shops,npc,economy}/
    ├── scenes/boot/
    ├── world/{map,navigation}/
    ├── presentation/{player_sprite,player_visual,hud}/
    ├── assets/characters/player/{source,player_atlas.png,player_frames.tres}
    ├── icon.svg
    ├── .godot/, gdtoolkit/ (tooling, chưa commit)

Cấu trúc đích dài hạn (chỉ tạo thư mục khi có tính năng thực sự dùng): `docs/design/`,
thư mục đích khác trong dòng đầu (`CONTRIBUTING.md`, `export_presets.cfg`,
`scenes/main_menu/`, `data/`, `systems/`, `localization/`, `tools/`, `builds/`, ...).

- Không tạo thư mục rỗng để "đủ bộ"; không tạo module mới nếu module hiện có mở rộng được.
- Mỗi module phải có `README.md`: mục đích, API, event, phụ thuộc, cách kiểm tra.
## 2. MÔI TRƯỜNG PHÁT TRIỂN

- Chỉ dùng điện thoại Android; Godot Android để mở/chạy/kiểm tra, Termux để chạy lệnh.
- Không yêu cầu PC, laptop, VS Code, Android Studio; không bắt người dùng tự tạo file, sửa code, ghép đoạn mã hoặc tự tìm vị trí chèn.
- Godot Android không có `--headless`; không được giả vờ đã chạy `godot --check-only`.
- Việc cần PC (export APK chính thức, profiling sâu, build template, test multiplayer nhiều client) phải báo rõ là giới hạn.
- Mọi thay đổi giao dưới dạng MỘT khối Termux copy-paste, kèm kiểm tra tự động:

```bash
cd /storage/emulated/0/Download/GameDemo && mkdir -p <thư_mục> && \
cat > <đường_dẫn_file> <<'EOF'
<nội dung file>
EOF
ls -la <đường_dẫn_file> && wc -l <đường_dẫn_file>
grep -n "class_name\|extends" <đường_dẫn_file>
```

Quy trình: phân tích → viết code → khối Termux → kiểm tra tự động → mở Godot Android chạy thử → chờ kết quả thực tế trước khi tuyên bố hoàn thành.
## 3. ĐỊNH HƯỚNG VÀ CÔNG NGHỆ

- Open-world Life Simulation, bối cảnh Việt Nam hiện đại, ưu tiên Android.
- Godot 4.x, GDScript có static typing, giải pháp nhẹ và dễ mở rộng.
- Tiền tệ VND, lưu bằng số nguyên (integer); thiết kế nguyên bản, không sao chép tài sản/nội dung/mã nguồn của game khác.
## 4. ĐỒ HỌA — KHÔNG TEXTURE

Giai đoạn hiện tại không dùng texture. Ưu tiên `MeshInstance3D`, primitive mesh, `ArrayMesh`/`SurfaceTool`, procedural mesh, `ShaderMaterial`/`Shader`, `StandardMaterial3D`, ánh sáng và bóng đổ.

Không dùng ảnh làm texture bề mặt, texture tải từ Internet, hoặc ảnh thay thế hình học 3D. Ngoại lệ chỉ khi có quyết định trong `docs/decisions/`.

Tối ưu: hạn chế draw call, tái sử dụng mesh/material, dùng LOD, kiểm soát vật thể và ánh sáng động.
## 5. KIẾN TRÚC MODULE VÀ PHỤ THUỘC

Thiết kế Modular Architecture + Data-driven. Không tạo GameManager khổng lồ.

- Core không phụ thuộc gameplay module; module không phụ thuộc trực tiếp module khác.
- Presentation không sở hữu logic nghiệp vụ; Data không chứa logic gameplay.
- Save không tự điều khiển logic nội bộ module; Bootstrap chịu trách nhiệm khởi tạo và kết nối.
- Module giao tiếp bằng API hoặc Event; không đọc biến/hàm nội bộ module khác.
- API dùng khi cần kết quả trực tiếp; Event dùng cho thông báo/thay đổi trạng thái.
- Mỗi module có logic/dữ liệu riêng, API công khai, README, kiểm tra độc lập và mở rộng không sửa module khác.
## 6. NGUỒN DỮ LIỆU DUY NHẤT

Không tạo nhiều hệ thống cùng quản lý một loại dữ liệu; không tạo bản sao trạng thái toàn cục. Các dịch vụ dùng chung:

- GameClock (thời gian), Economy (tiền), EventBus (sự kiện).
- SaveCoordinator (lưu/tải) — điều phối participant, không biết GameClock/module.
- Inventory, SceneRouter, ModuleRegistry, SettingsService, LocalizationService: chưa có — không liệt kê là dịch vụ dùng chung cho đến khi triển khai.

Mọi giao dịch tiền/vật phẩm/tài sản phải ATOMIC: kiểm tra đủ điều kiện → thực hiện toàn bộ → rollback nếu bất kỳ bước nào thất bại. `TransactionCoordinator` (chưa có — thiết kế, đặt khi triển khai) điều phối giao dịch nhiều module; chỉ commit khi tất cả thành công.
## 7. DỮ LIỆU, WORLD VÀ NPC

- Tách dữ liệu khỏi logic; ưu tiên Resource/JSON phù hợp; mọi đối tượng có ID ổn định.
- Kiểm tra dữ liệu đầu vào, có giá trị mặc định an toàn và xử lý dữ liệu lỗi.
- NPC phải DATA-DRIVEN: một script NPC chung đọc Resource/JSON; hành vi tách thành Action độc lập; thêm NPC = thêm file dữ liệu, không thêm script; không if/else theo tên NPC.
- World quản lý Regions, Districts, Locations, navigation, spawning.
## 8. SAVE/LOAD

- Mỗi module tự serialize/deserialize dữ liệu của mình; SaveCoordinator điều phối.
- Có version dữ liệu, kiểm tra trước khi tải, xử lý save lỗi/không tương thích.
- Không module nào ghi đè dữ liệu module khác.
## 9. PRESENTATION VÀ UI

- UI không chứa logic kinh tế/gameplay; gọi API module và nhận thay đổi qua Event.
- Tách giao diện khỏi dữ liệu; hỗ trợ màn hình điện thoại và thao tác cảm ứng.
- Nút bấm đủ lớn cho ngón tay; không thiết kế phụ thuộc chuột/bàn phím vật lý.
## 10. GDSCRIPT, GODOT, SCENE

- Cú pháp Godot 4.x, ưu tiên static typing, tên rõ nghĩa, không dùng API đã bị loại bỏ.
- Không viết file quá dài; tránh NodePath cứng khi có giải pháp tốt hơn.
- Quản lý vòng đời Node và Signal rõ ràng; không tạo autoload tràn lan.
- Không bỏ qua cảnh báo/lỗi parser; kiểm tra đường dẫn Resource và Scene.
- Mỗi scene một nhiệm vụ; scene module nằm trong module; tài nguyên dùng chung đặt ở vị trí dùng chung; ưu tiên tái sử dụng.
## 11. KIỂM TRA VÀ CHẤT LƯỢNG

Bốn mức, phải báo đúng mức đã đạt:

1. Chưa kiểm tra.
2. Đã kiểm tra bằng Termux (cú pháp, đường dẫn, cấu trúc file).
3. Đã mở Godot Android, không có lỗi parser.
4. Đã chạy thử chức năng thực tế trong game trên Godot Android.

Mỗi tính năng cần kiểm tra: cú pháp, đường dẫn, dữ liệu đầu vào, API, tương tác module khác, hiệu suất nếu ảnh hưởng lớn, và Godot Android khi có thể. Không báo cáo thành công ở mức cao hơn mức đã thực sự đạt.
## 12. MỞ RỘNG, TÀI LIỆU VÀ "DONE"

- Ưu tiên module mới nếu chức năng độc lập; tận dụng API/Event hiện có; không phá API cũ.
- Nếu đổi Contract, cập nhật tài liệu và mọi nơi sử dụng; không tạo abstraction không có nhu cầu thực tế.
- Sau mỗi thay đổi: cập nhật README liên quan, CHANGELOG, ghi quyết định kiến trúc quan trọng vào `docs/decisions/`, báo file đã tạo/sửa và kiểm tra đã thực hiện.

Một tính năng chỉ DONE khi: không lỗi parser trên Godot Android; có kết quả kiểm tra thủ công mức 3/4 được ghi lại; README và CHANGELOG đã cập nhật; không có regression đã biết; báo cáo ghi rõ phần CHƯA kiểm tra được và lý do. Nếu thiếu bất kỳ mục nào, phải báo "chưa xong" kèm việc còn lại.

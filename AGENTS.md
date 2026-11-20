# AGENTS.md — PROJECT GAME DEVELOPMENT RULES

Tài liệu này là luật phát triển dự án. AI đọc, phân tích và thực thi. Mọi
thiết kế và triển khai phải tuân thủ. Khi có xung đột, áp dụng theo bảng
ưu tiên ở mục 0.

---

## 0. THỨ TỰ ƯU TIÊN KHI CÓ XUNG ĐỘT

Khi hai quy tắc mâu thuẫn, quy tắc có số thứ tự ưu tiên nhỏ hơn thắng.

1. §2  — Chỉ phát triển bằng điện thoại.
2. §13 — Trung thực khi kiểm tra, không báo cáo khống.
3. §5  — Kiến trúc module và quy tắc phụ thuộc.
4. §6  — Nguồn dữ liệu duy nhất (Economy, Inventory, GameClock...).
5. §4  — Quy tắc đồ họa (không texture trong giai đoạn hiện tại).
6. §9  — Save/Load.
7. §10 — Presentation và UI.
8. §11 — Quy tắc GDScript và Godot.
9. Các mục còn lại.

Ví dụ: §4 cấm texture nhưng §3 muốn phong cách HD-2D. Theo bảng ưu tiên,
§4 thắng trong giai đoạn hiện tại. Muốn đổi, phải có quyết định thay đổi
định hướng đồ họa được ghi vào `docs/decisions/`.

---

## 1. CẤU TRÚC THƯ MỤC

### Đường dẫn dự án (chuẩn duy nhất)

    /storage/emulated/0/Download/GameDemo/

Đây là thư mục làm việc chính thức. Không dùng đường dẫn khác.

### Cấu trúc đích dài hạn

    GameDemo/
    ├── AGENTS.md
    ├── README.md
    ├── CHANGELOG.md
    ├── CONTRIBUTING.md
    ├── LICENSE
    ├── project.godot
    ├── export_presets.cfg
    ├── .gitignore
    ├── docs/
    │   ├── architecture/
    │   ├── design/
    │   ├── roadmap/
    │   └── decisions/
    ├── addons/
    ├── assets/
    │   ├── materials/
    │   ├── shaders/
    │   ├── fonts/
    │   ├── audio/
    │   └── animations/
    ├── scenes/
    │   ├── boot/
    │   ├── main_menu/
    │   ├── loading/
    │   └── debug/
    ├── core/
    │   ├── bootstrap/
    │   ├── contracts/
    │   ├── services/
    │   ├── events/
    │   ├── registry/
    │   └── utilities/
    ├── modules/
    │   ├── player/
    │   ├── needs/
    │   ├── interaction/
    │   ├── economy/
    │   ├── inventory/
    │   ├── jobs/
    │   ├── shops/
    │   ├── npc/
    │   ├── social/
    │   ├── housing/
    │   ├── vehicles/
    │   ├── transportation/
    │   ├── world/
    │   ├── environment/
    │   ├── crafting/
    │   ├── quests/
    │   └── activities/
    ├── world/
    ├── presentation/
    ├── data/
    ├── systems/
    ├── localization/
    ├── tools/
    └── builds/

### Quy tắc tạo thư mục

- Cấu trúc trên là ĐÍCH ĐẾN DÀI HẠN, không phải lệnh tạo hàng loạt.
- Trong giai đoạn hiện tại, chỉ tạo module khi có ít nhất một tính năng
  gameplay thực sự dùng nó.
- Không tạo thư mục rỗng để "đủ bộ".
- Không tạo module mới nếu module hiện có có thể mở rộng để đáp ứng.
- Khi tạo module mới, phải có README.md mô tả mục đích và API.

---

## 2. PHÁT TRIỂN CHỈ BẰNG ĐIỆN THOẠI

Đây là quy tắc ưu tiên cao nhất.

- Chỉ phát triển trên điện thoại Android.
- Godot Android dùng để mở, chạy và kiểm tra game.
- Termux dùng để nhận và thực thi lệnh AI cung cấp.
- Không yêu cầu máy tính, laptop, VS Code hoặc Android Studio.
- Không yêu cầu người dùng tự tạo file, thư mục hoặc sửa code thủ công.
- Không bắt người dùng ghép nhiều đoạn mã hoặc tự tìm vị trí chèn code.

### Template khối lệnh Termux

Mỗi công việc phải được giao dưới dạng MỘT khối lệnh copy-paste duy nhất,
có cấu trúc tối thiểu:

    cd /storage/emulated/0/Download/GameDemo && \
    mkdir -p <thư_mục_cần_thiết> && \
    cat > <đường_dẫn_file> <<'EOF'
    <nội dung file>
    EOF

Sau khối tạo/sửa, phải kèm bước kiểm tra tự động nếu có thể:

    ls -la <đường_dẫn>
    wc -l <đường_dẫn>
    grep -n "class_name\|extends" <đường_dẫn>  # kiểm tra header GDScript

### Giới hạn thực tế trên Android

- Godot Android Editor KHÔNG có CLI `--headless` như trên PC.
- Không thể tự động chạy `godot --check-only` trong Termux trừ khi có
  binary Godot CLI được cài riêng và xác nhận chạy được. Nếu chưa có,
  bước kiểm tra cú pháp phải làm thủ công bằng cách mở Godot Android và
  xem Output/Errors.
- Một số việc bắt buộc phải có PC: export APK chính thức, profiling sâu,
  build custom template, test multiplayer nhiều client. AI phải báo rõ
  giới hạn này thay vì giả vờ đã làm được trên điện thoại.

### Quy trình

AI phân tích → viết code → tạo khối lệnh Termux → kiểm tra tự động (nếu
có thể) → hướng dẫn mở Godot Android để chạy thử → chờ kết quả thực tế
trước khi tuyên bố hoàn thành.

---

## 3. ĐỊNH HƯỚNG DỰ ÁN

- Thể loại: Open-world Life Simulation.
- Bối cảnh: Việt Nam hiện đại.
- Đồ họa: HD-2D / 2.5D kết hợp 3D và 2D.
- Nền tảng ưu tiên: Android.
- Đơn vị tiền tệ: VND, lưu bằng số nguyên (integer).
- Trải nghiệm: tự do sinh hoạt, làm việc, kinh doanh, mua sắm, xây dựng
  tài sản, giao tiếp và khám phá thế giới.
- Thế giới có NPC, lịch sinh hoạt, kinh tế, thời tiết và chu kỳ ngày đêm.
- Thiết kế nguyên bản, không sao chép tài sản, nội dung hoặc mã nguồn
  của trò chơi khác.

---

## 4. CÔNG NGHỆ VÀ ĐỒ HỌA

### Công nghệ

- Godot 4.x.
- Ngôn ngữ chính: GDScript có static typing.
- Kiến trúc tương thích Android.
- Ưu tiên giải pháp nhẹ, dễ bảo trì, dễ mở rộng.

### Quy tắc dựng hình hiện tại — KHÔNG TEXTURE

Không sử dụng texture trong giai đoạn phát triển đồ họa hiện tại.

Ưu tiên:

- MeshInstance3D để dựng vật thể và môi trường.
- Primitive Mesh để tạo hình cơ bản.
- ArrayMesh và SurfaceTool khi cần hình học tùy chỉnh.
- ShaderMaterial và Shader để tạo hiệu ứng bề mặt.
- StandardMaterial3D với màu sắc, thông số vật liệu.
- Geometry để tạo đường, tường, nhà cửa, đồ vật, địa hình.
- Procedural Mesh để sinh hình học bằng code.
- Ánh sáng, bóng đổ và màu sắc để tạo chiều sâu.

Không:

- Dùng ảnh làm texture bề mặt.
- Dùng texture tải từ Internet.
- Tạo phụ thuộc vào texture để dựng vật thể.
- Dùng ảnh thay thế cho hình học 3D khi có thể dựng bằng Mesh hoặc Shader.

Ngoại lệ chỉ được chấp thuận khi có quyết định thay đổi rõ ràng trong
`docs/decisions/`.

### Tối ưu hiệu suất

- Hạn chế số lượng draw call.
- Tái sử dụng Mesh và Material.
- Dùng LOD khi cần.
- Hạn chế shader phức tạp.
- Kiểm soát số lượng vật thể và ánh sáng động.
- Tối ưu bộ nhớ và hiệu suất trên Android.

---

## 5. KIẾN TRÚC MODULE, CẤU TRÚC VÀ PHỤ THUỘC

### Nguyên tắc

Thiết kế theo Modular Architecture kết hợp Data-driven Design. Không xây
một GameManager khổng lồ. Không để module phụ thuộc vòng tròn. Không
truy cập trực tiếp biến hoặc hàm nội bộ của module khác.

Mỗi module phải:

- Có chức năng riêng biệt, sở hữu logic và dữ liệu nội bộ.
- Có API công khai.
- Có README mô tả chức năng và cách tích hợp.
- Có thể kiểm tra độc lập.
- Có thể mở rộng mà không phải sửa logic nội bộ module khác.

### Cấu trúc module (không bắt buộc tạo đủ thư mục)

    module_name/
    ├── api/          # giao diện công khai
    ├── core/         # logic nghiệp vụ
    ├── data/         # dữ liệu riêng
    ├── models/       # cấu trúc dữ liệu
    ├── services/     # xử lý nghiệp vụ
    ├── components/   # thành phần tái sử dụng
    ├── scenes/       # scene của module
    ├── resources/    # tài nguyên riêng
    └── README.md     # tài liệu tích hợp

### Phân tầng phụ thuộc

- Core: nền tảng và dịch vụ dùng chung.
- Modules: logic gameplay độc lập.
- Data: dữ liệu cấu hình.
- Presentation: hiển thị và tương tác.
- Systems: hệ thống cấp ứng dụng.
- World: tổ chức bản đồ và khu vực.

### Quy tắc phụ thuộc

- Core không phụ thuộc gameplay module.
- Module không phụ thuộc trực tiếp module khác.
- Presentation không sở hữu logic nghiệp vụ.
- Data không chứa logic gameplay.
- Save không tự ý điều khiển logic nội bộ module.
- Bootstrap chịu trách nhiệm khởi tạo và kết nối.
- Module giao tiếp bằng API hoặc Event.

API dùng cho yêu cầu cần kết quả trực tiếp. Event dùng cho thông báo sự
kiện và thay đổi trạng thái.

---

## 6. CORE SERVICES

Các dịch vụ dùng chung phải có một nguồn dữ liệu duy nhất:

- GameClock — thời gian trong game.
- Economy — tiền và giao dịch.
- Inventory — vật phẩm.
- EventBus — sự kiện.
- SaveCoordinator — điều phối lưu và tải.
- SceneRouter — chuyển scene.
- ModuleRegistry — đăng ký module.
- SettingsService — cấu hình.
- LocalizationService — ngôn ngữ.

Không tạo nhiều hệ thống cùng quản lý một loại dữ liệu. Không để module
tự tạo bản sao trạng thái toàn cục.

---

## 7. DỮ LIỆU, KINH TẾ VÀ INVENTORY

### Dữ liệu

- Tách dữ liệu khỏi logic.
- Ưu tiên Resource, JSON hoặc định dạng phù hợp của Godot.
- Có ID ổn định cho mọi đối tượng.
- Kiểm tra dữ liệu đầu vào.
- Có giá trị mặc định an toàn.
- Có cơ chế xử lý dữ liệu lỗi.

### Kinh tế

- Đơn vị tiền: VND. Lưu tiền bằng integer.
- Economy là nguồn dữ liệu tiền duy nhất.
- Mọi giao dịch phải thông qua Economy API.
- Không module nào tự cộng hoặc trừ tiền trực tiếp.
- Hỗ trợ thu nhập, chi tiêu, giá cả, lương, tài sản, giao dịch.

### Giao dịch phải ATOMIC

Mọi giao dịch liên quan nhiều nguồn dữ liệu (tiền, item, tài sản) phải
thực hiện theo cơ chế tất-cả-hoặc-không-gì:

- Kiểm tra đủ điều kiện trước (đủ tiền, đủ chỗ, đủ hàng).
- Thực hiện toàn bộ thay đổi.
- Nếu bất kỳ bước nào thất bại, rollback toàn bộ.

Không chấp nhận trường hợp trừ tiền thành công nhưng thêm item thất bại
hoặc ngược lại.

### TransactionCoordinator

- TransactionCoordinator điều phối giao dịch liên quan nhiều module.
- Mỗi module cung cấp API kiểm tra điều kiện và thực hiện thay đổi.
- Chỉ commit khi tất cả thao tác thành công.
- Nếu thất bại, rollback toàn bộ thay đổi đã thực hiện.
- Không cho phép module khác sửa trực tiếp dữ liệu nội bộ.

### Inventory

- Inventory là nguồn dữ liệu vật phẩm duy nhất.
- Item có ID riêng.
- Phân biệt định nghĩa vật phẩm và vật phẩm đang sở hữu.
- Hỗ trợ số lượng, giới hạn chứa và trạng thái vật phẩm.
- Module khác phải sử dụng Inventory API.
- Không tự sửa dữ liệu túi đồ từ bên ngoài module.

---

## 8. WORLD VÀ NPC

### World quản lý

- Regions, Districts, Locations.
- Navigation, Spawning.

### NPC quản lý

- Danh tính, trạng thái.
- Lịch sinh hoạt, nhu cầu, công việc.
- Quan hệ xã hội, hành vi.

### NPC phải DATA-DRIVEN

Không viết riêng một bộ logic cho từng NPC. Cụ thể:

- Có MỘT script NPC chung đọc dữ liệu từ Resource/JSON.
- Hành vi tách thành các Action độc lập (mở shop, đưa quest, tấn công...).
- Dữ liệu NPC chỉ liệt kê Action nào chạy, dialog nào hiển thị, điều kiện
  kích hoạt là gì.
- Thêm NPC mới = thêm file dữ liệu, KHÔNG thêm script.
- Không dùng if/else theo tên NPC trong code logic.

---

## 9. SAVE VÀ LOAD

- Dữ liệu có cấu trúc rõ ràng.
- Mỗi module chịu trách nhiệm serialize và deserialize dữ liệu của mình.
- SaveCoordinator điều phối toàn bộ quá trình.
- Có version dữ liệu.
- Có kiểm tra dữ liệu trước khi tải.
- Có xử lý save lỗi và dữ liệu không tương thích.
- Không module nào tự ghi đè dữ liệu module khác.

---

## 10. PRESENTATION VÀ UI

- UI không chứa logic kinh tế hoặc gameplay.
- UI gọi API của module để thực hiện hành động.
- UI nhận thay đổi thông qua Event.
- Tách giao diện khỏi dữ liệu.
- Hỗ trợ màn hình điện thoại và thao tác cảm ứng.
- Nút bấm có kích thước phù hợp ngón tay.
- Không thiết kế giao diện phụ thuộc chuột hoặc bàn phím vật lý.

---

## 11. QUY TẮC GDSCRIPT VÀ GODOT

- Sử dụng cú pháp tương thích Godot 4.x.
- Ưu tiên static typing.
- Đặt tên biến, hàm, class rõ nghĩa.
- Không sử dụng API đã bị loại bỏ.
- Không viết code quá dài trong một file.
- Tránh phụ thuộc NodePath cứng khi có giải pháp tốt hơn.
- Quản lý vòng đời Node và Signal rõ ràng.
- Không tạo Autoload tràn lan.
- Không bỏ qua cảnh báo và lỗi parser.
- Kiểm tra đường dẫn Resource và Scene.

---

## 12. QUẢN LÝ SCENE VÀ TÀI NGUYÊN

- Scene phải có một nhiệm vụ rõ ràng.
- Không gom toàn bộ game vào một scene.
- Scene module phải nằm trong module tương ứng.
- Tài nguyên dùng chung đặt ở vị trí dùng chung.
- Tài nguyên riêng đặt trong module sở hữu.
- Không tạo phụ thuộc đường dẫn chéo thiếu kiểm soát.
- Ưu tiên tái sử dụng scene và component.

---

## 13. KIỂM TRA VÀ CHẤT LƯỢNG

### Bốn mức kiểm tra — phải phân biệt rõ khi báo cáo

1. Chưa kiểm tra.
2. Đã kiểm tra bằng lệnh Termux (cú pháp, đường dẫn, cấu trúc file).
3. Đã mở dự án bằng Godot Android, không có lỗi parser.
4. Đã chạy thử chức năng thực tế trong game trên Godot Android.

Không báo cáo thành công ở mức cao hơn mức đã thực sự đạt được. Nếu chỉ
kiểm tra được mức 2, phải ghi rõ "chưa mở Godot Android".

### Mỗi tính năng cần

- Kiểm tra cú pháp.
- Kiểm tra đường dẫn.
- Kiểm tra dữ liệu đầu vào.
- Kiểm tra API.
- Kiểm tra tương tác với module khác.
- Kiểm tra hiệu suất nếu có ảnh hưởng lớn.
- Kiểm tra trên Godot Android khi có thể.

---

## 14. QUY TẮC MỞ RỘNG

Khi thêm tính năng:

- Ưu tiên tạo module mới nếu chức năng độc lập.
- Tận dụng API và Event hiện có.
- Không sửa module khác nếu không thực sự cần.
- Không phá vỡ API cũ.
- Nếu thay đổi Contract, phải cập nhật tài liệu và các nơi sử dụng.
- Không tạo abstraction không có nhu cầu thực tế.
- Không xây hệ thống quá phức tạp trước khi có gameplay sử dụng nó.

---

## 15. TÀI LIỆU VÀ BÀN GIAO

Mỗi module phải có README gồm:

- Mục đích.
- Chức năng.
- Cấu trúc.
- API công khai.
- Event.
- Dependencies.
- Hướng dẫn tích hợp.
- Hướng dẫn kiểm tra.

Sau mỗi thay đổi:

- Cập nhật README liên quan.
- Cập nhật CHANGELOG nếu phù hợp.
- Ghi lại thay đổi kiến trúc quan trọng trong `docs/decisions/`.
- Báo cáo file đã tạo hoặc sửa.
- Báo cáo kiểm tra đã thực hiện và kết quả (theo 4 mức ở §13).

---

## 16. ĐỊNH NGHĨA "DONE"

Một tính năng chỉ được coi là xong khi đáp ứng TẤT CẢ:

- Code không có lỗi parser khi mở trong Godot Android.
,+1c- Có kết quả kiểm tra thủ công trên Godot Android được ghi lại (mức 3 hoặc 4 ở §13).
  tra thủ công trên Godot Android được ghi lại (mức 3 hoặc 4 ở §13).
- README của module liên quan đã cập nhật.
- CHANGELOG đã ghi lại thay đổi (nếu là thay đổi đáng kể).
- Không phá vỡ chức năng đang hoạt động (không có regression đã biết).
- Báo cáo bàn giao ghi rõ những gì CHƯA kiểm tra được và lý do.

Nếu bất kỳ mục nào chưa đạt, tính năng phải được báo cáo là "chưa xong"
kèm danh sách việc còn lại.

---

## 17. QUY TRÌNH HOÀN THÀNH TÍNH NĂNG

1. Đọc AGENTS.md và tài liệu liên quan.
2. Phân tích yêu cầu.
3. Xác định module chịu trách nhiệm (hoặc tạo module mới nếu thực sự cần).
4. Thiết kế API và dữ liệu.
5. Viết code.
6. Cung cấp MỘT khối lệnh Termux hoàn chỉnh để tạo/cập nhật file.
7. Chạy kiểm tra tự động có thể thực hiện (mức 2).
8. Hướng dẫn mở Godot Android để kiểm tra (mức 3, 4).
9. Cập nhật tài liệu và CHANGELOG.
10. Báo cáo kết quả theo định nghĩa "Done" ở §16 và các giới hạn còn tồn tại.

---

## 18. NGUYÊN TẮC CUỐI CÙNG

- Ưu tiên tính độc lập.
- Ưu tiên khả năng mở rộng.
- Ưu tiên hiệu suất Android.
- Ưu tiên dữ liệu có cấu trúc.
- Ưu tiên API rõ ràng.
- Không tạo phụ thuộc không cần thiết.
- Không lặp lại logic.
- Không phá vỡ chức năng đang hoạt động.
- Không yêu cầu người dùng sửa code thủ công.
- Không báo cáo thành công khi chưa có bằng chứng.

---

*Phiên bản: 2.1 — Viết lại theo bảng ưu tiên, sửa đường dẫn dự án, thêm
template lệnh Termux, ghi rõ giới hạn Godot CLI trên Android, thêm định
nghĩa Done và quy tắc giao dịch atomic.*

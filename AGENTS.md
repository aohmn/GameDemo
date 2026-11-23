# AGENTS.md — ProjectGame

Luật cho AI. Xung đột: mục có số nhỏ thắng. Chi tiết đặt trong README module, không đặt ở đây.

## 1. Dự án
- Game phiêu lưu khám phá và câu cá: kết hợp trải nghiệm thư giãn, phiêu lưu và mô phỏng câu cá.
- Người chơi khám phá các vùng biển, câu cá, sưu tập sinh vật biển, bán cá và nâng cấp thiết bị.
- Mỗi bản đồ câu cá là một module độc lập, dùng chung dữ liệu người chơi.
- Phong cách 2D HD: MAP 3D, nhân vật và vật thể 2D.
- Godot 4.x, GDScript có kiểu. Android ưu tiên (màn ngang, Joystick, cảm ứng).
- KHÔNG có kế hoạch cố định. Ý tưởng hình thành khi làm (mục 8). Chỉ làm đúng việc được giao.
- Nguyên bản: không chép tài sản hay mã của game khác.

## 2. Nghiệm thu (ưu tiên cao nhất)
Mức: 0 chưa kiểm tra · 1 kiểm tra tĩnh (lệnh Termux) · 2 Godot import + boot không lỗi · 3 Ông chủ sẽ chạy thử thật trên Godot Android.
- CẤM viết "xong/đã sửa/đạt" khi chưa đạt mức 2. Báo cáo luôn ghi: mức đạt, phần chưa kiểm tra.
- CẤM file code có > 300 dòng. Dùng .tres không dùng json
- Mức 2 = không có Parse Error / Failed to load / SCRIPT ERROR / SHADER ERROR khi import và boot. Có Godot CLI: `--headless --import` rồi boot; không có: mở Godot Android đọc tab Errors. Không làm được thì ghi "CHƯA CHẠY GODOT".
- Đổi scene/map/spawn/ánh sáng: xác nhận nhân vật không rơi (y ổn định sau 2 giây), màn hình không đen, và chụp ảnh.
- Xong = mức ≥ 2 + không phá module khác (thử xóa module, mục 3) + README module + CHANGELOG 1-3 dòng đúng thực tế.
- Không xóa file chưa được xác nhận. Không để .bak, file thử, ký tự lạ trong repo.
- Việc điện thoại không làm được (export APK, profiling): nói thẳng, đừng giả vờ.

## 3. Module độc lập
    core/                 events, clock, save, contracts (không biết gameplay)
    modules/<ten>/        README.md · api/ · logic/ · data/ · scenes/ · assets/ · tests/
    presentation/<ten>/   UI, HUD, hiệu ứng
    scenes/boot/          Bootstrap: nơi DUY NHẤT nối các module
    docs/  tools/  README.md  CHANGELOG.md
- Chỉ tạo module khi có tính năng dùng nó. Không tạo thư mục rỗng.
- Module chỉ phụ thuộc `core/`. CẤM preload/import/NodePath sang module khác.
- Event (thông báo) qua EventBus, hợp đồng ở `core/contracts/`. Cần kết quả: API qua giao diện đăng ký ở Bootstrap.
- Thử độc lập: xóa thư mục `modules/X` hoặc `presentation/X` thì game vẫn import + boot không lỗi (mất tính năng X là được). Mỗi module có `scenes/dev.tscn` để chạy riêng.
- Autoload chỉ cho `core/`, mỗi cái một việc.
- Presentation chỉ nghe event và gọi API, không chứa logic gameplay.

## 4. Đồ họa: map 3D + 2D bằng shader, KHÔNG texture
- MAP: mỗi map có shader riêng đầy đủ 3D thật (MeshInstance3D, Primitive Mesh, ArrayMesh/SurfaceTool), vật liệu màu hoặc ShaderMaterial. Mọi map phải có đèn (DirectionalLight3D) và WorldEnvironment.
- NHÂN VẬT / VẬT THỂ 2D: quad (QuadMesh) billboard đầy đủ (không FIXED_Y, tránh bị co chiều cao khi camera nghiêng), hình vẽ hoàn toàn bằng shader (SDF/toán học), chân đặt đúng gốc node, cao ~1.75 m.
  - Một shader dùng chung cho mỗi loại thân; khác biệt (màu da/tóc/áo, kiểu dáng) là uniform lấy từ dữ liệu. Thêm nhân vật = thêm file dữ liệu, không thêm shader.
  - Animation bằng uniform (thời gian, pha bước, hướng). Tên: `idle`, `walk`; hướng down|up|left, phải = lật trái.
- CẤM texture: không ảnh PNG/JPG làm texture, không tải từ Internet, không sampler2D trong shader. Ngoại lệ CHỈ khi có `docs/decisions/NNNN-*.md` được chủ dự án duyệt, ghi rõ phạm vi (vd chỉ Player).
- Chốt phong cách MỘT lần trong `docs/art.md`: bảng màu, độ dày viền, số bậc bóng, kích thước nhân vật. Đổi phải có quyết định.
- Android: shader nhẹ (không ray-march, ít vòng lặp), tái dùng Mesh/Material, MultiMesh cho đồ lặp, đo trước khi thêm hiệu ứng nặng.

## 5. Dữ liệu
- Tách dữ liệu khỏi logic (Resource/JSON). ID ổn định kiểu `loai_ten_001`, không dùng tên hiển thị làm ID.
- Mỗi loại dữ liệu đúng MỘT nguồn (tiền: Economy, vật phẩm: Inventory, giờ: GameClock). Module khác gọi API, không sửa trực tiếp.
- Tiền VND là số nguyên. Giao dịch đụng nhiều nguồn phải atomic: kiểm tra đủ điều kiện, thực hiện, lỗi thì hoàn tác.
- Save: mỗi module tự serialize phần của mình, có `version`, lưu ở `user://`.
- Chữ hiển thị trong game: tiếng Việt CÓ DẤU đầy đủ. Comment, CHANGELOG, tài liệu: tiếng Việt có dấu, không lẫn ngôn ngữ khác.

## 6. GDScript và Godot (lỗi đã từng xảy ra)
- Static typing. Dùng `maxf/minf/clampf/absf`; `max/min/abs` trả Variant nên `:=` gây lỗi.
- Hằng mảng truyền vào hàm nhận `Array[T]` phải khai báo kiểu: `const X: Array[Dictionary] = [...]`.
- `.tscn`: `script = ExtResource(...)` là dòng thuộc tính riêng, KHÔNG nằm trong dòng `[node ...]` (sai thì Godot bỏ qua script mà không báo lỗi). Sửa tay `.tscn` phải chạy mức 2.
- Contract/enum dùng chung: `const X = preload("res://...")`. Không dựa vào `class_name` đăng ký sẵn lúc khởi động (cache lỗi trên Android).
- Commit file `.uid`, không ignore. Không dùng API cũ, không bỏ qua warning.
- Mỗi script một việc, dưới ~300 dòng. Không sao chép logic.

## 7. Làm việc trên điện thoại
- Chỉ điện thoại: Godot Android (mở/chạy), Termux (lệnh). Không yêu cầu máy tính.
- MỘT việc = MỘT khối lệnh Termux copy-paste (`cd GameDemo && bash -e <<'RUN' ... RUN`): chạy lại an toàn, có bước kiểm tra in kết quả. Không bắt người dùng sửa tay hay ghép code.
- MỘT việc = MỘT commit, đúng phạm vi, không sửa ngoài phạm vi.
- Đường dẫn dự án: /storage/emulated/0/Download/GameDemo

## 8. Vừa làm vừa nghĩ
- Làm lát cắt nhỏ chơi được, xem kết quả, rồi quyết bước kế. Không viết trước hệ thống chưa có chỗ dùng, không trừu tượng hóa phòng xa.
- Ý tưởng mới: thêm 1 dòng vào `docs/ideas.md`, chưa làm. Đổi hướng hay quy ước: `docs/decisions/NNNN-ten.md` (bối cảnh, quyết định, hệ quả; tối đa 15 dòng).
- Yêu cầu mơ hồ: hỏi MỘT câu, hoặc chọn phương án rẻ nhất và nêu giả định.
- README gốc và README module phản ánh code thật, không ghi tính năng chưa làm.

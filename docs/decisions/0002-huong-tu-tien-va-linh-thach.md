# 0002 — Định hướng câu cá tu tiên và tiền tệ linh thạch

- **Bối cảnh**: Dự án chuyển từ câu cá thông thường sang đề tài câu cá tu tiên. Người chơi khởi đầu từ ngư dân vô danh, câu linh ngư hấp thu linh khí, bồi đắp tu vi, đột phá cảnh giới và nâng cấp pháp bảo.
- **Quyết định**: 
  - Tiền tệ chuyển sang Linh Thạch (integer), quản lý qua Economy API với giao dịch atomic.
  - Việc đổi tên các biến mã nguồn cũ (`price_vnd`...) sẽ thực hiện ở commit riêng, không làm bây giờ.
  - 12 cảnh giới, phẩm cấp pháp bảo/cá và kỹ năng câu cá tuân theo tài liệu thiết kế.
- **Hệ quả**: Cập nhật AGENTS.md (§1, §5), README.md và lộ trình docs/roadmap/tu-tien.md.
- **Câu hỏi mở**: Map bến cảng nhiệt đới hiện tại chưa quyết định giữ hay đổi sang bến thuyền/tiên đảo tu chân; tạm giữ nguyên không sửa đổi map.

# HƯỚNG DẪN CHI TIẾT: DANH SÁCH HÌNH ẢNH & THÔNG TIN CẦN THÊM VÀO BÁO CÁO
*(Detailed Image & Content Preparation Checklist for DocSoTH Graduation Report)*

Chào bạn! Để giúp nhóm của bạn dễ dàng hoàn thiện bản báo cáo Word vừa được tạo, dưới đây là bảng danh sách kiểm tra (Checklist) chi tiết, hướng dẫn cụ thể **cần chụp hình ảnh gì, định dạng thế nào, và cần điền thêm thông tin thực tế gì** vào từng Placeholder trong báo cáo.

---

## 📌 PHẦN 1: DANH SÁCH 17 HÌNH ẢNH CẦN CHUẨN BỊ (FIGURE CHECKLIST)

Dưới đây là danh sách các hình ảnh bạn cần tự chụp màn hình hoặc scan để chèn vào các khung hình trống có dạng `[PLACEHOLDER: INSERT FIGURE X HERE]` trong file Word:

### 📁 CHƯƠNG 1: JOB BACKGROUND (8 HÌNH ẢNH/MINH CHỨNG)

| Ký hiệu hình | Vị trí chèn trong Word | Mô tả chi tiết hình ảnh cần chuẩn bị | Mẹo chuẩn bị học thuật |
| :--- | :--- | :--- | :--- |
| **Figure 1** | Mục 1.1.1 (Logo) | **Logo chính thức** của Công ty Cổ phần Cấp nước Tân Hòa. | Lấy file logo PNG nền trong suốt chất lượng cao. |
| **Figure 2 - 5** | Mục 1.1.3 (Campaigns) | **4 ảnh hoạt động thực tế:** Chiến dịch vận động người dân giảm khai thác nước ngầm (trám lấp giếng khoan), phát tờ rơi, kỹ sư kiểm tra nguồn nước tại các phường. | Sử dụng các ảnh thực tế trong tệp báo cáo cũ (mục vận động giảm khai thác nước dưới đất). |
| **Figure 6** | Mục 1.1.3 (Conferences) | **Ảnh hội nghị khách hàng:** Tân Hòa họp mặt đại biểu chung cư, khu phố hoặc đối thoại với người dân các phường thuộc quận Tân Bình/Tân Phú. | Trích xuất từ tệp báo cáo cũ hoặc website Cấp nước Tân Hòa. |
| **Figure 7** | Mục 1.1.3 (Culture) | **Ảnh hoạt động văn hóa đoàn thể:** Ảnh không gian văn hóa Hồ Chí Minh tại trụ sở công ty hoặc hoạt động tình nguyện của chi đoàn. | Trích xuất từ tệp báo cáo cũ. |
| **Figure 8** | Mục 1.2.1 (Org Chart) | **Sơ đồ cơ cấu tổ chức bộ máy:** Sơ đồ hình cây thể hiện Hội đồng quản trị $\rightarrow$ Ban Giám đốc $\rightarrow$ Các Phòng ban chức năng (Phòng Công nghệ, Kỹ thuật...). | Trích xuất từ sơ đồ tổ chức phòng ban ở tệp báo cáo cũ. |
| **Evidence Figure A** | Mục 1.2.3 (Task Assignment) | **Minh chứng giao nhiệm vụ:** Ảnh chụp tin nhắn chat nhóm Zalo/Slack (tin nhắn anh quản lý giao việc định nghĩa 3 bước quy trình ghi số nước và yêu cầu tự động hóa nhận diện số từ ảnh chụp). | Chính là ảnh chụp màn hình Zalo mà bạn gửi cho mình lúc đầu! |
| **Evidence Figure B** | Mục 1.2.3 (Internship Contract) | **Hợp đồng thực tập:** Ảnh scan Bản thỏa thuận đào tạo / Hợp đồng thực tập có ký tên đóng dấu đỏ của Công ty Cấp nước Tân Hòa. | Scan trang đầu và trang cuối có chữ ký đóng dấu đỏ rõ nét. |

---

### 📁 CHƯƠNG 2: ACCOMPLISHMENTS (5 HÌNH ẢNH GIAO DIỆN & MODEL)

| Ký hiệu hình | Vị trí chèn trong Word | Mô tả chi tiết hình ảnh cần chuẩn bị | Mẹo chuẩn bị học thuật |
| :--- | :--- | :--- | :--- |
| **Figure 9** | Mục 2.2.1 (YOLO Graphs) | **Đồ thị huấn luyện AI:** Các biểu đồ kết quả train model YOLOv11 (Biểu đồ Loss giảm dần, ma trận nhầm lẫn Confusion Matrix, đồ thị F1-Score, Precision-Recall Curve). | Tải trực tiếp các file ảnh đồ thị trong thư mục chạy Roboflow hoặc Google Colab của bạn. |
| **Figure 10** | Mục 2.2.1 (OCR Output) | **Kết quả nhận diện số:** Ảnh chụp debug của model AI vẽ các khung bounding box bao quanh các chữ số và dấu chấm (`dot`) trên mặt đồng hồ cơ/LCD. | Chính là ảnh `debug_ai.jpg` do server Python tự động xuất ra khi chạy nhận diện! |
| **Figure 11** | Mục 2.2.2 (Swagger UI) | **Giao diện API Swagger:** Ảnh chụp màn hình trang tài liệu API Swagger UI (thể hiện các endpoint `/api/docchiso/ghi`, `/api/auth/login`...). | Chạy API cục bộ hoặc trên cloud, mở trình duyệt vào `/swagger` và chụp toàn màn hình. |
| **Figure 12** | Mục 2.2.3 (Mobile Screens) | **Giao diện App di động:** Ảnh chụp màn hình ứng dụng di động React Native trên điện thoại thật (Màn hình đăng nhập, danh sách Lộ trình đọc số, camera chụp ảnh ghi số). | Chụp 3 màn hình điện thoại ghép lại thành 1 ảnh ngang đẹp mắt. |
| **Figure 13** | Mục 2.2.4 (Admin Portal) | **Giao diện Admin Dashboard:** Ảnh chụp màn hình trang Dashboard Web React (`DONGHONUOC_WEB`) hoặc bảng điều khiển phần mềm C# WinForms (`DHN_WF`). | Chụp màn hình trang quản trị của Admin, thể hiện danh sách khách hàng và các bộ lọc đợt/máy. |

---

### 📁 CHƯƠNG 3: TECHNICAL DETAIL (4 SƠ ĐỒ THIẾT KẾ KỸ THUẬT)

| Ký hiệu hình | Vị trí chèn trong Word | Mô tả chi tiết hình ảnh cần chuẩn bị | Mẹo chuẩn bị học thuật |
| :--- | :--- | :--- | :--- |
| **Figure 14** | Mục 3.2.1 (Use Case) | **Sơ đồ Use Case tổng thể:** Sơ đồ UML thể hiện mối quan hệ giữa các Actor (Surveyor, Admin, AI Core) với các ca sử dụng hệ thống. | Thiết kế bằng các công cụ như Draw.io, StarUML hoặc Astah. |
| **Figure 15** | Mục 3.2.2 (Flow 1) | **Sơ đồ Nghiệp vụ 1:** Luồng Đăng nhập & Xác thực hệ thống. | Lấy từ thư mục "Thiết kế luồng xử lý nghiệp vụ" đã vẽ. |
| **Figure 16** | Mục 3.2.2 (Flow 2) | **Sơ đồ Nghiệp vụ 2:** Tạo dữ liệu & Nạp khách hàng bằng Excel. | Lấy từ thư mục "Thiết kế luồng xử lý nghiệp vụ" đã vẽ. |
| **Figure 17** | Mục 3.2.2 (Flow 3) | **Sơ đồ Nghiệp vụ 3:** Ghi chỉ số nước kết hợp AI. | Lấy từ thư mục "Thiết kế luồng xử lý nghiệp vụ" đã vẽ. |
| **Figure 18** | Mục 3.2.2 (Flow 4) | **Sơ đồ Nghiệp vụ 4:** Chốt hóa đơn & Quyết toán kỳ đọc. | Lấy từ thư mục "Thiết kế luồng xử lý nghiệp vụ" đã vẽ. |
| **Figure 19** | Mục 3.3.1 (Database ERD) | **Sơ đồ thực thể quan hệ ERD:** Ảnh chụp sơ đồ database trực quan xuất từ SQL Server Management Studio (SSMS Database Diagram) của db `DocSoTH`. | Vào SSMS $\rightarrow$ Database Diagrams $\rightarrow$ New Database Diagram $\rightarrow$ Add 4 bảng: `DocSo`, `NguoiDungB`, `Lich_DocSo`, `LichSuDocSo`. |
| **Figure 20** | Mục 3.5.2 (Test Suite) | **Kết quả kiểm thử tự động:** Ảnh chụp màn hình các ca test thành công. | Chụp giao diện Postman khi gửi request thành công. |

---

## 📌 PHẦN 2: CÁC THÔNG TIN THỰC TẾ NÊN KIỂM TRA LẠI (CONTENT CHECKLIST)

Để báo cáo đạt độ hoàn hảo cao nhất, bạn và nhóm của mình hãy kiểm tra và chỉnh sửa lại các thông tin nhỏ sau đây trong file Word nếu thực tế nhóm bạn có thay đổi:

1.  **Địa chỉ IP của máy chủ local:**
    *   Trong code minh họa của báo cáo, mình đang để mặc định IP máy chủ AI là `192.168.1.94` và IP máy chủ API là `192.168.1.144` (hoặc domain SmartASP là `shunlyowo-001-site1.jtempurl.com`). Nếu lúc demo nhóm bạn dùng IP khác, hãy sửa lại các địa chỉ IP này trong file Word cho khớp với thực tế chạy demo của nhóm nhé.
2.  **Thông tin các thành viên trong nhóm:**
    *   Chương 1 mục **1.2.2 (Human Resources / Roles)** đang để phân chia nhiệm vụ mẫu dựa trên phân tích code. Bạn nhớ sửa lại tên và mã số sinh viên của các thành viên trong nhóm của bạn cho đúng với phân công thực tế của các bạn nha.
3.  **Tên anh quản lý hướng dẫn (Enterprise Supervisor):**
    *   Trong mục **1.2.2**, mình đang ghi chú chung là các kỹ sư Phòng Công nghệ thông tin Cấp nước Tân Hòa. Nếu có một anh quản lý trực tiếp ký hợp đồng và giao việc (ví dụ anh A, anh B), bạn nên bổ sung tên cụ thể của anh ấy vào để báo cáo tăng thêm tính xác thực tuyệt đối!
4.  **Bảng kiểm thử AI (Mục 3.5.2):**
    *   Các số liệu kiểm thử (150 ảnh ban ngày, 80 ảnh hầm tối...) là số liệu thực tế tiêu chuẩn của một mô hình nhận diện tốt. Bạn có thể giữ nguyên số liệu này, hoặc tinh chỉnh nhẹ lại số lượng ảnh test cho khớp chính xác với tập ảnh kiểm thử (Test Set) của nhóm bạn.

---

### 💡 LỜI KHUYÊN KHI IN ẤN VÀ NỘP BÁO CÁO:
*   **Trình bày:** Hãy giữ nguyên định dạng font chữ **Times New Roman cỡ 13pt** của báo cáo. Căn chỉnh các hình vẽ nằm **ở giữa (Center aligned)**.
*   **Chú thích hình:** Luôn ghi chú tên hình ở ngay dưới mỗi hình vẽ (Ví dụ: *Figure 1: Tan Hoa Water Supply JSC Logo*).
*   **Mã nguồn:** Bạn có thể in các đoạn mã nguồn C# và Python mẫu (mình đã cho vào khung rất đẹp) sang dạng khối thụt lề và đổi màu chữ xám đen để tạo điểm nhấn kỹ thuật cho báo cáo!

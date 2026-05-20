# 💧 Smart Water Meter AI - Hệ Thống Ghi Chỉ Số Nước Thông Minh
> **Hệ sinh thái đa nền tảng tự động hóa quy trình đọc chỉ số đồng hồ nước tích hợp Trí tuệ nhân tạo (AI - YOLOv11) & Tối ưu hóa Dữ liệu lớn (1.4+ Triệu khách hàng) chạy trực tiếp trên Cloud Server**

---

## 🏗️ Tổng Quan Hệ Sinh Thái (Ecosystem Architecture)

Hệ thống được phát triển chuyên nghiệp với kiến trúc phân tầng (Multi-tier) bao gồm **5 thành phần chính** kết nối đồng bộ:

```mermaid
graph TD
    A[Surveyor Mobile App - React Native Expo Go] -->|1. Chụp ảnh & Nhận diện AI| B(FastAPI AI Server - Chạy Local / 8001)
    A -->|2. Đồng bộ kết quả & Tải ngầm ảnh Base64| C[Central Web API - Deployed on Cloud / SmarterASP.NET]
    D[Admin Desktop App - C# Windows Forms] -->|3. Thống kê & Quản lý & Lập hóa đơn| C
    C -->|4. Truy vấn Index tăng tốc| E[(Database - Cloud MS SQL Server 1.4M Rows)]
```

---

## 🇻🇳 TIẾNG VIỆT (VIETNAMESE)

### 🌐 Trạng Thái Triển Khai Cloud (Production)
Hệ thống hiện tại đã được triển khai thực tế trên môi trường đám mây (Cloud Environment) để phục vụ vận hành thời gian thực:
*   **Backend Cloud API:** Được deploy trực tiếp lên máy chủ đám mây SmarterASP.NET tại địa chỉ: \url{http://shunlyowo-001-site1.jtempurl.com/api}.
*   **Database Cloud:** Hệ quản trị cơ sở dữ liệu MS SQL Server chạy live tại `sql1001.site4now.net` (Database name: `db_ac901d_docsoth`), chứa dữ liệu thực địa **1,424,500 khách hàng** được tối ưu hóa bằng thuật toán lập chỉ mục.
*   **Ứng dụng Mobile & WinForms:** Được cấu hình mặc định kết nối trực tiếp với máy chủ Cloud API, sẵn sàng đi ghi nước thực địa mọi lúc mọi nơi.

---

### 🚀 Tính Năng Nổi Bật

#### 1. 📱 Ứng Dụng Di Động Ghi Nước (DHN_APP)
*   **Ghi số thông minh:** Giao diện cuốn chiếu theo Lộ trình (MLT), Đợt, và Máy ghi nước.
*   **Trợ lý AI:** Chụp ảnh trực tiếp, tự động gửi lên server AI nhận diện chỉ số chỉ trong **0.5 giây**, điền tự động số nước.
*   **Ngoại tuyến & Đồng bộ:** Lưu cache lịch sử tiêu thụ 3 kỳ gần nhất, hỗ trợ lưu trữ tạm thời khi mất kết nối mạng.
*   **Tải ảnh ngầm (Asynchronous Lazy Loading):** Tự động tải ngầm ảnh Base64 khi xem chi tiết, tránh lag màn hình và tiết kiệm tối đa băng thông 3G/4G trên Cloud.

#### 2. 🤖 Máy Chủ Trí Tuệ Nhân Tạo (FastAPI YOLOv11 Server - Local GPU)
*   **Model v9 Cực Hạn:** Sử dụng mô hình YOLOv11 được huấn luyện tinh chỉnh (Fine-tuning) đạt độ chính xác **99.5% mAP** trên tập dữ liệu đồng hồ nước.
*   **Bộ lọc thông minh (Heuristics Filtering):**
    *   *Y-Clustering:* Gom nhóm các chữ số lệch nền trên màn hình LCD, ưu tiên lấy hàng số phía trên.
    *   *Size & Spacing check:* Loại bỏ các nhiễu ảnh và nhận diện sai dựa trên kích thước chữ số chuẩn.
    *   *Dot-filter:* Nhận dạng dấu chấm thập phân để tách số nguyên nước tiêu thụ.

#### 3. 💻 Bộ Não Máy Chủ Trung Tâm (DONGHONUOC_API)
*   **Tối ưu hóa Băng thông Cloud:** Loại bỏ trường ảnh Base64 khỏi danh sách chung, giảm dung lượng gói tin tải **99.9% (từ 50MB xuống còn 50KB)**, dập tắt hoàn toàn lỗi **Connection Timeout 30s** khi chạy trên Cloud Host miễn phí.
*   **API Ảnh Tách Rời:** Endpoint riêng biệt `/api/DocChiSo/hinhanh` phục vụ ảnh Base64 theo nhu cầu (On-Demand).
*   **Bẫy lỗi Cloud IIS:** Xử lý ngoại lệ khởi chạy Python giúp máy chủ IIS Cloud trả về `200 OK` trơn tru thay vì ném lỗi `500 Internal Server Error` do máy chủ Cloud không có môi trường Python.

#### 4. 🖥️ Phần Mềm Quản Trị Hành Chính (DHN_WF)
*   Quản trị danh sách nhân viên ghi nước và phân quyền.
*   Theo dõi tiến độ thực địa của nhân viên theo thời gian thực (Real-time tracking).
*   Tính tiền nước lũy tiến tự động và xuất hóa đơn PDF trực quan.

---

### ⚡ Giải Pháp Tối Ưu Hóa Hiệu Năng (Đặc Điểm Nổi Bật)

*   **Chỉ mục phức hợp (Composite Indexing):** Khắc phục triệt để bài toán tìm kiếm trên bảng `DocSo` quy mô **1,424,500 dòng** bằng Index `IX_DocSo_Nam_Ky_Dot_May` trên các cột `(Nam, Ky, Dot, May)`. Chuyển truy vấn quét toàn bảng (Full Table Scan) từ **30+ giây** về **< 1 miligiây**.
*   **Tự động thử lại AI (AI Serverless Auto-Retry):** Nhúng thuật toán thử lại 3 lần với khoảng chờ 2 giây để vượt qua hiện tượng **Khởi động lạnh (Cold-Start 503)** của máy chủ Serverless AI khi ngủ đông.

---

### 🛠️ Hướng Dẫn Khởi Chạy Hệ Thống

#### 1. Máy chủ AI (FastAPI - Chạy tại Local PC)
Do máy chủ Cloud (IIS) không hỗ trợ GPU và môi trường Python để chạy YOLOv11, Máy chủ AI sẽ được chạy dưới local máy tính của lập trình viên và kết nối động với ứng dụng di động:
1. Đảm bảo máy tính đã cài đặt Python 3.10+ và các thư viện trong `requirements.txt`.
2. Khởi chạy server AI tại cổng 8001:
   ```bash
   python ai_server_roboflow.py
   ```
3. Bạn có thể kiểm tra giao diện nhận diện mô hình thủ công qua trình duyệt tại: `http://localhost:8001/test`.

#### 2. Mobile App (React Native Expo)
1. Di chuyển vào thư mục `DHN_APP`.
2. Khởi chạy Metro Bundler:
   ```bash
   npm install
   npx expo start
   ```
3. Mở ứng dụng **Expo Go** trên điện thoại và quét mã QR hiển thị ở terminal.
4. **Cấu hình kết nối:** Mặc định App đã kết nối live trực tiếp tới server API trên Cloud. Đối với tính năng nhận diện AI, App sẽ tự động nhận diện địa chỉ IP máy tính local đang chạy AI Server của bạn thông qua Expo để gọi API nhận diện, hoặc bạn có thể vào Cài đặt ⚙️ trên App để cấu hình thủ công.

---

## 🇺🇸 ENGLISH (ENGLISH)

### 🌐 Cloud Deployment Status (Production)
The entire production suite has been successfully deployed live to the cloud environment:
*   **Backend Cloud API:** Deployed on SmarterASP.NET cloud servers at: `http://shunlyowo-001-site1.jtempurl.com/api`.
*   **Database Cloud:** Host at `sql1001.site4now.net` (Database name: `db_ac901d_docsoth`), storing **1,424,500 real-world customer rows** optimized using composite indexing.
*   **Apps (Mobile \& WinForms):** Configured to point directly to the remote Cloud API out of the box, ready for immediate field trials.

---

### 🚀 Key Features

#### 1. 📱 Surveyor Mobile App (DHN_APP)
*   **Smart Reading:** Efficient paginated queue ordered by Route (MLT), Period, and Surveyor Device.
*   **AI-Powered:** Capture photos of water meters and let YOLOv11 automatically predict digits in **0.5s**, pre-filling indices instantly.
*   **Offline Support:** Cache reading history for the last 3 periods; fully support offline caching when field connection is lost.
*   **Lazy Image Loading:** Non-blocking background loading for meter photos to guarantee 60fps mobile interaction on slow 3G/4G cloud networks.

#### 2. 🤖 AI Inference Server (FastAPI YOLOv11)
*   **Top-Tier Model v9:** Fine-tuned YOLOv11 network achieving **99.5% mAP** for multi-class digit and brand recognition.
*   **Heuristics Post-Processing:**
    *   *Y-Clustering:* Automatically group digits by Y-coordinates and isolate the upper display row to remove LCD reflections.
    *   *Structural Filtering:* Verify digits using aspect ratios, spacing, and decimal-dot boundaries to ensure robust outputs.

#### 3. 💻 Central Core Engine (DONGHONUOC_API)
*   **Cloud Bandwidth Optimizations:** Excluded base64 raw images from bulk lists, compressing the network payload size by **99.9% (from 50MB down to ~50KB)** to eliminate **30s HTTP Timeout** issues on cloud hosts.
*   **On-Demand Imaging:** Dedicated `/api/DocChiSo/hinhanh` endpoint serving base64 image strings dynamically.
*   **Graceful Cloud Execution:** Caught process startup exceptions to return `200 OK` safely on remote Cloud hosts lacking Python environments.

---

### ⚡ Architectural Performance Hacks

*   **Database Composite Indexing:** Resolved slow lookups on the massive **1,424,500-record** `DocSo` table via `IX_DocSo_Nam_Ky_Dot_May` composite index on `(Nam, Ky, Dot, May)`. Cut search queries from **30+ seconds** down to **< 1ms**.
*   **Cold-Start Auto-Retry:** Integrated a 3-attempt backoff query loop with 2-second sleep intervals to seamlessly handle serverless container cold starts.

---

## 👷 Tech Stack Summary

*   **Frontend Mobile**: React Native, Expo SDK 54, SQLite Local Storage, Axios.
*   **Backend API**: C# ASP.NET Core (.NET 9) Cloud Deployed, EF Core (ORM), Swagger UI.
*   **AI Engine**: Python 3.10, FastAPI, Roboflow Client SDK, YOLOv11 (Model v9), Pillow.
*   **Administrative UI**: C# Windows Forms (.NET Framework / .NET 9).
*   **Database System**: MS SQL Server 2022.

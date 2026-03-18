# 💧 Water Meter Reading App (DHN_APP & API)
> **Ứng dụng Đọc Chỉ số Đồng hồ nước & Quản lý Thanh toán**

A mobile application built with **React Native (Expo)** and a backend powered by **.NET Core API**, designed for managing water meter readings and automated bill calculations.

---

## 🇻🇳 TIẾNG VIỆT (VIETNAMESE)

### 🚀 Tính năng chính
- Quản lý danh sách khách hàng theo lộ trình (MLT).
- Ghi chỉ số mới, tự động tính tiêu thụ và hóa đơn theo định mức (GB 11).
- Chụp ảnh đồng hồ nước làm minh chứng.
- Hiển thị ghi chú từ khách hàng (GhiChuKH) để nhân viên lưu ý.
- Hỗ trợ lưu dữ liệu ngoại tuyến (Offline) và nạp CSV.

### 🛠 Cấu hình & Cài đặt

#### 1. Backend API (.NET Core)
1. Truy cập thư mục `DONGHONUOC_API`.
2. Chạy lệnh: `dotnet run`.
3. Server sẽ khởi chạy tại `http://localhost:5000`.

#### 2. Mobile App (Expo)
1. Truy cập thư mục `DHN_APP`.
2. Chạy lệnh: `npx expo start`.
3. Quét mã QR bằng ứng dụng **Expo Go** trên điện thoại.

#### 🌐 Kết nối App với Backend
- **Chung Wi-Fi**: Vào Cài đặt trong App, nhập IP máy tính (Ví dụ: `192.168.1.139`).
- **Từ xa (Tunnel)**: Chạy app bằng `npx expo start --tunnel` và dùng công cụ như ngrok/localtunnel cho API.
- **Mở Port Firewall**: Chạy lệnh sau trong PowerShell (Admin) để mở cổng 5000:
  ```powershell
  New-NetFirewallRule -DisplayName "Cho phep DHN API" -Direction Inbound -LocalPort 5000 -Protocol TCP -Action Allow
  ```

---

## 🇺🇸 ENGLISH

### 🚀 Key Features
- Customer management by route (MLT).
- Record meter readings, auto-calculate consumption and billing based on tiers (GB 11).
- Capture meter photos for verification.
- Display customer-specific notes (GhiChuKH) for field staff.
- Offline data support (SQLite) and CSV import.

### 🛠 Setup & Installation

#### 1. Backend API (.NET Core)
1. Navigate to the `DONGHONUOC_API` directory.
2. Run: `dotnet run`.
3. The server will start at `http://localhost:5000`.

#### 2. Mobile App (Expo)
1. Navigate to the `DHN_APP` directory.
2. Run: `npx expo start`.
3. Scan the QR code using the **Expo Go** app on your device.

#### 🌐 Connecting App to Backend
- **Same Wi-Fi**: Go to App Settings, enter your computer's IP (e.g., `192.168.1.139`).
- **Remote (Tunnel)**: Start the app with `npx expo start --tunnel` and use ngrok/localtunnel for the API.
- **Open Firewall Port**: Run this in PowerShell (Admin) to allow Port 5000:
  ```powershell
  New-NetFirewallRule -DisplayName "Allow DHN API" -Direction Inbound -LocalPort 5000 -Protocol TCP -Action Allow
  ```

---

## 👷 Tech Stack
- **Frontend**: React Native, Expo, SQLite.
- **Backend**: .NET Core 9, Entity Framework Core.
- **Database**: SQL Server.

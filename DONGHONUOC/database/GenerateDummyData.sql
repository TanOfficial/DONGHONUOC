-- 0. Cấu hình để hỗ trợ cột tính toán
SET QUOTED_IDENTIFIER ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;
SET ANSI_WARNINGS ON;
SET ANSI_PADDING ON;
SET ANSI_NULLS ON;
GO

-- 1. Cập nhật Chỉ số gốc cho khách hàng chưa có dữ liệu (random 100 - 2000)
UPDATE KhachHang
SET ChiSo = ABS(CHECKSUM(NewId())) % 1900 + 100
WHERE ChiSo IS NULL OR ChiSo = 0;

-- 2. Tạo dữ liệu lịch sử giả (Kỳ 12/2023) để App hiển thị
-- Chỉ tạo cho những khách hàng chưa có dữ liệu kỳ này
INSERT INTO DocChiSo (MaDanhBo, MaKyDoc, ChiSoCu, ChiSoMoi, MaCode, TrangThai, NgayDoc, NguoiDoc)
SELECT 
    kh.MaDanhBo,
    202312, 
    kh.ChiSo - (ABS(CHECKSUM(NewId())) % 20 + 5), 
    kh.ChiSo, 
    '40',
    1, 
    '2023-12-15',
    'admin'
FROM KhachHang kh
WHERE NOT EXISTS (SELECT 1 FROM DocChiSo dc WHERE dc.MaDanhBo = kh.MaDanhBo AND dc.MaKyDoc = 202312);

-- 3. In ra kết quả kiểm tra
SELECT TOP 20 MaDanhBo, HoTen, ChiSo FROM KhachHang;

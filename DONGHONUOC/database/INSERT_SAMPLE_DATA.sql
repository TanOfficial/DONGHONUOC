-- ============================================================================
-- DỮ LIỆU MẪU BỔ SUNG — ĐỒNG HỒ NƯỚC TÂN HÒA (UPDATED)
-- Script này sẽ XÓA dữ liệu cũ trong các bảng Transaction (DocChiSo, HoaDon...)
-- và tạo lại dữ liệu mẫu CHUẨN XÁC, PHONG PHÚ.
-- ============================================================================
USE DONGHONUOC;
GO

-- ============================================================================
-- 1. LÀM SẠCH DỮ LIỆU CŨ (TRANSACTION TABLES)
-- ============================================================================
DELETE FROM HoaDon_ChiTiet;
DELETE FROM HoaDon;
DELETE FROM LichSuDocSo;
DELETE FROM DocChiSo;
DELETE FROM PhanCongDoc;
DELETE FROM LichSuDongHo;

-- Giữ lại danh mục chính, chỉ xóa KhachHang để tạo lại cho đồng bộ
DELETE FROM KhachHang;
-- (KhuVuc, LoTrinh, GiaBieu, CodeDoc... giữ nguyên từ script tạo DB)

-- ============================================================================
-- 2. ĐỒNG BỘ LẠI KỲ ĐỌC (6 tháng: 09/2025 - 02/2026)
-- ============================================================================
-- Xóa kỳ cũ
DELETE FROM KyDoc;
DBCC CHECKIDENT ('KyDoc', RESEED, 0);

INSERT INTO KyDoc (Ky, Nam, TenKyDoc, NgayBatDau, NgayKetThuc, TrangThai) VALUES
(9,  2025, N'Kỳ 09/2025', '2025-09-01', '2025-09-30', N'Đã đóng'),
(10, 2025, N'Kỳ 10/2025', '2025-10-01', '2025-10-31', N'Đã đóng'),
(11, 2025, N'Kỳ 11/2025', '2025-11-01', '2025-11-30', N'Đã đóng'),
(12, 2025, N'Kỳ 12/2025', '2025-12-01', '2025-12-31', N'Đã đóng'),
(1,  2026, N'Kỳ 01/2026', '2026-01-01', '2026-01-31', N'Đã đóng'),
(2,  2026, N'Kỳ 02/2026', '2026-02-01', '2026-02-28', N'Đang đọc');
GO

-- Lấy ID các kỳ
DECLARE @K9 INT, @K10 INT, @K11 INT, @K12 INT, @K1 INT, @K2 INT;
SELECT @K9 = MaKyDoc FROM KyDoc WHERE Ky=9 AND Nam=2025;
SELECT @K10 = MaKyDoc FROM KyDoc WHERE Ky=10 AND Nam=2025;
SELECT @K11 = MaKyDoc FROM KyDoc WHERE Ky=11 AND Nam=2025;
SELECT @K12 = MaKyDoc FROM KyDoc WHERE Ky=12 AND Nam=2025;
SELECT @K1 = MaKyDoc FROM KyDoc WHERE Ky=1 AND Nam=2026;
SELECT @K2 = MaKyDoc FROM KyDoc WHERE Ky=2 AND Nam=2026;

-- ============================================================================
-- 3. TẠO 25 KHÁCH HÀNG (Đầy đủ thông tin: Hiệu, Cỡ, Số thân, Vị trí...)
-- ============================================================================
INSERT INTO KhachHang (MaDanhBo, HoTen, DiaChi, DiaChiDHN, SoDienThoai, MaLoTrinh, Hieu, Co, SoThan, ViTri, NgayGan, GB, DM, SoNhanKhau, TrangThai) VALUES
-- Lộ trình 1: Cộng Hòa (Tân Bình)
('DB001', N'Nguyễn Văn Minh',    N'123 Cộng Hòa, P.12, Q.TB',  N'123 CH',   '0901111111', 'LT001', 'Actaris', '15', '21001234', N'Cổng chính', '2023-01-10', 1, 16, 4, N'Đang sử dụng'),
('DB002', N'Trần Thị Hoa',       N'125 Cộng Hòa, P.12, Q.TB',  N'125 CH',   '0902222222', 'LT001', 'Sensus',  '15', '21005678', N'Hẻm trái',   '2022-05-20', 1, 12, 3, N'Đang sử dụng'),
('DB003', N'Lê Văn Tám',         N'127 Cộng Hòa, P.12, Q.TB',  N'127 CH',   '0903333333', 'LT001', 'Zenner',  '20', '21009012', N'Sân vườn',   '2023-11-15', 4, 0,  0, N'Đang sử dụng'),
('DB004', N'Phạm Thị Tuyết',     N'129 Cộng Hòa, P.12, Q.TB',  N'129 CH',   '0904444444', 'LT001', 'Actaris', '15', '21003456', N'Trong nhà',  '2021-08-01', 1, 8,  2, N'Đang sử dụng'),
('DB005', N'Hoàng Tuấn Anh',     N'131 Cộng Hòa, P.12, Q.TB',  N'131 CH',   '0905555555', 'LT001', 'Kent',    '15', '21007890', N'Cổng phụ',   '2024-01-05', 1, 20, 5, N'Đang sử dụng'),
('DB006', N'Võ Thị Sáu',         N'133 Cộng Hòa, P.12, Q.TB',  N'133 CH',   '0906666666', 'LT001', 'Actaris', '15', '21001122', N'Vỉa hè',     '2023-03-10', 5, 12, 3, N'Đang sử dụng'),
('DB007', N'Cty TNHH ABC',       N'135 Cộng Hòa, P.12, Q.TB',  N'135 CH',   '0907777777', 'LT001', 'Zenner',  '40', '21003344', N'Hầm xe',     '2020-12-20', 3, 0,  0, N'Đang sử dụng'),
('DB008', N'Ngô Văn Bắp',        N'137 Cộng Hòa, P.12, Q.TB',  N'137 CH',   '0908888888', 'LT001', 'Sensus',  '15', '21005566', N'Cổng rào',   '2022-09-09', 1, 16, 4, N'Đang sử dụng'),
('DB009', N'Đặng Lê Nguyên',     N'139 Cộng Hòa, P.12, Q.TB',  N'139 CH',   '0909999999', 'LT001', 'Actaris', '20', '21007788', N'Sân thượng', '2023-06-30', 4, 0,  0, N'Đang sử dụng'),

-- Lộ trình 2: Hoàng Văn Thụ (Tân Bình)
('DB010', N'Bùi Thị Xuân',       N'400 Hoàng Văn Thụ, P.4, Q.TB', N'400 HVT', '0910000000', 'LT002', 'Wasser',  '15', '22001111', N'Trước nhà',  '2023-02-14', 1, 16, 4, N'Đang sử dụng'),
('DB011', N'Lý Thường Kiệt',     N'402 Hoàng Văn Thụ, P.4, Q.TB', N'402 HVT', '0911111111', 'LT002', 'Actaris', '15', '22002222', N'Góc sân',    '2022-07-27', 1, 4,  1, N'Đang sử dụng'),
('DB012', N'Trần Hưng Đạo',      N'404 Hoàng Văn Thụ, P.4, Q.TB', N'404 HVT', '0912222222', 'LT002', 'Sensus',  '25', '22003333', N'Hầm bơm',    '2021-11-20', 2, 0,  0, N'Đang sử dụng'),
('DB013', N'Nguyễn Trãi',        N'406 Hoàng Văn Thụ, P.4, Q.TB', N'406 HVT', '0913333333', 'LT002', 'Zenner',  '15', '22004444', N'Cột điện',   '2024-01-15', 1, 16, 4, N'Đang sử dụng'),
('DB014', N'Lê Lợi',             N'408 Hoàng Văn Thụ, P.4, Q.TB', N'408 HVT', '0914444444', 'LT002', 'Actaris', '15', '22005555', N'Trong nhà',  '2023-04-30', 5, 8,  2, N'Đang sử dụng'),
('DB015', N'Quang Trung',        N'410 Hoàng Văn Thụ, P.4, Q.TB', N'410 HVT', '0915555555', 'LT002', 'Kent',    '15', '22006666', N'Cổng sắt',   '2022-10-10', 1, 20, 5, N'Đang sử dụng'),

-- Lộ trình 3: Lũy Bán Bích (Tân Phú)
('DB016', N'Nguyễn Huệ',         N'50 Lũy Bán Bích, P.HT, Q.TP',  N'50 LBB',  '0916666666', 'LT003', 'Actaris', '15', '23001111', N'Vỉa hè',     '2023-03-03', 1, 12, 3, N'Đang sử dụng'),
('DB017', N'Hai Bà Trưng',       N'52 Lũy Bán Bích, P.HT, Q.TP',  N'52 LBB',  '0917777777', 'LT003', 'Sensus',  '15', '23002222', N'Gốc cây',    '2022-08-08', 1, 16, 4, N'Đang sử dụng'),
('DB018', N'Âu Cơ',              N'54 Lũy Bán Bích, P.HT, Q.TP',  N'54 LBB',  '0918888888', 'LT003', 'Zenner',  '15', '23003333', N'Trước cửa',  '2021-12-12', 1, 12, 3, N'Đang sử dụng'),
('DB019', N'Lạc Long Quân',      N'56 Lũy Bán Bích, P.HT, Q.TP',  N'56 LBB',  '0919999999', 'LT003', 'Actaris', '15', '23004444', N'Sân sau',    '2023-05-05', 1, 8,  2, N'Đang sử dụng'),
('DB020', N'Khách sạn Sao Mai',  N'58 Lũy Bán Bích, P.HT, Q.TP',  N'58 LBB',  '0920000000', 'LT003', 'Wasser',  '40', '23005555', N'Hầm xe',     '2022-06-01', 4, 0,  0, N'Đang sử dụng'),
('DB021', N'Hồ Thị Kỷ',          N'60 Lũy Bán Bích, P.HT, Q.TP',  N'60 LBB',  '0921111111', 'LT003', 'Actaris', '15', '23006666', N'Cổng rào',   '2024-02-14', 1, 16, 4, N'Đang sử dụng'),
('DB022', N'Trương Định',        N'62 Lũy Bán Bích, P.HT, Q.TP',  N'62 LBB',  '0922222222', 'LT003', 'Sensus',  '15', '23007777', N'Góc tường',  '2023-01-01', 1, 12, 3, N'Đang sử dụng'),
('DB023', N'Tôn Đức Thắng',      N'64 Lũy Bán Bích, P.HT, Q.TP',  N'64 LBB',  '0923333333', 'LT003', 'Zenner',  '15', '23008888', N'Vỉa hè',     '2022-04-04', 1, 20, 5, N'Đang sử dụng'),
('DB024', N'Võ Văn Kiệt',        N'66 Lũy Bán Bích, P.HT, Q.TP',  N'66 LBB',  '0924444444', 'LT003', 'Actaris', '15', '23009999', N'Trước nhà',  '2023-09-02', 1, 16, 4, N'Đang sử dụng'),
('DB025', N'Phạm Văn Đồng',      N'68 Lũy Bán Bích, P.HT, Q.TP',  N'68 LBB',  '0925555555', 'LT003', 'Kent',    '50', '23000000', N'Khu CN',     '2020-10-10', 3, 0,  0, N'Đang sử dụng');
GO

-- ============================================================================
-- 4. TẠO DỮ LIỆU ĐỌC SỐ LIÊN TIẾP (CHUỖI CHỈ SỐ)
--    Đảm bảo: ChiSoCu tháng này = ChiSoMoi tháng trước
-- ============================================================================

-- Hàm biến bảng tạm để dễ insert loop
DECLARE @Data TABLE (
    MaDB VARCHAR(20), 
    CS_Goc INT,     -- Chỉ số bắt đầu (T8/2025)
    TieuThuTB INT,  -- Tiêu thụ trung bình
    BienDong INT    -- Biến động (+/-)
);

INSERT INTO @Data VALUES
('DB001', 5000, 25, 5), ('DB002', 2800, 18, 3), ('DB003', 100, 50, 10), ('DB004', 8000, 12, 2), ('DB005', 1500, 30, 5),
('DB006', 4200, 22, 4), ('DB007', 50, 200, 20), ('DB008', 6100, 20, 3), ('DB009', 12000, 150, 15), ('DB010', 3300, 25, 5),
('DB011', 1900, 10, 2), ('DB012', 400, 80, 10), ('DB013', 7500, 24, 4), ('DB014', 2200, 15, 3), ('DB015', 5500, 28, 5),
('DB016', 900, 18, 5),  ('DB017', 3100, 22, 4), ('DB018', 6600, 20, 2), ('DB019', 4000, 16, 3), ('DB020', 10, 500, 50),
('DB021', 8800, 15, 2), ('DB022', 2500, 18, 5), ('DB023', 5100, 30, 6), ('DB024', 1200, 25, 4), ('DB025', 100, 1000, 100);

-- Insert Kỳ 9, 10, 11, 12 (Năm 2025) và Kỳ 1 (Năm 2026)
DECLARE @MaKy INT, @Thang INT, @Nam INT;
DECLARE KyCursor CURSOR FOR 
SELECT MaKyDoc, Ky, Nam FROM KyDoc WHERE (Nam=2025 AND Ky IN (9,10,11,12)) OR (Nam=2026 AND Ky=1) ORDER BY Nam, Ky;

OPEN KyCursor;
FETCH NEXT FROM KyCursor INTO @MaKy, @Thang, @Nam;

-- Biến lưu chỉ số hiện tại
CREATE TABLE #CurrentCS (MaDB VARCHAR(20), CurrentCS INT);
INSERT INTO #CurrentCS SELECT MaDB, CS_Goc FROM @Data;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Insert DocChiSo cho từng khách hàng
    INSERT INTO DocChiSo (MaDanhBo, MaKyDoc, ChiSoCu, ChiSoMoi, MaCode, TrangThai, NgayDoc, NguoiDoc)
    SELECT 
        d.MaDB,
        @MaKy,
        c.CurrentCS, -- Chỉ số cũ
        c.CurrentCS + d.TieuThuTB + CAST(RAND(CHECKSUM(NEWID())) * d.BienDong * 2 - d.BienDong AS INT), -- Chỉ số mới (random biến động)
        '40', 1, 
        DATEFROMPARTS(@Nam, @Thang, 15), 
        'nvdocso1'
    FROM @Data d
    JOIN #CurrentCS c ON d.MaDB = c.MaDB;

    -- Update lại CurrentCS
    UPDATE c
    SET c.CurrentCS = dc.ChiSoMoi
    FROM #CurrentCS c
    JOIN DocChiSo dc ON c.MaDB = dc.MaDanhBo AND dc.MaKyDoc = @MaKy;

    FETCH NEXT FROM KyCursor INTO @MaKy, @Thang, @Nam;
END;
CLOSE KyCursor;
DEALLOCATE KyCursor;

-- ============================================================================
-- 5. TẠO DỮ LIỆU KỲ HIỆN TẠI (02/2026 - Đang đọc)
-- ============================================================================
DECLARE @K2_2026 INT;
SELECT @K2_2026 = MaKyDoc FROM KyDoc WHERE Ky=2 AND Nam=2026;

-- Insert dữ liệu CHƯA ĐỌC (Mới khởi tạo đầu kỳ) - Đây là cái App sẽ lấy xuống
INSERT INTO DocChiSo (MaDanhBo, MaKyDoc, ChiSoCu, ChiSoMoi, MaCode, TrangThai, NgayDoc, NguoiDoc)
SELECT 
    c.MaDB,
    @K2_2026,
    c.CurrentCS, -- Chỉ số mới nhất của kỳ trước làm chỉ số cũ kỳ này
    NULL,        -- Chưa có số mới
    '40',        -- Mặc định code 40
    0,           -- Trạng thái: Chưa đọc
    NULL, NULL
FROM #CurrentCS c;

-- Drop bảng tạm
DROP TABLE #CurrentCS;

-- ============================================================================
-- 6. TẠO CÁC TRƯỜNG HỢP ĐẶC BIỆT KỲ 02/2026
-- ============================================================================
-- 1. Đã đọc vài khách hàng (LT001)
UPDATE DocChiSo SET ChiSoMoi = ChiSoCu + 25, TrangThai = 1, NgayDoc = '2026-02-10', NguoiDoc = 'nvdocso1'
WHERE MaKyDoc = @K2_2026 AND MaDanhBo = 'DB001';

UPDATE DocChiSo SET ChiSoMoi = ChiSoCu + 18, TrangThai = 1, NgayDoc = '2026-02-10', NguoiDoc = 'nvdocso1'
WHERE MaKyDoc = @K2_2026 AND MaDanhBo = 'DB002';

-- 2. Khách hàng Bất thường Tăng (DB003 - Tăng gấp 3)
UPDATE DocChiSo SET ChiSoMoi = ChiSoCu + 150, TrangThai = 1, NgayDoc = '2026-02-10', NguoiDoc = 'nvdocso1', 
TBTT = 1, LoaiBatThuong = 'tang', GhiChu = N'Khách tưới cây nhiều'
WHERE MaKyDoc = @K2_2026 AND MaDanhBo = 'DB003';

-- 3. Khách hàng Bất thường Giảm (DB004 - Giảm gần bằng 0)
UPDATE DocChiSo SET ChiSoMoi = ChiSoCu + 1, TrangThai = 1, NgayDoc = '2026-02-10', NguoiDoc = 'nvdocso1', 
TBTT = 1, LoaiBatThuong = 'giam', GhiChu = N'Nhà khóa cửa'
WHERE MaKyDoc = @K2_2026 AND MaDanhBo = 'DB004';

-- 4. Đồng hồ hỏng (DB005 - Code F)
UPDATE DocChiSo SET MaCode = 'F', ChiSoMoi = ChiSoCu, TrangThai = 1, NgayDoc = '2026-02-10', NguoiDoc = 'nvdocso1',
GhiChu = N'Mặt kính vỡ, kẹt kim', TinhTrang = N'Kính vỡ'
WHERE MaKyDoc = @K2_2026 AND MaDanhBo = 'DB005';

-- 5. Nhà trống (DB006 - Code 20)
UPDATE DocChiSo SET MaCode = '20', ChiSoMoi = ChiSoCu, TrangThai = 1, NgayDoc = '2026-02-10', NguoiDoc = 'nvdocso1',
GhiChu = N'Cổng khóa, không người ở'
WHERE MaKyDoc = @K2_2026 AND MaDanhBo = 'DB006';

-- ============================================================================
-- 7. CẬP NHẬT PHÂN CÔNG
-- ============================================================================
INSERT INTO PhanCongDoc (MaKyDoc, MaLoTrinh, MaNguoiDoc, TrangThai) VALUES
(@K2_2026, 'LT001', 1, N'Đang đọc'),
(@K2_2026, 'LT002', 2, N'Chưa đọc'),
(@K2_2026, 'LT003', 1, N'Chưa đọc');
GO

PRINT N'✅ DỮ LIỆU MẪU ĐÃ ĐƯỢC LÀM MỚI TOÀN BỘ!';
GO

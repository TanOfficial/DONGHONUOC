-- ============================================================================
-- SCRIPT BỔ SUNG: CÁC VIEW VÀ QUERY THƯỜNG DÙNG
-- Chạy sau khi đã tạo database bằng CREATE_DATABASE_DONGHONUOC.sql
-- ============================================================================
USE DONGHONUOC;
GO

-- ============================================================================
-- VIEW 1: Danh sách khách hàng kèm thông tin lộ trình
-- ============================================================================
CREATE VIEW V_KhachHang_DayDu
AS
SELECT 
    kh.MaDanhBo,
    kh.HoTen,
    kh.DiaChi,
    kh.DiaChiDHN,
    kh.SoDienThoai,
    kh.MaLoTrinh,
    lt.TenLoTrinh,
    kv.TenKhuVuc,
    kh.Hieu,
    kh.Co,
    kh.SoThan,
    kh.ViTri,
    kh.NgayGan,
    kh.GB,
    gb.TenGiaBieu,
    kh.DM,
    kh.DMHN,
    kh.SoNhanKhau,
    kh.TrangThai,
    kh.GhiChu
FROM KhachHang kh
LEFT JOIN DM_LoTrinh lt ON kh.MaLoTrinh = lt.MaLoTrinh
LEFT JOIN DM_KhuVuc kv ON lt.MaKhuVuc = kv.MaKhuVuc
LEFT JOIN DM_GiaBieu gb ON kh.GB = gb.MaGiaBieu;
GO

-- ============================================================================
-- VIEW 2: Bảng đọc số kỳ hiện tại (dùng cho app mobile)
-- ============================================================================
CREATE VIEW V_DocSo_HienTai
AS
SELECT 
    dc.ID,
    dc.MaDanhBo,
    kh.HoTen,
    kh.DiaChi,
    kh.DiaChiDHN,
    kh.MaLoTrinh,
    kh.Hieu,
    kh.Co,
    kh.SoThan,
    kh.ViTri,
    kh.SoDienThoai,
    kh.GB,
    kh.DM,
    kh.DMHN,
    dc.MaKyDoc,
    kd.Ky,
    kd.Nam,
    dc.ChiSoCu,
    dc.ChiSoMoi,
    dc.TieuThu,
    dc.MaCode,
    cd.TenCode,
    dc.TBTT,
    dc.TrangThai,
    dc.HinhAnh,
    dc.GhiChu,
    dc.TinhTrang,
    dc.NgayDoc,
    dc.NguoiDoc
FROM DocChiSo dc
JOIN KhachHang kh ON dc.MaDanhBo = kh.MaDanhBo
JOIN KyDoc kd ON dc.MaKyDoc = kd.MaKyDoc
LEFT JOIN DM_CodeDoc cd ON dc.MaCode = cd.MaCode;
GO

-- ============================================================================
-- VIEW 3: Báo cáo tiến độ đọc số theo lộ trình
-- ============================================================================
CREATE VIEW V_TienDo_LoTrinh
AS
SELECT 
    lt.MaLoTrinh,
    lt.TenLoTrinh,
    kd.MaKyDoc,
    kd.TenKyDoc,
    COUNT(*) AS TongSo,
    SUM(CASE WHEN dc.TrangThai >= 1 THEN 1 ELSE 0 END) AS DaDoc,
    SUM(CASE WHEN dc.TrangThai = 0 THEN 1 ELSE 0 END) AS ChuaDoc,
    CAST(SUM(CASE WHEN dc.TrangThai >= 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS PhanTramHoanThanh
FROM DocChiSo dc
JOIN KhachHang kh ON dc.MaDanhBo = kh.MaDanhBo
JOIN DM_LoTrinh lt ON kh.MaLoTrinh = lt.MaLoTrinh
JOIN KyDoc kd ON dc.MaKyDoc = kd.MaKyDoc
GROUP BY lt.MaLoTrinh, lt.TenLoTrinh, kd.MaKyDoc, kd.TenKyDoc;
GO

-- ============================================================================
-- VIEW 4: Lịch sử đọc số gần nhất (3 kỳ) cho từng khách hàng
-- ============================================================================
CREATE VIEW V_LichSu_3Ky
AS
SELECT *
FROM (
    SELECT 
        dc.MaDanhBo,
        kd.Ky,
        kd.Nam,
        dc.ChiSoCu,
        dc.ChiSoMoi,
        dc.TieuThu,
        dc.MaCode,
        dc.NgayDoc,
        ROW_NUMBER() OVER (PARTITION BY dc.MaDanhBo ORDER BY kd.Nam DESC, kd.Ky DESC) AS RowNum
    FROM DocChiSo dc
    JOIN KyDoc kd ON dc.MaKyDoc = kd.MaKyDoc
    WHERE dc.TrangThai >= 1
) sub
WHERE RowNum <= 3;
GO

-- ============================================================================
-- QUERY: Tạo dữ liệu đọc số cho kỳ mới
-- (Chạy đầu mỗi kỳ để tạo bản ghi cho tất cả khách hàng)
-- ============================================================================
CREATE PROCEDURE SP_TaoKyDocMoi
    @Ky INT,
    @Nam INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @MaKyDoc INT;
    
    -- Kiểm tra kỳ đã tồn tại chưa
    SELECT @MaKyDoc = MaKyDoc FROM KyDoc WHERE Ky = @Ky AND Nam = @Nam;
    
    IF @MaKyDoc IS NULL
    BEGIN
        -- Tạo kỳ mới
        INSERT INTO KyDoc (Ky, Nam, TenKyDoc, TrangThai)
        VALUES (@Ky, @Nam, CONCAT(N'Kỳ ', RIGHT('0' + CAST(@Ky AS VARCHAR), 2), '/', @Nam), N'Mở');
        
        SET @MaKyDoc = SCOPE_IDENTITY();
    END
    
    -- Tạo bản ghi đọc số cho tất cả khách hàng đang hoạt động
    INSERT INTO DocChiSo (MaDanhBo, MaKyDoc, ChiSoCu, MaCode, TrangThai)
    SELECT 
        kh.MaDanhBo,
        @MaKyDoc,
        -- Lấy chỉ số mới của kỳ trước làm chỉ số cũ
        ISNULL(dcPrev.ChiSoMoi, 0),
        '40', -- Mặc định bình thường
        0     -- Chưa đọc
    FROM KhachHang kh
    LEFT JOIN (
        -- Lấy chỉ số mới nhất
        SELECT MaDanhBo, ChiSoMoi,
               ROW_NUMBER() OVER (PARTITION BY MaDanhBo ORDER BY MaKyDoc DESC) AS rn
        FROM DocChiSo WHERE TrangThai >= 1
    ) dcPrev ON kh.MaDanhBo = dcPrev.MaDanhBo AND dcPrev.rn = 1
    WHERE kh.TrangThai = N'Đang sử dụng'
      AND NOT EXISTS (
          SELECT 1 FROM DocChiSo WHERE MaDanhBo = kh.MaDanhBo AND MaKyDoc = @MaKyDoc
      );
    
    SELECT @MaKyDoc AS MaKyDoc, @@ROWCOUNT AS SoKhachHangTao;
END
GO

-- ============================================================================
-- QUERY: Export dữ liệu đọc số ra dạng bảng (cho xuất CSV)
-- ============================================================================
CREATE PROCEDURE SP_ExportDocSo
    @MaKyDoc INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        kh.MaDanhBo,
        kh.HoTen,
        kh.DiaChi,
        dc.ChiSoCu,
        dc.ChiSoMoi,
        dc.TieuThu,
        dc.MaCode,
        kh.MaLoTrinh,
        kh.Hieu,
        kh.Co,
        kh.SoThan,
        kh.ViTri,
        kh.GB,
        kh.DM,
        kh.DMHN,
        dc.TBTT,
        kh.SoDienThoai,
        dc.GhiChu,
        dc.TinhTrang,
        dc.NgayDoc
    FROM DocChiSo dc
    JOIN KhachHang kh ON dc.MaDanhBo = kh.MaDanhBo
    WHERE dc.MaKyDoc = @MaKyDoc
    ORDER BY kh.MaLoTrinh, kh.MaDanhBo;
END
GO

PRINT N'✅ Views và Stored Procedures bổ sung đã tạo thành công!';
GO

-- ============================================================================
-- DATABASE: QUẢN LÝ ĐỌC CHỈ SỐ ĐỒNG HỒ NƯỚC - CẤP NƯỚC TÂN HÒA
-- Version: 1.0
-- Created: 2026-02-10
-- Description: Script tạo database quản lý đọc số đồng hồ nước
--              Chạy trên SQL Server Management Studio (SSMS)
-- ============================================================================

-- ======================== TẠO DATABASE ========================
USE master;
GO

-- Xóa database cũ nếu tồn tại (CHÚ Ý: chỉ dùng khi phát triển)
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'DONGHONUOC')
BEGIN
    ALTER DATABASE DONGHONUOC SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DONGHONUOC;
END
GO

CREATE DATABASE DONGHONUOC
COLLATE Vietnamese_CI_AS;  -- Hỗ trợ tiếng Việt, không phân biệt hoa thường
GO

USE DONGHONUOC;
GO

-- ============================================================================
-- 1. BẢNG KHU VỰC (DM_KhuVuc)
--    Quản lý các khu vực cấp nước (Quận, Phường)
-- ============================================================================
CREATE TABLE DM_KhuVuc (
    MaKhuVuc        VARCHAR(20)     PRIMARY KEY,
    TenKhuVuc       NVARCHAR(100)   NOT NULL,
    MaQuanHuyen     VARCHAR(10)     NULL,
    TenQuanHuyen    NVARCHAR(100)   NULL,
    MaPhuongXa      VARCHAR(10)     NULL,
    TenPhuongXa     NVARCHAR(100)   NULL,
    TrangThai       BIT             DEFAULT 1,         -- 1=Hoạt động, 0=Không hoạt động
    NgayTao         DATETIME        DEFAULT GETDATE(),
    NgayCapNhat     DATETIME        DEFAULT GETDATE()
);
GO

-- ============================================================================
-- 2. BẢNG LỘ TRÌNH (DM_LoTrinh)
--    Quản lý các lộ trình đọc số, mỗi lộ trình thuộc 1 khu vực
-- ============================================================================
CREATE TABLE DM_LoTrinh (
    MaLoTrinh       VARCHAR(20)     PRIMARY KEY,
    TenLoTrinh      NVARCHAR(200)   NOT NULL,
    MaKhuVuc        VARCHAR(20)     NULL,
    MoTa            NVARCHAR(500)   NULL,
    ThuTu           INT             DEFAULT 0,         -- Thứ tự sắp xếp
    TrangThai       BIT             DEFAULT 1,
    NgayTao         DATETIME        DEFAULT GETDATE(),
    NgayCapNhat     DATETIME        DEFAULT GETDATE(),

    CONSTRAINT FK_LoTrinh_KhuVuc FOREIGN KEY (MaKhuVuc) REFERENCES DM_KhuVuc(MaKhuVuc)
);
GO

-- ============================================================================
-- 3. BẢNG GIÁ BIỂU (DM_GiaBieu)
--    Danh mục các loại giá biểu nước
--    Giá biểu (GB) phân loại: Sinh hoạt, Kinh doanh, Sản xuất, Hành chính...
-- ============================================================================
CREATE TABLE DM_GiaBieu (
    MaGiaBieu       INT             PRIMARY KEY,
    TenGiaBieu      NVARCHAR(200)   NOT NULL,
    MoTa            NVARCHAR(500)   NULL,
    TrangThai       BIT             DEFAULT 1,
    NgayTao         DATETIME        DEFAULT GETDATE()
);
GO

-- ============================================================================
-- 4. BẢNG BẬC THANG GIÁ NƯỚC (GiaNuoc_BacThang)
--    Giá nước theo bậc thang cho từng giá biểu
--    Ví dụ: Sinh hoạt Bậc 1 (0-4m³) = 6,300đ, Bậc 2 (4-6m³) = 10,800đ...
-- ============================================================================
CREATE TABLE GiaNuoc_BacThang (
    ID              INT IDENTITY(1,1) PRIMARY KEY,
    MaGiaBieu       INT             NOT NULL,
    Bac             INT             NOT NULL,          -- Bậc 1, 2, 3, 4
    TuM3            DECIMAL(10,2)   NOT NULL,          -- Từ (m³)
    DenM3           DECIMAL(10,2)   NULL,              -- Đến (m³), NULL = không giới hạn
    DonGia          DECIMAL(18,2)   NOT NULL,          -- Đồng/m³
    NgayHieuLuc     DATE            NOT NULL,
    NgayHetHieuLuc  DATE            NULL,
    GhiChu          NVARCHAR(200)   NULL,

    CONSTRAINT FK_BacThang_GiaBieu FOREIGN KEY (MaGiaBieu) REFERENCES DM_GiaBieu(MaGiaBieu)
);
GO

-- ============================================================================
-- 5. BẢNG CODE ĐỌC SỐ (DM_CodeDoc)
--    Danh mục mã code trạng thái khi đọc đồng hồ
--    Code 40 = Bình thường, F = Hỏng, 6 = Khóa nước, 10 = Ngược, 20 = Nhà trống
-- ============================================================================
CREATE TABLE DM_CodeDoc (
    MaCode          VARCHAR(10)     PRIMARY KEY,
    TenCode         NVARCHAR(100)   NOT NULL,
    MoTa            NVARCHAR(300)   NULL,
    MauSac          VARCHAR(20)     NULL,              -- Mã màu hiển thị trên app (hex)
    TrangThai       BIT             DEFAULT 1
);
GO

-- ============================================================================
-- 6. BẢNG LOẠI ĐỒNG HỒ (DM_LoaiDongHo)
--    Danh mục hiệu/loại đồng hồ nước
-- ============================================================================
CREATE TABLE DM_LoaiDongHo (
    MaLoai          VARCHAR(20)     PRIMARY KEY,
    TenLoai         NVARCHAR(100)   NOT NULL,          -- VD: Actaris, Sensus, Zenner...
    MoTa            NVARCHAR(300)   NULL,
    NuocSanXuat     NVARCHAR(100)   NULL,
    TrangThai       BIT             DEFAULT 1
);
GO

-- ============================================================================
-- 7. BẢNG KHÁCH HÀNG (KhachHang)
--    Thông tin danh bộ khách hàng sử dụng nước
-- ============================================================================
CREATE TABLE KhachHang (
    MaDanhBo        VARCHAR(20)     PRIMARY KEY,       -- Mã danh bộ (số định danh chính)
    HoTen           NVARCHAR(200)   NOT NULL,          -- Họ tên chủ hộ
    DiaChi          NVARCHAR(500)   NULL,              -- Địa chỉ nhà
    DiaChiDHN       NVARCHAR(500)   NULL,              -- Địa chỉ đồng hồ nước (có thể khác địa chỉ nhà)
    SoDienThoai     VARCHAR(20)     NULL,
    Email           NVARCHAR(100)   NULL,
    CMND_CCCD       VARCHAR(20)     NULL,              -- Số CMND/CCCD
    
    -- Thông tin đồng hồ
    MaLoTrinh       VARCHAR(20)     NULL,              -- Mã lộ trình
    Hieu            VARCHAR(50)     NULL,              -- Hiệu đồng hồ (Actaris, Sensus...)
    Co              VARCHAR(10)     NULL,              -- Cỡ đồng hồ (15, 20, 25mm...)
    SoThan          VARCHAR(50)     NULL,              -- Số thân đồng hồ (serial number)
    ViTri           NVARCHAR(200)   NULL,              -- Vị trí lắp đặt đồng hồ
    NgayGan         DATE            NULL,              -- Ngày gắn/thay đồng hồ
    
    -- Thông tin giá biểu & định mức
    GB              INT             NULL,              -- Giá biểu áp dụng
    DM              INT             NULL,              -- Định mức (số m³/tháng)
    DMHN            INT             NULL,              -- Định mức hộ nghèo
    SoNhanKhau      INT             DEFAULT 1,         -- Số nhân khẩu (ảnh hưởng định mức)
    
    -- Trạng thái
    TrangThai       NVARCHAR(50)    DEFAULT N'Đang sử dụng', -- Đang sử dụng, Tạm ngưng, Hủy
    GhiChu          NVARCHAR(500)   NULL,
    
    NgayDangKy      DATETIME        DEFAULT GETDATE(),
    NgayCapNhat     DATETIME        DEFAULT GETDATE(),

    CONSTRAINT FK_KH_LoTrinh FOREIGN KEY (MaLoTrinh) REFERENCES DM_LoTrinh(MaLoTrinh),
    CONSTRAINT FK_KH_GiaBieu FOREIGN KEY (GB) REFERENCES DM_GiaBieu(MaGiaBieu)
);
GO

-- ============================================================================
-- 8. BẢNG KỲ ĐỌC (KyDoc)
--    Quản lý các kỳ đọc số (tháng/năm)
-- ============================================================================
CREATE TABLE KyDoc (
    MaKyDoc         INT IDENTITY(1,1) PRIMARY KEY,
    Ky              INT             NOT NULL,          -- Tháng (1-12)
    Nam             INT             NOT NULL,          -- Năm
    TenKyDoc        NVARCHAR(50)    NULL,              -- VD: "Kỳ 01/2026"
    NgayBatDau      DATE            NULL,              -- Ngày bắt đầu đọc
    NgayKetThuc     DATE            NULL,              -- Ngày kết thúc đọc
    TrangThai       NVARCHAR(20)    DEFAULT N'Mở',     -- Mở, Đang đọc, Đã đóng
    NgayTao         DATETIME        DEFAULT GETDATE(),

    CONSTRAINT UQ_KyDoc UNIQUE (Ky, Nam)
);
GO

-- ============================================================================
-- 9. BẢNG GHI CHỈ SỐ (DocChiSo)
--    Lưu kết quả đọc chỉ số nước theo từng kỳ
--    Đây là bảng CHÍNH của nghiệp vụ đọc số
-- ============================================================================
CREATE TABLE DocChiSo (
    ID              BIGINT IDENTITY(1,1) PRIMARY KEY,
    MaDanhBo        VARCHAR(20)     NOT NULL,
    MaKyDoc         INT             NOT NULL,
    
    -- Chỉ số
    ChiSoCu         INT             NOT NULL DEFAULT 0,  -- Chỉ số kỳ trước
    ChiSoMoi        INT             NULL,                -- Chỉ số kỳ này (NULL = chưa đọc)
    TieuThu         AS (CASE WHEN ChiSoMoi IS NOT NULL AND ChiSoMoi >= ChiSoCu 
                         THEN ChiSoMoi - ChiSoCu ELSE 0 END) PERSISTED, -- Tự tính
    
    -- Code trạng thái đọc
    MaCode          VARCHAR(10)     DEFAULT '40',        -- 40, F, 6, 10, 20...
    
    -- Thông tin bất thường
    TBTT            INT             DEFAULT 0,           -- Thông báo tiêu thụ (số lần)
    LoaiBatThuong   NVARCHAR(50)    NULL,                -- tang, giam, NULL = bình thường
    
    -- Hình ảnh & ghi chú
    HinhAnh         NVARCHAR(500)   NULL,                -- Đường dẫn ảnh chụp đồng hồ
    GhiChu          NVARCHAR(500)   NULL,
    TinhTrang       NVARCHAR(200)   NULL,                -- Tình trạng đồng hồ khi đọc
    
    -- Tracking
    TrangThai       INT             DEFAULT 0,           -- 0=Chưa đọc, 1=Đã đọc, 2=Đã xác nhận
    NgayDoc         DATETIME        NULL,                -- Thời điểm đọc
    NguoiDoc        VARCHAR(50)     NULL,                -- Username người đọc
    NgayCapNhat     DATETIME        DEFAULT GETDATE(),

    CONSTRAINT FK_DocCS_KhachHang FOREIGN KEY (MaDanhBo) REFERENCES KhachHang(MaDanhBo),
    CONSTRAINT FK_DocCS_KyDoc FOREIGN KEY (MaKyDoc) REFERENCES KyDoc(MaKyDoc),
    CONSTRAINT FK_DocCS_Code FOREIGN KEY (MaCode) REFERENCES DM_CodeDoc(MaCode),
    CONSTRAINT UQ_DocCS UNIQUE (MaDanhBo, MaKyDoc)  -- 1 khách hàng chỉ đọc 1 lần/kỳ
);
GO

-- ============================================================================
-- 10. BẢNG LỊCH SỬ ĐỌC SỐ (LichSuDocSo)
--     Log lại mọi thao tác đọc/sửa chỉ số (audit trail)
-- ============================================================================
CREATE TABLE LichSuDocSo (
    ID              BIGINT IDENTITY(1,1) PRIMARY KEY,
    MaDanhBo        VARCHAR(20)     NOT NULL,
    MaKyDoc         INT             NOT NULL,
    ChiSo           INT             NOT NULL,
    TieuThu         INT             NOT NULL,
    MaCode          VARCHAR(10)     DEFAULT '40',
    HanhDong        NVARCHAR(50)    NOT NULL,           -- 'DocMoi', 'SuaChiSo', 'XoaChiSo'
    NguoiThucHien   VARCHAR(50)     NULL,
    GhiChu          NVARCHAR(500)   NULL,
    ThoiGian        DATETIME        DEFAULT GETDATE(),

    CONSTRAINT FK_LichSu_KhachHang FOREIGN KEY (MaDanhBo) REFERENCES KhachHang(MaDanhBo),
    CONSTRAINT FK_LichSu_KyDoc FOREIGN KEY (MaKyDoc) REFERENCES KyDoc(MaKyDoc)
);
GO

-- ============================================================================
-- 11. BẢNG HÓA ĐƠN (HoaDon)
--     Tính tiền nước theo bậc thang
-- ============================================================================
CREATE TABLE HoaDon (
    MaHoaDon        BIGINT IDENTITY(1,1) PRIMARY KEY,
    MaDanhBo        VARCHAR(20)     NOT NULL,
    MaKyDoc         INT             NOT NULL,
    MaDocChiSo      BIGINT          NULL,               -- Liên kết với bảng DocChiSo
    
    -- Thông tin tiêu thụ
    TieuThu         INT             NOT NULL DEFAULT 0,
    
    -- Thành tiền
    TienNuoc        DECIMAL(18,2)   DEFAULT 0,           -- Tiền nước (chưa thuế)
    ThueVAT         DECIMAL(18,2)   DEFAULT 0,           -- Thuế VAT (5% hoặc 8%)
    PhiBVMT         DECIMAL(18,2)   DEFAULT 0,           -- Phí bảo vệ môi trường (10%)
    TongTien        DECIMAL(18,2)   DEFAULT 0,           -- Tổng tiền phải trả
    
    -- Thanh toán
    TrangThaiTT     NVARCHAR(20)    DEFAULT N'Chưa thu', -- Chưa thu, Đã thu, Quá hạn
    NgayThu         DATETIME        NULL,
    NguoiThu        VARCHAR(50)     NULL,
    
    NgayTao         DATETIME        DEFAULT GETDATE(),
    NgayCapNhat     DATETIME        DEFAULT GETDATE(),

    CONSTRAINT FK_HoaDon_KhachHang FOREIGN KEY (MaDanhBo) REFERENCES KhachHang(MaDanhBo),
    CONSTRAINT FK_HoaDon_KyDoc FOREIGN KEY (MaKyDoc) REFERENCES KyDoc(MaKyDoc),
    CONSTRAINT FK_HoaDon_DocCS FOREIGN KEY (MaDocChiSo) REFERENCES DocChiSo(ID)
);
GO

-- ============================================================================
-- 12. BẢNG CHI TIẾT HÓA ĐƠN (HoaDon_ChiTiet)
--     Chi tiết tính tiền theo từng bậc thang
-- ============================================================================
CREATE TABLE HoaDon_ChiTiet (
    ID              BIGINT IDENTITY(1,1) PRIMARY KEY,
    MaHoaDon        BIGINT          NOT NULL,
    Bac             INT             NOT NULL,
    SoM3            DECIMAL(10,2)   NOT NULL,            -- Số m³ trong bậc này
    DonGia          DECIMAL(18,2)   NOT NULL,
    ThanhTien       DECIMAL(18,2)   NOT NULL,

    CONSTRAINT FK_CTHD_HoaDon FOREIGN KEY (MaHoaDon) REFERENCES HoaDon(MaHoaDon)
);
GO

-- ============================================================================
-- 13. BẢNG LỊCH SỬ ĐỒNG HỒ (LichSuDongHo)
--     Theo dõi lịch sử thay/sửa đồng hồ
-- ============================================================================
CREATE TABLE LichSuDongHo (
    ID              INT IDENTITY(1,1) PRIMARY KEY,
    MaDanhBo        VARCHAR(20)     NOT NULL,
    LoaiThayDoi     NVARCHAR(50)    NOT NULL,           -- 'GanMoi', 'ThayThe', 'ThaoDo', 'SuaChua'
    SoThanCu        VARCHAR(50)     NULL,
    SoThanMoi       VARCHAR(50)     NULL,
    HieuCu          VARCHAR(50)     NULL,
    HieuMoi         VARCHAR(50)     NULL,
    CoCu            VARCHAR(10)     NULL,
    CoMoi           VARCHAR(10)     NULL,
    ChiSoThaoDo     INT             NULL,               -- Chỉ số lúc tháo đồng hồ cũ
    ChiSoGanMoi     INT             DEFAULT 0,          -- Chỉ số ban đầu đồng hồ mới
    NgayThayDoi     DATE            NOT NULL,
    LyDo            NVARCHAR(500)   NULL,
    NguoiThucHien   VARCHAR(50)     NULL,
    GhiChu          NVARCHAR(500)   NULL,
    NgayTao         DATETIME        DEFAULT GETDATE(),

    CONSTRAINT FK_LSDH_KhachHang FOREIGN KEY (MaDanhBo) REFERENCES KhachHang(MaDanhBo)
);
GO

-- ============================================================================
-- 14. BẢNG NGƯỜI DÙNG (NguoiDung)
--     Quản lý tài khoản đăng nhập app/hệ thống
-- ============================================================================
CREATE TABLE NguoiDung (
    MaNguoiDung     INT IDENTITY(1,1) PRIMARY KEY,
    Username        VARCHAR(50)     UNIQUE NOT NULL,
    PasswordHash    VARCHAR(256)    NOT NULL,            -- Mật khẩu đã hash (SHA-256)
    HoTen           NVARCHAR(100)   NOT NULL,
    SoDienThoai     VARCHAR(20)     NULL,
    Email           NVARCHAR(100)   NULL,
    VaiTro          NVARCHAR(50)    DEFAULT N'NhanVien', -- Admin, QuanLy, NhanVien
    MaKhuVuc        VARCHAR(20)     NULL,                -- Khu vực phụ trách
    TrangThai       BIT             DEFAULT 1,           -- 1=Hoạt động, 0=Khóa
    NgayTao         DATETIME        DEFAULT GETDATE(),
    LanDangNhapCuoi DATETIME        NULL,

    CONSTRAINT FK_ND_KhuVuc FOREIGN KEY (MaKhuVuc) REFERENCES DM_KhuVuc(MaKhuVuc)
);
GO

-- ============================================================================
-- 15. BẢNG PHÂN CÔNG ĐỌC SỐ (PhanCongDoc)
--     Phân công nhân viên đọc số theo lộ trình và kỳ
-- ============================================================================
CREATE TABLE PhanCongDoc (
    ID              INT IDENTITY(1,1) PRIMARY KEY,
    MaKyDoc         INT             NOT NULL,
    MaLoTrinh       VARCHAR(20)     NOT NULL,
    MaNguoiDoc      INT             NOT NULL,            -- Nhân viên được phân công
    NgayPhanCong    DATETIME        DEFAULT GETDATE(),
    TrangThai       NVARCHAR(20)    DEFAULT N'Chưa đọc', -- Chưa đọc, Đang đọc, Hoàn thành
    GhiChu          NVARCHAR(500)   NULL,

    CONSTRAINT FK_PC_KyDoc FOREIGN KEY (MaKyDoc) REFERENCES KyDoc(MaKyDoc),
    CONSTRAINT FK_PC_LoTrinh FOREIGN KEY (MaLoTrinh) REFERENCES DM_LoTrinh(MaLoTrinh),
    CONSTRAINT FK_PC_NguoiDung FOREIGN KEY (MaNguoiDoc) REFERENCES NguoiDung(MaNguoiDung),
    CONSTRAINT UQ_PhanCong UNIQUE (MaKyDoc, MaLoTrinh)
);
GO

-- ============================================================================
--                         TẠO CÁC INDEX
-- ============================================================================
-- Index cho bảng KhachHang
CREATE INDEX IX_KhachHang_MaLoTrinh ON KhachHang(MaLoTrinh);
CREATE INDEX IX_KhachHang_GB ON KhachHang(GB);
CREATE INDEX IX_KhachHang_HoTen ON KhachHang(HoTen);

-- Index cho bảng DocChiSo
CREATE INDEX IX_DocCS_MaDanhBo ON DocChiSo(MaDanhBo);
CREATE INDEX IX_DocCS_MaKyDoc ON DocChiSo(MaKyDoc);
CREATE INDEX IX_DocCS_TrangThai ON DocChiSo(TrangThai);
CREATE INDEX IX_DocCS_NgayDoc ON DocChiSo(NgayDoc);

-- Index cho bảng HoaDon
CREATE INDEX IX_HoaDon_MaDanhBo ON HoaDon(MaDanhBo);
CREATE INDEX IX_HoaDon_MaKyDoc ON HoaDon(MaKyDoc);
CREATE INDEX IX_HoaDon_TrangThaiTT ON HoaDon(TrangThaiTT);

-- Index cho bảng LichSuDocSo
CREATE INDEX IX_LichSu_MaDanhBo ON LichSuDocSo(MaDanhBo);
CREATE INDEX IX_LichSu_ThoiGian ON LichSuDocSo(ThoiGian);
GO

-- ============================================================================
--                     STORED PROCEDURES
-- ============================================================================

-- SP1: Tính tiền nước theo bậc thang
CREATE PROCEDURE SP_TinhTienNuoc
    @MaDanhBo VARCHAR(20),
    @MaKyDoc INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TieuThu INT, @GB INT, @TienNuoc DECIMAL(18,2) = 0;
    DECLARE @VAT DECIMAL(18,2), @PhiBVMT DECIMAL(18,2), @Tong DECIMAL(18,2);
    DECLARE @MaDocCS BIGINT, @MaHoaDon BIGINT;
    
    -- Lấy thông tin tiêu thụ
    SELECT @MaDocCS = ID, @TieuThu = TieuThu
    FROM DocChiSo 
    WHERE MaDanhBo = @MaDanhBo AND MaKyDoc = @MaKyDoc AND TrangThai >= 1;
    
    IF @MaDocCS IS NULL
    BEGIN
        RAISERROR(N'Chưa có dữ liệu đọc số cho khách hàng này trong kỳ', 16, 1);
        RETURN;
    END
    
    -- Lấy giá biểu khách hàng
    SELECT @GB = GB FROM KhachHang WHERE MaDanhBo = @MaDanhBo;
    IF @GB IS NULL SET @GB = 1; -- Mặc định sinh hoạt
    
    -- Tính tiền theo bậc thang
    DECLARE @ConLai INT = @TieuThu;
    DECLARE @Bac INT, @Tu DECIMAL(10,2), @Den DECIMAL(10,2), @Gia DECIMAL(18,2);
    DECLARE @SoM3Bac DECIMAL(10,2), @ThanhTienBac DECIMAL(18,2);
    
    -- Xóa hóa đơn cũ nếu có
    DELETE FROM HoaDon_ChiTiet WHERE MaHoaDon IN (
        SELECT MaHoaDon FROM HoaDon WHERE MaDanhBo = @MaDanhBo AND MaKyDoc = @MaKyDoc
    );
    DELETE FROM HoaDon WHERE MaDanhBo = @MaDanhBo AND MaKyDoc = @MaKyDoc;
    
    -- Tạo hóa đơn mới
    INSERT INTO HoaDon (MaDanhBo, MaKyDoc, MaDocChiSo, TieuThu)
    VALUES (@MaDanhBo, @MaKyDoc, @MaDocCS, @TieuThu);
    SET @MaHoaDon = SCOPE_IDENTITY();
    
    -- Duyệt qua các bậc thang
    DECLARE cur CURSOR FOR
        SELECT Bac, TuM3, DenM3, DonGia
        FROM GiaNuoc_BacThang
        WHERE MaGiaBieu = @GB 
          AND NgayHieuLuc <= GETDATE()
          AND (NgayHetHieuLuc IS NULL OR NgayHetHieuLuc >= GETDATE())
        ORDER BY Bac;
    
    OPEN cur;
    FETCH NEXT FROM cur INTO @Bac, @Tu, @Den, @Gia;
    
    WHILE @@FETCH_STATUS = 0 AND @ConLai > 0
    BEGIN
        IF @Den IS NULL
            SET @SoM3Bac = @ConLai;
        ELSE
            SET @SoM3Bac = CASE WHEN @ConLai > (@Den - @Tu) THEN (@Den - @Tu) ELSE @ConLai END;
        
        SET @ThanhTienBac = @SoM3Bac * @Gia;
        SET @TienNuoc = @TienNuoc + @ThanhTienBac;
        SET @ConLai = @ConLai - @SoM3Bac;
        
        -- Lưu chi tiết
        INSERT INTO HoaDon_ChiTiet (MaHoaDon, Bac, SoM3, DonGia, ThanhTien)
        VALUES (@MaHoaDon, @Bac, @SoM3Bac, @Gia, @ThanhTienBac);
        
        FETCH NEXT FROM cur INTO @Bac, @Tu, @Den, @Gia;
    END
    
    CLOSE cur;
    DEALLOCATE cur;
    
    -- Tính VAT (5%) và Phí BVMT (10%)
    SET @VAT = @TienNuoc * 0.05;
    SET @PhiBVMT = @TienNuoc * 0.10;
    SET @Tong = @TienNuoc + @VAT + @PhiBVMT;
    
    -- Cập nhật hóa đơn
    UPDATE HoaDon
    SET TienNuoc = @TienNuoc,
        ThueVAT = @VAT,
        PhiBVMT = @PhiBVMT,
        TongTien = @Tong
    WHERE MaHoaDon = @MaHoaDon;
    
    -- Trả kết quả
    SELECT @MaHoaDon AS MaHoaDon, @TieuThu AS TieuThu, 
           @TienNuoc AS TienNuoc, @VAT AS ThueVAT, 
           @PhiBVMT AS PhiBVMT, @Tong AS TongTien;
END
GO

-- SP2: Phát hiện bất thường (tiêu thụ tăng/giảm đột ngột)
CREATE PROCEDURE SP_PhatHienBatThuong
    @MaKyDoc INT,
    @NguongTang FLOAT = 1.5,     -- Tăng > 150% so với trung bình
    @NguongGiam FLOAT = 0.5      -- Giảm < 50% so với trung bình
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        dc.MaDanhBo,
        kh.HoTen,
        kh.DiaChi,
        kh.MaLoTrinh,
        dc.ChiSoCu,
        dc.ChiSoMoi,
        dc.TieuThu AS TieuThuHienTai,
        tb.TrungBinh3Ky,
        CASE 
            WHEN dc.TieuThu > tb.TrungBinh3Ky * @NguongTang THEN N'TĂNG ĐỘT NGỘT'
            WHEN dc.TieuThu < tb.TrungBinh3Ky * @NguongGiam THEN N'GIẢM ĐỘT NGỘT'
        END AS LoaiBatThuong
    FROM DocChiSo dc
    JOIN KhachHang kh ON dc.MaDanhBo = kh.MaDanhBo
    CROSS APPLY (
        SELECT AVG(CAST(dcOld.TieuThu AS FLOAT)) AS TrungBinh3Ky
        FROM DocChiSo dcOld
        WHERE dcOld.MaDanhBo = dc.MaDanhBo
          AND dcOld.MaKyDoc < @MaKyDoc
          AND dcOld.TrangThai >= 1
          AND dcOld.TieuThu > 0
    ) tb
    WHERE dc.MaKyDoc = @MaKyDoc
      AND dc.TrangThai >= 1
      AND dc.TieuThu > 0
      AND tb.TrungBinh3Ky > 0
      AND (dc.TieuThu > tb.TrungBinh3Ky * @NguongTang 
           OR dc.TieuThu < tb.TrungBinh3Ky * @NguongGiam);
END
GO

-- SP3: Thống kê kỳ đọc
CREATE PROCEDURE SP_ThongKeKyDoc
    @MaKyDoc INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        (SELECT COUNT(*) FROM DocChiSo WHERE MaKyDoc = @MaKyDoc) AS TongSo,
        (SELECT COUNT(*) FROM DocChiSo WHERE MaKyDoc = @MaKyDoc AND TrangThai >= 1) AS DaDoc,
        (SELECT COUNT(*) FROM DocChiSo WHERE MaKyDoc = @MaKyDoc AND TrangThai = 0) AS ChuaDoc,
        (SELECT COUNT(*) FROM DocChiSo WHERE MaKyDoc = @MaKyDoc AND MaCode = 'F') AS DongHoHong,
        (SELECT COUNT(*) FROM DocChiSo WHERE MaKyDoc = @MaKyDoc AND MaCode = '6') AS KhoaNuoc,
        (SELECT COUNT(*) FROM DocChiSo WHERE MaKyDoc = @MaKyDoc AND MaCode = '20') AS NhaTrong,
        (SELECT SUM(TieuThu) FROM DocChiSo WHERE MaKyDoc = @MaKyDoc AND TrangThai >= 1) AS TongTieuThu,
        (SELECT AVG(CAST(TieuThu AS FLOAT)) FROM DocChiSo WHERE MaKyDoc = @MaKyDoc AND TrangThai >= 1 AND TieuThu > 0) AS TrungBinhTieuThu;
END
GO

-- ============================================================================
--                     INSERT DỮ LIỆU MẪU
-- ============================================================================

-- Dữ liệu danh mục Code đọc số
INSERT INTO DM_CodeDoc (MaCode, TenCode, MoTa, MauSac) VALUES
('40', N'Bình thường',     N'Đồng hồ hoạt động bình thường',    '#4CAF50'),
('F',  N'Đồng hồ hỏng',   N'Đồng hồ bị hỏng, không đọc được',  '#F44336'),
('6',  N'Khóa nước',       N'Khóa nước do nợ hoặc yêu cầu',     '#FF9800'),
('10', N'Đồng hồ ngược',   N'Đồng hồ chạy ngược, cần kiểm tra', '#9C27B0'),
('20', N'Nhà trống',       N'Nhà không có người ở',              '#607D8B'),
('30', N'Không vào được',  N'Không vào được nhà khách hàng',     '#795548'),
('50', N'Chủ báo',         N'Khách hàng tự báo chỉ số',         '#2196F3'),
('60', N'Tạm tính',        N'Tạm tính theo bình quân 3 kỳ',     '#FF5722');
GO

-- Dữ liệu danh mục Giá biểu
INSERT INTO DM_GiaBieu (MaGiaBieu, TenGiaBieu, MoTa) VALUES
(1, N'Sinh hoạt',                    N'Giá nước sinh hoạt hộ gia đình'),
(2, N'Cơ quan hành chính',           N'Giá nước cơ quan, đơn vị sự nghiệp'),
(3, N'Sản xuất',                     N'Giá nước cho sản xuất'),
(4, N'Kinh doanh dịch vụ',           N'Giá nước cho kinh doanh, dịch vụ'),
(5, N'Hộ nghèo, cận nghèo',         N'Giá nước ưu đãi cho hộ nghèo/cận nghèo');
GO

-- Bậc thang giá nước sinh hoạt (TP.HCM - tham khảo)
INSERT INTO GiaNuoc_BacThang (MaGiaBieu, Bac, TuM3, DenM3, DonGia, NgayHieuLuc, GhiChu) VALUES
-- Sinh hoạt
(1, 1, 0,  4,   6300,  '2024-01-01', N'Bậc 1: 0-4 m³/người/tháng'),
(1, 2, 4,  6,   10800, '2024-01-01', N'Bậc 2: >4-6 m³/người/tháng'),
(1, 3, 6,  10,  12500, '2024-01-01', N'Bậc 3: >6-10 m³/người/tháng'),
(1, 4, 10, NULL, 18400, '2024-01-01', N'Bậc 4: >10 m³/người/tháng'),
-- Hộ nghèo
(5, 1, 0,  4,   6300,  '2024-01-01', N'Bậc 1: 0-4 m³ (hộ nghèo)'),
(5, 2, 4,  NULL, 6300,  '2024-01-01', N'Bậc 2: trên 4 m³ (hộ nghèo - ưu đãi)');
GO

-- Dữ liệu mẫu Khu vực
INSERT INTO DM_KhuVuc (MaKhuVuc, TenKhuVuc, MaQuanHuyen, TenQuanHuyen) VALUES
('KV01', N'Khu vực 1 - Tân Bình',   'TB', N'Quận Tân Bình'),
('KV02', N'Khu vực 2 - Tân Phú',    'TP', N'Quận Tân Phú'),
('KV03', N'Khu vực 3 - Phú Nhuận',  'PN', N'Quận Phú Nhuận');
GO

-- Dữ liệu mẫu Lộ trình
INSERT INTO DM_LoTrinh (MaLoTrinh, TenLoTrinh, MaKhuVuc, ThuTu) VALUES
('LT001', N'Lộ trình 001 - Đường Cộng Hòa',     'KV01', 1),
('LT002', N'Lộ trình 002 - Đường Hoàng Văn Thụ', 'KV01', 2),
('LT003', N'Lộ trình 003 - Đường Lũy Bán Bích',  'KV02', 1);
GO

-- Dữ liệu mẫu Loại đồng hồ
INSERT INTO DM_LoaiDongHo (MaLoai, TenLoai, NuocSanXuat) VALUES
('ACT', N'Actaris',  N'Pháp'),
('SEN', N'Sensus',   N'Đức'),
('ZEN', N'Zenner',   N'Đức'),
('WS',  N'Wasser',   N'Trung Quốc'),
('DN',  N'Đại Nước', N'Việt Nam');
GO

-- Dữ liệu mẫu Người dùng (password hash = SHA-256 của '123456')
INSERT INTO NguoiDung (Username, PasswordHash, HoTen, VaiTro, MaKhuVuc) VALUES
('admin',    '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', N'Quản trị viên', N'Admin', NULL),
('nvdocso1', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', N'Nguyễn Văn A',  N'NhanVien', 'KV01'),
('nvdocso2', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', N'Trần Thị B',   N'NhanVien', 'KV02');
GO

-- Dữ liệu mẫu Kỳ đọc
INSERT INTO KyDoc (Ky, Nam, TenKyDoc, NgayBatDau, NgayKetThuc, TrangThai) VALUES
(1, 2026, N'Kỳ 01/2026', '2026-01-01', '2026-01-31', N'Đã đóng'),
(2, 2026, N'Kỳ 02/2026', '2026-02-01', '2026-02-28', N'Đang đọc');
GO

-- Dữ liệu mẫu Khách hàng
INSERT INTO KhachHang (MaDanhBo, HoTen, DiaChi, DiaChiDHN, SoDienThoai, MaLoTrinh, Hieu, Co, SoThan, ViTri, NgayGan, GB, DM, SoNhanKhau) VALUES
('DB001', N'Nguyễn Văn Minh', N'123 Cộng Hòa, P.4, Q.Tân Bình', N'123 Cộng Hòa', '0901234567', 'LT001', 'Actaris', '15', 'TH001', N'Cổng chính', '2023-05-15', 1, 16, 4),
('DB002', N'Trần Thị Lan',    N'456 Hoàng Văn Thụ, P.2, Q.Tân Bình', N'456 HVT', '0912345678', 'LT002', 'Sensus',  '15', 'TH002', N'Hẻm trái',   '2022-08-20', 1, 16, 3),
('DB003', N'Lê Hoàng Nam',    N'789 Lũy Bán Bích, P.Hòa Thạnh, Q.Tân Phú', N'789 LBB', '0923456789', 'LT003', 'Zenner',  '20', 'TH003', N'Trước nhà',  '2024-01-10', 1, 24, 6),
('DB004', N'Phạm Thị Hương',  N'101 Cộng Hòa, P.4, Q.Tân Bình', N'101 Cộng Hòa', '0934567890', 'LT001', 'Actaris', '15', 'TH004', N'Cổng phụ',   '2023-11-01', 5, 16, 2),
('DB005', N'Võ Minh Tuấn',    N'202 Hoàng Văn Thụ, P.2, Q.Tân Bình', N'202 HVT', '0945678901', 'LT002', 'Wasser',  '15', 'TH005', N'Vỉa hè',     '2024-06-15', 4, 0, 0);
GO

-- Dữ liệu mẫu DocChiSo - Kỳ 01/2026 (đã hoàn thành)
INSERT INTO DocChiSo (MaDanhBo, MaKyDoc, ChiSoCu, ChiSoMoi, MaCode, TrangThai, NgayDoc, NguoiDoc) VALUES
('DB001', 1, 5577, 5862, '40', 1, '2026-01-15', 'nvdocso1'),
('DB002', 1, 3200, 3480, '40', 1, '2026-01-15', 'nvdocso1'),
('DB003', 1, 12050, 12400, '40', 1, '2026-01-16', 'nvdocso2'),
('DB004', 1, 1500, 1520, '40', 1, '2026-01-15', 'nvdocso1'),
('DB005', 1, 8900, 8900, '6',  1, '2026-01-16', 'nvdocso2');
GO

-- Dữ liệu mẫu DocChiSo - Kỳ 02/2026 (đang đọc)
INSERT INTO DocChiSo (MaDanhBo, MaKyDoc, ChiSoCu, ChiSoMoi, MaCode, TrangThai, NgayDoc, NguoiDoc) VALUES
('DB001', 2, 5862, NULL,  '40', 0, NULL, NULL),       -- Chưa đọc
('DB002', 2, 3480, 3750,  '40', 1, '2026-02-10', 'nvdocso1'), -- Đã đọc
('DB003', 2, 12400, NULL, '40', 0, NULL, NULL),        -- Chưa đọc
('DB004', 2, 1520, 1535,  '40', 1, '2026-02-10', 'nvdocso1'), -- Đã đọc
('DB005', 2, 8900, NULL,  '6',  0, NULL, NULL);        -- Chưa đọc, vẫn khóa
GO

PRINT N'';
PRINT N'============================================';
PRINT N'  ✅ DATABASE DONGHONUOC CREATED SUCCESSFULLY';
PRINT N'  📊 15 Tables, 3 Stored Procedures';
PRINT N'  📋 Sample data inserted';
PRINT N'============================================';
GO

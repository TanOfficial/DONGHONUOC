IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
CREATE TABLE [DocSo] (
    [DocSoID] nvarchar(450) NOT NULL,
    [DanhBa] nvarchar(max) NOT NULL,
    [Nam] int NULL,
    [Ky] nvarchar(max) NULL,
    [CSCu] int NULL,
    [CSMoi] int NULL,
    [TieuThuMoi] int NULL,
    [CodeMoi] nvarchar(max) NULL,
    [TBTT] int NULL,
    [HinhAnh] nvarchar(max) NULL,
    [GhiChuDS] nvarchar(max) NULL,
    [TrangThai_API] int NULL,
    [GIOGHI] datetime2 NULL,
    [NVGHI] nvarchar(max) NULL,
    [SoNhaMoi] nvarchar(max) NULL,
    [SDT] nvarchar(max) NULL,
    [GB] nvarchar(max) NULL,
    [DM] nvarchar(max) NULL,
    [Dot] nvarchar(max) NULL,
    [HieuMoi] nvarchar(max) NULL,
    [CoMoi] nvarchar(max) NULL,
    [SoThanMoi] nvarchar(max) NULL,
    [ViTriMoi] nvarchar(max) NULL,
    [DMHN] int NULL,
    CONSTRAINT [PK_DocSo] PRIMARY KEY ([DocSoID])
);

CREATE TABLE [Lich_DocSo] (
    [ID] int NOT NULL IDENTITY,
    [Ky] int NOT NULL,
    [Nam] int NOT NULL,
    [TuNgay] datetime2 NULL,
    [DenNgay] datetime2 NULL,
    CONSTRAINT [PK_Lich_DocSo] PRIMARY KEY ([ID])
);

CREATE TABLE [LichSuDocSo] (
    [ID] int NOT NULL IDENTITY,
    [MaDanhBo] nvarchar(max) NOT NULL,
    [MaKyDoc] int NOT NULL,
    [ChiSo] int NOT NULL,
    [TieuThu] int NOT NULL,
    [MaCode] nvarchar(max) NOT NULL,
    [HanhDong] nvarchar(max) NOT NULL,
    [NguoiThucHien] nvarchar(max) NULL,
    [GhiChu] nvarchar(max) NULL,
    [ThoiGian] datetime2 NOT NULL,
    CONSTRAINT [PK_LichSuDocSo] PRIMARY KEY ([ID])
);

CREATE TABLE [NguoiDungB] (
    [MaND] int NOT NULL IDENTITY,
    [Username] nvarchar(max) NOT NULL,
    [PasswordHash] nvarchar(max) NOT NULL,
    [HoTen] nvarchar(max) NOT NULL,
    [DienThoai] nvarchar(max) NULL,
    [ChucVu] nvarchar(max) NULL,
    [Khoa] bit NULL,
    [Avatar] nvarchar(max) NULL,
    CONSTRAINT [PK_NguoiDungB] PRIMARY KEY ([MaND])
);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260318025833_InitialCreate', N'9.0.0');

COMMIT;
GO


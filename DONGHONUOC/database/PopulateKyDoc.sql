SET IDENTITY_INSERT KyDoc ON;

IF NOT EXISTS (SELECT * FROM KyDoc WHERE MaKyDoc = 202312)
INSERT INTO KyDoc (MaKyDoc, Ky, Nam, TenKyDoc, NgayBatDau, NgayKetThuc, TrangThai) 
VALUES (202312, 12, 2023, N'Kỳ 12/2023', '2023-12-01', '2023-12-31', N'Đã đóng');

IF NOT EXISTS (SELECT * FROM KyDoc WHERE MaKyDoc = 202401)
INSERT INTO KyDoc (MaKyDoc, Ky, Nam, TenKyDoc, NgayBatDau, NgayKetThuc, TrangThai) 
VALUES (202401, 1, 2024, N'Kỳ 01/2024', '2024-01-01', '2024-01-31', N'Đã đóng');

IF NOT EXISTS (SELECT * FROM KyDoc WHERE MaKyDoc = 202402)
INSERT INTO KyDoc (MaKyDoc, Ky, Nam, TenKyDoc, NgayBatDau, NgayKetThuc, TrangThai) 
VALUES (202402, 2, 2024, N'Kỳ 02/2024', '2024-02-01', '2024-02-29', N'Đã đóng');

SET IDENTITY_INSERT KyDoc OFF;

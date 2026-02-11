namespace DONGHONUOC_API.Models
{
    // ====== Request DTOs ======
    public class LoginRequest
    {
        public string Username { get; set; } = "";
        public string Password { get; set; } = "";
    }

    public class RegisterRequest
    {
        public string Username { get; set; } = "";
        public string Password { get; set; } = "";
        public string HoTen { get; set; } = "";
    }

    public class GhiChiSoRequest
    {
        public string MaDanhBo { get; set; } = "";
        public int MaKyDoc { get; set; }
        public int ChiSoMoi { get; set; }
        public string MaCode { get; set; } = "40";
        public string? GhiChu { get; set; }
        public string? TinhTrang { get; set; }
        public string? HinhAnh { get; set; }
        public string? NguoiDoc { get; set; }
    }

    public class CapNhatCodeRequest
    {
        public string MaDanhBo { get; set; } = "";
        public int MaKyDoc { get; set; }
        public string MaCode { get; set; } = "40";
    }

    public class CapNhatGhiChuRequest
    {
        public string MaDanhBo { get; set; } = "";
        public int MaKyDoc { get; set; }
        public string GhiChu { get; set; } = "";
    }

    public class CapNhatHinhAnhRequest
    {
        public string MaDanhBo { get; set; } = "";
        public int MaKyDoc { get; set; }
        public string HinhAnh { get; set; } = "";
    }

    public class ResetDocSoRequest
    {
        public string MaDanhBo { get; set; } = "";
        public int MaKyDoc { get; set; }
    }

    // ====== Response DTOs ======
    public class LoginResponse
    {
        public bool Success { get; set; }
        public string? Message { get; set; }
        public string? Username { get; set; }
        public string? HoTen { get; set; }
        public string? VaiTro { get; set; }
        public string? Avatar { get; set; }
    }

    public class UpdateAvatarRequest
    {
        public string Username { get; set; } = "";
        public string AvatarBase64 { get; set; } = "";
    }

    public class ThongKeResponse
    {
        public int TongSo { get; set; }
        public int DaDoc { get; set; }
        public int ChuaDoc { get; set; }
        public int DongHoHong { get; set; }
        public int KhoaNuoc { get; set; }
        public int NhaTrong { get; set; }
        public int TongTieuThu { get; set; }
        public double TrungBinhTieuThu { get; set; }
    }

    public class LichSuItem
    {
        public int Ky { get; set; }
        public int Nam { get; set; }
        public int ChiSo { get; set; }
        public int TieuThu { get; set; }
        public string MaCode { get; set; } = "40";
        public DateTime? NgayDoc { get; set; }
    }

    // ====== DTO cho danh sách đọc số (gom thông tin KH + chỉ số) ======
    public class DocSoItemResponse
    {
        // Thông tin khách hàng
        public string MaDanhBo { get; set; } = "";
        public string HoTen { get; set; } = "";
        public string? DiaChi { get; set; }
        public string? DiaChiDHN { get; set; }
        public string? MaLoTrinh { get; set; }
        public string? Hieu { get; set; }
        public string? Co { get; set; }
        public string? SoThan { get; set; }
        public string? ViTri { get; set; }
        public string? SoDienThoai { get; set; }
        public int? GB { get; set; }
        public int? DM { get; set; }
        public int? DMHN { get; set; }

        // Thông tin đọc số
        public long DocChiSoId { get; set; }
        public int MaKyDoc { get; set; }
        public int ChiSoCu { get; set; }
        public int? ChiSoMoi { get; set; }
        public int? TieuThu { get; set; }
        public string MaCode { get; set; } = "40";
        public int TBTT { get; set; }
        public int TrangThai { get; set; }
        public string? GhiChu { get; set; }
        public string? TinhTrang { get; set; }
        public string? HinhAnh { get; set; }
        public DateTime? NgayDoc { get; set; }
    }
}

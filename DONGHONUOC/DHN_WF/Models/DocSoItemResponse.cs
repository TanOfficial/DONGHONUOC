using System;

namespace DHN_WF.Models
{
    public class DocSoItemResponse
    {
        public string MaDanhBo { get; set; } = string.Empty;
        public string HoTen { get; set; } = string.Empty;
        public string? DiaChi { get; set; }
        public string? MaLoTrinh { get; set; }
        public int Nam { get; set; }
        public string Ky { get; set; } = string.Empty;
        
        public int MaKyDoc { get; set; }
        public int ChiSoCu { get; set; }
        public int? ChiSoMoi { get; set; }
        public int? TieuThuCu { get; set; }
        public int? TieuThu { get; set; }
        public string? MaCode { get; set; }
        
        public int TrangThai { get; set; }
        
        public double TienNuoc { get; set; }
        public double ThueGTGT { get; set; }
        public double Phivmt { get; set; }
        public double TongCong { get; set; }
        
        public string? GhiChu { get; set; }
        public string? GhiChuKH { get; set; }
        public DateTime? NgayDoc { get; set; }
        
        public string? GB { get; set; }
        public string? DM { get; set; }
        public string? HinhAnh { get; set; }
    }
}

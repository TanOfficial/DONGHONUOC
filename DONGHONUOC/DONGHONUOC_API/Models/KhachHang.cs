using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DONGHONUOC_API.Models
{
    [Table("KhachHang")]
    public class KhachHang
    {
        [Key]
        [Column("MaDanhBo")]
        public string MaDanhBo { get; set; } = "";

        [Column("HoTen")]
        public string HoTen { get; set; } = "";

        [Column("DiaChi")]
        public string? DiaChi { get; set; }

        [Column("DiaChiDHN")]
        public string? DiaChiDHN { get; set; }

        [Column("SoDienThoai")]
        public string? SoDienThoai { get; set; }

        [Column("MaLoTrinh")]
        public string? MaLoTrinh { get; set; }

        [Column("Hieu")]
        public string? Hieu { get; set; }

        [Column("Co")]
        public string? Co { get; set; }

        [Column("SoThan")]
        public string? SoThan { get; set; }

        [Column("ViTri")]
        public string? ViTri { get; set; }

        [Column("NgayGan")]
        public DateTime? NgayGan { get; set; }

        [Column("GB")]
        public int? GB { get; set; }

        [Column("DM")]
        public int? DM { get; set; }

        [Column("DMHN")]
        public int? DMHN { get; set; }

        [Column("SoNhanKhau")]
        public int SoNhanKhau { get; set; } = 1;

        [Column("TrangThai")]
        public string? TrangThai { get; set; }

        [Column("GhiChu")]
        public string? GhiChu { get; set; }

        [Column("ChiSo")]
        public int? ChiSo { get; set; }
    }
}

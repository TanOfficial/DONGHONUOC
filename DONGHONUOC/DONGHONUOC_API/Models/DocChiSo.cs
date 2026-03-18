using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DONGHONUOC_API.Models
{
    [Table("DocSo")]
    public class DocChiSo
    {
        [Key]
        [Column("DocSoID")]
        public string ID { get; set; } = "";

        [Column("DanhBa")]
        public string MaDanhBo { get; set; } = "";

        [Column("Nam")]
        public int? Nam { get; set; }

        [Column("Ky")]
        public string? Ky { get; set; }

        [Column("CSCu")]
        public int? ChiSoCu { get; set; }

        [Column("CSMoi")]
        public int? ChiSoMoi { get; set; }

        [Column("TieuThuCu")]
        public int? TieuThuCu { get; set; }

        [Column("TieuThuMoi")]
        public int? TieuThu { get; set; }

        [Column("CodeCu")]
        public string? CodeCu { get; set; }

        [Column("CodeMoi")]
        public string? MaCode { get; set; } = "40";

        [Column("TBTT")]
        public int? TBTT { get; set; }

        [Column("HinhAnh")]
        public string? HinhAnh { get; set; }

        [Column("TienNuoc")]
        public long? TienNuoc { get; set; }

        [Column("BVMT")]
        public int? BVMT { get; set; }

        [Column("Thue")]
        public int? Thue { get; set; }

        [Column("BVMT_Thue")]
        public int? ThueTDVTN { get; set; }

        [Column("TongTien")]
        public long? TongTien { get; set; }

        [Column("GhiChuDS")]
        public string? GhiChu { get; set; }

        [Column("GhiChuKH")]
        public string? GhiChuKH { get; set; }

        [Column("TrangThai_API")]
        public int? TrangThai { get; set; }

        [Column("GIOGHI")]
        public DateTime? NgayDoc { get; set; }

        [Column("NVGHI")]
        public string? NguoiDoc { get; set; }
        
        // KhachHang mapping
        [NotMapped] // Old schema: [Column("HoTen")]
        public string? TenKhachHang { get; set; }

        [Column("SoNhaMoi")]
        public string? SoNhaMoi { get; set; }

        [Column("SoNhaCu")]
        public string? SoNhaCu { get; set; }

        [Column("Duong")]
        public string? Duong { get; set; }

        [NotMapped]
        public string? DiaChi => string.IsNullOrWhiteSpace(SoNhaMoi) ? $"{SoNhaCu} {Duong}".Trim() : SoNhaMoi.Trim();

        [Column("SDT")]
        public string? SoDienThoaiKH { get; set; }

        [Column("GB")]
        public string? GB { get; set; }

        [Column("DM")]
        public string? DM { get; set; }

        [Column("Dot")]
        public string? MaLoTrinh { get; set; }
        [Column("HieuMoi")]
        public string? Hieu { get; set; }

        [Column("CoMoi")]
        public string? Co { get; set; }

        [Column("SoThanMoi")]
        public string? SoThan { get; set; }

        [Column("ViTriMoi")]
        public string? ViTri { get; set; }

        [Column("DMHN")]
        public int? DMHN { get; set; }

        [Column("TuNgay")]
        public DateTime? TuNgay { get; set; }

        [Column("DenNgay")]
        public DateTime? DenNgay { get; set; }
    }
}

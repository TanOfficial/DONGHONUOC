using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DONGHONUOC_API.Models
{
    [Table("DocChiSo")]
    public class DocChiSo
    {
        [Key]
        [Column("ID")]
        public long ID { get; set; }

        [Column("MaDanhBo")]
        public string MaDanhBo { get; set; } = "";

        [Column("MaKyDoc")]
        public int MaKyDoc { get; set; }

        [Column("ChiSoCu")]
        public int ChiSoCu { get; set; }

        [Column("ChiSoMoi")]
        public int? ChiSoMoi { get; set; }

        [Column("TieuThu")]
        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public int? TieuThu { get; set; }

        [Column("MaCode")]
        public string MaCode { get; set; } = "40";

        [Column("TBTT")]
        public int TBTT { get; set; }

        [Column("LoaiBatThuong")]
        public string? LoaiBatThuong { get; set; }

        [Column("HinhAnh")]
        public string? HinhAnh { get; set; }

        [Column("GhiChu")]
        public string? GhiChu { get; set; }

        [Column("TinhTrang")]
        public string? TinhTrang { get; set; }

        [Column("TrangThai")]
        public int TrangThai { get; set; }

        [Column("NgayDoc")]
        public DateTime? NgayDoc { get; set; }

        [Column("NguoiDoc")]
        public string? NguoiDoc { get; set; }

        // Navigation
        public KhachHang? KhachHang { get; set; }
    }
}

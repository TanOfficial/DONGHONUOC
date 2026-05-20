using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DONGHONUOC_API.Models
{
    [Table("LichSuDocSo")]
    public class LichSuDocSo
    {
        [Key]
        [Column("ID")]
        public int ID { get; set; }

        [Column("MaDanhBo")]
        public string MaDanhBo { get; set; } = "";

        [Column("MaKyDoc")]
        public int MaKyDoc { get; set; }

        [Column("ChiSo")]
        public int ChiSo { get; set; }

        [Column("TieuThu")]
        public int TieuThu { get; set; }

        [Column("MaCode")]
        public string MaCode { get; set; } = "40";

        [Column("HanhDong")]
        public string HanhDong { get; set; } = "DocMoi";

        [Column("NguoiThucHien")]
        public string? NguoiThucHien { get; set; }

        [Column("GhiChu")]
        public string? GhiChu { get; set; }

        [Column("ThoiGian")]
        public DateTime ThoiGian { get; set; } = DateTime.Now;
    }
}

using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DONGHONUOC_API.Models
{
    [Table("Lich_DocSo")]
    public class KyDoc
    {
        [Key]
        [Column("ID")]
        public int MaKyDoc { get; set; }

        [Column("Ky")]
        public int Ky { get; set; }

        [Column("Nam")]
        public int Nam { get; set; }

        [Column("TuNgay")]
        public DateTime? TuNgay { get; set; }

        [Column("DenNgay")]
        public DateTime? DenNgay { get; set; }

        [NotMapped]
        public string TenKyDoc => $"Tháng {Ky}/{Nam}";
    }
}

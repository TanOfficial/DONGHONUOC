using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DONGHONUOC_API.Models
{
    [Table("KyDoc")]
    public class KyDoc
    {
        [Key]
        [Column("MaKyDoc")]
        public int MaKyDoc { get; set; }

        [Column("Ky")]
        public int Ky { get; set; }

        [Column("Nam")]
        public int Nam { get; set; }

        [Column("TenKyDoc")]
        public string? TenKyDoc { get; set; }

        [Column("TrangThai")]
        public string TrangThai { get; set; } = "Mở";
    }
}

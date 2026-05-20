using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DONGHONUOC_API.Models
{
    [Table("NguoiDungB")]
    public class NguoiDung
    {
        [Key]
        [Column("MaND")]
        public int MaNguoiDung { get; set; }

        public string? Username { get; set; }
        public string? PasswordHash { get; set; }
        public string? HoTen { get; set; }
        
        [Column("DienThoai")]
        public string? SoDienThoai { get; set; }

        [Column("ChucVu")]
        public string? VaiTro { get; set; }

        [Column("Khoa")]
        public bool? Khoa { get; set; }

        public string? Avatar { get; set; }

        [NotMapped]
        public bool TrangThai { get => !(Khoa ?? false); set { Khoa = !value; } }
    }
}

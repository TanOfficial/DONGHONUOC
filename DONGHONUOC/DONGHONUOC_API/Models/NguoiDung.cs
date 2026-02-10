using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DONGHONUOC_API.Models
{
    [Table("NguoiDung")]
    public class NguoiDung
    {
        [Key]
        [Column("MaNguoiDung")]
        public int MaNguoiDung { get; set; }

        [Column("Username")]
        public string Username { get; set; } = "";

        [Column("PasswordHash")]
        public string PasswordHash { get; set; } = "";

        [Column("HoTen")]
        public string HoTen { get; set; } = "";

        [Column("SoDienThoai")]
        public string? SoDienThoai { get; set; }

        [Column("Email")]
        public string? Email { get; set; }

        [Column("VaiTro")]
        public string VaiTro { get; set; } = "NhanVien";

        [Column("MaKhuVuc")]
        public string? MaKhuVuc { get; set; }

        [Column("TrangThai")]
        public bool TrangThai { get; set; } = true;
    }
}

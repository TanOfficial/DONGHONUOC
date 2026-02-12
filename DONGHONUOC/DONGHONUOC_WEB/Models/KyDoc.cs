
namespace DONGHONUOC_WEB.Models
{
    public class KyDoc
    {
        public int MaKyDoc { get; set; }
        public int Ky { get; set; }
        public int Nam { get; set; }
        public string? TenKyDoc { get; set; }
        public DateTime? NgayBatDau { get; set; }
        public DateTime? NgayKetThuc { get; set; }
        public string? TrangThai { get; set; }
    }
}

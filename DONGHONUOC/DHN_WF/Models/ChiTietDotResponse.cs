namespace DHN_WF.Models
{
    public class ChiTietDotResponse
    {
        public int Dot { get; set; }
        public string NgayDoc { get; set; } = "";
        public string NgayKiemSoat { get; set; } = "";
        public string NgayChuyenListing { get; set; } = "";
        public string NgayThuTien { get; set; } = "";
        public bool KiemTraNgayDoc { get; set; }
    }
}

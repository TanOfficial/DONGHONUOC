namespace DHN_WF.Models
{
    public class ThongKeDotResponse
    {
        public string MaDot { get; set; } = "";
        public int TongHDKyTruoc { get; set; }
        public int TongBD { get; set; }
        public int TongTD { get; set; }
        public string? NgayLapBD { get; set; }
        public string? NgayLapTD { get; set; }
    }
}

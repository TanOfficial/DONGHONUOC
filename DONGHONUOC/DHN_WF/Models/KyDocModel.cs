namespace DHN_WF.Models
{
    public class KyDocModel
    {
        public int MaKyDoc { get; set; }
        public int Ky { get; set; }
        public int Nam { get; set; }
        public string? TuNgay { get; set; }
        public string? DenNgay { get; set; }
        public string? TenKyDoc { get; set; }

        public override string ToString()
            => TenKyDoc ?? $"Tháng {Ky}/{Nam}";
    }
}

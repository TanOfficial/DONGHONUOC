namespace DHN_WF.Models
{
    public class LoginResponse
    {
        public bool Success { get; set; }
        public string? Message { get; set; }
        public string? Username { get; set; }
        public string? HoTen { get; set; }
        public string? VaiTro { get; set; }
        public string? Avatar { get; set; }
    }
}
